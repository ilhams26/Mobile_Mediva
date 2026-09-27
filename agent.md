# Agent.md — Standar Coding untuk Mediva

> Panduan gaya dan best practice coding untuk siapapun (manusia atau AI agent) yang menulis kode di repository ini. Rujuk `PRD.md` untuk scope produk dan `workflow.md` untuk aturan kerja.

## Prinsip Utama

**Tes kualitas kode:** *"Bisakah developer lain — atau Ilham enam bulan lagi — memahami kode ini tanpa penjelasan tambahan dari penulisnya?"*

Kalau jawabannya tidak, kode itu belum selesai, meskipun sudah berjalan dengan benar. Kode yang jelas selalu lebih diutamakan daripada kode yang singkat atau "pintar".

---

## Struktur Proyek

Ikuti struktur yang sudah ditetapkan di `PRD.md`:

- **Backend (Laravel):** `app/Http/Controllers`, `app/Http/Requests`, `app/Http/Middleware`, `app/Models`, `app/Services`
- **Frontend (React):** `src/components`, `src/pages`, `src/layouts`, `src/services`, `src/hooks`, `src/context`, `src/routes`, `src/utils`
- **Mobile (Flutter):** `lib/models`, `lib/services`, `lib/screens`, `lib/widgets`, `lib/providers`, `lib/routes`, `lib/utils`

File baru ditaruh di folder yang sesuai fungsinya — jangan taruh logic di folder yang salah hanya karena lebih cepat.

---

## Backend — Laravel / PHP

- Ikuti **PSR-12** untuk formatting
- Business logic wajib di **Service layer**, bukan di Controller. Controller hanya: validasi request → panggil service → return response
- Penamaan: `PascalCase` untuk class, `camelCase` untuk method/variable, `snake_case` untuk kolom database
- Setiap method **public** di Service wajib docblock singkat: fungsi apa, parameter apa, return apa
- Gunakan Form Request class untuk validasi kompleks — jangan validasi manual bertumpuk di controller
- Error/exception ditangani di layer yang tepat dengan try-catch — jangan silent fail (menangkap error lalu tidak melakukan apa-apa)
- Query yang menyentuh banyak baris/join kompleks: tulis lewat Eloquent relationship atau Query Builder yang jelas, hindari raw SQL kecuali benar-benar perlu (misalnya query vector similarity via pgvector)

## Frontend — React

- Functional component + hooks (bukan class component)
- Satu file = satu komponen, kecuali komponen kecil yang memang selalu dipakai berdampingan
- Nama file komponen `PascalCase.jsx`, nama file util `camelCase.js`
- State: mulai dari local state (`useState`), naik ke context/store hanya kalau memang dibutuhkan lintas komponen
- Semua pemanggilan API dipisah ke folder `services/` — jangan `fetch`/`axios` langsung di dalam komponen

## Mobile — Flutter / Dart

- Ikuti [Effective Dart](https://dart.dev/effective-dart) style guide
- Pisahkan UI (`screens/`, `widgets/`) dari logic (`providers/`, `services/`)
- Buat model class untuk representasi data dari API — jangan pakai `Map<String, dynamic>` mentah langsung di UI

## Database — PostgreSQL

- Nama tabel: plural, `snake_case` (`medicines`, `order_items`)
- Nama kolom: `snake_case`
- Foreign key didefinisikan eksplisit dengan constraint, bukan cuma konvensi penamaan
- Index di kolom yang sering dipakai `WHERE`/`JOIN` (foreign key, kolom pencarian)
- Kolom `vector` (pgvector) hanya untuk data semantik (deskripsi obat, dll) — bukan untuk data transaksional

---

## Format Komentar

- Docblock (PHPDoc/JSDoc/Dartdoc sesuai bahasa) untuk setiap **public method/class**
- Inline comment hanya kalau logic-nya memang tidak jelas dari nama variable/function — bukan untuk menjelaskan hal yang sudah jelas dari kodenya sendiri
- Jangan tulis komentar yang cuma mengulang nama function (`// simpan order` di atas `function simpanOrder()` itu komentar yang tidak berguna)
- Komentar menjelaskan **kenapa** suatu keputusan diambil, bukan **apa** yang dilakukan baris kode itu (kode sudah menjelaskan "apa"-nya)

## Format Test

- Nama test deskriptif, jelaskan skenario: `test_buyer_cannot_access_staff_endpoint()`, bukan `test1()` atau `testOrder()`
- Pola **Arrange–Act–Assert (AAA)**: siapkan data → jalankan aksi → cek hasil
- Test AI (lihat `PRD.md` Section 28) minimal cakup: pertanyaan valid, tidak relevan, ambigu, produk tidak ditemukan, context kosong, pertanyaan medis berisiko, API gagal
- Test Recommendation minimal cakup: tanpa histori, dengan histori, produk populer, produk terkait, stok habis, produk nonaktif, tidak ada kandidat
- Test dan kode implementasi harus mudah ditemukan berdampingan (nama file/method saling merujuk jelas)

## Commit & Versioning

- Format commit message singkat dan konsisten:
  - `feat: tambah AI chat endpoint`
  - `fix: perbaiki FEFO batch selection`
  - `test: tambah test untuk recommendation service`
  - `refactor: pisahkan validasi resep ke Form Request`
- Satu commit = satu perubahan logis. Jangan gabungkan beberapa fitur berbeda dalam satu commit

---

## Checklist Sebelum Kode Dianggap "Bagus"

- [ ] Bisa dibaca tanpa penjelasan tambahan dari penulisnya
- [ ] Nama variable/function menjelaskan dirinya sendiri
- [ ] Tidak ada magic number tanpa penjelasan (pakai konstanta bernama)
- [ ] Tidak ada kode yang di-comment-out dibiarkan menumpuk
- [ ] Error case ditangani, bukan diabaikan
- [ ] Tidak ada data sensitif (password, token, secret) yang ter-log atau ter-hardcode
