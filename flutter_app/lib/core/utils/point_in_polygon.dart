import 'package:latlong2/latlong.dart';

/// Algoritma Ray-Casting (Jordan Curve Theorem) untuk geofencing lokasi bahaya.
class PointInPolygon {
  /// Memeriksa apakah [point] pengguna berada di dalam [polygon].
  static bool isInside(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    bool inside = false;
    final double x = point.longitude;
    final double y = point.latitude;

    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      final double xi = polygon[i].longitude;
      final double yi = polygon[i].latitude;
      final double xj = polygon[j].longitude;
      final double yj = polygon[j].latitude;

      final bool intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

      if (intersect) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }
}

