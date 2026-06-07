# Product Requirements Document (PRD)
## Summit App — Aplikasi B2C E-Commerce Peralatan Pendakian

---

| Field | Detail |
|---|---|
| **Nama Produk** | Summit App |
| **Tipe** | Mobile Application (B2C E-commerce) |
| **Platform** | Flutter (Android & iOS) |
| **Model Bisnis** | Retail B2C E-Commerce (Summit App sebagai satu-satunya penjual/penyedia produk) |
| **Versi Dokumen** | 2.0 |
| **Tanggal** | 30 April 2026 |

---

## 1. Gambaran Umum

Summit App adalah aplikasi mobile e-commerce tersentralisasi untuk penjualan peralatan pendakian. Seluruh produk yang dijual adalah inventory milik perusahaan (Summit App). Pengelolaan katalog, stok, order, pembayaran, pengiriman, dan layanan pelanggan sepenuhnya dikendalikan oleh tim internal melalui Admin Backoffice.

### 1.1 Visi
Menjadi platform nomor satu di Indonesia untuk pembelian peralatan pendakian yang terpercaya, lengkap, dan mudah diakses.

### 1.2 Target Pengguna
- Pendaki pemula yang butuh peralatan lengkap
- Pendaki berpengalaman yang mencari gear spesifik
- Komunitas outdoor secara umum
- Usia 18–45 tahun, domisili Indonesia

---

## 2. Fitur MVP (Minimum Viable Product)

### 2.1 Autentikasi & Profil User

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| A-01 | Register | Registrasi via email & password | Tinggi |
| A-02 | Login | Login via email, Google Sign-In, Apple Sign-In | Tinggi |
| A-03 | Lupa Password | Reset password via email | Tinggi |
| A-04 | Profil User | Edit nama, no. HP, foto profil | Sedang |
| A-05 | Manajemen Alamat | CRUD alamat pengiriman (bisa simpan multiple alamat, set utama) | Tinggi |
| A-06 | Verifikasi Email | Kirim link verifikasi saat register | Sedang |

### 2.2 Katalog & Pencarian Produk

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| C-01 | Homepage | Banner promo, kategori, produk terlaris, rekomendasi, flash sale | Tinggi |
| C-02 | List Produk | Grid/list produk dengan infinite scroll | Tinggi |
| C-03 | Filter & Sort | Filter: kategori, harga (range), brand, rating, diskon. Sort: terbaru, termurah, termahal, terlaris, rating tertinggi | Tinggi |
| C-04 | Search Bar | Pencarian dengan autocomplete & search history | Tinggi |
| C-05 | Detail Produk | Multi-foto (swipe/zoom), video, deskripsi, varian (ukuran/warna), stok, berat, harga coret jika diskon | Tinggi |
| C-06 | Kategori | Hierarki kategori: Tenda, Sleeping Bag, Carrier, Sepatu, Jaket, Harness, Carabiner, Headlamp, Matras, Cooking Set, Aksesoris, dll. | Tinggi |
| C-07 | Size Guide | Panduan ukuran berdasarkan TB/BB untuk sepatu, jaket, carrier | Sedang |
| C-08 | Gear Checklist | Template checklist peralatan per jenis pendakian (gunung, tebing, camping). Item bisa di-add to cart langsung | Sedang |
| C-09 | Produk Terkait | Rekomendasi produk serupa di halaman detail | Sedang |

### 2.3 Keranjang & Checkout

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| K-01 | Add to Cart | Tambah produk ke keranjang dengan pilihan varian | Tinggi |
| K-02 | Lihat Keranjang | Daftar item, update qty, hapus item, hitung subtotal | Tinggi |
| K-03 | Checkout | Alur: Pilih alamat → Pilih kurir → Pilih pembayaran → Konfirmasi | Tinggi |
| K-04 | Kalkulasi Ongkir | Hitung ongkir real-time berdasarkan alamat & berat total pesanan | Tinggi |
| K-05 | Pilih Kurir | Pilihan kurir & service (reguler, express, same day) dari gudang Summit App | Tinggi |
| K-06 | Apply Voucher | Input kode voucher, validasi, terapkan diskon | Tinggi |
| K-07 | Ringkasan Pesanan | Review item, alamat, ongkir, voucher, total sebelum bayar | Tinggi |

