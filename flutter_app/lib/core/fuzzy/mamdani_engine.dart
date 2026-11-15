import 'dart:math' as math;

/// Detail derajat keanggotaan per himpunan linguistik
class FuzzifiedVariable {
  final String namaVariabel;
  final double nilaiInput;
  final String satuan;
  final Map<String, double> derajatKeanggotaan;

  const FuzzifiedVariable({
    required this.namaVariabel,
    required this.nilaiInput,
    required this.satuan,
    required this.derajatKeanggotaan,
  });

  /// Mengambil label linguistik dengan derajat keanggotaan tertinggi
  String get dominantLabel {
    String maxLabel = '-';
    double maxVal = -1;
    derajatKeanggotaan.forEach((label, val) {
      if (val > maxVal) {
        maxVal = val;
        maxLabel = label;
      }
    });
    return maxLabel;
  }
}

/// Aturan yang terpicu beserta detail kontribusinya
class FiredRuleDetail {
  final String ruleId;
  final String deskripsi;
  final double kekuatanTembak; // Firing Strength (alpha)
  final String konsekuen; // Aman, Waspada, Siaga, Awas

  const FiredRuleDetail({
    required this.ruleId,
    required this.deskripsi,
    required this.kekuatanTembak,
    required this.konsekuen,
  });
}

/// Hasil evaluasi inferensi Fuzzy Mamdani terperinci (Explainable AI)
class FuzzyResultDart {
  final double curahHujan;
  final double durasiHujan;
  final double kejenuhanTanah; // %
  final double tinggiMukaAir; // cm
  final double crispOutputZ; // 0 - 100%
  final String statusBahaya; // Aman, Waspada, Siaga, Awas
  final List<FiredRuleDetail> firedRules;
  final List<FuzzifiedVariable> fuzzifiedInputs;
  final String ringkasanPenyebab; // "Mengapa alarm ini berbunyi?"
  final List<String> faktorKunci;

  const FuzzyResultDart({
    required this.curahHujan,
    required this.durasiHujan,
    required this.kejenuhanTanah,
    required this.tinggiMukaAir,
    required this.crispOutputZ,
    required this.statusBahaya,
    required this.firedRules,
    required this.fuzzifiedInputs,
    required this.ringkasanPenyebab,
    required this.faktorKunci,
  });
}

/// Mesin Inferensi Fuzzy Mamdani Multi-Input 4 Variabel
/// Disesuaikan dengan karakteristik geografis sempadan sungai & perbukitan Desa Rahong, Cianjur
class MamdaniFuzzyEngine {
  // Fungsi Keanggotaan Trapesium
  static double trapezoid(double x, double a, double b, double c, double d) {
    if (x <= a || x >= d) return 0.0;
    if (a < x && x < b) return b != a ? (x - a) / (b - a) : 1.0;
    if (b <= x && x <= c) return 1.0;
    if (c < x && x < d) return d != c ? (d - x) / (d - c) : 1.0;
    return 0.0;
  }

  // Fungsi Keanggotaan Segitiga
  static double triangle(double x, double a, double b, double c) {
    if (x <= a || x >= c) return 0.0;
    if (a < x && x <= b) return b != a ? (x - a) / (b - a) : 1.0;
    if (b < x && x < c) return c != b ? (c - x) / (c - b) : 1.0;
    return 0.0;
  }

  // 1. Curah Hujan (mm/jam): [0 - 150]
  static double curahRendah(double x) => trapezoid(x, 0, 0, 10, 25);
  static double curahSedang(double x) => triangle(x, 15, 35, 55);
  static double curahLebat(double x) => triangle(x, 45, 75, 105);
  static double curahSangatLebat(double x) => trapezoid(x, 90, 120, 150, 150);

