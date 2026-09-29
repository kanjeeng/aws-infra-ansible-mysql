# ==========================================
# File: output.tf
# Deskripsi: Output Value Infrastruktur
# ==========================================

output "bastion_public_ip" {
  description = "IP Publik Bastion Host untuk akses SSH"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : "Bastion Disabled" # Conditional Expression: Handle string alternatif jika nilai count Bastion 0
}

output "database_nodes_ips" {
  description = "Daftar IP Privat dari Database Nodes (Digunakan untuk SSH ProxyJump)"
  value       = aws_instance.managed_nodes[*].private_ip # Splat Expression: Mengekstrak seluruh private IP dari kumpulan (list) EC2 sekaligus
}

output "vpc_id" {
  description = "ID dari VPC yang terbentuk"
  value       = aws_vpc.main.id
}