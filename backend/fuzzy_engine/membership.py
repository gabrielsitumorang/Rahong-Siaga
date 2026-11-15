"""
Membership functions for the Fuzzy Mamdani flood risk engine.
Fungsi keanggotaan untuk mesin fuzzy Mamdani risiko banjir.

This module implements trapezoid and triangle membership functions
and defines the linguistic variable sets for:
- Input 1: Curah Hujan (Rainfall intensity) — Universe [0, 150] mm
- Input 2: Durasi Hujan (Rainfall duration) — Universe [0, 12] jam
- Output:  Status Bahaya (Danger level) — Universe [0, 100] %

All functions are pure Python — no external fuzzy libraries required.
"""

from typing import Dict


# ============================================================
# Core membership functions / Fungsi keanggotaan inti
# ============================================================


def trapezoid(x: float, a: float, b: float, c: float, d: float) -> float:
    """
    Trapezoid (trapezoidal) membership function.
    Fungsi keanggotaan trapesium.

    Shape:
        0 for x <= a or x >= d
        rising slope  from a to b
        1 for b <= x <= c  (flat top / puncak datar)
        falling slope from c to d

    Args:
        x: Crisp input value / Nilai input tegas.
        a: Left foot / Kaki kiri.
        b: Left shoulder / Bahu kiri.
        c: Right shoulder / Bahu kanan.
        d: Right foot / Kaki kanan.

    Returns:
        Membership degree μ ∈ [0, 1] / Derajat keanggotaan μ ∈ [0, 1].
    """
    if x <= a or x >= d:
        # Completely outside the support / Sepenuhnya di luar support
        # Special case: if a == b (left-open) or c == d (right-open)
        if a == b and x <= a:
            return 1.0
        if c == d and x >= d:
            return 1.0
        return 0.0
    elif a < x < b:
        # Rising slope / Lereng naik
        return (x - a) / (b - a)
    elif b <= x <= c:
        # Flat top / Puncak datar
        return 1.0
    elif c < x < d:
        # Falling slope / Lereng turun
        return (d - x) / (d - c)
    else:
        return 0.0


def triangle(x: float, a: float, b: float, c: float) -> float:
    """
    Triangle (triangular) membership function.
    Fungsi keanggotaan segitiga.

    Shape:
        0 for x <= a or x >= c
        rising slope  from a to b
        peak = 1 at x == b
        falling slope from b to c

    Args:
        x: Crisp input value / Nilai input tegas.
        a: Left foot / Kaki kiri.
        b: Peak / Puncak.
        c: Right foot / Kaki kanan.

    Returns:
        Membership degree μ ∈ [0, 1] / Derajat keanggotaan μ ∈ [0, 1].
    """
    if x <= a or x >= c:
        return 0.0
    elif a < x < b:
        # Rising slope / Lereng naik
        return (x - a) / (b - a)
    elif x == b:
        return 1.0
    elif b < x < c:
        # Falling slope / Lereng turun
        return (c - x) / (c - b)
    else:
        return 0.0


# ============================================================
# Membership function sets / Himpunan fungsi keanggotaan
# ============================================================


def curah_hujan_rendah(x: float) -> float:
    """Curah hujan RENDAH — Trapesium [0, 0, 10, 25]."""
    return trapezoid(x, 0, 0, 10, 25)


def curah_hujan_sedang(x: float) -> float:
    """Curah hujan SEDANG — Segitiga [15, 35, 55]."""
    return triangle(x, 15, 35, 55)


def curah_hujan_lebat(x: float) -> float:
    """Curah hujan LEBAT — Segitiga [45, 75, 105]."""
    return triangle(x, 45, 75, 105)


def curah_hujan_sangat_lebat(x: float) -> float:
    """Curah hujan SANGAT LEBAT — Trapesium [90, 120, 150, 150]."""
    return trapezoid(x, 90, 120, 150, 150)


def durasi_hujan_singkat(x: float) -> float:
    """Durasi hujan SINGKAT — Trapesium [0, 0, 1, 3]."""
    return trapezoid(x, 0, 0, 1, 3)


def durasi_hujan_sedang(x: float) -> float:
    """Durasi hujan SEDANG — Segitiga [2, 4, 6]."""
    return triangle(x, 2, 4, 6)


def durasi_hujan_lama(x: float) -> float:
    """Durasi hujan LAMA — Trapesium [5, 7, 12, 12]."""
    return trapezoid(x, 5, 7, 12, 12)


def bahaya_aman(x: float) -> float:
    """Status bahaya AMAN — Trapesium [0, 0, 20, 35]."""
    return trapezoid(x, 0, 0, 20, 35)


def bahaya_waspada(x: float) -> float:
    """Status bahaya WASPADA — Segitiga [25, 45, 60]."""
    return triangle(x, 25, 45, 60)


def bahaya_siaga(x: float) -> float:
    """Status bahaya SIAGA — Segitiga [50, 65, 80]."""
    return triangle(x, 50, 65, 80)


def bahaya_awas(x: float) -> float:
    """Status bahaya AWAS — Trapesium [70, 85, 100, 100]."""
    return trapezoid(x, 70, 85, 100, 100)


# ============================================================
# Grouped accessors / Aksesor terkelompok
# ============================================================

# Dictionary mapping linguistic labels to membership functions
# Kamus yang memetakan label linguistik ke fungsi keanggotaan

CURAH_HUJAN_MF: Dict[str, callable] = {
    "Rendah": curah_hujan_rendah,
    "Sedang": curah_hujan_sedang,
    "Lebat": curah_hujan_lebat,
    "Sangat Lebat": curah_hujan_sangat_lebat,
}

DURASI_HUJAN_MF: Dict[str, callable] = {
    "Singkat": durasi_hujan_singkat,
    "Sedang": durasi_hujan_sedang,
    "Lama": durasi_hujan_lama,
}

BAHAYA_MF: Dict[str, callable] = {
    "Aman": bahaya_aman,
    "Waspada": bahaya_waspada,
    "Siaga": bahaya_siaga,
    "Awas": bahaya_awas,
}
