data "aws_eks_cluster" "cluster" {
  name = "eks-X10-prod-01"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "eks-X10-prod-01"
}

locals {
  original_url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  sliced_url   = replace(local.original_url, "https://", "")
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket                  = "terraform-state-ofri"
    key                     = "terraform.tfstate"
    region                  = "us-east-2"
    shared_credentials_file = "~/.aws/credentials"
  }
}

provider "aws" {
  region = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket = "eks-velero-backup-bucket"
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  acl    = "private"

  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "expire_backups"
      enabled = true

      filter = {
        prefix = "" # Applies to all objects in the bucket
      }

      expiration = {
        days = 30 # Delete objects after 30 days
      }
    }
  ]

  tags = {
    aws_backup = true
  }
}

module "velero" {
  source  = "terraform-module/release/helm"
  version = "2.6.0"

  namespace  = "velero-ofri"
  repository = "https://vmware-tanzu.github.io/helm-charts"

  app = {
    name          = "velero"
    version       = "8.0.0"  # Specify the Velero chart version
    chart         = "velero"
    force_update  = true
    wait          = false
    recreate_pods = false
    deploy        = 1
  }

  # Reference a values file stored in your repository
  values = [
    templatefile("${path.module}/values/velero.yaml", {
      region               = "us-east-2"
      bucket_name          = "eks-velero-backup-bucket"
      velero_role_arn      = module.velero_irsa_role.iam_role_arn
    })
  ]
  # Dynamic Helm chart settings
  set = [
    {
      name  = "serviceAccount.server.create"
      value = "true"
    },
    {
      name  = "serviceAccount.server.name"
      value = "velero"
    }
  ]
}

module "velero_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name             = "velero"
  attach_velero_policy  = true
  velero_s3_bucket_arns = ["arn:aws:s3:::eks-velero-backup-bucket"]

  oidc_providers = {
    ex = {
      provider_arn               = "arn:aws:iam::023196572641:oidc-provider/${local.sliced_url}"
      namespace_service_accounts = ["velero-ofri:velero"]
    }
  }

  tags = {
    Createdby = "OFRI"
  }
}

module "aws_backup" {
  source            = "./modules/backup"
  backup_vault_name = "ofri-backup-project"
  backup_plan_name  = "ofri-backup-plan"
  backup_rule_name  = "ofri-backup-rule"
  schedule          = "cron(0 12 * * ? *)"
  delete_after      = 97
  cold_storage_after = 7
  selection_name    = "ofri-backup-selection"
  tag_key           = "aws_backup"
  tag_value         = "true"
  role_name         = "aws-backup-role"
}





