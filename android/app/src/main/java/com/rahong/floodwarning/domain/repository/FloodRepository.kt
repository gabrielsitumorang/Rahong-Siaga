package com.rahong.floodwarning.domain.repository

import com.rahong.floodwarning.data.remote.dto.FloodStatusResponse
import com.rahong.floodwarning.data.remote.dto.GeoLayerResponse
import com.rahong.floodwarning.data.remote.dto.WeatherResponse
import com.rahong.floodwarning.domain.model.Resource
import kotlinx.coroutines.flow.Flow

/**
 * Interface repository untuk akses data banjir.
 *
 * Mendefinisikan kontrak akses data yang digunakan oleh use case di lapisan domain.
 * Implementasi konkret terdapat di lapisan data ([FloodRepositoryImpl]).
 *
 * Semua fungsi mengembalikan [Flow] yang memancarkan [Resource] untuk menangani
 * state loading, success, dan error secara reaktif.
 */
interface FloodRepository {

    /**
     * Mengambil status banjir terkini dari server.
     *
     * @return Flow yang memancarkan [Resource] berisi [FloodStatusResponse].
     */
    fun getFloodStatus(): Flow<Resource<FloodStatusResponse>>

    /**
     * Mengambil data cuaca terkini dari sensor.
     *
     * @return Flow yang memancarkan [Resource] berisi [WeatherResponse].
     */
    fun getCurrentWeather(): Flow<Resource<WeatherResponse>>

    /**
     * Mengambil layer GIS (GeoJSON) untuk ditampilkan di peta.
     *
     * @return Flow yang memancarkan [Resource] berisi [GeoLayerResponse].
     */
    fun getGeoLayers(): Flow<Resource<GeoLayerResponse>>
}
