# ==========================================
# File: locals.tf
# Deskripsi: Pengolahan Logika & Variabel Lokal
# ==========================================
locals {
  project_name = "aws-infra-dev"

  common_tags = {
    Project     = local.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
  # Built-in Function (cidrsubnet(prefix, newbits, netnum)): Mengalkulasi blok CIDR subnet secara otomatis yang menghasilkan: 10.0.1.0/24
  public_subnet_cidr = cidrsubnet(var.vpc_cidr, 8, 1) 

  # Dynamic Mapping: Memetakan tipe EC2 berdasarkan environment
  instance_types = {
    dev     = "t2.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }

  # Built-in Function: Melakukan pencarian data (lookup) dari mapping di atas
  selected_instance_type = lookup(local.instance_types, var.environment, "t2.micro")
}