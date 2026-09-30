# Automasi Instalasi MySQL dengan Ansible

Proyek ini berisi panduan dan file konfigurasi Ansible untuk mengotomatiskan instalasi dan konfigurasi klaster basis data MySQL pada Managed Nodes (Database Nodes) secara terpusat melalui Bastion Host (Control Node)[cite: 10].

### Arsitektur Infrastruktur
<p align="center">
  <img src="../../infra.png" alt="Arsitektur Infrastruktur AWS" width="600">
</p>

---

## 1. Persiapan: Mengaktifkan SSH Agent dan Mendaftarkan Kunci

Untuk menjaga keamanan, kunci privat (`id_rsa`) tidak boleh disimpan di dalam Bastion Host[cite: 12]. Kita akan menggunakan metode **SSH Agent Forwarding** untuk meneruskan identitas kunci dari mesin lokal secara virtual[cite: 12]. 

Jalankan perintah berikut di komputer lokal Anda sesuai dengan Sistem Operasi yang digunakan:

### Linux (Bash / Zsh) & Git Bash (Windows)
* Mengaktifkan ssh-agent di latar belakang: `eval "$(ssh-agent -s)"`[cite: 12, 14]
* Memuat kunci privat ke memori agent: `ssh-add ~/.ssh/id_rsa`[cite: 12, 14]

### macOS (Terminal)
* Mengaktifkan ssh-agent di latar belakang: `eval "$(ssh-agent -s)"`[cite: 13]
* Memuat kunci privat ke macOS Keychain: `ssh-add --apple-use-keychain ~/.ssh/id_rsa`[cite: 13]
* *(Catatan: Gunakan `-K` untuk macOS sebelum Monterey 12)*[cite: 13]

### Windows (PowerShell) - Run as Administrator
* Mengubah tipe startup service menjadi Automatic: `Set-Service -Name ssh-agent -StartupType Automatic`[cite: 13]
* Menjalankan service: `Start-Service ssh-agent`[cite: 13]
* Memuat kunci privat (bisa di PowerShell biasa): `ssh-add $env:USERPROFILE\.ssh\id_rsa`[cite: 13]

### Windows (Command Prompt / CMD) - Run as Administrator
* Mengubah startup service menjadi Otomatis: `sc config ssh-agent start= auto`[cite: 13]
* Menjalankan service: `net start ssh-agent`[cite: 13]
* Memuat kunci privat (bisa di CMD biasa): `ssh-add %USERPROFILE%\.ssh\id_rsa`[cite: 13]

---

## 2. Mengakses Bastion Host & Persiapan Environment

Setelah kunci terdaftar di lokal, lakukan koneksi SSH ke Bastion Host dengan menambahkan argumen `-A` (Agent Forwarding)[cite: 14].

```bash
# Ganti IP dengan Public IP Bastion Host Anda
ssh -A ubuntu@<bastion_public_ip>

```

Verifikasi apakah kunci lokal telah berhasil diteruskan ke Bastion Host:

```bash
ssh-add -l

```

*(Terminal akan menampilkan sidik jari/fingerprint dari kunci lokal Anda)*

### Instalasi Ansible

Di dalam terminal Bastion Host, perbarui repositori dan instal Ansible:

```bash
sudo apt update
sudo apt install -y ansible

```

---

## 3. Mengunduh Konfigurasi (Clone Repository)

Unduh *playbook* dan konfigurasi Ansible langsung dari repositori:

```bash
git clone [https://github.com/kanjeeng/aws-infra-ansible-mysql.git](https://github.com/kanjeeng/aws-infra-ansible-mysql.git)
cd aws-infra-ansible-mysql/ansible-install-mysql

```

---

## 4. Konfigurasi Inventori

Buka file `inventory.ini` dan sesuaikan IP Private dengan Database Nodes milik Anda:

```ini
[db_nodes]
10.0.1.222
10.0.1.70

```

---

## 5. Pengujian Konektivitas (Ping)

Uji koneksi dari Bastion Host ke seluruh target node untuk memastikan SSH Agent berfungsi dan Ansible dapat menjangkau server:

```bash
ansible db_nodes -m ping

```

*(Pastikan hasilnya menampilkan status `SUCCESS` atau `pong`)*

---

## 6. Mengeksekusi Playbook MySQL

Jalankan playbook untuk memulai instalasi dan konfigurasi otomatis MySQL Server:

```bash
ansible-playbook install_mysql.yml

```

Tunggu hingga proses selesai. Pada bagian `PLAY RECAP` di terminal, pastikan status menunjukkan `failed=0` dan `unreachable=0` yang membuktikan bahwa seluruh *tasks* berhasil dieksekusi.

---

## 7. Verifikasi Instalasi MySQL

Untuk memastikan database benar-benar berjalan, lakukan pengujian langsung ke salah satu mesin Database (contoh IP: `10.0.1.222`):

1. **Masuk ke Database Node**:
```bash
ssh ubuntu@10.0.1.222

```



2. **Cek Status Service MySQL**:
```bash
sudo systemctl status mysql

```


*(Pastikan statusnya `Active: active (running)`)*

3. **Login ke Shell MySQL**:
```bash
sudo mysql -u root

```




```

```