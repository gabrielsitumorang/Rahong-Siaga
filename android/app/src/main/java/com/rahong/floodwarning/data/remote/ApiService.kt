package com.rahong.floodwarning.data.remote

import com.rahong.floodwarning.data.remote.dto.FloodStatusResponse
import com.rahong.floodwarning.data.remote.dto.GeoLayerResponse
import com.rahong.floodwarning.data.remote.dto.WeatherResponse
import retrofit2.http.GET

/**
 * Interface Retrofit untuk komunikasi dengan backend API
 * Sistem Peringatan Dini Banjir Desa Rahong.
 *
 * Semua endpoint menggunakan suspend function untuk mendukung
 * pemanggilan asinkron menggunakan Kotlin Coroutines.
 */
interface ApiService {

    /**
     * Mengambil data cuaca terkini dari sensor.
     *
     * @return [WeatherResponse] berisi data curah hujan, suhu, kelembapan, dan lainnya.
     */
    @GET("api/v1/weather/current")
    suspend fun getCurrentWeather(): WeatherResponse

    /**
     * Mengambil status banjir terkini berdasarkan analisis fuzzy dan SBL.
     *
     * @return [FloodStatusResponse] berisi skor fuzzy global dan status per zona.
     */
    @GET("api/v1/flood/status")
    suspend fun getFloodStatus(): FloodStatusResponse

    /**
     * Mengambil layer GIS dalam format GeoJSON untuk ditampilkan di peta.
     *
     * @return [GeoLayerResponse] berisi FeatureCollection GeoJSON.
     */
    @GET("api/v1/gis/layers")
    suspend fun getGeoLayers(): GeoLayerResponse
}
