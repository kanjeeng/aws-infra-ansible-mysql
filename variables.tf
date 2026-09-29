# ==========================================
# File: variables.tf
# Deskripsi: Deklarasi Variabel & Validasi
# ==========================================
variable "aws_region" { # Variable Declaration: Mendefinisikan variabel untuk region AWS
  type        = string # Type Constraints: Membatasi tipe input hanya teks
  default     = "ap-southeast-1"
  description = "Region AWS tempat infrastruktur dibentuk"
}

variable "environment" { # Variable Declaration: Mendefinisikan variabel untuk lingkungan deployment
  type        = string
  default     = "dev"
  description = "Lingkungan deployment (dev, staging, prod)"
  validation {  # Custom Validation: Mencegah error akibat salah input nilai
    condition     = contains(["dev", "staging", "prod"], var.environment) # Validasi menggunakan fungsi contains()
    error_message = "Nilai environment harus dev, staging, atau prod."
  }
}

variable "vpc_cidr" { # Variable Declaration: Mendefinisikan variabel untuk CIDR VPC
  type        = string
  default     = "10.0.0.0/16"
  description = "Base CIDR Block untuk VPC"
}

variable "node_count" { # Variable Declaration: Mendefinisikan variabel untuk jumlah node database
  type        = number # Type Constraints: Membatasi tipe input hanya angka
  default     = 2
  description = "Jumlah Database Nodes yang dibuat"
}

variable "enable_bastion" { # Variable Declaration: Mendefinisikan variabel untuk mengaktifkan Bastion Host
  type        = bool # Type Constraints: Membatasi input boolean (true/false)
  default     = true
  description = "Flag kondisional untuk mengaktifkan/mematikan Bastion Host"
}

variable "ingress_ports" { # Variable Declaration: Mendefinisikan variabel untuk port yang diizinkan masuk ke Database Security Group
  type        = list(number) # Type Constraints: Membatasi input berupa array/list of numbers
  default     = [22, 3306]
  description = "Port yang diizinkan masuk ke Database Security Group"
}

variable "public_key_path" { # Variable Declaration: Mendefinisikan variabel untuk path public SSH key lokal
  type        = string
  default     = "~/.ssh/id_rsa.pub"
  description = "Path lokasi Public SSH Key lokal"
}