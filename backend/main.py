"""
FastAPI Main Application Entry Point
Sistem Peringatan Dini Banjir Berbasis Fuzzy Logic - Desa Rahong

Authors: Senior Android & Backend Engineer & Ahli Sistem Cerdas
Version: 1.0.0
"""

from contextlib import asynccontextmanager
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from config import settings
from routes.flood import router as flood_router, run_flood_evaluation
from routes.gis import router as gis_router
from routes.weather import router as weather_router
from scheduler import start_scheduler, stop_scheduler

# Configure structured logging
logging.basicConfig(
    level=logging.INFO if not settings.DEBUG else logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("FloodWarningBackend")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan manager for startup and shutdown procedures.
    Mengelola startup (start scheduler, pre-warm cache) dan shutdown (stop scheduler).
    """
    logger.info("==================================================")
    logger.info("Memulai Sistem Peringatan Dini Banjir Desa Rahong")
    logger.info(f"Koordinat: ({settings.DESA_RAHONG_LAT}, {settings.DESA_RAHONG_LON})")
    logger.info(f"Interval Pemantauan: {settings.FETCH_INTERVAL_MINUTES} Menit")
    logger.info("==================================================")

    # Pre-warm initial flood evaluation
    try:
        logger.info("Menjalankan evaluasi awal risiko banjir...")
        await run_flood_evaluation()
    except Exception as e:
        logger.warning(f"Gagal melakukan evaluasi awal saat startup: {e}")

    # Start periodic background scheduler
    start_scheduler()

    yield

    # Shutdown procedure
    logger.info("Menghentikan background scheduler...")
    stop_scheduler()
    logger.info("Aplikasi selesai dihentikan.")


app = FastAPI(
    title="Flood Early Warning System API - Desa Rahong",
    description=(
        "Sistem Peringatan Dini Banjir Berbasis Android & Fuzzy Logic Mamdani "
        "dengan Integrasi API Cuaca Real-Time dan Analisis Spasial Topografi Desa Rahong."
    ),
    version="1.0.0",
    lifespan=lifespan,
)

# CORS configuration to allow Android client & web dashboards
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API routes
app.include_router(weather_router)
app.include_router(flood_router)
app.include_router(gis_router)


@app.get("/", tags=["Health Check"])
async def root():
    """
    Root endpoint verifying service health and API configuration.
    """
    return {
        "service": "Desa Rahong Flood Early Warning Backend",
        "status": "healthy",
        "version": "1.0.0",
        "fuzzy_method": "Mamdani (12 Rules, T-Norm MIN, Defuzzifikasi COA 200 Steps)",
        "spatial_integration": "SBL = Min(100, Z* × Koefisien_Spasial)",
        "endpoints": {
            "weather": "/api/v1/weather/current",
            "flood_status": "/api/v1/flood/status",
            "gis_layers": "/api/v1/gis/layers",
            "docs": "/docs",
        },
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

