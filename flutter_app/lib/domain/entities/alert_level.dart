import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Enum representasi tingkat bahaya banjir.
enum AlertLevel {
  aman('Aman', AppColors.statusAman),
  waspada('Waspada', AppColors.statusWaspada),
  siaga('Siaga', AppColors.statusSiaga),
  awas('Awas / Evakuasi', AppColors.statusAwas);

  final String label;
  final Color color;

  const AlertLevel(this.label, this.color);

  /// Menentukan AlertLevel berdasarkan Skor Bahaya Lokal (SBL).
  static AlertLevel fromSblScore(double score) {
    if (score > 80.0) return AlertLevel.awas;
    if (score > 60.0) return AlertLevel.siaga;
    if (score > 35.0) return AlertLevel.waspada;
    return AlertLevel.aman;
  }

  /// Menentukan AlertLevel dari string status.
  static AlertLevel fromString(String status) {
    switch (status.toLowerCase().trim()) {
      case 'awas':
      case 'awas / evakuasi':
      case 'evakuasi':
        return AlertLevel.awas;
      case 'siaga':
        return AlertLevel.siaga;
      case 'waspada':
        return AlertLevel.waspada;
      default:
        return AlertLevel.aman;
    }
  }
}

