import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/alert_level.dart';

class ZoneStatusTile extends StatelessWidget {
  final String nama;
  final double sblScore;
  final AlertLevel level;
  final double koefisien;
  final int elevasi;
  final VoidCallback? onTap;

  const ZoneStatusTile({
    super.key,
    required this.nama,
    required this.sblScore,
    required this.level,
    required this.koefisien,
    required this.elevasi,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: level == AlertLevel.awas ? AppColors.statusAwas.withOpacity(0.5) : AppColors.borderSubtle,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.royalPurpleRadiant.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Glowing indicator dot with outer ring
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: level.color.withOpacity(0.5), width: 1.5),
                  ),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: level.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: level.color.withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          color: AppColors.textHeader,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'Koefisien: ${koefisien.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: AppColors.paleGoldMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•  Elevasi: ${elevasi}m dpl',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: level.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: level.color.withOpacity(0.7), width: 1.2),
                  ),
                  child: Text(
                    '${level.label} (${sblScore.toStringAsFixed(1)})',
                    style: TextStyle(
                      color: level.color,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
