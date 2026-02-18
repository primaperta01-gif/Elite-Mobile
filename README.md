# Elite Mobile

Flutter mobile app untuk **Elite Management System**. Terhubung ke backend via REST API (`/api/v1/`).

## Fitur

- **Login** — Pilih role (Master/Kasir/Agency/Mitra), autentikasi JWT
- **Dashboard** — Ringkasan shift, transaksi, stok, saldo rekening
- **Input Transaksi** — Jual Koin, Beli Gift, Reload, Pelunasan Kasbon, Transfer
- **Shift Management** — Buka/tutup shift, pilih partner
- **Laporan** — Per shift, global (30 hari), selisih
- **Master Data** — Produk, mitra, rekening (read-only untuk non-master)
- **Profile** — Info user, logout

## Prasyarat

1. **Flutter SDK** >= 3.0.0 — [Install Flutter](https://flutter.dev/docs/get-started/install)
2. **Android Studio** (untuk Android) atau **Xcode** (untuk iOS di Mac)
3. **Backend server** Elite Management System berjalan dengan REST API aktif

## Setup

```bash
# 1. Clone repo
git clone https://github.com/primaperta01-gif/Elite-Mobile.git
cd Elite-Mobile

# 2. Install dependencies
flutter pub get

# 3. Ubah API URL (PENTING!)
#    Edit file: lib/config/api_config.dart
#    Ganti baseUrl ke IP/domain server Anda

# 4. Jalankan
flutter run
```

## Konfigurasi API URL

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Emulator Android:
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';

  // HP real (sama WiFi dengan server):
  // static const String baseUrl = 'http://192.168.x.x:5000/api/v1';

  // Production (domain):
  // static const String baseUrl = 'https://yourdomain.com/api/v1';
}
```

## Build APK

```bash
flutter build apk --release
```

File APK ada di `build/app/outputs/flutter-apk/app-release.apk`.

## Struktur Project

```
lib/
├── config/          # API URL, theme
├── models/          # Data models (User, Product, Shift, dll)
├── services/        # HTTP API calls
├── providers/       # State management (auth)
├── screens/         # Halaman-halaman UI
│   ├── auth/        # Login
│   ├── dashboard/   # Home dashboard
│   ├── transaksi/   # Input transaksi
│   ├── shift/       # Start/close shift
│   ├── laporan/     # Reports
│   ├── master/      # Master data
│   └── profile/     # User profile
└── widgets/         # Komponen reusable
```

## Tech Stack

- Flutter 3.x (Dart)
- Provider (state management)
- http (REST API client)
- flutter_secure_storage (token storage)
- intl (format angka Rupiah)
