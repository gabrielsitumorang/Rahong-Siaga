import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/constants/api_constants.dart';
import '../../core/fuzzy/mamdani_engine.dart';
import '../../domain/entities/alert_level.dart';
import '../../domain/entities/flood_zone.dart';
import '../models/flood_status_model.dart';
import '../models/weather_model.dart';

class FloodRepository {
  /// Mengambil data cuaca terkini secara REALTIME dari Open-Meteo API
  Future<WeatherModel> fetchCurrentWeather() async {
    // 1. Prioritas Utama: Open-Meteo (Realtime, Gratis, Tanpa API Key)
    try {
      final uri = Uri.parse(ApiConstants.openMeteoUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>? ?? {};
        final hourly = data['hourly'] as Map<String, dynamic>? ?? {};

        final double rainMm = (current['precipitation'] as num?)?.toDouble() ??
            (current['rain'] as num?)?.toDouble() ??
            0.0;

        final double temp = (current['temperature_2m'] as num?)?.toDouble() ?? 27.0;
        final double humidity = (current['relative_humidity_2m'] as num?)?.toDouble() ?? 80.0;
        final int wmoCode = (current['weather_code'] as num?)?.toInt() ?? 0;

        // Kejenuhan tanah (m3/m3 ke persentase kapasitas lapang)
        final double rawSoil = (current['soil_moisture_0_to_1cm'] as num?)?.toDouble() ?? 0.22;
        final double soilPercent = (rawSoil / 0.40 * 100).clamp(10.0, 100.0);

        final hourlyPrecip = (hourly['precipitation'] as List<dynamic>?) ?? [];
        final double estimatedDuration = _estimateDurationFromHourly(hourlyPrecip, rainMm);

        // Estimasi tinggi muka air sungai normal Rahong (cm) berkorelasi dengan curah hujan
        final double estimatedTma = 55.0 + (rainMm * 1.2) + (estimatedDuration * 3.5);

        return WeatherModel(
          temperature: temp,
          humidity: humidity,
          description: '${_decodeWmoWeatherCode(wmoCode)} (Open-Meteo Realtime)',
          rainfallMm: rainMm,
          durationHours: estimatedDuration,
          soilMoisturePercent: double.parse(soilPercent.toStringAsFixed(1)),
          waterLevelCm: double.parse(estimatedTma.toStringAsFixed(1)),
          timestamp: DateTime.now(),
        );
      }
    } catch (_) {}

    // 2. Prioritas Kedua: Coba API Backend FastAPI lokal
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.weatherEndpoint))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherModel.fromJson(data);
      }
    } catch (_) {}

    // 3. Fallback jika offline total
    return WeatherModel(
      temperature: 26.5,
      humidity: 88.0,
      description: 'Hujan Rintik (Mode Offline)',
      rainfallMm: 15.0,
      durationHours: 1.0,
      soilMoisturePercent: 45.0,
      waterLevelCm: 65.0,
      timestamp: DateTime.now(),
    );
  }

  /// Menghitung durasi jam hujan berkelanjutan dari data per-jam Open-Meteo
  double _estimateDurationFromHourly(List<dynamic> hourlyPrecip, double currentRain) {
    if (hourlyPrecip.isEmpty) return currentRain > 0 ? 1.0 : 0.0;

    double consecutiveHours = 0.0;
    for (int i = hourlyPrecip.length - 1; i >= 0; i--) {
      final val = (hourlyPrecip[i] as num?)?.toDouble() ?? 0.0;
      if (val > 0.1) {
        consecutiveHours += 1.0;
      } else {
        if (consecutiveHours > 0) break;
      }
    }

    if (consecutiveHours == 0.0 && currentRain > 0) {
      return 0.5;
    }
    return consecutiveHours.clamp(0.0, 12.0);
  }

  /// Menerjemahkan kode cuaca WMO ke Bahasa Indonesia
  String _decodeWmoWeatherCode(int code) {
    if (code == 0) return 'Cerah';
    if (code >= 1 && code <= 3) return 'Cerah Berawan / Mendung';
    if (code >= 45 && code <= 48) return 'Berkabut';
    if (code >= 51 && code <= 55) return 'Gerimis / Hujan Ringan';
    if (code >= 61 && code <= 63) return 'Hujan Sedang';
    if (code >= 65 && code <= 67) return 'Hujan Lebat';
    if (code >= 80 && code <= 82) return 'Hujan Deras Disertai Angin';
    if (code >= 95) return 'Badai Hujan & Petir';
    return 'Hujan';
  }

  /// Mengambil status banjir & melakukan inferensi Fuzzy Mamdani 4 Variabel
  Future<FloodStatusModel> fetchFloodStatus({
    double? curahHujan,
    double? durasiHujan,
    double? kejenuhanTanah,
    double? tinggiMukaAir,
  }) async {
    final c = curahHujan ?? 15.0;
    final d = durasiHujan ?? 1.0;
    final soil = kejenuhanTanah ?? 45.0;
    final tma = tinggiMukaAir ?? 65.0;

    // Evaluasi Mesin Fuzzy Mamdani 4 Variabel
    final localResult = MamdaniFuzzyEngine.compute(
      curahInput: c,
      durasiInput: d,
      soilMoistureInput: soil,
      tmaInput: tma,
    );

    // Hitung SBL untuk masing-masing zona geografis Desa Rahong
    final localZones = [
      ZoneStatusModel(
        zoneId: 'zona-01',
        nama: 'Bantaran Sungai Rahong',
        koefisien: 1.25,
        elevasi: 45,
        sblScore: (localResult.crispOutputZ * 1.25).clamp(0.0, 100.0),
        status: AlertLevel.fromSblScore(localResult.crispOutputZ * 1.25).label,
        warna: localResult.crispOutputZ * 1.25 > 80
            ? 'Merah'
            : (localResult.crispOutputZ * 1.25 > 60 ? 'Oranye' : 'Hijau'),
        actionRequired: 'Segera evakuasi mandiri ke Posko Balai Desa jika status Siaga/Awas.',
      ),
      ZoneStatusModel(
        zoneId: 'zona-02',
        nama: 'Permukiman Inti Desa',
        koefisien: 1.00,
        elevasi: 85,
        sblScore: localResult.crispOutputZ,
        status: AlertLevel.fromSblScore(localResult.crispOutputZ).label,
        warna: localResult.crispOutputZ > 60 ? 'Oranye' : 'Kuning',
        actionRequired: 'Pantau sempadan sungai dan amankan barang berharga.',
      ),
      ZoneStatusModel(
        zoneId: 'zona-03',
        nama: 'Bukit Harapan (Posko)',
        koefisien: 0.70,
        elevasi: 150,
        sblScore: (localResult.crispOutputZ * 0.70).clamp(0.0, 100.0),
        status: AlertLevel.fromSblScore(localResult.crispOutputZ * 0.70).label,
        warna: 'Hijau',
        actionRequired: 'Posko evakuasi siap siaga menampung warga.',
      ),
    ];

    return FloodStatusModel(
      crispOutputZ: localResult.crispOutputZ,
      statusBahaya: localResult.statusBahaya,
      zones: localZones,
      timestamp: DateTime.now(),
      fuzzyDetail: localResult,
    );
  }

  /// Memuat layer spasial GeoJSON Desa Rahong
  Future<List<FloodZone>> loadSpatialLayers() async {
    try {
      String rawJson = '';
      try {
        final response = await http
            .get(Uri.parse(ApiConstants.gisLayersEndpoint))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode == 200) {
          rawJson = response.body;
        }
      } catch (_) {}

      if (rawJson.isEmpty) {
        rawJson = await rootBundle.loadString('assets/desa_rahong.geojson');
      }

      final Map<String, dynamic> parsed = json.decode(rawJson);
      final features = parsed['features'] as List<dynamic>? ?? [];

      final List<FloodZone> zones = [];

      for (final f in features) {
        final props = f['properties'] as Map<String, dynamic>? ?? {};
        final geom = f['geometry'] as Map<String, dynamic>? ?? {};
        final type = (geom['type'] as String? ?? '').toLowerCase();
        final rawCoords = geom['coordinates'];

        List<LatLng> polygonPts = [];
        List<LatLng> polylinePts = [];
        LatLng? markerPt;

        if (type == 'polygon' && rawCoords is List) {
          final outer = rawCoords.first as List<dynamic>;
          for (final c in outer) {
            if (c is List && c.length >= 2) {
              final lon = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              polygonPts.add(LatLng(lat, lon));
            }
          }
        } else if (type == 'linestring' && rawCoords is List) {
          for (final c in rawCoords) {
            if (c is List && c.length >= 2) {
              final lon = (c[0] as num).toDouble();
              final lat = (c[1] as num).toDouble();
              polylinePts.add(LatLng(lat, lon));
            }
          }
        } else if (type == 'point' && rawCoords is List && rawCoords.length >= 2) {
          final lon = (rawCoords[0] as num).toDouble();
          final lat = (rawCoords[1] as num).toDouble();
          markerPt = LatLng(lat, lon);
        }

        zones.add(FloodZone(
          id: props['id'] as String? ?? props['nama'] as String? ?? '',
          nama: props['nama'] as String? ?? 'Zona',
          tipe: props['tipe'] as String? ?? 'zona',
          koefisien: (props['koefisien_spasial'] as num?)?.toDouble() ?? 1.0,
          elevasi: (props['elevasi'] as num?)?.toInt() ?? 0,
          deskripsi: props['deskripsi'] as String? ?? '',
          polygonPoints: polygonPts,
          polylinePoints: polylinePts,
          markerPosition: markerPt,
          kapasitas: (props['kapasitas'] as num?)?.toInt(),
        ));
      }

      return zones;
    } catch (_) {
      return [];
    }
  }
}
