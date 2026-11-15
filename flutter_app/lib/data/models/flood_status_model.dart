import '../../core/fuzzy/mamdani_engine.dart';
import '../../domain/entities/alert_level.dart';

class ZoneStatusModel {
  final String zoneId;
  final String nama;
  final double koefisien;
  final int elevasi;
  final double sblScore;
  final String status;
  final String warna;
  final String actionRequired;

  ZoneStatusModel({
    required this.zoneId,
    required this.nama,
    required this.koefisien,
    required this.elevasi,
    required this.sblScore,
    required this.status,
    required this.warna,
    required this.actionRequired,
  });

  factory ZoneStatusModel.fromJson(Map<String, dynamic> json) {
    return ZoneStatusModel(
      zoneId: json['zone_id'] as String? ?? '',
      nama: json['zone_name'] as String? ?? (json['nama'] as String? ?? ''),
      koefisien: (json['koefisien_spasial'] as num?)?.toDouble() ??
          (json['koefisien'] as num?)?.toDouble() ?? 1.0,
      elevasi: (json['elevasi'] as num?)?.toInt() ?? 0,
      sblScore: (json['sbl_score'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'Aman',
      warna: json['warna'] as String? ?? 'Hijau',
      actionRequired: json['action_required'] as String? ?? '',
    );
  }
}

class FloodStatusModel {
  final double crispOutputZ;
  final String statusBahaya;
  final List<ZoneStatusModel> zones;
  final DateTime timestamp;
  final FuzzyResultDart? fuzzyDetail; // Detail transparansi AI Fuzzy

  FloodStatusModel({
    required this.crispOutputZ,
    required this.statusBahaya,
    required this.zones,
    required this.timestamp,
    this.fuzzyDetail,
  });

  AlertLevel get alertLevel => AlertLevel.fromString(statusBahaya);

  factory FloodStatusModel.fromJson(Map<String, dynamic> json, {FuzzyResultDart? fuzzyDetail}) {
    final fuzzy = json['fuzzy_result'] as Map<String, dynamic>? ??
        json['fuzzy_global'] as Map<String, dynamic>? ??
        {};

    final rawZones = (json['zone_statuses'] as List<dynamic>?) ??
        (json['zones'] as List<dynamic>?) ??
        [];

    return FloodStatusModel(
      crispOutputZ: (fuzzy['crisp_output_z'] as num?)?.toDouble() ?? 0.0,
      statusBahaya: fuzzy['status_bahaya'] as String? ?? 'Aman',
      zones: rawZones.map((z) => ZoneStatusModel.fromJson(z as Map<String, dynamic>)).toList(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      fuzzyDetail: fuzzyDetail,
    );
  }
}
