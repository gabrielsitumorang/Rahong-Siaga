/**
 * Demo Simulator (Node.js version)
 * Sistem Peringatan Dini Banjir Berbasis Fuzzy Mamdani - Desa Rahong
 * 
 * Jalankan langsung di terminal:
 *   node demo_simulator.js
 */

const fs = require('fs');
const path = require('path');

// --- 1. FUNGSI KEANGGOTAAN ---
function trapezoid(x, a, b, c, d) {
    if (x <= a || x >= d) return 0.0;
    if (a < x && x < b) return b !== a ? (x - a) / (b - a) : 1.0;
    if (b <= x && x <= c) return 1.0;
    if (c < x && x < d) return d !== c ? (d - x) / (d - c) : 1.0;
    return 0.0;
}

function triangle(x, a, b, c) {
    if (x <= a || x >= c) return 0.0;
    if (a < x && x <= b) return b !== a ? (x - a) / (b - a) : 1.0;
    if (b < x && x < c) return c !== b ? (c - x) / (c - b) : 1.0;
    return 0.0;
}

const BAHAYA_MF = {
    Aman: (z) => trapezoid(z, 0, 0, 20, 35),
    Waspada: (z) => triangle(z, 25, 45, 60),
    Siaga: (z) => triangle(z, 50, 65, 80),
    Awas: (z) => trapezoid(z, 70, 85, 100, 100),
};

const RULES = [
    { id: "R1", curah: "Rendah", durasi: "Singkat", out: "Aman", desc: "IF Rendah AND Singkat THEN Aman" },
    { id: "R2", curah: "Rendah", durasi: "Sedang",  out: "Aman", desc: "IF Rendah AND Sedang THEN Aman" },
    { id: "R3", curah: "Rendah", durasi: "Lama",    out: "Waspada", desc: "IF Rendah AND Lama THEN Waspada" },
    { id: "R4", curah: "Sedang", durasi: "Singkat", out: "Aman", desc: "IF Sedang AND Singkat THEN Aman" },
    { id: "R5", curah: "Sedang", durasi: "Sedang",  out: "Waspada", desc: "IF Sedang AND Sedang THEN Waspada" },
    { id: "R6", curah: "Sedang", durasi: "Lama",    out: "Siaga", desc: "IF Sedang AND Lama THEN Siaga" },
    { id: "R7", curah: "Lebat",  durasi: "Singkat", out: "Waspada", desc: "IF Lebat AND Singkat THEN Waspada" },
    { id: "R8", curah: "Lebat",  durasi: "Sedang",  out: "Siaga", desc: "IF Lebat AND Sedang THEN Siaga" },
    { id: "R9", curah: "Lebat",  durasi: "Lama",    out: "Awas", desc: "IF Lebat AND Lama THEN Awas" },
    { id: "R10", curah: "Sangat Lebat", durasi: "Singkat", out: "Siaga", desc: "IF Sangat Lebat AND Singkat THEN Siaga" },
    { id: "R11", curah: "Sangat Lebat", durasi: "Sedang",  out: "Awas", desc: "IF Sangat Lebat AND Sedang THEN Awas" },
    { id: "R12", curah: "Sangat Lebat", durasi: "Lama",    out: "Awas", desc: "IF Sangat Lebat AND Lama THEN Awas" },
];

