class WeatherModel {
  final double temperature;
  final double humidity;
  final String description;
  final double rainfallMm;
  final double durationHours;
  final double soilMoisturePercent; // Kejenuhan tanah (0-100%)
  final double waterLevelCm; // Tinggi muka air sungai (cm)
  final DateTime timestamp;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.rainfallMm,
    required this.durationHours,
    this.soilMoisturePercent = 45.0,
    this.waterLevelCm = 65.0,
    required this.timestamp,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature_celsius'] as num?)?.toDouble() ?? 27.0,
      humidity: (json['humidity_percent'] as num?)?.toDouble() ?? 80.0,
      description: json['weather_description'] as String? ?? 'Hujan Ringan',
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      durationHours: (json['estimated_duration_hours'] as num?)?.toDouble() ?? 0.0,
      soilMoisturePercent: (json['soil_moisture_percent'] as num?)?.toDouble() ?? 45.0,
      waterLevelCm: (json['water_level_cm'] as num?)?.toDouble() ?? 65.0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
