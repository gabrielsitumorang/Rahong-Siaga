/// Konstanta endpoint REST API & External Services
class ApiConstants {
  // Koordinat Tengah Desa Rahong
  static const double desaRahongLat = -6.8495;
  static const double desaRahongLon = 106.7505;

  /// Base URL Backend lokal FastAPI (jika aktif)
  static const String baseUrl = 'http://10.0.2.2:8000';
  static const String weatherEndpoint = '$baseUrl/api/v1/weather/current';
  static const String floodStatusEndpoint = '$baseUrl/api/v1/flood/status';
  static const String gisLayersEndpoint = '$baseUrl/api/v1/gis/layers';

  /// Endpoint Open-Meteo Real-Time (100% Gratis, Tanpa API Key)
  /// Mengambil presipitasi, intensitas hujan (mm), kelembapan, suhu, dan data per-jam untuk menghitung durasi hujan.
  static String get openMeteoUrl =>
      'https://api.open-meteo.com/v1/forecast?latitude=$desaRahongLat&longitude=$desaRahongLon&current=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,soil_moisture_0_to_1cm&hourly=precipitation,rain&past_hours=12&forecast_hours=1&timezone=Asia%2FJakarta';
}
