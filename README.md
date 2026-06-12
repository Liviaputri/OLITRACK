# 🛢️ OLITRACK - Smart Oil Change Reminder App

Aplikasi reminder cerdas untuk tracking penggantian oli kendaraan dengan sistem dual-factor (KM dan Tanggal). OLITRACK membantu Anda tidak melewatkan jadwal perawatan dengan notifikasi pintar dan tracking biaya.

---

## 📋 Daftar Isi
1. [Fitur Utama](#-fitur-utama)
2. [Arsitektur Sistem](#-arsitektur-sistem)
3. [Struktur Data](#-struktur-data)
4. [Panduan Penggunaan](#-panduan-penggunaan)
5. [Teknologi & Dependencies](#-teknologi--dependencies)

---

## ✨ Fitur Utama

### 1. **Dashboard Interaktif**
- 📊 Status oli real-time dengan animasi
- ⏳ Jadwal ganti oli berikutnya (target KM + Tanggal)
- 📈 Progress indicator pemakaian oli dalam persentase
- 🔔 Notifikasi dengan badge counter
- 📊 Tombol Statistik di app bar
- 4 Quick Actions dalam grid 2x2:
  - 📝 Tambah Riwayat Ganti Oli
  - ⚡ Ganti Oli Sekarang (Quick Input)
  - 🔄 Perbarui Odometer KM
  - 📋 Riwayat Lengkap

### 2. **Smart Dual-Factor Tracking**
Sistem cerdas yang membandingkan dua interval sekaligus:
- **Interval KM**: Default 5000 km, dapat disesuaikan
- **Interval Bulan**: Default 3 bulan, dapat disesuaikan
- **Automatic Priority Detection**: Sistem otomatis menentukan mana yang tercapai duluan
- **Estimation Logic**: Menggunakan estimasi 50 KM/hari untuk membandingkan progress

### 3. **Manajemen Riwayat Lengkap**
Setiap entry ganti oli menyimpan:
- 📅 **Tanggal** ganti oli
- 🎯 **KM** saat dilakukan penggantian
- 🛢️ **Jenis Oli** yang digunakan
- 📏 **Interval KM** untuk ganti berikutnya
- 📆 **Interval Bulan** untuk ganti berikutnya
- 💰 **Biaya** (optional) - untuk tracking pengeluaran
- 📍 **Tempat** (optional) - nama bengkel atau toko
- 📝 **Catatan** (optional) - informasi tambahan

**Fitur History:**
- ✅ Display lengkap dengan color-coded badges (orange KM, blue bulan, green biaya)
- ✅ Edit & Delete functionality
- ✅ Search by KM dan notes
- ✅ Filter by date range
- ✅ Export ke CSV

### 4. **Statistik & Laporan Komprehensif**
Halaman Statistics menampilkan:
- **💰 Cost Summary Card**:
  - Total biaya ganti oli
  - Rata-rata biaya per penggantian
  - Biaya terakhir yang dikeluarkan
  
- **🛢️ Oil Usage Breakdown**:
  - Jenis oli paling sering digunakan
  - Breakdown per jenis dengan persentase
  - Progress bar visual untuk setiap jenis
  
- **📊 Interval Statistics**:
  - Rata-rata interval KM antar penggantian
  - Total jumlah penggantian oli
  
- **⏱️ Recent Changes**:
  - Daftar 5 penggantian terakhir
  - Info: tanggal, oli type, KM
  - Quick link ke riwayat lengkap

### 5. **Sistem Notifikasi Cerdas**
- **Dual-Factor Alerts**: Memberitahu status KM overdue DAN tanggal overdue secara terpisah
- **Color-Coded Status**:
  - 🔴 **GANTI OLI SEKARANG** (Merah) - sudah overdue
  - 🟠 **HAMPIR GANTI** (Orange) - warning mendekati batas
  - 🔵 **INFO** (Biru) - informasi jadwal
  - 🟢 **AMAN** (Hijau) - masih aman

---

## 🏗️ Arsitektur Sistem

```
lib/
├── core/
│   ├── oil_change_helper.dart      # Core business logic dual-factor tracking
│   ├── cost_statistics.dart        # Utility untuk cost calculations
│   ├── color_extensions.dart       # Color manipulation extensions
│   ├── app_theme.dart              # Theme configuration
│   └── route.dart                  # Route management
│
├── models/
│   └── history_model.dart          # Data model untuk oil change entries
│
├── pages/
│   ├── splash_screen.dart          # Splash screen
│   ├── login_page.dart             # Login authentication
│   ├── register_page.dart          # User registration
│   ├── dashboard_page.dart         # Main dashboard with status & quick actions
│   ├── history_page.dart           # Complete history list & management
│   ├── statistics_page.dart        # Comprehensive statistics & reporting
│   ├── motor_form_page.dart        # Motor/vehicle configuration
│   └── home_page.dart              # Home wrapper
│
├── services/
│   └── notification_service.dart   # Notification logic & alerts
│
├── widgets/
│   ├── history_entry_dialog.dart   # Dialog for adding/editing history
│   └── history_chart.dart          # Chart visualization
│
└── main.dart                        # Application entry point
```

### Core Business Logic

#### `oil_change_helper.dart`
Utility class untuk semua logika perhitungan tracking oli:
- `getRemainingKm()` - Sisa KM hingga ganti berikutnya
- `getRemainingDays()` - Sisa hari hingga ganti berikutnya
- `getPriority()` - Tentukan mana yang tercapai duluan (KM_OVERDUE, DATE_OVERDUE, KM, DATE)
- `getStatus()` - Status user-friendly (AMAN, HAMPIR GANTI, GANTI OLI SEKARANG)
- `getDetailedMessage()` - Pesan deskriptif lengkap untuk dashboard
- `getNextChangeKm()` - Hitung target KM ganti berikutnya
- `getNextChangeDate()` - Hitung target tanggal ganti berikutnya

#### `cost_statistics.dart`
Utility class untuk perhitungan statistik biaya:
- `getTotalCost()` - Total semua pengeluaran ganti oli
- `getAverageCost()` - Rata-rata biaya per penggantian
- `getLastCost()` - Biaya terakhir
- `formatCurrency()` - Format currency ke IDR
- `getMostUsedOil()` - Jenis oli yang paling sering digunakan
- `getAverageInterval()` - Rata-rata interval KM
- `getCountByOil()` - Hitungan per jenis oli

### Data Persistence
- **Framework**: Hive (NoSQL local database)
- **Boxes**:
  - `motor` - Menyimpan info kendaraan & preferensi
  - `history` - Menyimpan semua riwayat ganti oli

---

## 📊 Struktur Data

### HistoryModel
```dart
class HistoryModel {
  DateTime tanggal;           // Tanggal ganti oli
  int km;                     // KM saat ganti
  String oli;                 // Jenis oli (Shell, Mobil, Castrol, dll)
  int intervalKm;             // Interval KM ke ganti berikutnya (default: 5000)
  int intervalBulan;          // Interval bulan ke ganti berikutnya (default: 3)
  int? cost;                  // Biaya ganti (optional)
  String? place;              // Tempat ganti (bengkel/toko)
  String? notes;              // Catatan tambahan
}
```

### Motor Data (Hive box: 'motor')
```
{
  'km': 125000,                    // Current odometer reading
  'lastOilChangeKm': 120000,      // KM saat ganti terakhir
  'lastOilChangeDate': DateTime,  // Tanggal ganti terakhir
  'defaultIntervalKm': 5000,      // Default interval KM
  'defaultIntervalBulan': 3,      // Default interval bulan
}
```

---

## 📱 Panduan Penggunaan

### 1. **Pertama Kali Menggunakan**
1. Register akun baru atau Login
2. Isi informasi kendaraan di Motor Form
3. Input penggantian oli pertama untuk baseline

### 2. **Tracking Penggantian Oli**
**Pilihan A - Input Lengkap:**
- Tap "Tambah Riwayat"
- Isi semua detail (tanggal, KM, oli, interval, biaya, tempat)
- Sesuaikan interval KM & bulan jika berbeda dari default

**Pilihan B - Quick Input:**
- Tap "Ganti Oli Sekarang"
- Quick dialog dengan input minimal + biaya & tempat
- Lebih cepat untuk update rutin

**Pilihan C - Update Odometer:**
- Tap "Perbarui Odometer"
- Update KM kendaraan tanpa mencatat penggantian

### 3. **Monitoring Status**
- Dashboard menampilkan status real-time
- Lihat "Next Service Schedule" untuk jadwal berikutnya
- Sistem otomatis menentukan deadline yang paling urgent

### 4. **Melihat Riwayat Lengkap**
- Tap "Riwayat Lengkap" dari dashboard
- Filter by date range, search by KM/notes
- Edit atau delete entry yang salah
- Export ke CSV untuk backup/analisis

### 5. **Analisis Statistik**
- Tap icon "📊" di app bar
- Lihat breakdown biaya, penggunaan oli, average interval
- Track tren pengeluaran & preferensi oli

---

## 🛠️ Teknologi & Dependencies

### Framework & Core
- **Flutter** - UI framework
- **Dart** - Programming language
- **Hive** - Local database (NoSQL)

### UI & Design
- **Material Design 3** - Design system
- **fl_chart** - Chart visualization
- **intl** - Internationalization & date/currency formatting

### Key Features Implementation
- **State Management**: StatefulWidget + Hive boxes
- **Date/Time**: `intl` package (date formatting & locale)
- **Number Formatting**: `intl` package (currency formatting)
- **Notifications**: Custom NotificationService
- **Charts**: fl_chart for statistics visualization

### Color Theme
```
Primary: 0xFF070B1A (Deep Dark Blue)
Cards: 0xFF0F1630 (Dark Blue)
Accent: 0xFFFF9800 (Orange)
Secondary: 0xFF1A2847 (Slightly lighter Blue)
Success: 0xFF4CAF50 (Green)
Warning: 0xFFFFC107 (Amber)
Error: 0xFFE53935 (Red)
```

---

## 🚀 Fitur Unggulan Sistem

### ✅ Smart Dual-Factor Detection
```
Contoh:
- Interval KM: 5000 km
- Interval Bulan: 3 bulan
- Estimated: 50 KM/hari

Kendaraan saat ini: 124,700 KM (300 KM untuk ganti)
Hari sejak ganti terakhir: 80 hari (10 hari untuk deadline)

Sistem akan alert:
→ KM masih aman (300 KM sisa)
→ TAPI TANGGAL SUDAH DEKAT (hanya 10 hari!)
→ Priority: DATE_OVERDUE
```

### ✅ Automatic Status Determination
- Sistem tidak perlu user pilih, otomatis determine status berdasarkan priority
- User hanya perlu lihat warna & pesan untuk mengetahui action yang diperlukan

### ✅ Cost Tracking & Analytics
- Setiap penggantian bisa dicatat dengan biaya
- Analytics halaman menunjukkan pengeluaran total & trend
- Breakdown by oil type untuk optimasi budget

### ✅ Flexible Interval Settings
- Default 5000 KM / 3 bulan
- Setiap penggantian bisa set interval berbeda
- Cocok untuk berbagai kondisi berkendara

---

## 📚 Catatan Teknis

### Default Values
- Interval KM: 5000 km
- Interval Bulan: 3 bulan
- KM Estimation: 50 km/hari

### Warning Thresholds
- KM Warning: Ketika sisa < 500 KM
- Date Warning: Ketika sisa < 7 hari

### Data Export Format (CSV)
```
date,km,oli,interval_km,interval_bulan,cost,place,notes
2024-01-15,120000,Shell,5000,3,250000,Bengkel Jaya,Regular
2024-04-10,125000,Mobil,5000,3,200000,Toko ABC,Saya ganti
```

---

## 📖 Getting Started dengan Development

```bash
# Clone project
git clone https://github.com/Liviaputri/OLITRACK.git

# Install dependencies
flutter pub get

# Run aplikasi
flutter run

# Build APK
flutter build apk --release
```

---

**OLITRACK** © 2024 - Smart Oil Change Reminder System
