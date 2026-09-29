# ==========================================
# File: terraform.tfvars
# Deskripsi: Injeksi Nilai Aktual Variabel
# ==========================================
# Injeksi: Menyuplai nilai akhir aktual yang akan disuntikkan ke modul Terraform
aws_region      = "ap-southeast-1"
environment     = "dev"
vpc_cidr        = "10.0.0.0/16"
node_count      = 2
enable_bastion  = true
ingress_ports   = [22, 3306]
public_key_path = "~/.ssh/id_rsa.pub"