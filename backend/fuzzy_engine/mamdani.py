"""
Mamdani fuzzy inference engine with Center of Area (COA) defuzzification.
Mesin inferensi fuzzy Mamdani dengan defuzzifikasi Center of Area (COA).

Pipeline:
1. Fuzzification — compute μ for each input against all membership functions
2. Rule Evaluation — apply T-Norm MIN for the AND operator
3. Aggregation — combine rule outputs using MAX
4. Defuzzification — Centroid / Center of Area via numerical integration

Pure Python implementation — no external fuzzy libraries.
"""

from typing import Any, Dict, List

from .membership import BAHAYA_MF, CURAH_HUJAN_MF, DURASI_HUJAN_MF
from .rules import RULES

# Number of discrete steps for COA numerical integration
# Jumlah langkah diskret untuk integrasi numerik COA
NUM_STEPS: int = 200


def _fuzzify_curah_hujan(value: float) -> Dict[str, float]:
    """
    Fuzzify the curah hujan (rainfall) input.
    Fuzzifikasi input curah hujan.

    Args:
        value: Crisp rainfall value in mm (universe [0, 150]).

    Returns:
        Dictionary mapping linguistic labels to their membership degrees.
    """
    return {label: mf(value) for label, mf in CURAH_HUJAN_MF.items()}


def _fuzzify_durasi_hujan(value: float) -> Dict[str, float]:
    """
    Fuzzify the durasi hujan (rain duration) input.
    Fuzzifikasi input durasi hujan.

    Args:
        value: Crisp duration value in hours (universe [0, 12]).

    Returns:
        Dictionary mapping linguistic labels to their membership degrees.
    """
    return {label: mf(value) for label, mf in DURASI_HUJAN_MF.items()}


def _evaluate_rules(
    fuzz_curah: Dict[str, float],
    fuzz_durasi: Dict[str, float],
) -> List[Dict[str, Any]]:
    """
    Evaluate all 12 fuzzy rules using T-Norm MIN (AND operator).
    Evaluasi seluruh 12 aturan fuzzy menggunakan T-Norm MIN (operator AND).

    Only rules with firing strength > 0 are included in the result.
    Hanya aturan dengan kekuatan tembak > 0 yang dimasukkan ke hasil.

    Args:
        fuzz_curah: Fuzzified curah hujan values.
        fuzz_durasi: Fuzzified durasi hujan values.

    Returns:
        List of fired rule dictionaries containing rule_id, description,
        antecedent memberships, firing strength, and consequent label.
    """
    fired: List[Dict[str, Any]] = []

    for rule in RULES:
        mu_curah = fuzz_curah.get(rule.curah_hujan, 0.0)
        mu_durasi = fuzz_durasi.get(rule.durasi_hujan, 0.0)

        # T-Norm MIN for AND / T-Norm MIN untuk operator AND
        strength = min(mu_curah, mu_durasi)

        if strength > 0.0:
            fired.append(
                {
                    "rule_id": rule.rule_id,
                    "description": rule.description,
                    "mu_curah_hujan": round(mu_curah, 4),
                    "mu_durasi_hujan": round(mu_durasi, 4),
                    "firing_strength": round(strength, 4),
                    "consequent": rule.output,
                }
            )

    return fired


