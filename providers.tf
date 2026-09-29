# ==========================================
# File: providers.tf
# Deskripsi: Konfigurasi Provider AWS & Versi
# ==========================================
terraform {
  required_version = ">= 1.5.0" # Provider Constraints: Mengunci minimal versi Terraform
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Provider Constraints: Mengunci versi minor AWS agar terhindar dari breaking changes
    }
  }
}

provider "aws" {
  region = var.aws_region # Provider Configuration: Mengatur region AWS sesuai variabel
  default_tags {
    tags = local.common_tags # Default Tags: Menyuntikkan tag secara otomatis & terpusat ke semua resource
  }
}