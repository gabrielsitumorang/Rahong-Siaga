import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/constants/api_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/alert_level.dart';
import '../../domain/entities/flood_zone.dart';
import '../providers/flood_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(ApiConstants.desaRahongLat, ApiConstants.desaRahongLon);
  FloodZone? _selectedZone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        backgroundColor: AppColors.royalPurpleDeep,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Peta Risiko Spasial & Jalur Evakuasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.paleGold,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              'Pemetaan Zona Cekungan & Sempadan Sungai Desa Rahong',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_pin_circle_rounded, color: AppColors.paleGold),
            tooltip: 'Simulasi GPS di Bantaran Sungai',
            onPressed: () {
              final testLoc = LatLng(-6.8510, 106.7480);
              context.read<FloodProvider>().updateUserLocation(testLoc);
              _mapController.move(testLoc, 16.0);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Simulasi GPS: Posisi Anda diletakkan di dalam Bantaran Sungai Rahong'),
                  backgroundColor: AppColors.royalPurplePrimary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textHeader),
            tooltip: 'Segarkan Layer Peta',
            onPressed: () => context.read<FloodProvider>().refreshData(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.royalPurplePrimary,
        foregroundColor: AppColors.paleGold,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.paleGoldMuted, width: 1.5),
        ),
        child: const Icon(Icons.center_focus_strong_rounded, size: 26),
        onPressed: () => _mapController.move(_center, 15.0),
      ),
      body: Consumer<FloodProvider>(
        builder: (context, provider, child) {
          final zones = provider.zones;

          // 1. Layer Poligon Zonasi Banjir (SBL Color-Coded)
          final polygons = zones.where((z) => z.isPolygon).map((z) {
            final level = z.alertLevel ?? AlertLevel.aman;
            return Polygon(
              points: z.polygonPoints,
              color: level.color.withOpacity(0.38),
              borderColor: level.color,
              borderStrokeWidth: 3.0,
              isFilled: true,
            );
          }).toList();

          // 2. Layer Garis Aliran Sungai Rahong
          final polylines = zones.where((z) => z.isPolyline).map((z) {
            return Polyline(
              points: z.polylinePoints,
              color: const Color(0xFF0284C7),
              strokeWidth: 5.5,
            );
          }).toList();

          // 3. Layer Marker
          final markers = <Marker>[];

          if (provider.userLocation != null) {
            markers.add(
              Marker(
                point: provider.userLocation!,
                width: 42,
                height: 42,
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: AppColors.paleGold,
                  size: 42,
                ),
              ),
            );
          }

          for (final z in zones.where((z) => z.isMarker)) {
            if (z.markerPosition != null) {
              final isPosko = z.tipe == 'posko';
              markers.add(
                Marker(
                  point: z.markerPosition!,
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedZone = z);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.royalPurpleDeep,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPosko ? AppColors.statusAman : AppColors.statusSiaga,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isPosko ? Icons.health_and_safety_rounded : Icons.warning_rounded,
                        color: isPosko ? AppColors.statusAman : AppColors.statusSiaga,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 15.0,
                  onTap: (_, __) {
                    setState(() => _selectedZone = null);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.rahong.floodwarning',
                  ),
                  PolygonLayer(polygons: polygons),
                  PolylineLayer(polylines: polylines),
                  MarkerLayer(markers: markers),
                ],
              ),

              // Banner Geofencing Darurat
              if (provider.isUserInDanger)
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBE123C), Color(0xFF4C0519)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.paleGold, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.statusAwas.withOpacity(0.4),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.paleGold, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'GEOFENCE CRITICAL: Anda berada di dalam ${provider.dangerZoneName}! Segera evakuasi.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom Popover Detail Sheet saat Marker / Zona disentuh
              if (_selectedZone != null)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.royalPurpleSurface,
                          AppColors.surfaceCard,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderGold, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black87,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedZone!.nama,
                              style: const TextStyle(
                                color: AppColors.paleGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                              onPressed: () => setState(() => _selectedZone = null),
                            ),
                          ],
                        ),
                        if (_selectedZone!.kapasitas != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Kapasitas Daya Tampung: ${_selectedZone!.kapasitas} Jiwa (Area Aman)',
                            style: const TextStyle(
                              color: AppColors.statusAman,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _selectedZone!.deskripsi,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
