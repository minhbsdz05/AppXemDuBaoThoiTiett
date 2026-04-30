// lib/features/weather/presentation/widgets/daily_forecast_section.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// --- MOCK ENTITY ---
class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String iconCode;
  final int rainChance;
  final int humidity;
  final double windSpeed;
  final DateTime sunrise;
  final DateTime sunset;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.iconCode,
    required this.rainChance,
    required this.humidity,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
  });
}

class DailyForecastSection extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;

  const DailyForecastSection({
    super.key,
    this.isLoading = false,
    this.errorMessage,
  });

  // >>> ĐÃ ĐỔI TÊN THÀNH PUBLIC METHOD ĐỂ TRANG HOME CÓ THỂ GỌI TRUYỀN CHO AI <<<
  List<DailyForecast> getMockData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return DailyForecast(
        date: now.add(Duration(days: index)),
        maxTemp: 28.0 + (index % 3),
        minTemp: 18.0 + (index % 2),
        iconCode: index % 3 == 0 ? '10d' : (index % 2 == 0 ? '03d' : '01d'),
        rainChance: (index % 4) * 20,
        humidity: 60 + (index * 2),
        windSpeed: 3.5 + index,
        sunrise: DateTime(now.year, now.month, now.day, 6, 15),
        sunset: DateTime(now.year, now.month, now.day, 18, 30),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _DailySkeletonLoader();
    if (errorMessage != null) return _buildErrorState(errorMessage!);

    // Đã cập nhật gọi hàm getMockData ở đây
    final data = getMockData();
    if (data.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 16),
                child: Text(
                  'DỰ BÁO 7 NGÀY TỚI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              // ListView hiển thị các ngày
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                itemBuilder: (context, index) {
                  return _DailyForecastItem(
                    data: data[index],
                    isToday: index == 0,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(error, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

// ===================================================================
// WIDGET CON: ITEM TỪNG NGÀY (CÓ STATE ĐỂ EXPAND/COLLAPSE)
// ===================================================================
class _DailyForecastItem extends StatefulWidget {
  final DailyForecast data;
  final bool isToday;

  const _DailyForecastItem({required this.data, required this.isToday});

  @override
  State<_DailyForecastItem> createState() => _DailyForecastItemState();
}

class _DailyForecastItemState extends State<_DailyForecastItem> {
  bool _isExpanded = false;

  IconData _getSmallIcon(String iconCode) {
    if (iconCode.contains('01')) return Icons.wb_sunny;
    if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04'))
      return Icons.cloud;
    if (iconCode.contains('09') || iconCode.contains('10'))
      return Icons.water_drop;
    if (iconCode.contains('11')) return Icons.thunderstorm;
    if (iconCode.contains('13')) return Icons.ac_unit;
    return Icons.cloud;
  }

  String _formatDay(DateTime date) {
    if (widget.isToday) return 'Hôm nay';
    return DateFormat('EEEE', 'vi').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: Column(
            children: [
              // --- PHẦN HEADER LUÔN HIỂN THỊ ---
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      _formatDay(widget.data.date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.data.rainChance > 0) ...[
                          Text(
                            '${widget.data.rainChance}%',
                            style: const TextStyle(
                              color: Colors.lightBlueAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        Icon(
                          _getSmallIcon(widget.data.iconCode),
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.data.minTemp.round()}°',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 16,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.data.maxTemp.round()}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // --- PHẦN CHI TIẾT ẨN/HIỆN (EXPAND) ---
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailItem(
                        Icons.air,
                        'Gió',
                        '${widget.data.windSpeed} km/h',
                      ),
                      _buildDetailItem(
                        Icons.water_drop_outlined,
                        'Độ ẩm',
                        '${widget.data.humidity}%',
                      ),
                      _buildDetailItem(
                        Icons.wb_sunny_outlined,
                        'UV',
                        'Cao (8)',
                      ),
                      _buildDetailItem(
                        Icons.brightness_4,
                        'Hoàng hôn',
                        DateFormat('HH:mm').format(widget.data.sunset),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }
}

// ===================================================================
// WIDGET SKELETON
// ===================================================================
class _DailySkeletonLoader extends StatelessWidget {
  const _DailySkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.3),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            ...List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
