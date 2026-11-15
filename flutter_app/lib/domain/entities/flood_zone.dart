import 'package:latlong2/latlong.dart';
import 'alert_level.dart';

/// Entity model untuk zona spasial Desa Rahong.
class FloodZone {
  final String id;
  final String nama;
  final String tipe; // zona, sungai, posko, genangan
  final double koefisien;
  final int elevasi;
  final String deskripsi;
  final double? sblScore;
  final AlertLevel? alertLevel;
  final List<LatLng> polygonPoints;
  final List<LatLng> polylinePoints;
  final LatLng? markerPosition;
  final int? kapasitas;

  const FloodZone({
    required this.id,
    required this.nama,
    required this.tipe,
    this.koefisien = 1.0,
    this.elevasi = 0,
    this.deskripsi = '',
    this.sblScore,
    this.alertLevel,
    this.polygonPoints = const [],
    this.polylinePoints = const [],
    this.markerPosition,
    this.kapasitas,
  });

  bool get isPolygon => tipe == 'zona' && polygonPoints.isNotEmpty;
  bool get isPolyline => tipe == 'sungai' && polylinePoints.isNotEmpty;
  bool get isMarker => (tipe == 'posko' || tipe == 'genangan') && markerPosition != null;

  FloodZone copyWith({
    double? sblScore,
    AlertLevel? alertLevel,
  }) {
    return FloodZone(
      id: id,
      nama: nama,
      tipe: tipe,
      koefisien: koefisien,
      elevasi: elevasi,
      deskripsi: deskripsi,
      sblScore: sblScore ?? this.sblScore,
      alertLevel: alertLevel ?? this.alertLevel,
      polygonPoints: polygonPoints,
      polylinePoints: polylinePoints,
      markerPosition: markerPosition,
      kapasitas: kapasitas,
    );
  }
}

