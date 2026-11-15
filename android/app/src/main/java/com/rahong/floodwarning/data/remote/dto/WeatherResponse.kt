package com.rahong.floodwarning.data.remote.dto

import com.google.gson.annotations.SerializedName

/**
 * DTO (Data Transfer Object) untuk respons data cuaca dari API.
 *
 * Memetakan field JSON dari endpoint `/api/v1/weather/current`.
 *
 * @property curahHujan Curah hujan dalam milimeter (mm).
 * @property durasiHujan Durasi hujan dalam menit.
 * @property suhu Suhu udara dalam derajat Celsius.
 * @property kelembapan Kelembapan relatif dalam persen (%).
 * @property deskripsi Deskripsi kondisi cuaca saat ini.
 * @property timestamp Waktu pengambilan data dalam format ISO 8601.
 */
data class WeatherResponse(
    @SerializedName("curah_hujan")
    val curahHujan: Double,

    @SerializedName("durasi_hujan")
    val durasiHujan: Int,

    @SerializedName("suhu")
    val suhu: Double,

    @SerializedName("kelembapan")
    val kelembapan: Double,

    @SerializedName("deskripsi")
    val deskripsi: String,

    @SerializedName("timestamp")
    val timestamp: String
)
