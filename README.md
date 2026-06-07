# Summit App

> Aplikasi mobile e-commerce B2C untuk penjualan peralatan pendakian (camping & hiking equipment).

---

## Tech Stack

| Layer            | Technology                                          |
|------------------|-----------------------------------------------------|
| Framework        | Flutter (Dart) 3.12+                                |
| Platform Target  | Android (min SDK 21)                                |
| State Management | `provider` (ChangeNotifier)                         |
| Database         | SQLite via `sqflite`                                 |
| Image Cache      | `cached_network_image`                              |
| Typography       | `google_fonts` (Inter)                              |
| Local Storage    | `shared_preferences` (onboarding flag)              |
| Image Picker     | `image_picker` (profile photo)                      |

---

## Fitur MVP

| Kategori     | Fitur                                          |
|--------------|------------------------------------------------|
| Autentikasi  | Register, Login, Logout                        |
| Profil       | Edit profil, foto profil, no HP                |
| Alamat       | CRUD alamat, set alamat utama                  |
| Katalog      | Browse, search, filter per kategori, sort      |
| Produk       | Detail produk, varian, size guide, related     |
| Keranjang    | Add, update qty, hapus, voucher                |
| Checkout     | Pilih alamat, kurir (4 opsi flat), pembayaran  |
| Pesanan      | List, detail, status tracking, batal           |
| Pembayaran   | Simulasi (klik bayar → auto diproses & kirim)  |
| Notifikasi   | In-app toast (push notification FCM: skip)     |
| Voucher      | 3 voucher seed (SUMMIT10, HEMAT50, NEWUSER)    |
| Bottom Nav   | Beranda, Kategori, Keranjang, Pesanan, Profil  |

**20 produk seed** dalam 10 kategori (Tenda, Sleeping Bag, Carrier, Sepatu, Jaket, Harness, Headlamp, Matras, Cooking Set, Aksesoris) bermerk Eiger, Consina, Deuter, Salomon, Naturehike, Petzl, dll.

---

## Struktur Folder

```
summitapp/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # MaterialApp, routes, providers
│   │
│   ├── config/                            # Konfigurasi global
│   │   ├── app_theme.dart                 # Theme Material (warna, button, input)
│   │   ├── app_routes.dart                # Konstanta nama route
│   │   └── constants.dart                 # DB name, ongkir flat, payment methods
│   │
│   ├── models/                            # Data model (toMap / fromMap)
│   │   ├── user.dart
│   │   ├── product.dart
│   │   ├── category.dart
│   │   ├── cart_item.dart
│   │   ├── order.dart
│   │   ├── order_item.dart
│   │   ├── address.dart
│   │   └── voucher.dart
│   │
│   ├── services/                          # Business logic & data access
│   │   ├── database_service.dart          # SQLite init, migration 10 tabel
│   │   ├── auth_service.dart               # Register, login, profile, address CRUD
│   │   └── seed_data.dart                  # 20 produk + 10 kategori + 3 voucher
│   │
│   ├── providers/                         # State management (ChangeNotifier)
│   │   ├── auth_provider.dart              # State user login
│   │   ├── product_provider.dart           # State produk + filter/sort/search
│   │   ├── cart_provider.dart              # State keranjang + voucher
│   │   └── order_provider.dart             # State pesanan + flow status
│   │
│   ├── pages/                             # Halaman UI
│   │   ├── splash/splash_page.dart
│   │   ├── onboarding/onboarding_page.dart
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── main_shell/main_shell.dart       # BottomNavigationBar host
│   │   ├── home/
│   │   │   ├── home_page.dart               # Beranda
│   │   │   ├── alpine_theme.dart             # Color tokens & typography
│   │   │   └── widgets/
│   │   │       ├── section_label.dart
│   │   │       ├── alpine_category_card.dart
│   │   │       ├── alpine_product_card.dart
│   │   │       ├── countdown_chip.dart
│   │   │       ├── hero_banner.dart
│   │   │       └── shared_widgets.dart       # PageHeader, EmptyState, StatusBadge
│   │   ├── catalog/
│   │   │   ├── category_page.dart
│   │   │   ├── product_list_page.dart
│   │   │   ├── product_detail_page.dart
│   │   │   └── search_page.dart
│   │   ├── cart/cart_page.dart
│   │   ├── checkout/checkout_page.dart
│   │   ├── orders/
│   │   │   ├── order_list_page.dart
│   │   │   └── order_detail_page.dart
│   │   ├── profile/
│   │   │   ├── profile_page.dart
│   │   │   ├── edit_profile_page.dart
│   │   │   ├── address_list_page.dart
│   │   │   └── address_form_page.dart
│   │   └── wishlist/wishlist_page.dart
│   │
│   └── widgets/
│       └── product_card.dart               # Legacy card (masih dipakai di beberapa tempat)
│
├── android/                                 # Konfigurasi Android native
├── ios/                                     # Konfigurasi iOS native (tidak dikembangkan)
├── assets/                                  # Aset statis (placeholder)
├── pubspec.yaml                             # Dependencies Flutter
└── PRD 3.md                                 # Dokumen PRD asli
```

---

## Prasyarat

Pastikan sudah terinstall di Windows:

| Tool       | Versi Minimum | Cara Cek                          |
|------------|---------------|-----------------------------------|
| Flutter    | 3.12+         | `flutter --version`               |
| Dart       | 3.12+         | (ikut Flutter)                    |
| Android SDK| 35+           | (via Android Studio)              |
| JDK        | 17            | `java -version`                   |
| Git        | -             | `git --version`                   |

