// lib/features/weather/presentation/pages/weather_map_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- CÁC PROVIDER QUẢN LÝ TRẠNG THÁI BẢN ĐỒ ---
// 1. Quản lý Layer hiện tại (Mưa, Nhiệt độ, Gió)
final mapLayerProvider = StateProvider<String>((ref) => 'precipitation_new');
// 2. Quản lý Time Slider (UI mô phỏng thời gian)
final timeSliderProvider = StateProvider<double>((ref) => 0);

class WeatherMapPage extends ConsumerWidget {
  final double lat;
  final double lon;
  final String cityName;

  const WeatherMapPage({
    super.key,
    required this.lat,
    required this.lon,
    required this.cityName,
  });

  // API Key của OpenWeatherMap
  static const String apiKey = 'b7f73a4f451c8ee834406c3cfab4a8e9';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLayer = ref.watch(mapLayerProvider);
    final sliderValue = ref.watch(timeSliderProvider);

    return Scaffold(
      body: Stack(
        children: [
          // ==========================================
          // 1. BẢN ĐỒ NỀN (FLUTTER MAP)
          // ==========================================
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                lat,
                lon,
              ), // Tọa độ trung tâm (Lấy từ thành phố)
              initialZoom: 6.0,
              minZoom: 3.0,
              maxZoom: 12.0,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.all &
                    ~InteractiveFlag.rotate, // Cho phép pan, zoom, tắt rotate
              ),
            ),
            children: [
              // Lớp 1: Bản đồ địa hình OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_xem_du_bao_thoi_tiet',
              ),

              // Lớp 2: Overlay Radar Thời tiết từ OpenWeatherMap
              // Chuyển opacity ra ngoài và xóa backgroundColor
              Opacity(
                opacity: 0.6,
                child: TileLayer(
                  urlTemplate:
                      'https://tile.openweathermap.org/map/$currentLayer/{z}/{x}/{y}.png?appid=$apiKey',
                ),
              ),
            ],
          ),

          // ==========================================
          // 2. UI: NÚT BACK (GÓC TRÊN TRÁI)
          // ==========================================
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: _buildGlassButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
          ),

          // ==========================================
          // 3. UI: TIÊU ĐỀ THÀNH PHỐ (GIỮA TRÊN)
          // ==========================================
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 80,
            right: 80,
            child: _buildGlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Radar: $cityName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // 4. UI: NHÓM NÚT CHỌN LAYER (GÓC TRÊN PHẢI)
          // ==========================================
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            right: 16,
            child: Column(
              children: [
                _buildLayerButton(
                  ref,
                  'Lượng mưa',
                  'precipitation_new',
                  Icons.water_drop,
                  currentLayer,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildLayerButton(
                  ref,
                  'Nhiệt độ',
                  'temp_new',
                  Icons.thermostat,
                  currentLayer,
                  Colors.redAccent,
                ),
                const SizedBox(height: 12),
                _buildLayerButton(
                  ref,
                  'Sức gió',
                  'wind_new',
                  Icons.air,
                  currentLayer,
                  Colors.teal,
                ),
                const SizedBox(height: 12),
                _buildLayerButton(
                  ref,
                  'Mây',
                  'clouds_new',
                  Icons.cloud,
                  currentLayer,
                  Colors.grey,
                ),
              ],
            ),
          ),

          // ==========================================
          // 5. UI: TIME SLIDER (GÓC DƯỚI CÙNG)
          // ==========================================
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: _buildGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Dự báo thời gian (Mô phỏng)',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '+${sliderValue.toInt()} Giờ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 36,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: Colors.amberAccent,
                            inactiveTrackColor: Colors.white24,
                            thumbColor: Colors.amber,
                            overlayColor: Colors.amber.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: sliderValue,
                            min: 0,
                            max: 24,
                            divisions: 8,
                            onChanged: (value) {
                              ref.read(timeSliderProvider.notifier).state =
                                  value;
                              // Lưu ý: API Miễn phí không hỗ trợ đổi TileLayer theo thời gian thực
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // WIDGET BỔ TRỢ: Nút bấm kính mờ
  // ==========================================
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BỔ TRỢ: Nút chọn Layer (Bên phải)
  // ==========================================
  Widget _buildLayerButton(
    WidgetRef ref,
    String tooltip,
    String layerCode,
    IconData icon,
    String currentLayer,
    Color activeColor,
  ) {
    final isActive = currentLayer == layerCode;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => ref.read(mapLayerProvider.notifier).state = layerCode,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BỔ TRỢ: Container Kính mờ
  // ==========================================
  Widget _buildGlassContainer({
    required Widget child,
    required EdgeInsets padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