  // 2. Durasi Hujan (Jam): [0 - 12]
  static double durasiSingkat(double x) => trapezoid(x, 0, 0, 1, 3);
  static double durasiSedang(double x) => triangle(x, 2, 4, 6);
  static double durasiLama(double x) => trapezoid(x, 5, 7, 12, 12);

  // 3. Kejenuhan Tanah / Akumulasi Hulu (%): [0 - 100]
  // Karakteristik tanah lempung Rahong: >70% daya serap air anjlok drastis
  static double tanahKering(double x) => trapezoid(x, 0, 0, 25, 45);
  static double tanahLembab(double x) => triangle(x, 35, 55, 75);
  static double tanahJenuh(double x) => trapezoid(x, 65, 80, 100, 100);

  // 4. Tinggi Muka Air Sungai Rahong (cm): [0 - 250 cm]
  // Sensor TMA: Normal < 90cm, Rawan 90-150cm, Meluap > 150cm
  static double tmaNormal(double x) => trapezoid(x, 0, 0, 60, 90);
  static double tmaRawan(double x) => triangle(x, 75, 120, 160);
  static double tmaKritis(double x) => trapezoid(x, 140, 180, 250, 250);

  // Output: Status Bahaya (%) [0 - 100]
  static double muAman(double z) => trapezoid(z, 0, 0, 20, 35);
  static double muWaspada(double z) => triangle(z, 25, 45, 60);
  static double muSiaga(double z) => triangle(z, 50, 65, 80);
  static double muAwas(double z) => trapezoid(z, 70, 85, 100, 100);

  static double getMuConsequent(String label, double z) {
    switch (label) {
      case 'Aman':
        return muAman(z);
      case 'Waspada':
        return muWaspada(z);
      case 'Siaga':
        return muSiaga(z);
      case 'Awas':
        return muAwas(z);
      default:
        return 0.0;
    }
  }

