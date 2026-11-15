"""
Background Scheduler for Desa Rahong Flood Early Warning System.
Penjadwal latar belakang untuk Sistem Peringatan Dini Banjir Desa Rahong.

Periodically fetches weather data, executes Mamdani fuzzy evaluation,
calculates SBL for each zone, and triggers FCM alerts if danger thresholds are reached.
"""

import logging
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.interval import IntervalTrigger

from config import settings

logger = logging.getLogger(__name__)

# Singleton scheduler instance
scheduler = AsyncIOScheduler()


async def scheduled_flood_pipeline_job():
    """
    Scheduled job executed periodically (every 10-15 minutes).
    Tugas terjadwal yang dijalankan secara berkala (tiap 10-15 menit).
    """
    logger.info("Memulai siklus evaluasi terjadwal risiko banjir Desa Rahong...")
    try:
        from routes.flood import run_flood_evaluation
        result = await run_flood_evaluation()
        logger.info(
            f"Evaluasi terjadwal selesai. Cuaca: {result.weather.rainfall_mm}mm/{result.weather.estimated_duration_hours}h, "
            f"Crisp Z*: {result.fuzzy_result.crisp_output_z:.2f} ({result.fuzzy_result.status_bahaya}), "
            f"FCM Triggered: {result.fcm_triggered}"
        )
    except Exception as e:
        logger.error(f"Error dalam siklus evaluasi terjadwal: {e}", exc_info=True)


def start_scheduler():
    """
    Start the background asyncio scheduler.
    Memulai scheduler asyncio latar belakang.
    """
    if not scheduler.running:
        interval = settings.FETCH_INTERVAL_MINUTES
        scheduler.add_job(
            scheduled_flood_pipeline_job,
            trigger=IntervalTrigger(minutes=interval),
            id="flood_pipeline_job",
            name="Periodic Flood Risk Evaluation",
            replace_existing=True,
        )
        scheduler.start()
        logger.info(f"Scheduler berhasil dimulai dengan interval {interval} menit.")


def stop_scheduler():
    """
    Gracefully shut down the background scheduler.
    Hentikan scheduler latar belakang dengan aman.
    """
    if scheduler.running:
        scheduler.shutdown(wait=False)
        logger.info("Scheduler berhasil dihentikan.")

