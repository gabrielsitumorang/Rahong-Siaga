"""
Pydantic models (schemas) for API request/response data validation.
Model Pydantic (skema) untuk validasi data request/response API.

All models use strict type validation and include field descriptions
in both Indonesian and English for documentation clarity.
"""

from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field


# ============================================================
# Weather Data Models / Model Data Cuaca
# ============================================================


class WeatherData(BaseModel):
    """
    Current weather observation data.
    Data observasi cuaca terkini.
    """

    timestamp: datetime = Field(
        ...,
        description="Waktu pengambilan data / Data fetch timestamp",
    )
    temperature_celsius: float = Field(
        ...,
        description="Suhu udara dalam Celsius / Air temperature in Celsius",
    )
    humidity_percent: float = Field(
        ...,
        description="Kelembaban relatif (%) / Relative humidity (%)",
    )
    weather_description: str = Field(
        ...,
        description="Deskripsi cuaca / Weather description",
    )
    wind_speed_mps: float = Field(
        ...,
        description="Kecepatan angin (m/s) / Wind speed (m/s)",
    )
    rainfall_mm: float = Field(
        ...,
        description="Intensitas curah hujan dalam mm / Rainfall intensity in mm",
    )
    estimated_duration_hours: float = Field(
        ...,
        description="Estimasi durasi hujan (jam) / Estimated rainfall duration (hours)",
    )
    source: str = Field(
        default="OpenWeatherMap",
        description="Sumber data cuaca / Weather data source",
    )
    is_mock: bool = Field(
        default=False,
        description="Apakah data ini mock/dummy / Whether this is mock data",
    )


# ============================================================
# Fuzzy Engine Result Models / Model Hasil Mesin Fuzzy
# ============================================================


class FiredRule(BaseModel):
    """
    A single fired fuzzy rule with its evaluation details.
    Satu aturan fuzzy yang terpicu dengan detail evaluasinya.
    """

    rule_id: str = Field(..., description="ID aturan (R1-R12)")
    description: str = Field(..., description="Deskripsi aturan dalam bahasa Indonesia")
    mu_curah_hujan: float = Field(
        ..., description="Derajat keanggotaan curah hujan / Rainfall membership degree"
    )
    mu_durasi_hujan: float = Field(
        ..., description="Derajat keanggotaan durasi hujan / Duration membership degree"
    )
    firing_strength: float = Field(
        ..., description="Kekuatan tembak aturan (MIN) / Rule firing strength (MIN)"
    )
    consequent: str = Field(
        ..., description="Label konsekuen (Aman/Waspada/Siaga/Awas)"
    )


class FuzzifiedInputs(BaseModel):
    """
    Fuzzified membership degrees for both inputs.
    Derajat keanggotaan terfuzzifikasi untuk kedua input.
    """

    curah_hujan: Dict[str, float] = Field(
        ..., description="Derajat keanggotaan curah hujan per label linguistik"
    )
    durasi_hujan: Dict[str, float] = Field(
        ..., description="Derajat keanggotaan durasi hujan per label linguistik"
    )


class FuzzyResult(BaseModel):
    """
    Complete result from the Mamdani fuzzy inference engine.
    Hasil lengkap dari mesin inferensi fuzzy Mamdani.
    """

    curah_hujan: float = Field(
        ..., description="Input curah hujan (mm) / Rainfall input (mm)"
    )
    durasi_hujan: float = Field(
        ..., description="Input durasi hujan (jam) / Duration input (hours)"
    )
    fuzzified_inputs: FuzzifiedInputs = Field(
        ..., description="Derajat keanggotaan terfuzzifikasi / Fuzzified membership degrees"
    )
    fired_rules: List[FiredRule] = Field(
        ..., description="Daftar aturan yang terpicu / List of fired rules"
    )
    crisp_output_z: float = Field(
        ..., description="Nilai output tegas hasil defuzzifikasi COA / COA defuzzified output"
    )
    status_bahaya: str = Field(
        ..., description="Label status bahaya: Aman, Waspada, Siaga, atau Awas"
    )


# ============================================================
# Zone / Spatial Models / Model Zona / Spasial
# ============================================================