### 2.4 Pembayaran

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| P-01 | Payment Gateway | Integrasi Midtrans | Tinggi |
| P-02 | Transfer Bank | VA BCA, BNI, BRI, Mandiri, Permata | Tinggi |
| P-03 | E-Wallet | GoPay, OVO, DANA, ShopeePay | Tinggi |
| P-04 | Kartu Kredit/Debit | Visa, Mastercard | Tinggi |
| P-05 | COD | Bayar di tempat | Rendah |
| P-06 | Countdown Timer | Batas waktu pembayaran (mis. 24 jam untuk VA, 15 menit untuk e-wallet) | Tinggi |
| P-07 | Konfirmasi Bayar | Halaman status setelah pembayaran berhasil/gagal | Tinggi |

### 2.5 Order Management

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| O-01 | Daftar Pesanan | List semua pesanan dengan tab status | Tinggi |
| O-02 | Detail Pesanan | Info lengkap: item, alamat, pembayaran, ongkir, status, timeline | Tinggi |
| O-03 | Status Pesanan | Menunggu Pembayaran → Diproses → Dikirim → Selesai | Tinggi |
| O-04 | Batalkan Pesanan | Cancel oleh user (sebelum dibayar / sebelum diproses) | Tinggi |
| O-05 | Tracking Pengiriman | Lacak resi + link ke website kurir | Tinggi |
| O-06 | Konfirmasi Diterima | User konfirmasi barang sudah diterima | Tinggi |
| O-07 | Return / Pengembalian | Ajukan pengembalian barang dengan alasan & foto | Sedang |
| O-08 | Riwayat Pesanan | Semua pesanan yang sudah selesai | Tinggi |
| O-09 | Komplain Order | Ajukan kendala untuk item tertentu (barang kurang, rusak, salah kirim) | Sedang |

### 2.6 Review & Rating

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| R-01 | Tulis Review Produk | Bintang 1–5 + teks + foto (hanya untuk pesanan selesai) | Sedang |
| R-02 | Lihat Review Produk | List review di halaman detail produk dengan filter rating | Sedang |
| R-03 | Rating Summary Produk | Rata-rata rating + distribusi bintang | Sedang |

### 2.7 Wishlist

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| W-01 | Tambah Wishlist | Simpan produk ke daftar favorit | Sedang |
| W-02 | Lihat Wishlist | Halaman daftar produk favorit | Sedang |
| W-03 | Notifikasi Diskon | Push notif saat item di wishlist mendapat diskon | Rendah |

### 2.8 Notifikasi

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| N-01 | Push Notification | Status pesanan, promo, restock item wishlist | Tinggi |
| N-02 | In-App Notification | Halaman daftar notifikasi di dalam app | Sedang |

### 2.9 Promo & Diskon

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| D-01 | Voucher Diskon | Kode promo: potongan harga, free ongkir, dll. Dikelola admin | Tinggi |
| D-02 | Diskon Produk | Harga coret (harga asli vs harga diskon) di detail produk | Tinggi |
| D-03 | Flash Sale | Promo waktu terbatas dengan countdown timer | Sedang |
| D-04 | Banner Promo | Carousel banner di homepage, klik arahkan ke halaman promo | Tinggi |

### 2.10 Customer Service

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| CS-01 | WhatsApp Chat | Tombol chat langsung ke nomor WA CS (deep link ke WhatsApp) | Tinggi |
| CS-02 | FAQ | Halaman pertanyaan umum | Sedang |

### 2.11 Artikel / Blog

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| B-01 | List Artikel | Daftar artikel tips, review gear, edukasi pendaki pemula | Rendah |
| B-02 | Detail Artikel | Halaman baca artikel | Rendah |

### 2.12 Admin / Backoffice (Web Portal & Inventory Management)

