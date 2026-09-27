# Workflow — Aturan Kerja AI Agent untuk Mediva

> Dokumen ini adalah aturan main bagi AI agent (Claude Code, MCP agent, atau AI lain) yang bekerja di repository Mediva. Rujuk `PRD.md` untuk scope produk, dan `agent.md` untuk standar coding. Kalau ada instruksi user yang bertentangan dengan dokumen ini, instruksi user langsung yang menang — dokumen ini adalah default, bukan pagar mati.

---

## 1. Prinsip Umum

- AI agent adalah **kolaborator**, bukan pengambil keputusan akhir. Keputusan scope, desain besar, dan trade-off tetap di tangan pemilik proyek (Ilham).
- Setiap perubahan kode harus bisa ditelusuri ke requirement di `PRD.md`. Kalau tidak ada di `PRD.md` dan user tidak memintanya secara eksplisit, jangan ditambahkan (hindari scope creep).
- Lebih baik berhenti dan bertanya daripada menebak lalu diam-diam mengubah scope atau behavior.

---

## 2. Kapan AI Boleh Jalan Otonom (Tanpa Izin Dulu)

AI boleh langsung eksekusi untuk hal-hal berikut, selama scope-nya sudah jelas dari `PRD.md` atau instruksi user saat itu:

- Menulis atau mengedit kode untuk fitur yang scope-nya sudah disepakati
- Menulis test untuk kode yang baru dibuat
- Memperbaiki bug yang jelas (typo, syntax error, logic error kecil) tanpa mengubah behavior yang disengaja
- Menjalankan test, linter, atau migration di environment **development/lokal**
- Menulis/memperbarui dokumentasi teknis (docblock, komentar, README modul) supaya sesuai kode aktual
- Refactor kecil yang tidak mengubah behavior (rename variable, extract method) — selama semua test tetap hijau setelahnya

## 3. Kapan AI HARUS Minta Izin Dulu

Berhenti dan tanya ke user sebelum:

- Mengubah skema database (migration baru, ubah/drop kolom, ubah relasi)
- Mengubah atau menghapus data di database — termasuk di environment demo/staging, bukan cuma production
- Menghapus atau menimpa file yang sudah ada, tanpa diminta eksplisit untuk itu
- Push ke branch utama (`main`/`master`), atau melakukan force push
- Mengubah konfigurasi deployment/CI/CD
- Menambah atau mengganti dependency/package baru (composer, npm, pub)
- Mengubah logic yang menyentuh keamanan: auth, authorization, validasi resep, payment callback, rate limiting
- Mengubah scope fitur di luar yang tertulis di `PRD.md`
- Menyentuh `.env`, secret, credential, atau API key apapun — dalam bentuk apapun, termasuk menampilkannya di chat/log
- Instruksi user ambigu dan ada lebih dari satu interpretasi yang masuk akal secara teknis

## 4. Definisi "Selesai" (Definition of Done)

Sebuah fitur/perubahan baru dianggap **selesai** kalau semua ini terpenuhi:

1. Kode sesuai scope yang tertulis di `PRD.md` — tidak lebih, tidak kurang
2. Ada minimal satu test untuk jalur utama (happy path) dan satu test untuk kasus gagal/edge case
3. Semua test yang ada (lama maupun baru) tetap hijau
4. Kode mengikuti standar di `agent.md` (struktur, penamaan, gaya komentar)
5. Tidak ada `TODO`/placeholder yang dibiarkan tanpa diberi tahu ke user
6. Kalau menyentuh data sensitif (resep, payment, auth), sudah dicek terhadap checklist security di `PRD.md` Section 18, 19, dan 30
7. Dokumentasi (docblock, README modul) sudah disesuaikan kalau ada perubahan perilaku/scope

Fitur yang belum memenuhi semua poin di atas **tidak boleh dilaporkan sebagai "sudah selesai"** ke user, meskipun kelihatan berjalan saat dicoba manual sekali.

## 5. Alur Kerja Iteratif

1. Pahami requirement dari `PRD.md` dan instruksi user
2. Kalau desain/pendekatan implementasi belum jelas atau ada lebih dari satu opsi yang masuk akal, ajukan opsi singkat ke user dulu — **jangan langsung eksekusi** pendekatan yang belum disepakati
3. Setelah disetujui, kerjakan dalam potongan kecil (per modul/fungsi/endpoint), bukan sekaligus semua fitur dalam satu langkah
4. Setelah tiap potongan selesai, laporkan singkat: apa yang dikerjakan, file mana yang berubah, dan cara mengetesnya
5. Jangan mengklaim sesuatu "sudah bekerja" atau "sudah aman" kalau belum benar-benar diuji

## 6. Komunikasi dengan User

- Bahasa Indonesia, santai, dan langsung ke intinya
- Jargon teknis dijelaskan kalau memang perlu dipakai — jangan asumsikan user sudah tahu semua istilah
- Struktur penjelasan step-by-step, bukan paragraf panjang tanpa jeda
- Kalau ragu atau requirement kurang jelas: **tanya**, jangan diam-diam menebak dan mengubah scope

## 7. Eskalasi Saat Buntu

Kalau AI menemukan hal berikut, laporkan ke user alih-alih mencoba menyelesaikan sendiri secara diam-diam:

- Requirement di `PRD.md` bertentangan dengan kondisi kode aktual
- Kode Project 2 (referensi lama) tidak konsisten dengan `PRD.md` Project 3
- Sebuah pendekatan teknis membutuhkan trade-off yang berdampak ke scope atau timeline
- Ditemukan celah keamanan yang di luar task yang sedang dikerjakan saat itu
