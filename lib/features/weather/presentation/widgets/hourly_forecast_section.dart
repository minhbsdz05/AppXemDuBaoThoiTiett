// lib/features/weather/presentation/widgets/hourly_forecast_section.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
// DÒNG NÀY RẤT QUAN TRỌNG ĐỂ HẾT LỖI TỪ CHỐI TYPE 'HourlyForecast':
import '../../domain/entities/weather_entity.dart';

class HourlyForecastSection extends StatelessWidget {
  final List<HourlyForecast>
  forecasts; // Nhận data thật từ trang Home truyền vào

  const HourlyForecastSection({super.key, required this.forecasts});

  @override
  Widget build(BuildContext context) {
    if (forecasts.isEmpty) return const SizedBox.shrink();

    const double itemWidth = 70.0;
    final double totalWidth = forecasts.length * itemWidth;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'DỰ BÁO 24 GIỜ TỚI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      width: totalWidth,
                      child: _buildLineChart(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: totalWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: forecasts
                            .map((item) => _buildHourlyItem(item, itemWidth))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    double maxTemp = forecasts
        .map((e) => e.temp)
        .reduce((a, b) => a > b ? a : b);
    double minTemp = forecasts
        .map((e) => e.temp)
        .reduce((a, b) => a < b ? a : b);
    if (maxTemp == minTemp) {
      maxTemp += 1;
      minTemp -= 1;
    }

    List<FlSpot> spots = forecasts
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.temp))
        .toList();

    return LineChart(
      LineChartData(
        minY: minTemp - 2,
        maxY: maxTemp + 2,
        minX: 0,
        maxX: (forecasts.length - 1).toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.4,
            color: Colors.amberAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: Colors.amberAccent,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.amberAccent.withOpacity(0.3),
                  Colors.amberAccent.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyItem(HourlyForecast item, double width) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Text(
            '${item.temp.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Icon(_getSmallIcon(item.iconCode), color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            DateFormat('HH:mm').format(item.time),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.water_drop,
                color: Colors.lightBlueAccent,
                size: 12,
              ),
              const SizedBox(width: 2),
              Text(
                '${item.rainChance}%',
                style: const TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getSmallIcon(String iconCode) {
    if (iconCode.contains('01d')) return Icons.wb_sunny;
    if (iconCode.contains('01n')) return Icons.nightlight_round;
    if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04'))
      return Icons.cloud;
    if (iconCode.contains('09') || iconCode.contains('10'))
      return Icons.water_drop;
    if (iconCode.contains('11')) return Icons.thunderstorm;
    if (iconCode.contains('13')) return Icons.ac_unit;
    return Icons.cloud; // Mặc định
  }
}