Modul sentral bagi tim internal Summit App untuk mengelola seluruh operasional e-commerce.

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| AD-01 | Dashboard Utama | Ringkasan metrik: total penjualan, order aktif, produk terlaris, revenue bulanan | Tinggi |
| AD-02 | Manajemen Katalog & Inventory | CRUD produk (tambah, edit, hapus, set stok & varian, harga beli, harga jual, margin) | Tinggi |
| AD-03 | Stock Alert System | Notifikasi ke tim gudang/purchasing jika stok menipis (< 10 unit) | Tinggi |
| AD-04 | Manajemen Order & Fulfillment | List semua order, cetak resi pengiriman, cetak invoice, update status order (Diproses -> Dikirim + Input Resi) | Tinggi |
| AD-05 | Manajemen Promo & Voucher | CRUD voucher, set periode, kuota, tipe diskon (persen/nominal), minimum belanja | Tinggi |
| AD-06 | Manajemen Banner & Flash Sale | CRUD banner homepage, atur jadwal flash sale, produk partisipan | Tinggi |
| AD-07 | Manajemen Kategori | CRUD kategori produk, hierarki, icon | Sedang |
| AD-08 | Manajemen User (Customer) | Daftar user, detail history belanja pelanggan, ban/unban akun | Sedang |
| AD-09 | Laporan Penjualan & Analytics | Laporan penjualan harian/bulanan, laba kotor, produk terlaris, user growth | Tinggi |
| AD-10 | Manajemen Return (RMA) | Daftar pengajuan pengembalian, approve/reject, proses refund dana via payment gateway | Sedang |
| AD-11 | Customer Support Dashboard | Melihat riwayat komplain pesanan dan resolusi | Rendah |

### 2.13 Fitur Pendukung Lainnya

| ID | Fitur | Deskripsi | Prioritas |
|---|---|---|---|
| F-01 | Deep Linking | Link produk bisa dibuka langsung di app (sharing ke sosmed, WA, dll.) | Sedang |
| F-02 | Force Update | Mekanisme wajib update app jika versi lama tidak kompatibel | Tinggi |
| F-03 | Notification Preferences | User bisa pilih jenis notif yang mau diterima (pesanan, promo, dll.) | Sedang |
| F-04 | Onboarding Screen | Tutorial singkat fitur app untuk user baru (first-time launch) | Rendah |

---

## 3. Fitur Post-MVP (Fase 2+)

| Fitur | Deskripsi |
|---|---|
| Sewa Peralatan (Rental) | Opsi sewa selain beli untuk gear mahal |
| Loyalty / Poin | Sistem poin untuk repeat buyer, tier membership |
| Live Chat In-App | Chat real-time dengan CS di dalam app |
| Komunitas / Forum | Sharing trip report, rekomendasi gear antar user |
| AR Try-On | Coba virtual sepatu/jaket via AR |
| Notifikasi Harga | Alert saat harga turun |
| Dark Mode | Tema gelap |
| Multi-bahasa | Bahasa Indonesia & English |

---

## 4. Alur Utama (User Flow)

### 4.1 Alur Pembelian

```
Buka App → Browse/Cari Produk → Lihat Detail → Add to Cart
→ Lihat Keranjang → Checkout → Pilih Alamat → Pilih Kurir
→ Apply Voucher (opsional) → Ringkasan → Bayar
→ Menunggu Pembayaran → Bayar → Diproses (Tim Internal) → Dikirim
→ Tracking → Diterima → Selesai → Review
```

### 4.2 Alur Registrasi

```
Buka App → Pilih Register → Input Email & Password / Google / Apple
→ Verifikasi Email → Lengkapi Profil → Selesai
```

### 4.3 Alur Return

```
Detail Pesanan (Selesai) → Ajukan Return → Pilih Alasan + Upload Foto
→ Submit → Menunggu Review Admin → Disetujui/Ditolak
→ Kirim Barang → Refund Diproses → Dana Kembali
```

### 4.4 Alur Pemrosesan Order (Sisi Admin Gudang)

