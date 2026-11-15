package com.rahong.floodwarning.presentation.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.rahong.floodwarning.domain.model.AlertLevel
import com.rahong.floodwarning.presentation.theme.*

/**
 * Banner Peringatan Darurat resolusi tinggi di bagian atas layar Dashboard dan Peta.
 */
@Composable
fun AlertBanner(
    highestAlert: AlertLevel,
    affectedZoneName: String,
    actionMessage: String,
    modifier: Modifier = Modifier,
    onEvacuateClick: () -> Unit = {}
) {
    val isEmergency = highestAlert == AlertLevel.SIAGA || highestAlert == AlertLevel.AWAS

    AnimatedVisibility(
        visible = isEmergency,
        enter = fadeIn(),
        exit = fadeOut()
    ) {
        val bannerBg = if (highestAlert == AlertLevel.AWAS) FloodRed else FloodOrange
        val titleText = if (highestAlert == AlertLevel.AWAS) {
            "🚨 PERINGATAN DARURAT: STATUS AWAS!"
        } else {
            "⚠️ PERINGATAN WASPADA TINGGI: STATUS SIAGA"
        }

        Card(
            modifier = modifier
                .fillMaxWidth()
                .padding(8.dp),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = bannerBg),
            elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = "Peringatan",
                        tint = Color.White,
                        modifier = Modifier.size(28.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = titleText,
                        style = MaterialTheme.typography.titleMedium.copy(
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                    )
                }

                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Zona Terdampak: $affectedZoneName",
                    style = MaterialTheme.typography.bodyMedium.copy(
                        fontWeight = FontWeight.SemiBold,
                        color = Color.White
                    )
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = actionMessage,
                    style = MaterialTheme.typography.bodySmall.copy(color = Color.White.copy(alpha = 0.95f))
                )

                if (highestAlert == AlertLevel.AWAS) {
                    Spacer(modifier = Modifier.height(12.dp))
                    Button(
                        onClick = onEvacuateClick,
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color.White,
                            contentColor = FloodRedDark
                        ),
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text(
                            text = "LIHAT JALUR & POSKO EVAKUASI TERDEKAT",
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        }
    }
}

