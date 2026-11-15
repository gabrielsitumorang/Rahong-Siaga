import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/alert_level.dart';
import '../providers/flood_provider.dart';
import '../widgets/alert_banner.dart';
import '../widgets/fuzzy_transparency_card.dart';
import '../widgets/status_metric_card.dart';
import '../widgets/zone_status_tile.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onNavigateToMap;
  final VoidCallback onNavigateToSimulator;

  const DashboardScreen({
    super.key,
    required this.onNavigateToMap,
    required this.onNavigateToSimulator,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.royalPurpleDeep,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Sistem Komando Peringatan Dini',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.paleGold,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'Desa Rahong, Cianjur — Intelligence Fuzzy System',
              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.paleGold, size: 22),
            tooltip: 'Simulasi What-If',
            onPressed: onNavigateToSimulator,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textHeader, size: 22),
            tooltip: 'Segarkan Data',
            onPressed: () => context.read<FloodProvider>().refreshData(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Consumer<FloodProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.floodStatus == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.paleGold));
            }

            final weather = provider.weather;
            final flood = provider.floodStatus;
            final fuzzyDetail = provider.fuzzyDetail;

            return RefreshIndicator(
              color: AppColors.paleGold,
              backgroundColor: AppColors.royalPurpleSurface,
              onRefresh: () => provider.refreshData(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  // 1. Emergency Alert Banner (Siaga / Awas)
                  AlertBanner(
                    level: provider.highestAlert,
                    affectedZone: provider.worstZoneName,
                    onEvacuatePressed: onNavigateToMap,
                  ),

                  // 2. Sensor Lingkungan Section (4 Variabel Input)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PARAMETER SENSOR LINGKUNGAN',
                        style: TextStyle(
                          color: AppColors.paleGoldMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.midnightNavy,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.oceanicBlue.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppColors.statusAman,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              weather?.description.split('(').first.trim() ?? 'Real-Time',
                              style: const TextStyle(color: AppColors.riverCyan, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Baris 1: Curah Hujan & Durasi Hujan
                  Row(
                    children: [
                      Expanded(
                        child: StatusMetricCard(
                          title: 'Curah Hujan',
                          value: '${provider.activeCurah.toStringAsFixed(1)} mm/j',
                          subtitle: 'Intensitas presipitasi',
                          indicatorColor: AppColors.riverCyan,
                          icon: Icons.water_drop_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatusMetricCard(
                          title: 'Durasi Hujan',
                          value: '${provider.activeDurasi.toStringAsFixed(1)} Jam',
                          subtitle: 'Akumulasi waktu',
                          indicatorColor: AppColors.paleGold,
                          icon: Icons.timer_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Baris 2: Kondisi Kejenuhan Tanah & Ketinggian Muka Air Sungai (TMA)
                  Row(
                    children: [
                      Expanded(
                        child: StatusMetricCard(
                          title: 'Kejenuhan Tanah',
                          value: '${provider.activeSoil.toStringAsFixed(0)}%',
                          subtitle: provider.activeSoil > 70 ? 'Jenuh (Limpasan Cepat)' : 'Daya Serap Baik',
                          indicatorColor: provider.activeSoil > 70 ? AppColors.statusAwas : const Color(0xFFD4A373),
                          icon: Icons.terrain_outlined,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatusMetricCard(
                          title: 'Tinggi Muka Air',
                          value: '${provider.activeTma.toStringAsFixed(0)} cm',
                          subtitle: provider.activeTma > 140 ? 'Bibir Tanggul Kritis' : 'Normal / Terkendali',
                          indicatorColor: provider.activeTma > 140 ? AppColors.statusAwas : AppColors.oceanicBlue,
                          icon: Icons.waves_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // 3. Hero Status Probabilitas Bahaya Global (Crisp Z*)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.royalPurplePrimary,
                          AppColors.royalPurpleDeep,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.paleGold.withOpacity(0.4), width: 1.3),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.royalPurpleGlow,
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.royalPurpleDeep,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.paleGold, width: 1.3),
                          ),
                          child: Icon(
                            Icons.insights_rounded,
                            color: flood?.alertLevel.color ?? AppColors.statusAman,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PROBABILITAS BAHAYA GLOBAL (CRISP Z*)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.paleGoldMuted,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '${flood?.crispOutputZ.toStringAsFixed(1) ?? '0.0'}%',
                                  style: TextStyle(
                                    color: flood?.alertLevel.color ?? AppColors.statusAman,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Text(
                                'Status: ${flood?.statusBahaya ?? 'Aman'} (Defuzzifikasi Centroid COA 200 Step)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Panel Transparansi Penilaian Risiko ("Mengapa Alarm Ini Berbunyi?")
                  if (fuzzyDetail != null)
                    FuzzyTransparencyCard(
                      fuzzyDetail: fuzzyDetail,
                      alertLevel: flood?.alertLevel ?? AlertLevel.aman,
                    ),

                  const SizedBox(height: 18),

                  // 5. Per-zone SBL list
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ZONASI TOPOGRAFI WILAYAH (SBL)',
                        style: TextStyle(
                          color: AppColors.paleGoldMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onNavigateToMap,
                        icon: const Icon(Icons.map_rounded, size: 14, color: AppColors.paleGold),
                        label: const Text(
                          'Peta GIS',
                          style: TextStyle(color: AppColors.paleGold, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (flood != null)
                    ...flood.zones.map(
                      (z) => ZoneStatusTile(
                        nama: z.nama,
                        sblScore: z.sblScore,
                        level: AlertLevel.fromSblScore(z.sblScore),
                        koefisien: z.koefisien,
                        elevasi: z.elevasi,
                        onTap: onNavigateToMap,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Action Navigation Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onNavigateToMap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.royalPurplePrimary,
                            foregroundColor: AppColors.paleGold,
                            elevation: 3,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AppColors.paleGoldMuted, width: 1),
                            ),
                          ),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('PETA SPASIAL', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: 11.5)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onNavigateToSimulator,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.royalPurpleDeep,
                            foregroundColor: AppColors.paleGold,
                            side: const BorderSide(color: AppColors.borderGold, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 18),
                          label: const Text('SIMULASI WHAT-IF', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: 11.5)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