```
Pelanggan Bayar Order → Order masuk tab "Perlu Diproses" di Dashboard
→ Admin mencetak Label Pengiriman (Resi) dan Packing List
→ Admin gudang menyiapkan barang & mempacking
→ Admin menyerahkan paket ke kurir → Admin update status "Dikirim"
→ Nomor Resi ter-update otomatis / manual di sistem
```

---

## 5. Arsitektur Teknis (High-Level)

### 5.1 Tech Stack

| Layer | Teknologi |
|---|---|
| **Mobile App** | Flutter (Dart) |
| **Backend API** | Node.js (Express) / Laravel (PHP) — TBD |
| **Database** | PostgreSQL |
| **Cache** | Redis |
| **Storage Gambar** | Cloud Storage (AWS S3 / GCS) |
| **Payment Gateway** | Midtrans |
| **Ongkir API** | RajaOngkir / BinderByte |
| **Push Notification** | Firebase Cloud Messaging (FCM) |
| **Authentication** | Firebase Auth / JWT |
| **Admin Portal (Web)** | React.js / Vue.js untuk tim manajemen internal |
| **Deployment** | Docker + Cloud (AWS / GCP / DigitalOcean) |

### 5.2 Entity Utama

- **User** — id, nama, email, no_hp, foto, created_at
- **Product** — id, nama, deskripsi, kategori_id, brand, berat, harga, harga_diskon, foto[], is_active
- **ProductVariant** — id, product_id, sku, ukuran, warna, stok, harga_tambahan
- **Category** — id, nama, parent_id, icon
- **Cart** — id, user_id, items[]
- **CartItem** — id, cart_id, product_id, varian_id, qty
- **Order** — id, user_id, alamat_pengiriman, ongkir, voucher_id, total, status, created_at
- **OrderItem** — id, order_id, product_id, product_variant_id, qty, harga_satuan, subtotal
- **Payment** — id, order_id, metode, status, waktu_bayar, midtrans_id
- **Shipment** — id, order_id, kurir, service, no_resi, status
- **Review** — id, user_id, product_id, rating, teks, foto[], created_at
- **Voucher** — id, kode, tipe, nilai, min_belanja, max_diskon, berlaku_mulai, berlaku_sampai, kuota
- **Wishlist** — id, user_id, product_id
- **Address** — id, user_id, label, penerima, no_hp, alamat_lengkap, kota, kecamatan, kode_pos, is_utama
- **Banner** — id, judul, gambar, link_tujuan, urutan, aktif
- **Article** — id, judul, konten, gambar, penulis, created_at

---

## 6. Non-Functional Requirements

| Aspek | Requirement |
|---|---|
| **Performa** | Halaman home & list produk load < 3 detik |
| **Performa** | Scroll list produk 60fps tanpa jank |
| **Skalabilitas** | Mendukung 10.000 concurrent users di fase awal |
| **Keamanan** | Enkripsi data sensitif (password bcrypt, token JWT) |
| **Keamanan** | HTTPS untuk semua API call |
| **Keamanan** | Rate limiting pada endpoint auth & pembayaran |
| **Keamanan** | Validasi input di backend (tidak hanya di client) |
| **Availability** | Uptime target 99.5% |
| **Backup** | Database backup harian |
| **Monitoring** | Logging & error tracking (Sentry / similar) |

---

## 7. Desain & UX Guidelines

| Aspek | Panduan |
|---|---|
| **Warna Utama** | Hijau hutan / earth tone (sesuai tema pendakian) |
| **Warna Aksen** | Oranye / kuning (CTA, highlight) |
| **Tipografi** | Sans-serif, clean, readable (Inter / Poppins) |
| **Navigasi** | Bottom Navigation: Home, Kategori, Keranjang, Pesanan, Profil |
| **Layout** | Mobile-first, thumb-friendly, CTA mudah dijangkau |
| **Gambar** | Format 1:1 atau 4:3 untuk produk, background outdoor/pendakian |

---

## 8. Milestone & Timeline

