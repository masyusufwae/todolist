# Aplikasi To-Do List CRUD (Flutter + Laravel)

## Deskripsi Aplikasi
Aplikasi **To-Do List** ini adalah aplikasi CRUD (Create, Read, Update, Delete) berbasis **Flutter** sebagai frontend dan **Laravel** sebagai backend API. Aplikasi ini memungkinkan pengguna untuk:
- Menambahkan tugas dengan title, prioritas, dan deadline
- Mengatur tanggal dan jam `created_at` dan `updated_at` **sesuai tanggal dan waktu di laptop saat membuat dan mengedit tugas**
- Mengedit tugas
- Menghapus tugas 
- Menampilkan semua tugas dengan tampilan modern menggunakan Flutter Card

## Fitur Utama
- **Halaman Utama**: Menampilkan daftar semua tugas
- **Form Tambah/Edit**: Input title, prioritas, deadline, created_at, updated_at
- **Checklist**: Menandai tugas selesai

## Database
Menggunakan database **MySQL** dengan tabel `tasks` dan field berikut:
- `id`
- `title`
- `priority` (low, medium, high)
- `due_date`
- `is_done`
- `created_at`
- `updated_at`

## API (Laravel)
API berada di folder `/api/` dengan endpoint:
- `GET /api/tasks` — Menampilkan semua tugas
- `POST /api/tasks` — Menambah tugas baru
- `PUT /api/tasks/{id}` — Mengupdate tugas
- `DELETE /api/tasks/{id}` — Menghapus tugas

## Software yang Digunakan
- **Flutter** (versi terbaru)
- **Laravel 10**
- **MySQL**
- **Postman** (untuk testing API)
- **VS Code**
- **Laragon**

---

## Cara Instalasi

### 1. Clone Repository
```bash
git clone https://github.com/masyusufwae/todolist
cd todolist
```

### 2. Backend (Laravel)
Masuk ke folder `api/`:

```bash
cd api
composer install
cp .env.example .env
php artisan key:generate
```

Edit file `.env` dan sesuaikan konfigurasi database:
```
DB_DATABASE=todo_app
DB_USERNAME=root
DB_PASSWORD=   # kosongkan jika tidak pakai password
```

Jalankan migrasi database:
```bash
php artisan migrate
php artisan serve
```

### 3. Frontend (Flutter)
Masuk ke folder aplikasi Flutter (misal: `flutter_app/`):

```bash
cd flutter_app
flutter pub get
flutter run
```

---

## Cara Menjalankan

1. Jalankan Laravel API:
   ```bash
   php artisan serve
   ```
2. Jalankan Flutter:
   ```bash
   flutter run
   ```

---

## Demo Aplikasi



https://github.com/user-attachments/assets/088bfbbb-bfa0-42a3-a5bc-a67e998646d8


---

## Identitas Pembuat

- **Nama**: Muhammad Yusuf
- **No**: 25
- **Kelas**: XI RPL2
- **Sekolah**: SMK Negeri 1 Bantul
- **Jurusan**: Rekayasa Perangkat Lunak (RPL)
