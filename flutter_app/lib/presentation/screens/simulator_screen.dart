import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/fuzzy/mamdani_engine.dart';
import '../../domain/entities/alert_level.dart';
import '../providers/flood_provider.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  double _curah = 45.0;
  double _durasi = 3.0;
  double _soil = 75.0;
  double _tma = 110.0;

  // Preset Skenario Cepat untuk Admin Desa
  final List<Map<String, dynamic>> _presets = [
    {
      'nama': '1. Cuaca Normal & Air Terkendali',
      'icon': Icons.wb_sunny_rounded,
      'color': AppColors.statusAman,
      'curah': 10.0,
      'durasi': 1.0,
      'soil': 30.0,
      'tma': 50.0,
      'ket': 'Presipitasi rintik singkat, daya serap tanah perbukitan optimal.',
    },
    {
      'nama': '2. Tanah Jenuh + Hujan Sedang',
      'icon': Icons.grain_rounded,
      'color': AppColors.statusWaspada,
      'curah': 40.0,
      'durasi': 3.0,
      'soil': 85.0,
      'tma': 85.0,
      'ket': 'Tanah hulu jenuh air dari hari sebelumnya. Air hujan langsung jadi limpasan sungai.',
    },
    {
      'nama': '3. Banjir Kiriman Hulu (TMA Kritis)',
      'icon': Icons.waves_rounded,
      'color': AppColors.statusSiaga,
      'curah': 25.0,
      'durasi': 2.0,
      'soil': 70.0,
      'tma': 165.0,
      'ket': 'Hujan lokal ringan namun Sungai Rahong meluap akibat debit air hulu Citarum.',
    },
    {
      'nama': '4. Badai Ekstrem Siklon (Awas Total)',
      'icon': Icons.thunderstorm_rounded,
      'color': AppColors.statusAwas,
      'curah': 110.0,
      'durasi': 7.5,
      'soil': 95.0,
      'tma': 210.0,
      'ket': 'Kondisi bencana darurat: Hujan lebat, tanah jenuh total, dan sungai meluap ke permukiman.',
    },
  ];

  void _applyPreset(Map<String, dynamic> p) {
    setState(() {
      _curah = p['curah'] as double;
      _durasi = p['durasi'] as double;
      _soil = p['soil'] as double;
      _tma = p['tma'] as double;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Evaluasi langsung di layar simulator menggunakan mesin Fuzzy Mamdani
    final simResult = MamdaniFuzzyEngine.compute(
      curahInput: _curah,
      durasiInput: _durasi,
      soilMoistureInput: _soil,
      tmaInput: _tma,
    );

    final simAlert = AlertLevel.fromString(simResult.statusBahaya);

    // Hitung SBL per zona
    final sblBantaran = (simResult.crispOutputZ * 1.25).clamp(0.0, 100.0);
    final sblPermukiman = simResult.crispOutputZ.clamp(0.0, 100.0);
    final sblPosko = (simResult.crispOutputZ * 0.70).clamp(0.0, 100.0);

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.royalPurpleDeep,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Simulasi Skenario "What-If"',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: AppColors.paleGold,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'Modul Pengujian Kebijakan & Kalibrasi Aturan Fuzzy',
              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          children: [
            // Banner Output Simulasi Real-Time
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.royalPurpleSurface,
                    AppColors.surfaceCard,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: simAlert.color.withOpacity(0.8), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: simAlert.color.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PREDIKSI PROBABILITAS BAHAYA',
                              style: TextStyle(
                                color: AppColors.paleGoldMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${simAlert.label.toUpperCase()} (${simResult.crispOutputZ.toStringAsFixed(1)}%)',
                                style: TextStyle(
                                  color: simAlert.color,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: simAlert.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: simAlert.color.withOpacity(0.6), width: 1.3),
                        ),
                        child: Icon(
                          simAlert == AlertLevel.awas ? Icons.warning_rounded : Icons.shield_rounded,
                          color: simAlert.color,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.royalPurpleDeep,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Text(
                      simResult.ringkasanPenyebab,
                      style: const TextStyle(color: AppColors.textHeader, fontSize: 11.5, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.borderSubtle),
                  const SizedBox(height: 6),

                  // Estimasi SBL per zona
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildZoneChip('Bantaran (K=1.25)', sblBantaran),
                      _buildZoneChip('Permukiman (K=1.0)', sblPermukiman),
                      _buildZoneChip('Posko (K=0.70)', sblPosko),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Tombol Sinkronkan ke Sistem Utama
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<FloodProvider>().refreshData(
                            curahHujan: _curah,
                            durasiHujan: _durasi,
                            kejenuhanTanah: _soil,
                            tinggiMukaAir: _tma,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Skenario berhasil disinkronkan ke Peta & Dashboard! Status: ${simAlert.label}'),
                          backgroundColor: AppColors.royalPurplePrimary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalPurplePrimary,
                      foregroundColor: AppColors.paleGold,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.paleGoldMuted, width: 1),
                      ),
                    ),
                    icon: const Icon(Icons.sync_rounded, color: AppColors.paleGold, size: 18),
                    label: const Text('TERAPKAN KE PETA & DASHBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5, fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.royalPurpleDeep,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.restart_alt_rounded, color: AppColors.paleGold, size: 20),
                    tooltip: 'Kembali ke Cuaca Realtime Open-Meteo',
                    onPressed: () {
                      context.read<FloodProvider>().refreshData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kembali ke pemantauan cuaca realtime Open-Meteo.')),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Preset Skenario Cepat
            const Text(
              'PRESET SKENARIO CEPAT (ADMIN BPBD)',
              style: TextStyle(
                color: AppColors.paleGoldMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),
            ..._presets.map((preset) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  onTap: () => _applyPreset(preset),
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (preset['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: (preset['color'] as Color).withOpacity(0.5)),
                    ),
                    child: Icon(preset['icon'] as IconData, color: preset['color'] as Color, size: 18),
                  ),
                  title: Text(
                    preset['nama'] as String,
                    style: const TextStyle(color: AppColors.textHeader, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  subtitle: Text(
                    preset['ket'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.paleGold, size: 12),
                ),
              );
            }),

            const SizedBox(height: 18),

            // Sliders Kustom 4 Variabel
            const Text(
              'PENGATURAN PARAMETER KUSTOM',
              style: TextStyle(
                color: AppColors.paleGoldMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),

            // Slider 1: Curah Hujan
            _buildSlider(
              title: '1. Curah Hujan (Presipitasi)',
              value: _curah,
              satuan: 'mm/jam',
              min: 0,
              max: 150,
              divisions: 30,
              color: AppColors.riverCyan,
              onChanged: (val) => setState(() => _curah = val),
            ),

            // Slider 2: Durasi Hujan
            _buildSlider(
              title: '2. Durasi Hujan Kumulatif',
              value: _durasi,
              satuan: 'Jam',
              min: 0,
              max: 12,
              divisions: 24,
              color: AppColors.paleGold,
              onChanged: (val) => setState(() => _durasi = val),
            ),

            // Slider 3: Kejenuhan Tanah
            _buildSlider(
              title: '3. Kejenuhan Tanah Perbukitan Hulu',
              value: _soil,
              satuan: '%',
              min: 0,
              max: 100,
              divisions: 20,
              color: const Color(0xFFD4A373),
              onChanged: (val) => setState(() => _soil = val),
            ),

            // Slider 4: Tinggi Muka Air
            _buildSlider(
              title: '4. Ketinggian Muka Air Sungai (TMA)',
              value: _tma,
              satuan: 'cm',
              min: 0,
              max: 250,
              divisions: 25,
              color: AppColors.oceanicBlue,
              onChanged: (val) => setState(() => _tma = val),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneChip(String nama, double sbl) {
    final alert = AlertLevel.fromSblScore(sbl);
    return Column(
      children: [
        Text(
          nama,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: alert.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: alert.color, width: 1),
          ),
          child: Text(
            '${sbl.toStringAsFixed(1)} (${alert.label})',
            style: TextStyle(color: alert.color, fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required String satuan,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textHeader, fontSize: 12, fontWeight: FontWeight.w700)),
              Text(
                '${value.toStringAsFixed(1)} $satuan',
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: AppColors.royalPurpleDeep,
              thumbColor: AppColors.paleGold,
              overlayColor: color.withOpacity(0.2),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
