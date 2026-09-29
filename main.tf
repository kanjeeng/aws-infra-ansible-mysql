# ==========================================
# File: main.tf
# Deskripsi: Resor Utama AWS (Cost-Optimized Dev)
# ==========================================

# 1. DATA SOURCES
data "aws_ami" "ubuntu" { # Data Sources: Mengambil ID AMI terbaru langsung dari AWS secara otomatis
  most_recent = true
  owners      = ["099720109477"] # Canonical ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" { # Data Sources: Melakukan query AZ yang berstatus aktif
  state = "available"
}

# 2. NETWORK ARCHITECTURE (VPC & IGW ONLY)
resource "aws_vpc" "main" { # Resource Declaration: Membuat VPC baru
  cidr_block           = var.vpc_cidr # Resource Declaration: Menggunakan CIDR Block dari variabel yang disuplai
  enable_dns_hostnames = true # Resource Declaration: Mengaktifkan DNS Hostnames untuk EC2 agar bisa diakses via hostname
  enable_dns_support   = true # Resource Declaration: Mengaktifkan DNS Support untuk EC2
  tags = { Name = "${local.project_name}-vpc" }
}

resource "aws_internet_gateway" "igw" { # Resource Declaration: Membuat Internet Gateway untuk akses publik
  vpc_id = aws_vpc.main.id
  tags = { Name = "${local.project_name}-igw" }
}

resource "aws_subnet" "public" { # Resource Declaration: Membuat Subnet Publik untuk EC2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidr # Resource Declaration: Menggunakan CIDR Block Subnet Publik yang dihitung secara otomatis dari locals.tf
  availability_zone       = data.aws_availability_zones.available.names[0] # Menggunakan AZ pertama yang tersedia
  map_public_ip_on_launch = true # Semua EC2 mendapat IP Publik untuk akses IGW
  tags = { Name = "${local.project_name}-public-subnet" }
}

# 3. ROUTE TABLES
resource "aws_route_table" "public" { # Resource Declaration: Membuat Route Table untuk Subnet Publik
  vpc_id = aws_vpc.main.id
  route { # Resource Declaration: Membuat route default ke IGW untuk akses publik
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${local.project_name}-rt" }
}

resource "aws_route_table_association" "public" { # Resource Declaration: Mengasosiasikan Route Table ke Subnet Publik
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# 4. SECURITY GROUPS (KUNCI ISOLASI LOGIS)
resource "aws_security_group" "bastion_sg" { # Resource Declaration: Membuat Security Group untuk Bastion Host
  name        = "${local.project_name}-bastion-sg"
  description = "Menerima akses SSH dari Publik"
  vpc_id      = aws_vpc.main.id

  ingress { # Resource Declaration: Membuka port SSH dari Publik
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { # Resource Declaration: Membuka semua akses keluar untuk Bastion Host
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_sg" { # Resource Declaration: Membuat Security Group untuk Database Nodes
  name        = "${local.project_name}-database-sg"
  description = "Akses ketat hanya dari Bastion Host"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" { # Dynamic Block: Menghasilkan blok ingress berulang secara dinamis dari list var.ingress_ports
    for_each = var.ingress_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [aws_security_group.bastion_sg.id] # Isolasi terbentuk di sini
    }
  }
  
  egress { # Resource Declaration: Membuka semua akses keluar untuk Database Nodes
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. SSH KEY PAIR
resource "aws_key_pair" "deployer" { # Resource Declaration: Membuat SSH Key Pair untuk akses EC2
  key_name   = "${local.project_name}-key"
  public_key = file(var.public_key_path) # Built-in Function: Membaca teks mentah public key dari disk menggunakan file()
}

# 6. EC2 INSTANCES
resource "aws_instance" "bastion" { # Resource Declaration: Membuat Bastion Host EC2
  count                  = var.enable_bastion ? 1 : 0 # Conditional Expression (Ternary): Jika 'true' buat 1, jika 'false' lewati pembuatan (0)
  ami                    = data.aws_ami.ubuntu.id # Resource Declaration: Menggunakan AMI Ubuntu terbaru dari data source
  instance_type          = local.selected_instance_type # Resource Declaration: Menggunakan instance type yang dihitung dari locals.tf
  subnet_id              = aws_subnet.public.id # Resource Declaration: Menempatkan Bastion Host di Subnet Publik
  vpc_security_group_ids = [aws_security_group.bastion_sg.id] # Resource Declaration: Mengasosiasikan Bastion Host dengan Security Group Bastion
  key_name               = aws_key_pair.deployer.key_name # Resource Declaration: Mengasosiasikan Bastion Host dengan SSH Key Pair yang dibuat sebelumnya

  tags = { Name = "${local.project_name}-bastion" }
}

resource "aws_instance" "managed_nodes" { # Resource Declaration: Membuat Database Nodes EC2
  count                  = var.node_count  # Meta-Argument: Mengontrol jumlah duplikasi (looping) penciptaan instans EC2
  ami                    = data.aws_ami.ubuntu.id # Resource Declaration: Menggunakan AMI Ubuntu terbaru dari data source
  instance_type          = local.selected_instance_type # Resource Declaration: Menggunakan instance type yang dihitung dari locals.tf
  subnet_id              = aws_subnet.public.id # Resource Declaration: Menempatkan Database Nodes di Subnet Publik
  vpc_security_group_ids = [aws_security_group.database_sg.id] # Resource Declaration: Mengasosiasikan Database Nodes dengan Security Group Database
  key_name               = aws_key_pair.deployer.key_name # Resource Declaration: Mengasosiasikan Database Nodes dengan SSH Key Pair yang dibuat sebelumnya

  lifecycle { # Resource Lifecycle: Mencegah downtime; buat mesin baru dulu sebelum hapus yang lama
    create_before_destroy = true
  }

  tags = {
    Name = "${local.project_name}-db-node-${count.index + 1}"
    Role = "Database-Node"
  }
}