# 🌊 Sistem Peringatan Dini Banjir Desa Rahong (Flutter Dart)

Aplikasi mobile cross-platform berbasis **Flutter & Dart** dengan **Fuzzy Logic Mamdani**, integrasi REST API cuaca real-time, dan layer spasial GIS topografi Desa Rahong.

---

## 🚀 Fitur Utama
1. **Hybrid Fuzzy Engine (Online & Offline Edge Computing):**
   - Mengambil data dari REST API Backend (FastAPI).
   - Dilengkapi fallback mesin inferensi **Fuzzy Mamdani lokal di perangkat (Dart)** jika koneksi internet terputus di lapangan.
2. **Interactive Map (GIS Spatial Layers):**
   - Menggunakan `flutter_map` berbasis OpenStreetMap (bebas biaya, tanpa kendala Google Maps API Key billing).
   - Render poligon zona bahaya berwarna dinamis (🟢 Hijau $\to$ 🟡 Kuning $\to$ 🟠 Oranye $\to$ 🔴 Merah).
   - Garis aliran Sungai Rahong dan titik posko evakuasi pengungsi (Balai Desa, SD Rahong, Masjid).
3. **Geofencing Bahaya (Ray-Casting Algorithm):**
   - Mendeteksi apakah perangkat pengguna berada di dalam batas poligon zona rawan tinggi (*Point-in-Polygon*).
   - Memicu banner merah dan peringatan evakuasi otomatis.
4. **Simulasi Cuaca Interaktif:**
   - Dilengkapi fitur penggeser (*slider*) curah hujan (0-150mm) dan durasi (0-12 jam) langsung di aplikasi untuk presentasi/pengujian.

---

## 🛠️ Cara Menjalankan

1. **Buka Proyek:**
   Buka folder `flutter_app` di **VS Code** atau **Android Studio**.

2. **Install Dependensi:**
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi:**
   Pilih emulator atau HP fisik Anda, lalu jalankan:
   ```bash
   flutter run
   ```

---

## 📂 Struktur Direktori

```
flutter_app/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/ (app_colors.dart, api_constants.dart)
│   │   ├── fuzzy/ (mamdani_engine.dart)          <-- Pure Dart Fuzzy Engine
│   │   └── utils/ (point_in_polygon.dart, notification_helper.dart)
│   ├── data/
│   │   ├── models/ (weather_model.dart, flood_status_model.dart)
│   │   └── repositories/ (flood_repository.dart)  <-- Hybrid Online/Offline
│   ├── domain/
│   │   └── entities/ (alert_level.dart, flood_zone.dart)
│   └── presentation/
│       ├── providers/ (flood_provider.dart)       <-- State Management
│       ├── screens/
│       │   ├── main_navigation_screen.dart
│       │   ├── dashboard_screen.dart
│       │   └── map_screen.dart                   <-- Flutter Map Leaflet GIS
│       └── widgets/ (alert_banner.dart, status_metric_card.dart, zone_status_tile.dart)
└── assets/
    └── desa_rahong.geojson                       <-- Data Spasial Desa Rahong
```

