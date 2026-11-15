"""
Spatial service for GeoJSON loading and SBL (Skor Bahaya Lokal) calculation.
Layanan spasial untuk memuat GeoJSON dan perhitungan SBL (Skor Bahaya Lokal).

SBL = Min(100, Z* × Koefisien_Spasial)

Where Z* is the global crisp output from the Mamdani fuzzy engine and
Koefisien_Spasial is a zone-specific multiplier reflecting local vulnerability.

Classification:
    0–35  : Aman    (Hijau  / Green)
    36–60 : Waspada (Kuning / Yellow)
    61–80 : Siaga   (Oranye / Orange)
    81–100: Awas    (Merah  / Red)
"""

import json
import logging
from pathlib import Path
from typing import Any, Dict, List, Optional

from models.schemas import ZoneStatus

logger = logging.getLogger(__name__)

# Path to the GeoJSON data file / Path ke file data GeoJSON
GEOJSON_PATH = Path(__file__).parent.parent / "data" / "desa_rahong.geojson"

# Cached GeoJSON data / Data GeoJSON yang di-cache
_geojson_cache: Optional[Dict[str, Any]] = None


def load_geojson() -> Dict[str, Any]:
    """
    Load and cache the Desa Rahong GeoJSON data.
    Memuat dan menyimpan cache data GeoJSON Desa Rahong.

    Reads the file once and caches it in memory for subsequent calls.

    Returns:
        Dictionary containing the full GeoJSON FeatureCollection.

    Raises:
        FileNotFoundError: If the GeoJSON file does not exist.
        json.JSONDecodeError: If the GeoJSON file is malformed.
    """
    global _geojson_cache

    if _geojson_cache is not None:
        return _geojson_cache

    logger.info(f"Memuat data GeoJSON dari: {GEOJSON_PATH}")

    if not GEOJSON_PATH.exists():
        raise FileNotFoundError(
            f"File GeoJSON tidak ditemukan: {GEOJSON_PATH}. "
            f"Pastikan file data/desa_rahong.geojson tersedia."
        )

    with open(GEOJSON_PATH, "r", encoding="utf-8") as f:
        _geojson_cache = json.load(f)

    feature_count = len(_geojson_cache.get("features", []))
    logger.info(f"Berhasil memuat {feature_count} fitur dari GeoJSON.")

    return _geojson_cache


def reload_geojson() -> Dict[str, Any]:
    """
    Force-reload the GeoJSON data (clears cache).
    Muat ulang paksa data GeoJSON (hapus cache).

    Returns:
        Dictionary containing the refreshed GeoJSON FeatureCollection.
    """
    global _geojson_cache
    _geojson_cache = None
    return load_geojson()


def get_zone_features() -> List[Dict[str, Any]]:
    """
    Extract only zone (polygon) features from the GeoJSON data.
    Ekstrak hanya fitur zona (polygon) dari data GeoJSON.

    Returns:
        List of GeoJSON feature dictionaries where tipe == 'zona'.
    """
    geojson = load_geojson()
    return [
        feature
        for feature in geojson.get("features", [])
        if feature.get("properties", {}).get("tipe") == "zona"
    ]


def classify_sbl(sbl_score: float) -> Dict[str, str]:
    """
    Classify an SBL score into status label and color.
    Klasifikasikan skor SBL ke label status dan warna.

    Args:
        sbl_score: Skor Bahaya Lokal ∈ [0, 100].

    Returns:
        Dictionary with 'status', 'warna' (color name), and 'action_required'.
    """
    if sbl_score <= 35:
        return {
            "status": "Aman",
            "warna": "Hijau",
            "action_required": "Tidak ada tindakan khusus. Pantau informasi cuaca secara berkala.",
        }
    elif sbl_score <= 60:
        return {
            "status": "Waspada",
            "warna": "Kuning",
            "action_required": (
                "Waspada terhadap potensi banjir. Siapkan dokumen penting dan "
                "tas darurat. Pantau ketinggian air sungai."
            ),
        }
    elif sbl_score <= 80:
        return {
            "status": "Siaga",
            "warna": "Oranye",
            "action_required": (
                "SIAGA BANJIR! Segera amankan barang berharga. Bersiap untuk "
                "evakuasi ke posko terdekat. Ikuti arahan petugas BPBD."
            ),
        }
    else:
        return {
            "status": "Awas",
            "warna": "Merah",
            "action_required": (
                "AWAS BANJIR! SEGERA EVAKUASI ke posko evakuasi terdekat "
                "(Balai Desa / Masjid Al-Ikhlas / SD Negeri 1 Rahong). "
                "Jangan mendekati sungai. Hubungi hotline darurat BPBD."
            ),
        }


def compute_sbl_per_zone(crisp_output_z: float) -> List[ZoneStatus]:
    """
    Compute SBL (Skor Bahaya Lokal) for each zone polygon.
    Hitung SBL (Skor Bahaya Lokal) untuk setiap poligon zona.

    Formula: SBL = Min(100, Z* × Koefisien_Spasial)

    Args:
        crisp_output_z: Global crisp output from Mamdani defuzzification (Z*).

    Returns:
        List of ZoneStatus objects, one per zone polygon.
    """
    zones = get_zone_features()
    results: List[ZoneStatus] = []

    for zone in zones:
        props = zone.get("properties", {})
        zone_id = props.get("id", "unknown")
        zone_name = props.get("nama", "Zona Tidak Dikenal")
        koefisien = props.get("koefisien_spasial", 1.0)
        elevasi = props.get("elevasi", 0)

        # Calculate SBL / Hitung SBL
        sbl_score = min(100.0, crisp_output_z * koefisien)
        sbl_score = round(sbl_score, 2)

        # Classify / Klasifikasikan
        classification = classify_sbl(sbl_score)

        results.append(
            ZoneStatus(
                zone_id=zone_id,
                zone_name=zone_name,
                koefisien_spasial=koefisien,
                elevasi=elevasi,
                sbl_score=sbl_score,
                status=classification["status"],
                warna=classification["warna"],
                action_required=classification["action_required"],
            )
        )

    logger.info(
        f"SBL dihitung untuk {len(results)} zona. "
        f"Z* = {crisp_output_z:.2f}"
    )

    return results
