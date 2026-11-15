"""
Rule base definitions for the Mamdani fuzzy inference system.
Definisi basis aturan untuk sistem inferensi fuzzy Mamdani.

Contains the 12 fuzzy rules that map combinations of:
- Curah Hujan (Rainfall intensity): Rendah, Sedang, Lebat, Sangat Lebat
- Durasi Hujan (Rainfall duration): Singkat, Sedang, Lama

to the output:
- Status Bahaya (Danger level): Aman, Waspada, Siaga, Awas
"""

from dataclasses import dataclass
from typing import List


@dataclass(frozen=True)
class FuzzyRule:
    """
    Represents a single Mamdani fuzzy rule.
    Merepresentasikan satu aturan fuzzy Mamdani.

    Attributes:
        rule_id: Unique rule identifier (R1–R12).
        curah_hujan: Linguistic label for rainfall input.
        durasi_hujan: Linguistic label for duration input.
        output: Linguistic label for the consequent (danger status).
        description: Human-readable rule description in Indonesian.
    """

    rule_id: str
    curah_hujan: str
    durasi_hujan: str
    output: str
    description: str


# ============================================================
# 12 Rule Definitions / 12 Definisi Aturan
# ============================================================

RULES: List[FuzzyRule] = [
    FuzzyRule(
        rule_id="R1",
        curah_hujan="Rendah",
        durasi_hujan="Singkat",
        output="Aman",
        description="JIKA curah hujan Rendah DAN durasi Singkat MAKA Aman",
    ),
    FuzzyRule(
        rule_id="R2",
        curah_hujan="Rendah",
        durasi_hujan="Sedang",
        output="Aman",
        description="JIKA curah hujan Rendah DAN durasi Sedang MAKA Aman",
    ),
    FuzzyRule(
        rule_id="R3",
        curah_hujan="Rendah",
        durasi_hujan="Lama",
        output="Waspada",
        description="JIKA curah hujan Rendah DAN durasi Lama MAKA Waspada",
    ),
    FuzzyRule(
        rule_id="R4",
        curah_hujan="Sedang",
        durasi_hujan="Singkat",
        output="Aman",
        description="JIKA curah hujan Sedang DAN durasi Singkat MAKA Aman",
    ),
    FuzzyRule(
        rule_id="R5",
        curah_hujan="Sedang",
        durasi_hujan="Sedang",
        output="Waspada",
        description="JIKA curah hujan Sedang DAN durasi Sedang MAKA Waspada",
    ),
    FuzzyRule(
        rule_id="R6",
        curah_hujan="Sedang",
        durasi_hujan="Lama",
        output="Siaga",
        description="JIKA curah hujan Sedang DAN durasi Lama MAKA Siaga",
    ),
    FuzzyRule(
        rule_id="R7",
        curah_hujan="Lebat",
        durasi_hujan="Singkat",
        output="Waspada",
        description="JIKA curah hujan Lebat DAN durasi Singkat MAKA Waspada",
    ),
    FuzzyRule(
        rule_id="R8",
        curah_hujan="Lebat",
        durasi_hujan="Sedang",
        output="Siaga",
        description="JIKA curah hujan Lebat DAN durasi Sedang MAKA Siaga",
    ),
    FuzzyRule(
        rule_id="R9",
        curah_hujan="Lebat",
        durasi_hujan="Lama",
        output="Awas",
        description="JIKA curah hujan Lebat DAN durasi Lama MAKA Awas",
    ),
    FuzzyRule(
        rule_id="R10",
        curah_hujan="Sangat Lebat",
        durasi_hujan="Singkat",
        output="Siaga",
        description="JIKA curah hujan Sangat Lebat DAN durasi Singkat MAKA Siaga",
    ),
    FuzzyRule(
        rule_id="R11",
        curah_hujan="Sangat Lebat",
        durasi_hujan="Sedang",
        output="Awas",
        description="JIKA curah hujan Sangat Lebat DAN durasi Sedang MAKA Awas",
    ),
    FuzzyRule(
        rule_id="R12",
        curah_hujan="Sangat Lebat",
        durasi_hujan="Lama",
        output="Awas",
        description="JIKA curah hujan Sangat Lebat DAN durasi Lama MAKA Awas",
    ),
]
