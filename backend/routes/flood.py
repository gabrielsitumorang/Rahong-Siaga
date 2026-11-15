"""
Flood status API route for Desa Rahong early warning system.
Router API status banjir untuk sistem peringatan dini Desa Rahong.

Evaluates flood risk using Mamdani Fuzzy Logic and spatial vulnerability coefficients.
"""

from collections import deque
from datetime import datetime, timezone
import logging
from typing import Deque, List, Optional
from fastapi import APIRouter, HTTPException, Query, status

from fuzzy_engine.mamdani import compute_flood_risk
from models.schemas import (
    FloodHistoryEntry,
    FloodStatusResponse,
    FuzzyResult,
    WeatherData,
    ZoneStatus,
)
from services.fcm_service import send_flood_alerts
from services.spatial_service import compute_sbl_per_zone
from services.weather_service import fetch_current_weather

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/flood", tags=["Flood Risk"])

# In-memory history buffer (keeps latest 50 evaluations)
# Buffer riwayat dalam memori (menyimpan 50 evaluasi terakhir)
_evaluation_history: Deque[FloodHistoryEntry] = deque(maxlen=50)

# Cached latest evaluation
_latest_status: Optional[FloodStatusResponse] = None


def get_latest_status() -> Optional[FloodStatusResponse]:
    """Retrieve the most recent flood status evaluation."""
    return _latest_status


async def run_flood_evaluation(
    override_curah_hujan: Optional[float] = None,
    override_durasi_hujan: Optional[float] = None,
) -> FloodStatusResponse:
    """
    Execute full flood evaluation pipeline:
    1. Retrieve weather data (or use override values)
    2. Run Mamdani Fuzzy Inference Engine -> crisp Z*
    3. Compute SBL (Skor Bahaya Lokal) for each spatial zone
    4. Trigger FCM broadcast if any zone reaches Siaga or Awas
    5. Record evaluation into history log
    """
    global _latest_status

    # Step 1: Weather data acquisition
    weather = await fetch_current_weather()
    curah = override_curah_hujan if override_curah_hujan is not None else weather.rainfall_mm
    durasi = override_durasi_hujan if override_durasi_hujan is not None else weather.estimated_duration_hours

    # Update weather object if overridden
    if override_curah_hujan is not None or override_durasi_hujan is not None:
        weather = WeatherData(
            timestamp=datetime.now(timezone.utc),
            temperature_celsius=weather.temperature_celsius,
            humidity_percent=weather.humidity_percent,
            weather_description=f"Simulasi: Curah {curah}mm, Durasi {durasi}j",
            wind_speed_mps=weather.wind_speed_mps,
            rainfall_mm=curah,
            estimated_duration_hours=durasi,
            source="Simulation/Manual Override",
            is_mock=True,
        )

    # Step 2: Mamdani Fuzzy Inference Engine
    fuzzy_raw = compute_flood_risk(curah, durasi)
    fuzzy_result = FuzzyResult(**fuzzy_raw)

    # Step 3: Compute SBL for all spatial zones
    zone_statuses = compute_sbl_per_zone(fuzzy_result.crisp_output_z)

    # Step 4: Check and dispatch FCM push alerts
    fcm_triggered = await send_flood_alerts(zone_statuses)

    # Step 5: Append to history
    now = datetime.now(timezone.utc)
    history_entry = FloodHistoryEntry(
        timestamp=now,
        curah_hujan=curah,
        durasi_hujan=durasi,
        crisp_output_z=fuzzy_result.crisp_output_z,
        status_bahaya=fuzzy_result.status_bahaya,
    )
    _evaluation_history.appendleft(history_entry)

    response = FloodStatusResponse(
        timestamp=now,
        weather=weather,
        fuzzy_result=fuzzy_result,
        zone_statuses=zone_statuses,
        fcm_triggered=fcm_triggered,
        recent_history=list(_evaluation_history)[:10],
    )

    _latest_status = response
    return response


@router.get(
    "/status",
    response_model=FloodStatusResponse,
    summary="Dapatkan Status Risiko Banjir Terkini & SBL Tiap Zona",
    description=(
        "Mengembalikan status bahaya banjir global (Fuzzy Mamdani Crisp Z*), "
        "Skor Bahaya Lokal (SBL) untuk setiap zona poligon Desa Rahong, "
        "status cuaca terkini, dan riwayat evaluasi terbaru. "
        "Dapat menerima parameter simulasi curah hujan & durasi hujan opsional."
    ),
)
async def get_flood_status(
    simulate_curah_hujan: Optional[float] = Query(
        None,
        ge=0.0,
        le=150.0,
        description="Override curah hujan (mm) untuk keperluan pengujian / simulasi",
    ),
    simulate_durasi_hujan: Optional[float] = Query(
        None,
        ge=0.0,
        le=12.0,
        description="Override durasi hujan (jam) untuk keperluan pengujian / simulasi",
    ),
) -> FloodStatusResponse:
    """
    Get current flood risk status and zone SBL scores.
    """
    try:
        # If parameters provided or no previous evaluation, run evaluation
        if simulate_curah_hujan is not None or simulate_durasi_hujan is not None or _latest_status is None:
            return await run_flood_evaluation(
                override_curah_hujan=simulate_curah_hujan,
                override_durasi_hujan=simulate_durasi_hujan,
            )
        return _latest_status
    except Exception as e:
        logger.error(f"Error evaluating flood status: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal menghitung status risiko banjir: {str(e)}",
        )