class ZoneStatus(BaseModel):
    """
    Flood risk status for a single spatial zone.
    Status risiko banjir untuk satu zona spasial.
    """

    zone_id: str = Field(..., description="ID zona / Zone ID")
    zone_name: str = Field(..., description="Nama zona / Zone name")
    koefisien_spasial: float = Field(
        ..., description="Koefisien spasial zona / Zone spatial coefficient"
    )
    elevasi: int = Field(..., description="Elevasi rata-rata (m) / Average elevation (m)")
    sbl_score: float = Field(
        ...,
        description="Skor Bahaya Lokal = min(100, Z* × koefisien) / Local Hazard Score",
    )
    status: str = Field(
        ..., description="Status bahaya zona: Aman, Waspada, Siaga, atau Awas"
    )
    warna: str = Field(
        ..., description="Kode warna status / Status color code (Hijau/Kuning/Oranye/Merah)"
    )
    action_required: str = Field(
        ..., description="Tindakan yang diperlukan / Required action"
    )


class FloodHistoryEntry(BaseModel):
    """
    A single entry in the flood evaluation history log.
    Satu entri dalam log riwayat evaluasi banjir.
    """

    timestamp: datetime = Field(..., description="Waktu evaluasi / Evaluation timestamp")
    curah_hujan: float = Field(..., description="Curah hujan (mm)")
    durasi_hujan: float = Field(..., description="Durasi hujan (jam)")
    crisp_output_z: float = Field(..., description="Output COA global")
    status_bahaya: str = Field(..., description="Status bahaya global")


class FloodStatusResponse(BaseModel):
    """
    Complete flood status response including global fuzzy result and per-zone SBL.
    Response status banjir lengkap termasuk hasil fuzzy global dan SBL per zona.
    """

    timestamp: datetime = Field(
        ..., description="Waktu evaluasi / Evaluation timestamp"
    )
    weather: WeatherData = Field(
        ..., description="Data cuaca terkini / Current weather data"
    )
    fuzzy_result: FuzzyResult = Field(
        ..., description="Hasil inferensi fuzzy global / Global fuzzy inference result"
    )
    zone_statuses: List[ZoneStatus] = Field(
        ..., description="Status per zona / Per-zone statuses"
    )
    fcm_triggered: bool = Field(
        ...,
        description="Apakah notifikasi FCM dikirim / Whether FCM notification was sent",
    )
    recent_history: List[FloodHistoryEntry] = Field(
        default_factory=list,
        description="Log riwayat evaluasi terbaru / Recent evaluation history log",
    )


# ============================================================
# GIS Layer Models / Model Layer GIS
# ============================================================


class GeoLayerResponse(BaseModel):
    """
    GeoJSON layers response for the frontend map.
    Response layer GeoJSON untuk peta frontend.
    """

    type: str = Field(default="FeatureCollection", description="GeoJSON type")
    name: str = Field(
        default="Desa Rahong - Spatial Data",
        description="Nama dataset / Dataset name",
    )
    features: List[Dict[str, Any]] = Field(
        ..., description="Daftar fitur GeoJSON / List of GeoJSON features"
    )
    metadata: Dict[str, Any] = Field(
        default_factory=dict,
        description="Metadata tambahan / Additional metadata",
    )


# ============================================================
# FCM Payload Model / Model Payload FCM
# ============================================================


class FCMPayload(BaseModel):
    """
    Firebase Cloud Messaging notification payload.
    Payload notifikasi Firebase Cloud Messaging.
    """

    zone_name: str = Field(..., description="Nama zona terdampak / Affected zone name")
    sbl_score: float = Field(
        ..., description="Skor Bahaya Lokal / Local Hazard Score"
    )
    status: str = Field(..., description="Status bahaya: Siaga atau Awas")
    action_required: str = Field(
        ..., description="Tindakan yang diperlukan / Required action"
    )
    evacuation_route: str = Field(
        ...,
        description="Rute evakuasi terdekat / Nearest evacuation route",
    )
    timestamp: datetime = Field(
        ..., description="Waktu peringatan / Alert timestamp"
    )
