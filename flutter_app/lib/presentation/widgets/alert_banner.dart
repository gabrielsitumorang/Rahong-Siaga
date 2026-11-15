import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/alert_level.dart';

class AlertBanner extends StatelessWidget {
  final AlertLevel level;
  final String affectedZone;
  final VoidCallback? onEvacuatePressed;

  const AlertBanner({
    super.key,
    required this.level,
    required this.affectedZone,
    this.onEvacuatePressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEmergency = level == AlertLevel.siaga || level == AlertLevel.awas;
    if (!isEmergency) return const SizedBox.shrink();

    final bool isAwas = level == AlertLevel.awas;
    final List<Color> gradientColors = isAwas
        ? [const Color(0xFF881337), const Color(0xFF4C0519), AppColors.royalPurpleDeep]
        : [const Color(0xFF7C2D12), const Color(0xFF431407), AppColors.royalPurpleDeep];

    final Color accentColor = isAwas ? AppColors.statusAwas : AppColors.statusSiaga;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.paleGold.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.paleGold.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.paleGold, width: 1.5),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.paleGold, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAwas ? 'KOMANDO DARURAT: STATUS AWAS' : 'PERINGATAN SIAGA AKTIF',
                      style: const TextStyle(
                        color: AppColors.paleGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'Sektor Terdampak: $affectedZone',
                      style: const TextStyle(
                        color: AppColors.textHeader,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.royalPurpleDeep,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor, width: 1.2),
                ),
                child: Text(
                  level.label.toUpperCase(),
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isAwas
                ? 'Potensi bahaya luapan Sungai Rahong telah mencapai ambang batas kritis. Warga bantaran sungai diwajibkan segera evakuasi ke Posko Balai Desa.'
                : 'Intensitas air hulu meningkat signifikan. Petugas dan warga diimbau siaga serta amankan dokumen penting.',
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.9),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (isAwas && onEvacuatePressed != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEvacuatePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.paleGold,
                  foregroundColor: AppColors.royalPurpleDeep,
                  elevation: 4,
                  shadowColor: AppColors.paleGold.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                icon: const Icon(Icons.navigation_rounded, size: 20),
                label: const Text(
                  'BUKA RUTE & POSKO EVAKUASI RESMI',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