| Fase | Cakupan | Estimasi |
|---|---|---|
| **Fase 1: MVP** | Autentikasi, Katalog B2C, Keranjang, Checkout, Pembayaran, Pesanan, Notifikasi, WA CS, Admin Backoffice (Katalog, Inventory, Order Fulfillment, Voucher, Laporan Penjualan), Force Update | 3–4 bulan |
| **Fase 2: Enhancement** | Review Produk, Wishlist, Flash Sale, Size Guide, Gear Checklist, Deep Linking, Notification Preferences | 1–2 bulan |
| **Fase 3: Growth** | Artikel/Blog, Manajemen Return / RMA Terotomatisasi, Rental, Loyalty Program, Live Chat In-App, Onboarding Screen | 2–3 bulan |

---

## 9. Kebutuhan Pihak Ketiga (Third-Party Services)

| Layanan | Provider | Kegunaan |
|---|---|---|
| Payment Gateway | Midtrans | Proses pembayaran |
| Ongkir & Kurir | RajaOngkir / BinderByte | Hitung ongkir, tracking |
| Push Notification | Firebase FCM | Notifikasi mobile |
| Cloud Storage | AWS S3 / GCS | Simpan gambar produk, review, dll. |
| Google Sign-In | Google OAuth | Login via Google |
| Apple Sign-In | Apple OAuth | Login via Apple (wajib untuk iOS) |
| Email Service | SendGrid / Mailgun | Email verifikasi, reset password, notifikasi |
| Error Tracking | Sentry | Monitoring error production |
| Analytics | Google Analytics / Mixpanel | Tracking user behavior |

---

## 10. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Stok tidak akurat | User order tapi barang habis | Real-time stock check, reserved stock saat checkout, stock audit mingguan di gudang internal |
| Fraud pembayaran | Kerugian finansial | Midtrans fraud detection, verifikasi ketat jika ada COD |
| Ongkir API down | Tidak bisa hitung ongkir | Fallback ke tarif flat per zona pengiriman |
| Return abuse | Kerugian operasional | Kebijakan return ketat, batas waktu pengembalian, wajib video unboxing |
| Performa app lambat | User churn | Optimasi query, caching, lazy loading gambar |

---

## 11. Business Rules

| Kategori | Aturan | Detail |
|---|---|---|
| **Return** | Batas waktu pengembalian | Maksimal 7 hari setelah barang diterima |
| **Return** | Kondisi barang | Harus dalam kondisi asli, belum dipakai, dengan kemasan utuh (disertai video unboxing) |
| **Return** | Ongkir return | Ditanggung Summit App jika kesalahan gudang (salah kirim, rusak); ditanggung buyer jika alasan buyer (ubah pikiran) |
| **Pembayaran** | Batas waktu VA | 24 jam sejak order dibuat |
| **Pembayaran** | Batas waktu e-wallet | 15 menit sejak order dibuat |
| **Pembayaran** | Auto-cancel | Order otomatis dibatalkan jika melewati batas waktu pembayaran |
| **Fulfillment** | SLA Gudang | Tim gudang harus memproses (packing) maksimal 1x24 jam di hari kerja setelah pembayaran berhasil |
| **Voucher** | Cakupan | Voucher berlaku secara platform-wide, diatur sepenuhnya oleh tim marketing Summit App |
| **Voucher** | Stacking | 1 voucher per checkout, tidak bisa ditumpuk dengan voucher lain |
| **Stok** | Reserved stock | Stok di-reserve saat checkout, dilepas kembali jika pembayaran gagal/expired |
| **Stok** | Low stock alert | Notifikasi ke dashboard admin jika stok varian < 10 unit |
| **Review** | Syarat review | Hanya bisa review setelah order berstatus Selesai |
| **Review** | Moderasi | Admin berhak menyembunyikan review yang mengandung SARA/ujaran kebencian/spam |
| **COD** | Ketersediaan | Tersedia untuk seluruh pengiriman, dengan batasan maksimal transaksi Rp 2.000.000 |

---

*Dokumen ini bersifat living document dan akan diupdate seiring progress development.*
