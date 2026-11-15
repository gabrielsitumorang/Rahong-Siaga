package com.rahong.floodwarning.domain.model

import com.google.android.gms.maps.model.LatLng

/**
 * Model domain yang merepresentasikan zona banjir di Desa Rahong.
 *
 * Setiap zona memiliki geometri poligon untuk ditampilkan di peta,
 * properti metadata, dan status peringatan terkini.
 *
 * @property id Identifier unik zona.
 * @property nama Nama zona wilayah (misalnya "Zona Bantaran Sungai").
 * @property tipe Tipe layer GIS: "zona", "sungai", "posko", "genangan".
 * @property koefisien Koefisien kerentanan zona terhadap banjir (0.0–1.0).
 * @property warna Kode warna heksadesimal untuk visualisasi.
 * @property deskripsi Deskripsi tambahan tentang zona.
 * @property sblScore Skor Sub-Basin Level terkini. Null jika belum tersedia.
 * @property alertLevel Level peringatan terkini. Null jika belum tersedia.
 * @property polygonPoints Daftar titik koordinat poligon untuk rendering di peta.
 * @property polylinePoints Daftar titik untuk polyline (khusus tipe sungai).
 * @property markerPosition Posisi marker (khusus tipe posko/genangan).
 * @property kapasitas Kapasitas tampung (khusus posko evakuasi). Null untuk lainnya.
 */
data class FloodZone(
    val id: String,
    val nama: String,
    val tipe: String,
    val koefisien: Double = 0.0,
    val warna: String = "#808080",
    val deskripsi: String = "",
    val sblScore: Double? = null,
    val alertLevel: AlertLevel? = null,
    val polygonPoints: List<LatLng> = emptyList(),
    val polylinePoints: List<LatLng> = emptyList(),
    val markerPosition: LatLng? = null,
    val kapasitas: Int? = null
) {

    /**
     * Memeriksa apakah zona ini adalah tipe poligon (zona banjir).
     */
    val isPolygon: Boolean
        get() = tipe == "zona" && polygonPoints.isNotEmpty()

    /**
     * Memeriksa apakah zona ini adalah tipe polyline (sungai).
     */
    val isPolyline: Boolean
        get() = tipe == "sungai" && polylinePoints.isNotEmpty()

    /**
     * Memeriksa apakah zona ini adalah tipe marker (posko atau genangan).
     */
    val isMarker: Boolean
        get() = (tipe == "posko" || tipe == "genangan") && markerPosition != null

    /**
     * Mengembalikan warna efektif berdasarkan alert level jika tersedia,
     * atau warna default dari properti GeoJSON.
     */
    val effectiveColor: String
        get() = alertLevel?.colorHex ?: warna
}
