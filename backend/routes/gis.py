"""
GIS API route for Desa Rahong flood early warning system.
Router API GIS untuk sistem peringatan dini banjir Desa Rahong.

Provides GeoJSON layers containing spatial zones, river polyline,
historical flood points, and evacuation shelters.
"""

import logging
from fastapi import APIRouter, HTTPException, status

from models.schemas import GeoLayerResponse
from services.spatial_service import load_geojson

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/gis", tags=["GIS"])


@router.get(
    "/layers",
    response_model=GeoLayerResponse,
    summary="Dapatkan Layer Spasial GeoJSON Desa Rahong",
    description=(
        "Mengembalikan data spasial lengkap dalam format GeoJSON FeatureCollection. "
        "Mencakup poligon zonasi risiko banjir, garis aliran sungai, "
        "posko evakuasi aman, dan titik genangan banjir historis."
    ),
)
async def get_gis_layers() -> GeoLayerResponse:
    """
    Retrieve GeoJSON spatial layers for Desa Rahong.
    Ambil layer spasial GeoJSON untuk Desa Rahong.
    """
    try:
        geojson_data = load_geojson()
        return GeoLayerResponse(
            type=geojson_data.get("type", "FeatureCollection"),
            name=geojson_data.get("name", "Desa Rahong - Spatial Data"),
            features=geojson_data.get("features", []),
            metadata={
                "crs": geojson_data.get("crs", {}),
                "total_features": len(geojson_data.get("features", [])),
                "description": "Layer spasial topografi, zonasi, dan posko evakuasi Desa Rahong",
            },
        )
    except FileNotFoundError as e:
        logger.error(f"GeoJSON file missing: {e}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="File data spasial Desa Rahong tidak ditemukan di server.",
        )
    except Exception as e:
        logger.error(f"Error loading GIS layers: {e}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal memuat data GIS: {str(e)}",
        )

