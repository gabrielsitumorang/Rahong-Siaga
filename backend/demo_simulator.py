"""
Demo Simulator: Simulasi Dinamis Skenario Bencana Banjir Desa Rahong.
Skrip mandiri untuk memvalidasi alur kerja end-to-end Mesin Fuzzy Mamdani
dan Integrasi Spasial SBL tanpa memerlukan koneksi eksternal.

Jalankan dengan perintah:
    python demo_simulator.py
"""

import sys
from pathlib import Path

# Tambahkan direktori root backend ke sys.path
sys.path.insert(0, str(Path(__file__).parent))

from fuzzy_engine.mamdani import compute_flood_risk
from services.spatial_service import compute_sbl_per_zone


def run_storm_scenario_simulation():
    """
    Simulasi perkembangan badai dari kondisi kering (T0) hingga badai ekstrem (T4)
    dan surut kembali ke kondisi normal (T5).
    """
    print("\n" + "=" * 80)
    print(" 🌊 SIMULASI DINAMIS SISTEM PERINGATAN DINI BANJIR DESA RAHONG")
    print("    Metode: Fuzzy Mamdani (12 Rules, COA) + Koefisien Spasial Topografi")
    print("=" * 80 + "\n")

    scenarios = [
        {
            "waktu": "10:00 WIB",
            "fase": "Kondisi Cerah Berawan",
            "curah_hujan": 5.0,
            "durasi_hujan": 0.5,
        },
        {
            "waktu": "11:30 WIB",
            "fase": "Hujan Rintik Mulai Turun",
            "curah_hujan": 20.0,
            "durasi_hujan": 1.5,
        },
        {
            "waktu": "13:00 WIB",
            "fase": "Hujan Lebat Meningkat",
            "curah_hujan": 50.0,
            "durasi_hujan": 3.0,
        },
        {
            "waktu": "15:00 WIB",
            "fase": "Puncak Badai Hujan Sangat Lebat",
            "curah_hujan": 85.0,
            "durasi_hujan": 6.5,
        },
        {
            "waktu": "16:30 WIB",
            "fase": "Kondisi Ekstrem / Banjir Bandang",
            "curah_hujan": 125.0,
            "durasi_hujan": 9.0,
        },
        {
            "waktu": "18:00 WIB",
            "fase": "Hujan Mereda Pasca Badai",
            "curah_hujan": 30.0,
            "durasi_hujan": 2.0,
        },
    ]

    for idx, sc in enumerate(scenarios, 1):
        curah = sc["curah_hujan"]
        durasi = sc["durasi_hujan"]

        # 1. Hitung output fuzzy Mamdani
        fuzzy_result = compute_flood_risk(curah, durasi)
        z_star = fuzzy_result["crisp_output_z"]
        global_status = fuzzy_result["status_bahaya"]
        fired_rules = fuzzy_result["fired_rules"]

        # 2. Hitung SBL per zona
        zones = compute_sbl_per_zone(z_star)

        print(f"[{idx}] Waktu: {sc['waktu']} | Fase: {sc['fase']}")
        print(f"    ├─ Input Sensor Cuaca : Curah = {curah:.1f} mm | Durasi = {durasi:.1f} jam")
        print(f"    ├─ Rules Aktif        : {len(fired_rules)} aturan terpicu")
        for r in fired_rules:
            print(f"    │  • {r['rule_id']}: {r['description']} (Strength: {r['firing_strength']:.3f})")
        print(f"    ├─ Defuzzifikasi COA  : Z* = {z_star:.2f}% (Status Global: {global_status})")
        print("    └─ Skor Bahaya Lokal (SBL) per Zona:")

        for z in zones:
            status_icon = {
                "Aman": "🟢 [AMAN]",
                "Waspada": "🟡 [WASPADA]",
                "Siaga": "🟠 [SIAGA]",
                "Awas": "🔴 [AWAS]",
            }.get(z.status, z.status)

            print(
                f"       • {z.zone_name:<25} (K={z.koefisien_spasial:.2f}) -> "
                f"SBL = {z.sbl_score:5.1f} | {status_icon} | {z.warna}"
            )
        print("-" * 80)


if __name__ == "__main__":
    run_storm_scenario_simulation()

