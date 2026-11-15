package com.rahong.floodwarning.domain.usecase

import com.rahong.floodwarning.data.remote.dto.GeoLayerResponse
import com.rahong.floodwarning.domain.model.Resource
import com.rahong.floodwarning.domain.repository.FloodRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

/**
 * Use case untuk mengambil layer GIS (GeoJSON).
 *
 * Membungkus pemanggilan repository untuk mendapatkan data layer peta
 * yang berisi zona banjir, aliran sungai, posko evakuasi, dan titik genangan.
 *
 * @property repository Repository untuk akses data GIS.
 */
class GetGeoLayersUseCase @Inject constructor(
    private val repository: FloodRepository
) {

    /**
     * Menjalankan use case untuk mengambil layer GIS.
     *
     * @return [Flow] yang memancarkan [Resource] berisi [GeoLayerResponse].
     */
    operator fun invoke(): Flow<Resource<GeoLayerResponse>> {
        return repository.getGeoLayers()
    }
}