function computeFloodRisk(curahHujan, durasiHujan) {
    const curah = Math.max(0, Math.min(150, curahHujan));
    const durasi = Math.max(0, Math.min(12, durasiHujan));

    // Fuzzifikasi
    const fuzzCurah = {
        Rendah: trapezoid(curah, 0, 0, 10, 25),
        Sedang: triangle(curah, 15, 35, 55),
        Lebat: triangle(curah, 45, 75, 105),
        "Sangat Lebat": trapezoid(curah, 90, 120, 150, 150),
    };

    const fuzzDurasi = {
        Singkat: trapezoid(durasi, 0, 0, 1, 3),
        Sedang: triangle(durasi, 2, 4, 6),
        Lama: trapezoid(durasi, 5, 7, 12, 12),
    };

    // Evaluasi 12 Aturan
    const firedRules = [];
    for (const rule of RULES) {
        const muCurah = fuzzCurah[rule.curah] || 0;
        const muDurasi = fuzzDurasi[rule.durasi] || 0;
        const strength = Math.min(muCurah, muDurasi);
        if (strength > 0) {
            firedRules.push({
                rule_id: rule.id,
                desc: rule.desc,
                strength: strength,
                consequent: rule.out
            });
        }
    }

    // Defuzzifikasi Centroid / COA (200 step)
    const NUM_STEPS = 200;
    let num = 0.0;
    let den = 0.0;

    for (let i = 0; i <= NUM_STEPS; i++) {
        const z = i * (100.0 / NUM_STEPS);
        let muAgg = 0.0;
        for (const fr of firedRules) {
            const muOut = BAHAYA_MF[fr.consequent](z);
            const clipped = Math.min(fr.strength, muOut);
            if (clipped > muAgg) muAgg = clipped;
        }
        num += z * muAgg;
        den += muAgg;
    }

    const crispZ = den > 0 ? num / den : 0.0;
    let status = "Aman";
    if (crispZ > 80) status = "Awas";
    else if (crispZ > 60) status = "Siaga";
    else if (crispZ > 35) status = "Waspada";

    return {
        curah_hujan: curah,
        durasi_hujan: durasi,
        crisp_output_z: Number(crispZ.toFixed(2)),
        status_bahaya: status,
        fired_rules: firedRules
    };
}

const ZONES = [
    { nama: "Bantaran Sungai Rahong", koef: 1.25, elevasi: 45 },
    { nama: "Permukiman Inti Desa",  koef: 1.00, elevasi: 85 },
    { nama: "Bukit Harapan (Posko)",  koef: 0.70, elevasi: 150 },
];

function runDemo() {
    console.log("\n" + "=".repeat(80));
    console.log(" 🌊 SIMULASI SISTEM PERINGATAN DINI BANJIR DESA RAHONG (Node.js Engine)");
    console.log("    Fuzzy Mamdani (12 Rules, Centroid COA) + Koefisien Spasial");
    console.log("=".repeat(80) + "\n");

    const scenarios = [
        { waktu: "10:00 WIB", fase: "Kondisi Cerah", curah: 5.0, durasi: 0.5 },
        { waktu: "11:30 WIB", fase: "Hujan Mulai Turun", curah: 20.0, durasi: 1.5 },
        { waktu: "13:00 WIB", fase: "Hujan Lebat", curah: 50.0, durasi: 3.0 },
        { waktu: "15:00 WIB", fase: "Puncak Badai", curah: 85.0, durasi: 6.5 },
        { waktu: "16:30 WIB", fase: "Kondisi Ekstrem", curah: 125.0, durasi: 9.0 },
        { waktu: "18:00 WIB", fase: "Hujan Mereda", curah: 30.0, durasi: 2.0 },
    ];

    scenarios.forEach((sc, i) => {
        const res = computeFloodRisk(sc.curah, sc.durasi);
        console.log(`[${i + 1}] Waktu: ${sc.waktu} | Fase: ${sc.fase}`);
        console.log(`    ├─ Sensor Cuaca       : Curah = ${sc.curah} mm | Durasi = ${sc.durasi} jam`);
        console.log(`    ├─ Rules Aktif        : ${res.fired_rules.length} aturan terpicu (${res.fired_rules.map(r => r.rule_id).join(", ")})`);
        console.log(`    ├─ Defuzzifikasi COA  : Z* = ${res.crisp_output_z}% (Status Global: ${res.status_bahaya})`);
        console.log(`    └─ Skor Bahaya Lokal (SBL) per Zona:`);

        ZONES.forEach(z => {
            const sbl = Math.min(100.0, Number((res.crisp_output_z * z.koef).toFixed(2)));
            let status = "Aman";
            let icon = "🟢 [AMAN]";
            if (sbl > 80) { status = "Awas"; icon = "🔴 [AWAS]"; }
            else if (sbl > 60) { status = "Siaga"; icon = "🟠 [SIAGA]"; }
            else if (sbl > 35) { status = "Waspada"; icon = "🟡 [WASPADA]"; }

            console.log(`       • ${z.nama.padEnd(25)} (K=${z.koef.toFixed(2)}) -> SBL = ${sbl.toFixed(1).padStart(5)} | ${icon}`);
        });
        console.log("-".repeat(80));
    });
}

runDemo();

