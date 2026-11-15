package com.rahong.floodwarning.presentation.map

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.maps.model.LatLng
import com.rahong.floodwarning.data.remote.dto.FloodStatusResponse
import com.rahong.floodwarning.domain.model.AlertLevel
import com.rahong.floodwarning.domain.model.FloodZone
import com.rahong.floodwarning.domain.model.Resource
import com.rahong.floodwarning.domain.usecase.GetFloodStatusUseCase
import com.rahong.floodwarning.domain.usecase.GetGeoLayersUseCase
import com.rahong.floodwarning.util.GeoJsonParser
import com.rahong.floodwarning.util.PointInPolygon
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class MapUiState(
    val isLoading: Boolean = false,
    val zones: List<FloodZone> = emptyList(),
    val floodStatus: FloodStatusResponse? = null,
    val userLocation: LatLng? = null,
    val isUserInDangerZone: Boolean = false,
    val dangerZoneName: String? = null,
    val selectedFeature: FloodZone? = null,
    val errorMessage: String? = null
)

@HiltViewModel
class MapViewModel @Inject constructor(
    private val getGeoLayersUseCase: GetGeoLayersUseCase,
    private val getFloodStatusUseCase: GetFloodStatusUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(MapUiState(isLoading = true))
    val uiState: StateFlow<MapUiState> = _uiState.asStateFlow()

    init {
        loadMapData()
        startPeriodicRefresh()
    }

    fun loadMapData() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, errorMessage = null) }

            // 1. Ambil data layer GeoJSON
            getGeoLayersUseCase().collect { geoResource ->
                when (geoResource) {
                    is Resource.Success -> {
                        val parsedZones = geoResource.data?.let { GeoJsonParser.parse(it) } ?: emptyList()

                        // 2. Ambil status SBL terkini untuk mewarnai zona
                        getFloodStatusUseCase().collect { floodResource ->
                            when (floodResource) {
                                is Resource.Success -> {
                                    val statusData = floodResource.data
                                    val updatedZones = correlateZonesWithStatus(parsedZones, statusData)

                                    _uiState.update {
                                        it.copy(
                                            isLoading = false,
                                            zones = updatedZones,
                                            floodStatus = statusData
                                        )
                                    }
                                    checkUserGeofence()
                                }
                                is Resource.Error -> {
                                    _uiState.update {
                                        it.copy(
                                            isLoading = false,
                                            zones = parsedZones,
                                            errorMessage = floodResource.message
                                        )
                                    }
                                }
                                is Resource.Loading -> {}
                            }
                        }
                    }
                    is Resource.Error -> {
                        _uiState.update {
                            it.copy(isLoading = false, errorMessage = geoResource.message)
                        }
                    }
                    is Resource.Loading -> {}
                }
            }
        }
    }

    private fun correlateZonesWithStatus(
        zones: List<FloodZone>,
        status: FloodStatusResponse?
    ): List<FloodZone> {
        if (status == null) return zones

        val statusMap = status.zones.associateBy { it.nama.lowercase() }

        return zones.map { zone ->
            if (zone.isPolygon) {
                val matched = statusMap[zone.nama.lowercase()]
                if (matched != null) {
                    val alert = AlertLevel.fromSblScore(matched.sblScore)
                    zone.copy(
                        sblScore = matched.sblScore,
                        alertLevel = alert,
                        warna = alert.colorHex
                    )
                } else zone
            } else zone
        }
    }

    fun onUserLocationChanged(location: LatLng) {
        _uiState.update { it.copy(userLocation = location) }
        checkUserGeofence()
    }

    fun selectFeature(feature: FloodZone?) {
        _uiState.update { it.copy(selectedFeature = feature) }
    }

    private fun checkUserGeofence() {
        val userLoc = _uiState.value.userLocation ?: return
        val dangerPolygons = _uiState.value.zones.filter {
            it.isPolygon && (it.alertLevel == AlertLevel.SIAGA || it.alertLevel == AlertLevel.AWAS)
        }

        var inDanger = false
        var dangerName: String? = null

        for (zone in dangerPolygons) {
            if (PointInPolygon.isPointInPolygon(userLoc, zone.polygonPoints)) {
                inDanger = true
                dangerName = zone.nama
                break
            }
        }

        _uiState.update {
            it.copy(isUserInDangerZone = inDanger, dangerZoneName = dangerName)
        }
    }

    private fun startPeriodicRefresh() {
        viewModelScope.launch {
            while (true) {
                delay(10 * 60 * 1000L) // Refresh tiap 10 menit
                loadMapData()
            }
        }
    }
}

