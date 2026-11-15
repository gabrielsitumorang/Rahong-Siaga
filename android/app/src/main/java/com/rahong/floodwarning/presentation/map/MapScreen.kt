package com.rahong.floodwarning.presentation.map

import android.graphics.Color as AndroidColor
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.MyLocation
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*
import com.rahong.floodwarning.domain.model.AlertLevel
import com.rahong.floodwarning.domain.model.FloodZone
import com.rahong.floodwarning.presentation.theme.*

private val DESA_RAHONG_CENTER = LatLng(-6.8500, 106.7500)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    viewModel: MapViewModel,
    onNavigateBack: () -> Unit = {}
) {
    val state by viewModel.uiState.collectAsState()
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(DESA_RAHONG_CENTER, 14.8f)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Peta Risiko & Evakuasi", style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold))
                        Text("Desa Rahong", style = MaterialTheme.typography.bodySmall)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Kembali")
                    }
                },
                actions = {
                    IconButton(onClick = { viewModel.loadMapData() }) {
                        Icon(imageVector = Icons.Default.Refresh, contentDescription = "Segarkan")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(
                onClick = {
                    cameraPositionState.move(CameraUpdateFactory.newLatLngZoom(DESA_RAHONG_CENTER, 15f))
                },
                containerColor = PrimaryBlue,
                contentColor = Color.White
            ) {
                Icon(imageVector = Icons.Default.MyLocation, contentDescription = "Pusatkan Peta")
            }
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            GoogleMap(
                modifier = Modifier.fillMaxSize(),
                cameraPositionState = cameraPositionState,
                uiSettings = MapUiSettings(
                    zoomControlsEnabled = false,
                    myLocationButtonEnabled = false
                )
            ) {
                // 1. Render Poligon Zona Risiko Banjir
                state.zones.filter { it.isPolygon }.forEach { zone ->
                    val colorHex = zone.effectiveColor
                    val parsedColor = try {
                        AndroidColor.parseColor(colorHex)
                    } catch (e: Exception) {
                        AndroidColor.GRAY
                    }

                    val fillColor = Color(
                        red = AndroidColor.red(parsedColor) / 255f,
                        green = AndroidColor.green(parsedColor) / 255f,
                        blue = AndroidColor.blue(parsedColor) / 255f,
                        alpha = 0.40f // Semi-transparan 40%
                    )
                    val strokeColor = Color(
                        red = AndroidColor.red(parsedColor) / 255f,
                        green = AndroidColor.green(parsedColor) / 255f,
                        blue = AndroidColor.blue(parsedColor) / 255f,
                        alpha = 0.90f
                    )

                    Polygon(
                        points = zone.polygonPoints,
                        fillColor = fillColor,
                        strokeColor = strokeColor,
                        strokeWidth = 4f,
                        clickable = true,
                        onClick = { viewModel.selectFeature(zone) }
                    )
                }

                // 2. Render Aliran Sungai (Polyline)
                state.zones.filter { it.isPolyline }.forEach { river ->
                    Polyline(
                        points = river.polylinePoints,
                        color = Color(0xFF1976D2), // Biru sungai
                        width = 8f,
                        clickable = true,
                        onClick = { viewModel.selectFeature(river) }
                    )
                }

                // 3. Render Marker (Posko Evakuasi & Titik Genangan)
                state.zones.filter { it.isMarker }.forEach { markerZone ->
                    val pos = markerZone.markerPosition ?: return@forEach
                    val isPosko = markerZone.tipe == "posko"

                    Marker(
                        state = rememberMarkerState(position = pos),
                        title = markerZone.nama,
                        snippet = if (isPosko) "Kapasitas: ${markerZone.kapasitas ?: "-"} Jiwa" else "Titik Genangan Historis",
                        icon = if (isPosko) {
                            BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN)
                        } else {
                            BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE)
                        },
                        onClick = {
                            viewModel.selectFeature(markerZone)
                            false
                        }
                    )
                }
            }

            // Banner Deteksi Bahaya Geofencing (Jika pengguna berada dalam zona rawan)
            if (state.isUserInDangerZone) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp)
                        .align(Alignment.TopCenter),
                    colors = CardDefaults.cardColors(containerColor = FloodRed),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(12.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(imageVector = Icons.Default.Warning, contentDescription = null, tint = Color.White)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "PERINGATAN: Anda terdeteksi berada di dalam ${state.dangerZoneName}! Segera evakuasi.",
                            color = Color.White,
                            style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                        )
                    }
                }
            }

            // Bottom Detail Sheet saat fitur di peta diklik
            val selected = state.selectedFeature
            if (selected != null) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp)
                        .align(Alignment.BottomCenter),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                    elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = selected.nama,
                                style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                            )
                            IconButton(onClick = { viewModel.selectFeature(null) }) {
                                Text("✕", style = MaterialTheme.typography.titleMedium)
                            }
                        }

                        if (selected.isPolygon) {
                            val alert = selected.alertLevel ?: AlertLevel.AMAN
                            Text(
                                text = "Status Bahaya: ${alert.label} (SBL: ${"%.1f".format(selected.sblScore ?: 0.0)})",
                                style = MaterialTheme.typography.bodyMedium.copy(
                                    fontWeight = FontWeight.SemiBold,
                                    color = when (alert) {
                                        AlertLevel.AMAN -> FloodGreenDark
                                        AlertLevel.WASPADA -> FloodYellowDark
                                        AlertLevel.SIAGA -> FloodOrangeDark
                                        AlertLevel.AWAS -> FloodRedDark
                                    }
                                )
                            )
                            Text(
                                text = "Koefisien Spasial Kerentanan: ${selected.koefisien}",
                                style = MaterialTheme.typography.bodySmall
                            )
                        } else if (selected.tipe == "posko") {
                            Text(
                                text = "Fasilitas Pengungsian Aman — Kapasitas: ${selected.kapasitas} Jiwa",
                                style = MaterialTheme.typography.bodyMedium.copy(color = FloodGreenDark)
                            )
                        }

                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = selected.deskripsi,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