  /// Eksekusi Pipeline Fuzzy Mamdani Lengkap 4 Variabel
  static FuzzyResultDart compute({
    required double curahInput,
    required double durasiInput,
    double soilMoistureInput = 45.0, // Default tanah sedang
    double tmaInput = 60.0, // Default TMA normal
  }) {
    final curah = curahInput.clamp(0.0, 150.0);
    final durasi = durasiInput.clamp(0.0, 12.0);
    final soil = soilMoistureInput.clamp(0.0, 100.0);
    final tma = tmaInput.clamp(0.0, 250.0);

    // 1. Fuzzifikasi Seluruh Variabel
    final fCurah = {
      'Rendah': curahRendah(curah),
      'Sedang': curahSedang(curah),
      'Lebat': curahLebat(curah),
      'Sangat Lebat': curahSangatLebat(curah),
    };

    final fDurasi = {
      'Singkat': durasiSingkat(durasi),
      'Sedang': durasiSedang(durasi),
      'Lama': durasiLama(durasi),
    };

    final fSoil = {
      'Kering': tanahKering(soil),
      'Lembab': tanahLembab(soil),
      'Jenuh': tanahJenuh(soil),
    };

    final fTma = {
      'Normal': tmaNormal(tma),
      'Rawan': tmaRawan(tma),
      'Kritis': tmaKritis(tma),
    };

    final fuzzifiedList = [
      FuzzifiedVariable(
        namaVariabel: 'Curah Hujan',
        nilaiInput: curah,
        satuan: 'mm/jam',
        derajatKeanggotaan: fCurah,
      ),
      FuzzifiedVariable(
        namaVariabel: 'Durasi Hujan',
        nilaiInput: durasi,
        satuan: 'Jam',
        derajatKeanggotaan: fDurasi,
      ),
      FuzzifiedVariable(
        namaVariabel: 'Kejenuhan Tanah',
        nilaiInput: soil,
        satuan: '%',
        derajatKeanggotaan: fSoil,
      ),
      FuzzifiedVariable(
        namaVariabel: 'Tinggi Muka Air (TMA)',
        nilaiInput: tma,
        satuan: 'cm',
        derajatKeanggotaan: fTma,
      ),
    ];

    // 2. Evaluasi Matriks Aturan (Rule Base Diperkaya)
    // Pengaruh tanah jenuh & TMA kritis dapat mengeskalasi tingkat bahaya
    final firedRules = <FiredRuleDetail>[];

    void addRule(String id, String desc, double strength, String out) {
      if (strength > 0.001) {
        firedRules.add(FiredRuleDetail(
          ruleId: id,
          deskripsi: desc,
          kekuatanTembak: strength,
          konsekuen: out,
        ));
      }
    }

    // --- Aturan Primer (Curah Hujan & Durasi) ---
    addRule('R1', 'Curah Rendah & Durasi Singkat',
        math.min(fCurah['Rendah']!, fDurasi['Singkat']!), 'Aman');
    addRule('R2', 'Curah Rendah & Durasi Sedang',
        math.min(fCurah['Rendah']!, fDurasi['Sedang']!), 'Aman');
    addRule('R3', 'Curah Rendah & Durasi Lama',
        math.min(fCurah['Rendah']!, fDurasi['Lama']!), 'Waspada');
    addRule('R4', 'Curah Sedang & Durasi Singkat',
        math.min(fCurah['Sedang']!, fDurasi['Singkat']!), 'Aman');
    addRule('R5', 'Curah Sedang & Durasi Sedang',
        math.min(fCurah['Sedang']!, fDurasi['Sedang']!), 'Waspada');
    addRule('R6', 'Curah Sedang & Durasi Lama',
        math.min(fCurah['Sedang']!, fDurasi['Lama']!), 'Siaga');
    addRule('R7', 'Curah Lebat & Durasi Singkat',
        math.min(fCurah['Lebat']!, fDurasi['Singkat']!), 'Waspada');
    addRule('R8', 'Curah Lebat & Durasi Sedang',
        math.min(fCurah['Lebat']!, fDurasi['Sedang']!), 'Siaga');
    addRule('R9', 'Curah Lebat & Durasi Lama',
        math.min(fCurah['Lebat']!, fDurasi['Lama']!), 'Awas');
    addRule('R10', 'Curah Sangat Lebat & Durasi Singkat',
        math.min(fCurah['Sangat Lebat']!, fDurasi['Singkat']!), 'Siaga');
    addRule('R11', 'Curah Sangat Lebat & Durasi Sedang',
        math.min(fCurah['Sangat Lebat']!, fDurasi['Sedang']!), 'Awas');
    addRule('R12', 'Curah Sangat Lebat & Durasi Lama',
        math.min(fCurah['Sangat Lebat']!, fDurasi['Lama']!), 'Awas');

    // --- Aturan Eskalasi Geografis Rahong (Kondisi Tanah & TMA Sungai) ---
    // Rule E1: Tanah Jenuh + Curah Sedang -> Eskalasi ke Siaga (Limpasan air cepat)
    final e1Strength = math.min(fSoil['Jenuh']!, fCurah['Sedang']!);
    addRule('E1', 'Tanah Hulu Jenuh & Hujan Sedang (Infiltrasi Nol)', e1Strength, 'Siaga');

    // Rule E2: Tanah Jenuh + Curah Lebat -> Eskalasi ke Awas
    final e2Strength = math.min(fSoil['Jenuh']!, fCurah['Lebat']!);
    addRule('E2', 'Tanah Hulu Jenuh & Hujan Lebat (Banjir Limpasan Cepat)', e2Strength, 'Awas');

    // Rule E3: Sungai Kritis/Meluap -> Otomatis Awas tanpa memandang durasi
    final e3Strength = fTma['Kritis']!;
    addRule('E3', 'Tinggi Muka Air Sungai Meluap (TMA Kritis)', e3Strength, 'Awas');

    // Rule E4: Sungai Rawan + Hujan Sedang/Lebat -> Siaga
    final e4Strength = math.min(fTma['Rawan']!, math.max(fCurah['Sedang']!, fCurah['Lebat']!));
    addRule('E4', 'Muka Air Rawan & Terjadi Hujan Sedang/Lebat', e4Strength, 'Siaga');

    // 3. Defuzzifikasi Centroid / Center of Area (200 step)
    const int numSteps = 200;
    double numerator = 0.0;
    double denominator = 0.0;

    for (int i = 0; i <= numSteps; i++) {
      final z = i * (100.0 / numSteps);
      double muAgg = 0.0;

      for (final fr in firedRules) {
        final muOut = getMuConsequent(fr.konsekuen, z);
        final clipped = math.min(fr.kekuatanTembak, muOut);
        if (clipped > muAgg) muAgg = clipped;
      }

      numerator += z * muAgg;
      denominator += muAgg;
    }

    final crispZ = denominator > 0 ? (numerator / denominator) : 0.0;

    String status = 'Aman';
    if (crispZ > 80) {
      status = 'Awas';
    } else if (crispZ > 60) {
      status = 'Siaga';
    } else if (crispZ > 35) {
      status = 'Waspada';
    }

    // 4. Pembangkit Penjelasan Transparansi (Explainable AI - XAI)
    final faktorKunci = <String>[];
    final alasanList = <String>[];

    if (tma >= 140) {
      faktorKunci.add('Ketinggian Muka Air Sungai Kritis (${tma.toStringAsFixed(0)} cm)');
      alasanList.add('Debit Sungai Rahong telah mendekati batas bibir tanggul.');
    } else if (tma >= 80) {
      faktorKunci.add('Ketinggian Muka Air Meningkat (${tma.toStringAsFixed(0)} cm)');
    }

    if (soil >= 75) {
      faktorKunci.add('Kejenuhan Tanah Hulu Sangat Tinggi (${soil.toStringAsFixed(0)}%)');
      alasanList.add('Tanah perbukitan telah jenuh air akibat hujan beberapa hari terakhir, menghilangkan daya serap tanah.');
    }

    if (curah >= 75) {
      faktorKunci.add('Intensitas Curah Hujan Lebat (${curah.toStringAsFixed(0)} mm/jam)');
      alasanList.add('Presipitasi hujan berintensitas tinggi terus turun.');
    } else if (curah >= 35) {
      faktorKunci.add('Hujan Intensitas Sedang (${curah.toStringAsFixed(0)} mm/jam)');
    }

    if (durasi >= 5) {
      faktorKunci.add('Durasi Hujan Akumulatif Panjang (${durasi.toStringAsFixed(1)} Jam)');
      alasanList.add('Hujan telah berlangsung lama secara terus-menerus.');
    }

    String ringkasanPenyebab;
    if (status == 'Aman') {
      ringkasanPenyebab =
          'Kondisi wilayah Desa Rahong normal dan aman. Kapasitas sungai masih mencukupi dan daya serap tanah masih optimal.';
    } else {
      final joinedAlasan = alasanList.isNotEmpty
          ? alasanList.join(' ')
          : 'Kombinasi intensitas dan durasi hujan mulai membebani daerah aliran sungai.';
      ringkasanPenyebab =
          'Alarm $status (${crispZ.toStringAsFixed(1)}%) aktif karena: $joinedAlasan Warga di bantaran sungai diimbau meningkatkan kesiapsiagaan.';
    }

    return FuzzyResultDart(
      curahHujan: curah,
      durasiHujan: durasi,
      kejenuhanTanah: soil,
      tinggiMukaAir: tma,
      crispOutputZ: double.parse(crispZ.toStringAsFixed(2)),
      statusBahaya: status,
      firedRules: firedRules,
      fuzzifiedInputs: fuzzifiedList,
      ringkasanPenyebab: ringkasanPenyebab,
      faktorKunci: faktorKunci,
    );
  }
}
