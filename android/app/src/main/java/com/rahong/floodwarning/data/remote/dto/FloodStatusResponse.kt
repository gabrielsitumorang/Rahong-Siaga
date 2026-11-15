package com.rahong.floodwarning.data.remote.dto

import com.google.gson.annotations.SerializedName

/**
 * DTO untuk respons status banjir dari API.
 * Mendukung alias nama field agar kompatibel dengan berbagai versi API.
 */
data class FloodStatusResponse(
    @SerializedName(value = "fuzzy_global", alternate = ["fuzzy_result"])
    val fuzzyGlobal: FuzzyGlobalDto,

    @SerializedName(value = "zones", alternate = ["zone_statuses"])
    val zones: List<ZoneStatusDto>,

    @SerializedName(value = "last_updated", alternate = ["timestamp"])
    val lastUpdated: String
)

/**
 * DTO untuk hasil analisis fuzzy global.
 */
data class FuzzyGlobalDto(
    @SerializedName("crisp_output_z")
    val crispOutputZ: Double,

    @SerializedName("status_bahaya")
    val statusBahaya: String
)

/**
 * DTO untuk status banjir setiap zona.
 */
data class ZoneStatusDto(
    @SerializedName(value = "nama", alternate = ["zone_name"])
    val nama: String,

    @SerializedName("sbl_score")
    val sblScore: Double,

    @SerializedName("status")
    val status: String,

    @SerializedName(value = "koefisien", alternate = ["koefisien_spasial"])
    val koefisien: Double,

    @SerializedName("warna")
    val warna: String
)
