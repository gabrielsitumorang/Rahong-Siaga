package com.rahong.floodwarning.data.remote.dto

import com.google.gson.annotations.SerializedName

/**
 * DTO untuk respons layer GIS dalam format GeoJSON.
 *
 * Memetakan field JSON dari endpoint `/api/v1/gis/layers`.
 * Mengikuti spesifikasi GeoJSON RFC 7946.
 *
 * @property type Tipe GeoJSON, biasanya "FeatureCollection".
 * @property features Daftar fitur GeoJSON yang berisi geometri dan properti.
 */
data class GeoLayerResponse(
    @SerializedName("type")
    val type: String,

    @SerializedName("features")
    val features: List<GeoFeatureDto>
)

/**
 * DTO untuk satu fitur GeoJSON.
 *
 * @property type Tipe fitur, biasanya "Feature".
 * @property properties Properti metadata dari fitur.
 * @property geometry Geometri spasial (titik, garis, poligon).
 */
data class GeoFeatureDto(
    @SerializedName("type")
    val type: String,

    @SerializedName("properties")
    val properties: GeoPropertiesDto,

    @SerializedName("geometry")
    val geometry: GeoGeometryDto
)

/**
 * DTO untuk properti metadata fitur GeoJSON.
 *
 * @property nama Nama fitur (nama zona, nama sungai, atau nama titik).
 * @property tipe Tipe fitur: "zona", "sungai", "posko", "genangan".
 * @property koefisien Koefisien kerentanan (untuk zona). Null untuk fitur lainnya.
 * @property warna Kode warna heksadesimal untuk visualisasi. Null jika tidak tersedia.
 * @property deskripsi Deskripsi tambahan. Null jika tidak tersedia.
 * @property kapasitas Kapasitas tampung (untuk posko evakuasi). Null untuk fitur lainnya.
 */
data class GeoPropertiesDto(
    @SerializedName("nama")
    val nama: String,

    @SerializedName("tipe")
    val tipe: String,

    @SerializedName("koefisien")
    val koefisien: Double? = null,

    @SerializedName("warna")
    val warna: String? = null,

    @SerializedName("deskripsi")
    val deskripsi: String? = null,

    @SerializedName("kapasitas")
    val kapasitas: Int? = null
)

/**
 * DTO untuk geometri GeoJSON.
 *
 * Mendukung tipe: Point, LineString, Polygon, MultiPolygon.
 * Koordinat disimpan sebagai nested list sesuai spesifikasi GeoJSON.
 *
 * @property type Tipe geometri (Point, LineString, Polygon, MultiPolygon).
 * @property coordinates Koordinat dalam format nested list. Parsing dilakukan berdasarkan [type].
 */
data class GeoGeometryDto(
    @SerializedName("type")
    val type: String,

    @SerializedName("coordinates")
    val coordinates: Any
)