Tambahkan path berikut ke **System Environment Variables → PATH**:
- `C:\src\flutter\bin`
- `C:\Users\<user>\AppData\Local\Android\Sdk\platform-tools`

---

## Cara Menjalankan

### 1. Clone & Install Dependencies

```powershell
# Clone repo (jika belum)
git clone <url-repo>
cd summitapp

# Install semua package Flutter
flutter pub get
```

### 2. Nyalakan Emulator

**Opsi A — Via Android Studio:**
Buka Android Studio → Device Manager → klik ▶ di emulator

**Opsi B — Via terminal:**
```powershell
flutter emulators --launch Pixel_10
```

**Opsi C — Langsung run (auto-detect):**
```powershell
flutter run
# Kalau ada banyak device:
flutter run -d emulator-5554
```

Tunggu sampai muncul:
```
✓ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...
```

### 3. Hot Reload (saat development)

Setelah app jalan, di terminal tempat `flutter run` aktif:

| Key          | Fungsi                                                |
|--------------|-------------------------------------------------------|
| `r`          | Hot reload — state aplikasi tetap                     |
| `R`          | Hot restart — full restart, state hilang              |
| `q`          | Quit / stop                                           |
| `h`          | List semua command interaktif                          |

Di VS Code:
- `Ctrl + S` → otomatis hot reload
- Klik ⚡ icon (hot reload) atau 🔄 icon (hot restart) di toolbar bawah

---

## Build APK

```powershell
# Debug APK (untuk testing, ukuran ~30-50 MB)
flutter build apk --debug
# Output: build\app\outputs\flutter-apk\app-debug.apk

# Release APK (ukuran lebih kecil, butuh signing)
flutter build apk --release
# Output: build\app\outputs\flutter-apk\app-release.apk

# Split per arsitektur (paling kecil, file terpisah per ABI)
flutter build apk --split-per-abi
```

Install APK manual ke device:
```powershell
adb install build\app\outputs\flutter-apk\app-debug.apk
```

---

## Alur Testing Awal

1. **Buka app** → muncul Splash → Onboarding (3 slide) → klik "Lewati" atau "Mulai Sekarang"
2. **Register** akun baru (email + password + nama) atau langsung register via form
3. **Browse** produk di Beranda atau Kategori
4. **Tap produk** → lihat detail → klik "Tambah Keranjang" atau "Beli Sekarang"
5. **Buka tab Keranjang** → update qty / hapus / apply voucher
6. **Checkout** → pilih / tambah alamat → pilih kurir → pilih metode bayar → "Buat Pesanan"
7. **Tab Pesanan** → klik "Bayar Sekarang" → status berubah: Diproses → Dikirim → Selesai

**Akun test cepat** (opsional, register manual lebih bagus):
- Email: `test@summit.com`
- Password: `test123`

---

## Troubleshooting

### ❌ Build Gagal: "image_picker_android: Could not close incremental caches"

Bug Kotlin incremental compiler pada Windows dengan `image_picker`. Sudah difix permanen di `android/gradle.properties`:
```properties
kotlin.incremental=false
```

Kalau masih error, bersihkan cache:
```powershell
Get-Process -Name "java" -ErrorAction SilentlyContinue | Stop-Process -Force
Remove-Item -LiteralPath "D:\project_android\summitapp\build" -Recurse -Force -ErrorAction SilentlyContinue
flutter run
```

### ❌ Error: "Stuck di loading" / Splash tanpa navigasi

Pastikan `splash_page.dart` punya timer `Future.delayed` + `Navigator.pushReplacementNamed`. Kalau baru clone, lakukan:
```powershell
flutter clean
flutter pub get
flutter run
```

### ❌ Error: "Null is not a subtype of Map<String, dynamic>"

Cast argument route null. Biasanya terjadi di halaman yang dipush tanpa arguments. Sudah difix dengan nullable cast di `product_detail_page` & `order_detail_page`.

### ❌ App Crash Setelah Lihat Banyak Produk

Clear data lokal:
```powershell
adb -s emulator-5554 shell pm clear com.example.summitapp
flutter run
```

### ❌ "Developer Mode Required" saat `flutter pub get`

Aktifkan Developer Mode Windows:
```powershell
# Buka Settings → Privacy & Security → For developers
start ms-settings:developers
# Toggle "Developer Mode" ON → restart
```

### ❌ Multiple Devices Terdeteksi

Pilih device tertentu:
```powershell
flutter devices
flutter run -d emulator-5554
```

---

## Catatan Pengembangan

- **Data seed** (20 produk, 10 kategori, 3 voucher) di-load otomatis pertama kali app jalan
- **Database SQLite** disimpan di device, tidak hilang setelah restart
- **Voucher**: `SUMMIT10` (10% max 50rb, min 200rb), `HEMAT50` (50rb off, min 300rb), `NEWUSER` (15% max 75rb)
- **Ongkir flat** (lihat `lib/config/constants.dart`) — tidak ada integrasi RajaOngkir
- **Pembayaran** disimulasikan: klik "Bayar Sekarang" → status langsung berubah ke Diproses → Dikirim
- **Gambar produk** dari Unsplash (hot-link) — butuh internet untuk load

---

## Lisensi

Proyek ini dibuat untuk keperluan tugas kuliah. Bebas digunakan untuk pembelajaran.
