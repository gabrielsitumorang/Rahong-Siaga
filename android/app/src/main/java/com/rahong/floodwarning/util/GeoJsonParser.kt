package com.rahong.floodwarning.util

import com.google.android.gms.maps.model.LatLng
import com.rahong.floodwarning.data.remote.dto.GeoFeatureDto
import com.rahong.floodwarning.data.remote.dto.GeoLayerResponse
import com.rahong.floodwarning.domain.model.FloodZone

/**
 * Parser untuk mengubah respons GeoJSON dari server menjadi model domain [FloodZone].
 * Menangani konversi koordinat GeoJSON (longitude, latitude) ke Google Maps [LatLng] (latitude, longitude).
 */
object GeoJsonParser {

    /**
     * Mengubah [GeoLayerResponse] menjadi daftar [FloodZone].
     *
     * @param response Respons DTO GeoJSON dari endpoint `/api/v1/gis/layers`.
     * @return Daftar objek [FloodZone] yang siap dirender di peta.
     */
    fun parse(response: GeoLayerResponse): List<FloodZone> {
        return response.features.mapNotNull { feature ->
            parseFeature(feature)
        }
    }

    private fun parseFeature(feature: GeoFeatureDto): FloodZone? {
        val props = feature.properties
        val geom = feature.geometry
        val tipe = props.tipe.lowercase()

        var polygonPoints = emptyList<LatLng>()
        var polylinePoints = emptyList<LatLng>()
        var markerPosition: LatLng? = null

        when (geom.type) {
            "Polygon" -> {
                polygonPoints = parsePolygonCoordinates(geom.coordinates)
            }
            "LineString" -> {
                polylinePoints = parseLineStringCoordinates(geom.coordinates)
            }
            "Point" -> {
                markerPosition = parsePointCoordinates(geom.coordinates)
            }
        }

        val defaultColor = props.warna ?: when (tipe) {
            "sungai" -> "#2196F3"
            "posko" -> "#4CAF50"
            "genangan" -> "#FF9800"
            else -> "#757575"
        }

        return FloodZone(
            id = props.nama.lowercase().replace(" ", "_"),
            nama = props.nama,
            tipe = tipe,
            koefisien = props.koefisien ?: 1.0,
            warna = defaultColor,
            deskripsi = props.deskripsi ?: "",
            polygonPoints = polygonPoints,
            polylinePoints = polylinePoints,
            markerPosition = markerPosition,
            kapasitas = props.kapasitas
        )
    }

    @Suppress("UNCHECKED_CAST")
    private fun parsePolygonCoordinates(coordinates: Any): List<LatLng> {
        return try {
            // GeoJSON Polygon coordinates: List<List<List<Double>>> (Outer ring is index 0)
            val outerRing = (coordinates as? List<*>)?.firstOrNull() as? List<*> ?: return emptyList()
            outerRing.mapNotNull { coord ->
                val pair = coord as? List<*> ?: return@mapNotNull null
                val lon = (pair.getOrNull(0) as? Number)?.toDouble() ?: return@mapNotNull null
                val lat = (pair.getOrNull(1) as? Number)?.toDouble() ?: return@mapNotNull null
                LatLng(lat, lon)
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun parseLineStringCoordinates(coordinates: Any): List<LatLng> {
        return try {
            // GeoJSON LineString coordinates: List<List<Double>>
            val pointList = coordinates as? List<*> ?: return emptyList()
            pointList.mapNotNull { coord ->
                val pair = coord as? List<*> ?: return@mapNotNull null
                val lon = (pair.getOrNull(0) as? Number)?.toDouble() ?: return@mapNotNull null
                val lat = (pair.getOrNull(1) as? Number)?.toDouble() ?: return@mapNotNull null
                LatLng(lat, lon)
            }
        } catch (e: Exception) {
            emptyList()
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun parsePointCoordinates(coordinates: Any): LatLng? {
        return try {
            // GeoJSON Point coordinates: List<Double> [lon, lat]
            val pair = coordinates as? List<*> ?: return null
            val lon = (pair.getOrNull(0) as? Number)?.toDouble() ?: return null
            val lat = (pair.getOrNull(1) as? Number)?.toDouble() ?: return null
            LatLng(lat, lon)
        } catch (e: Exception) {
            null
        }
    }
}

