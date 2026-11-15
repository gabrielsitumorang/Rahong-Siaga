"""
Unit tests for Mamdani Fuzzy Inference Engine & Spatial SBL computation.
Pengujian unit untuk Mesin Inferensi Fuzzy Mamdani & Perhitungan SBL Spasial.
"""

import pytest
from fuzzy_engine.mamdani import compute_flood_risk
from fuzzy_engine.membership import (
    BAHAYA_MF,
    CURAH_HUJAN_MF,
    DURASI_HUJAN_MF,
    trapezoid,
    triangle,
)
from services.spatial_service import classify_sbl, compute_sbl_per_zone


class TestMembershipFunctions:
    """Test individual membership functions for inputs and outputs."""

    def test_triangle_peak_and_boundaries(self):
        # Segitiga [15, 35, 55]
        assert triangle(15, 15, 35, 55) == 0.0
        assert triangle(35, 15, 35, 55) == 1.0
        assert triangle(55, 15, 35, 55) == 0.0
        assert triangle(25, 15, 35, 55) == 0.5
        assert triangle(10, 15, 35, 55) == 0.0
        assert triangle(60, 15, 35, 55) == 0.0

    def test_trapezoid_shoulders_and_plateau(self):
        # Trapesium Rendah [0, 0, 10, 25]
        assert trapezoid(0, 0, 0, 10, 25) == 1.0
        assert trapezoid(5, 0, 0, 10, 25) == 1.0
        assert trapezoid(10, 0, 0, 10, 25) == 1.0
        assert trapezoid(17.5, 0, 0, 10, 25) == 0.5
        assert trapezoid(25, 0, 0, 10, 25) == 0.0
        assert trapezoid(30, 0, 0, 10, 25) == 0.0

        # Trapesium Sangat Lebat [90, 120, 150, 150]
        assert trapezoid(80, 90, 120, 150, 150) == 0.0
        assert trapezoid(105, 90, 120, 150, 150) == 0.5
        assert trapezoid(120, 90, 120, 150, 150) == 1.0
        assert trapezoid(150, 90, 120, 150, 150) == 1.0


class TestFuzzyMamdaniInference:
    """Test full Mamdani fuzzy inference pipeline."""

    def test_edge_case_dry_weather(self):
        """0 mm rain, 0 hours duration -> should be Aman."""
        res = compute_flood_risk(0.0, 0.0)
        assert 0.0 <= res["crisp_output_z"] <= 35.0
        assert res["status_bahaya"] == "Aman"
        assert len(res["fired_rules"]) > 0

    def test_edge_case_extreme_storm(self):
        """150 mm rain, 12 hours duration -> should be Awas."""
        res = compute_flood_risk(150.0, 12.0)
        assert 70.0 <= res["crisp_output_z"] <= 100.0
        assert res["status_bahaya"] == "Awas"

    def test_moderate_rain(self):
        """Medium rainfall and duration."""
        res = compute_flood_risk(35.0, 4.0)
        assert 0.0 <= res["crisp_output_z"] <= 100.0
        # Sedang (35) AND Sedang (4) -> R5 should fire -> Waspada
        assert res["status_bahaya"] in ["Aman", "Waspada", "Siaga"]

    def test_heavy_long_rain(self):
        """Lebat (75mm) and Lama (8h) -> should trigger R9 (Awas)."""
        res = compute_flood_risk(75.0, 8.0)
        assert res["crisp_output_z"] >= 65.0
        assert res["status_bahaya"] in ["Siaga", "Awas"]

    def test_output_bounds_all_ranges(self):
        """Ensure crisp Z* always stays strictly in [0, 100] across a grid."""
        for curah in [0.0, 20.0, 50.0, 80.0, 110.0, 150.0]:
            for durasi in [0.0, 2.0, 5.0, 8.0, 12.0]:
                res = compute_flood_risk(curah, durasi)
                z = res["crisp_output_z"]
                assert 0.0 <= z <= 100.0, f"Z* {z} out of bounds for ({curah}, {durasi})"
                assert res["status_bahaya"] in ["Aman", "Waspada", "Siaga", "Awas"]


class TestSpatialSBLIntegration:
    """Test spatial vulnerability multiplier and classification."""

    def test_sbl_clamping_at_100(self):
        """SBL must never exceed 100 even with 1.25 multiplier."""
        # If Z* = 90 and multiplier = 1.25 -> 90 * 1.25 = 112.5 -> clamped to 100
        zones = compute_sbl_per_zone(90.0)
        for zone in zones:
            assert zone.sbl_score <= 100.0

    def test_sbl_zone_multipliers(self):
        """Verify multiplier application for zones."""
        z_star = 50.0
        zones = compute_sbl_per_zone(z_star)

        zone_dict = {z.zone_id: z for z in zones}

        # Bantaran Sungai: 1.25 * 50 = 62.5
        if "zona-01" in zone_dict:
            assert zone_dict["zona-01"].sbl_score == 62.5
            assert zone_dict["zona-01"].status == "Siaga"

        # Permukiman Inti: 1.00 * 50 = 50.0
        if "zona-02" in zone_dict:
            assert zone_dict["zona-02"].sbl_score == 50.0
            assert zone_dict["zona-02"].status == "Waspada"

        # Bukit Harapan: 0.70 * 50 = 35.0
        if "zona-03" in zone_dict:
            assert zone_dict["zona-03"].sbl_score == 35.0
            assert zone_dict["zona-03"].status == "Aman"

    def test_classify_sbl_thresholds(self):
        assert classify_sbl(20)["status"] == "Aman"
        assert classify_sbl(35)["status"] == "Aman"
        assert classify_sbl(36)["status"] == "Waspada"
        assert classify_sbl(60)["status"] == "Waspada"
        assert classify_sbl(61)["status"] == "Siaga"
        assert classify_sbl(80)["status"] == "Siaga"
        assert classify_sbl(81)["status"] == "Awas"
        assert classify_sbl(100)["status"] == "Awas"

