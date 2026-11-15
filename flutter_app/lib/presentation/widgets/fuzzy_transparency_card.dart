import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/fuzzy/mamdani_engine.dart';
import '../../domain/entities/alert_level.dart';

class FuzzyTransparencyCard extends StatelessWidget {
  final FuzzyResultDart fuzzyDetail;
  final AlertLevel alertLevel;

  const FuzzyTransparencyCard({
    super.key,
    required this.fuzzyDetail,
    required this.alertLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.royalPurpleSurface,
            AppColors.surfaceCard,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: alertLevel == AlertLevel.aman ? AppColors.borderGold : alertLevel.color.withOpacity(0.6),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.royalPurpleDeep.withOpacity(0.5),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Transparansi AI
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF581C87), Color(0xFF3B0764)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.paleGold, width: 1.2),
                ),
                child: const Icon(
                  Icons.psychology_alt_rounded,
                  color: AppColors.paleGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Mengapa Alarm Ini Berbunyi?',
                      style: TextStyle(
                        color: AppColors.paleGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Transparansi Model Sistem Pakar Fuzzy Mamdani',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: alertLevel.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: alertLevel.color, width: 1.2),
                ),
                child: Text(
                  '${alertLevel.label} (${fuzzyDetail.crispOutputZ.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    color: alertLevel.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Penjelasan Naratif dalam Bahasa Manusia
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.royalPurpleDeep.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.paleGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fuzzyDetail.ringkasanPenyebab,
                    style: const TextStyle(
                      color: AppColors.textHeader,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (fuzzyDetail.faktorKunci.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'FAKTOR PEMICU UTAMA',
              style: TextStyle(
                color: AppColors.paleGoldMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: fuzzyDetail.faktorKunci.map((faktor) {
                return Chip(
                  label: Text(faktor, style: const TextStyle(fontSize: 11, color: AppColors.textHeader)),
                  backgroundColor: AppColors.royalPurpleDeep,
                  side: const BorderSide(color: AppColors.borderGold, width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: AppColors.borderSubtle),

          // Visualisasi Derajat Keanggotaan
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text(
                'Indikator Derajat Keanggotaan (μ Membership)',
                style: TextStyle(
                  color: AppColors.paleGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'Ketuk untuk melihat kurva fuzzifikasi matematis 4 variabel',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              children: [
                const SizedBox(height: 10),
                ...fuzzyDetail.fuzzifiedInputs.map((fVar) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.royalPurpleDeep.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fVar.namaVariabel,
                              style: const TextStyle(
                                color: AppColors.textHeader,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${fVar.nilaiInput.toStringAsFixed(1)} ${fVar.satuan} (${fVar.dominantLabel})',
                              style: const TextStyle(
                                color: AppColors.paleGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...fVar.derajatKeanggotaan.entries.map((entry) {
                          final double mu = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      color: mu > 0 ? AppColors.textPrimary : AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: mu,
                                      minHeight: 6,
                                      backgroundColor: AppColors.borderSubtle,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        mu > 0.5 ? AppColors.paleGold : AppColors.royalPurpleRadiant,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 44,
                                  child: Text(
                                    'μ=${mu.toStringAsFixed(2)}',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: mu > 0 ? AppColors.paleGold : AppColors.textMuted,
                                      fontSize: 11,
                                      fontWeight: mu > 0 ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ATURAN INFERENSI YANG AKTIF',
                    style: TextStyle(
                      color: AppColors.paleGoldMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ...fuzzyDetail.firedRules.map((r) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.royalPurpleDeep,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '• ${r.ruleId}: ${r.deskripsi}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.royalPurplePrimary.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.paleGold.withOpacity(0.5)),
                          ),
                          child: Text(
                            'α = ${r.kekuatanTembak.toStringAsFixed(2)} ➔ ${r.konsekuen}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.paleGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
