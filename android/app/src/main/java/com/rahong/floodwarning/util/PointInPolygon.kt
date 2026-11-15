package com.rahong.floodwarning.util

import com.google.android.gms.maps.model.LatLng

/**
 * Utilitas untuk deteksi geofencing spasial menggunakan algoritma Ray-Casting (Point-in-Polygon).
 *
 * Digunakan untuk mendeteksi apakah lokasi GPS pengguna berada di dalam batas poligon
 * zona rawan banjir (misalnya Zona Bantaran Sungai Rahong).
 */
object PointInPolygon {

    /**
     * Memeriksa apakah suatu titik koordinat (latitude, longitude) berada di dalam poligon.
     * Menggunakan algoritma ray-casting Jordan curve theorem.
     *
     * @param point Titik koordinat pengujian (posisi pengguna).
     * @param polygon Daftar titik batas poligon (vertex).
     * @return true jika titik berada di dalam poligon, false jika di luar.
     */
    fun isPointInPolygon(point: LatLng, polygon: List<LatLng>): Boolean {
        if (polygon.size < 3) return false

        var inside = false
        val x = point.longitude
        val y = point.latitude

        var j = polygon.size - 1
        for (i in polygon.indices) {
            val xi = polygon[i].longitude
            val yi = polygon[i].latitude
            val xj = polygon[j].longitude
            val yj = polygon[j].latitude

            // Ray-casting formula: intersect test
            val intersect = ((yi > y) != (yj > y)) &&
                    (x < (xj - xi) * (y - yi) / (yj - yi) + xi)

            if (intersect) {
                inside = !inside
            }
            j = i
        }

        return inside
    }

    /**
     * Menghitung jarak perkiraan dalam meter antara dua titik koordinat (Haversine formula).
     *
     * @param start Titik awal.
     * @param end Titik akhir (misalnya posko evakuasi).
     * @return Jarak dalam meter.
     */
    fun calculateDistanceMeters(start: LatLng, end: LatLng): Double {
        val earthRadius = 6371000.0 // meter
        val dLat = Math.toRadians(end.latitude - start.latitude)
        val dLon = Math.toRadians(end.longitude - start.longitude)

        val a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(start.latitude)) * Math.cos(Math.toRadians(end.latitude)) *
                Math.sin(dLon / 2) * Math.sin(dLon / 2)

        val c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        return earthRadius * c
    }
}