def _aggregate_and_defuzzify(fired_rules: List[Dict[str, Any]]) -> float:
    """
    Aggregate fired rule outputs using MAX, then defuzzify with COA.
    Agregasi output aturan yang terpicu menggunakan MAX, lalu defuzzifikasi dengan COA.

    The aggregated membership for each output point z is:
        μ_agg(z) = MAX over all fired rules of MIN(firing_strength, μ_consequent(z))

    Center of Area (COA):
        Z* = Σ(z_i × μ_agg(z_i)) / Σ(μ_agg(z_i))

    Uses NUM_STEPS discrete sample points over the output universe [0, 100].

    Args:
        fired_rules: List of fired rule dictionaries from _evaluate_rules.

    Returns:
        Crisp defuzzified output Z* ∈ [0, 100].
        Returns 0.0 if no rules fired (denominator is zero).
    """
    if not fired_rules:
        return 0.0

    # Discrete sampling over output universe [0, 100]
    # Sampling diskret pada universe output [0, 100]
    step_size = 100.0 / NUM_STEPS
    numerator = 0.0
    denominator = 0.0

    for i in range(NUM_STEPS + 1):
        z = i * step_size  # Current output point / Titik output saat ini

        # Compute aggregated membership at this point using MAX
        # Hitung keanggotaan teragregasi pada titik ini menggunakan MAX
        mu_agg = 0.0
        for rule in fired_rules:
            consequent_label = rule["consequent"]
            firing_strength = rule["firing_strength"]
            consequent_mf = BAHAYA_MF[consequent_label]

            # Implication: clip the consequent MF at firing strength (MIN)
            # Implikasi: potong MF konsekuen pada kekuatan tembak (MIN)
            mu_impl = min(firing_strength, consequent_mf(z))

            # Aggregation: take MAX across all rules
            # Agregasi: ambil MAX dari semua aturan
            mu_agg = max(mu_agg, mu_impl)

        numerator += z * mu_agg
        denominator += mu_agg

    if denominator == 0.0:
        return 0.0

    return numerator / denominator


def _classify_status(z_star: float) -> str:
    """
    Classify the crisp output into a danger status label.
    Klasifikasikan output tegas ke label status bahaya.

    Classification thresholds:
        0–35  : Aman   (Safe)
        36–60 : Waspada (Alert)
        61–80 : Siaga  (Warning)
        81–100: Awas   (Danger)

    Args:
        z_star: Crisp defuzzified output value.

    Returns:
        Status label string.
    """
    if z_star <= 35:
        return "Aman"
    elif z_star <= 60:
        return "Waspada"
    elif z_star <= 80:
        return "Siaga"
    else:
        return "Awas"


def compute_flood_risk(curah_hujan: float, durasi_hujan: float) -> Dict[str, Any]:
    """
    Execute the full Mamdani fuzzy inference pipeline for flood risk.
    Jalankan pipeline inferensi fuzzy Mamdani lengkap untuk risiko banjir.

    Pipeline steps:
    1. Fuzzification of both inputs.
    2. Rule evaluation with T-Norm MIN.
    3. Aggregation with MAX and defuzzification with COA.
    4. Status classification.

    Args:
        curah_hujan: Rainfall intensity in mm (universe [0, 150]).
        durasi_hujan: Rainfall duration in hours (universe [0, 12]).

    Returns:
        Dictionary containing:
        - curah_hujan: The input rainfall value.
        - durasi_hujan: The input duration value.
        - fuzzified_inputs: Membership degrees for both inputs.
        - fired_rules: List of rules that fired (strength > 0).
        - crisp_output_z: Defuzzified COA output value.
        - status_bahaya: Classified danger status label.

    Example:
        >>> result = compute_flood_risk(65.0, 5.5)
        >>> print(result["status_bahaya"])
        'Siaga'
    """
    # Clamp inputs to valid universe ranges
    # Batasi input ke rentang universe yang valid
    curah_hujan = max(0.0, min(150.0, curah_hujan))
    durasi_hujan = max(0.0, min(12.0, durasi_hujan))

    # Step 1: Fuzzification / Langkah 1: Fuzzifikasi
    fuzz_curah = _fuzzify_curah_hujan(curah_hujan)
    fuzz_durasi = _fuzzify_durasi_hujan(durasi_hujan)

    # Step 2: Rule evaluation / Langkah 2: Evaluasi aturan
    fired_rules = _evaluate_rules(fuzz_curah, fuzz_durasi)

    # Step 3 & 4: Aggregation + Defuzzification
    # Langkah 3 & 4: Agregasi + Defuzzifikasi
    crisp_z = _aggregate_and_defuzzify(fired_rules)

    # Classify output / Klasifikasikan output
    status = _classify_status(crisp_z)

    return {
        "curah_hujan": curah_hujan,
        "durasi_hujan": durasi_hujan,
        "fuzzified_inputs": {
            "curah_hujan": {k: round(v, 4) for k, v in fuzz_curah.items()},
            "durasi_hujan": {k: round(v, 4) for k, v in fuzz_durasi.items()},
        },
        "fired_rules": fired_rules,
        "crisp_output_z": round(crisp_z, 2),
        "status_bahaya": status,
    }
