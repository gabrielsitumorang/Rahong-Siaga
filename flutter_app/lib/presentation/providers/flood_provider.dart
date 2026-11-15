import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../core/fuzzy/mamdani_engine.dart';
import '../../core/utils/notification_helper.dart';
import '../../core/utils/point_in_polygon.dart';
import '../../data/models/flood_status_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/repositories/flood_repository.dart';
import '../../domain/entities/alert_level.dart';
import '../../domain/entities/flood_zone.dart';

class FloodProvider extends ChangeNotifier {
  final FloodRepository _repository = FloodRepository();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  FloodStatusModel? _floodStatus;
  FloodStatusModel? get floodStatus => _floodStatus;

  FuzzyResultDart? get fuzzyDetail => _floodStatus?.fuzzyDetail;

  List<FloodZone> _zones = [];
  List<FloodZone> get zones => _zones;

  AlertLevel _highestAlert = AlertLevel.aman;
  AlertLevel get highestAlert => _highestAlert;

  String _worstZoneName = '';
  String get worstZoneName => _worstZoneName;

  LatLng? _userLocation;
  LatLng? get userLocation => _userLocation;

  bool _isUserInDanger = false;
  bool get isUserInDanger => _isUserInDanger;

  String? _dangerZoneName;
  String? get dangerZoneName => _dangerZoneName;

  Timer? _refreshTimer;

  // Nilai aktif saat ini (bisa dari realtime atau simulasi)
  double _activeCurah = 0.0;
  double _activeDurasi = 0.0;
  double _activeSoil = 45.0;
  double _activeTma = 65.0;

  double get activeCurah => _activeCurah;
  double get activeDurasi => _activeDurasi;
  double get activeSoil => _activeSoil;
  double get activeTma => _activeTma;

  FloodProvider() {
    init();
  }

  Future<void> init() async {
    await refreshData();
    // Auto refresh tiap 10 menit
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      refreshData();
    });
  }

  Future<void> refreshData({
    double? curahHujan,
    double? durasiHujan,
    double? kejenuhanTanah,
    double? tinggiMukaAir,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ambil data cuaca realtime dari Open-Meteo
      final weather = await _repository.fetchCurrentWeather();
      _weather = weather;

      // 2. Tentukan input yang digunakan (override simulasi atau realtime)
      _activeCurah = curahHujan ?? weather.rainfallMm;
      _activeDurasi = durasiHujan ?? weather.durationHours;
      _activeSoil = kejenuhanTanah ?? weather.soilMoisturePercent;
      _activeTma = tinggiMukaAir ?? weather.waterLevelCm;

      // 3. Evaluasi risiko banjir Fuzzy Mamdani 4 Variabel & SBL
      final floodStatus = await _repository.fetchFloodStatus(
        curahHujan: _activeCurah,
        durasiHujan: _activeDurasi,
        kejenuhanTanah: _activeSoil,
        tinggiMukaAir: _activeTma,
      );
      _floodStatus = floodStatus;

      // 4. Muat layer spasial GeoJSON jika belum ada
      final rawZones = _zones.isEmpty ? await _repository.loadSpatialLayers() : _zones;

      // 5. Sinkronkan Skor SBL dengan poligon layer
      _syncZonesWithStatus(rawZones, floodStatus);
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void _syncZonesWithStatus(List<FloodZone> rawZones, FloodStatusModel status) {
    AlertLevel maxAlert = AlertLevel.aman;
    String worstName = '';

    final statusMap = {
      for (var z in status.zones) z.nama.toLowerCase(): z
    };

    _zones = rawZones.map((zone) {
      if (zone.isPolygon) {
        final match = statusMap[zone.nama.toLowerCase()];
        if (match != null) {
          final level = AlertLevel.fromSblScore(match.sblScore);
          if (level.index > maxAlert.index) {
            maxAlert = level;
            worstName = zone.nama;
          }
          return zone.copyWith(
            sblScore: match.sblScore,
            alertLevel: level,
          );
        }
      }
      return zone;
    }).toList();

    _highestAlert = maxAlert;
    _worstZoneName = worstName;

    // Trigger local push notification jika Siaga/Awas
    if (_highestAlert == AlertLevel.siaga || _highestAlert == AlertLevel.awas) {
      NotificationHelper.showEmergencyNotification(
        title: _highestAlert == AlertLevel.awas
            ? '🚨 PERINGATAN DARURAT: BANJIR (AWAS)!'
            : '⚠️ PERINGATAN: STATUS SIAGA BANJIR',
        body: 'Zona $_worstZoneName terancam bahaya banjir. Harap siaga dan pantau jalur evakuasi.',
        isEmergency: _highestAlert == AlertLevel.awas,
      );
    }

    _checkUserGeofence();
  }

  void updateUserLocation(LatLng location) {
    _userLocation = location;
    _checkUserGeofence();
    notifyListeners();
  }

  void _checkUserGeofence() {
    if (_userLocation == null) return;

    final dangerPolygons = _zones.where(
      (z) => z.isPolygon && (z.alertLevel == AlertLevel.siaga || z.alertLevel == AlertLevel.awas),
    );

    bool inside = false;
    String? name;

    for (final dp in dangerPolygons) {
      if (PointInPolygon.isInside(_userLocation!, dp.polygonPoints)) {
        inside = true;
        name = dp.nama;
        break;
      }
    }

    _isUserInDanger = inside;
    _dangerZoneName = name;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
