// lib/features/weather/presentation/pages/weather_analytics_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// --- MOCK DATA MODEL ---
// Dùng để vẽ UI biểu đồ phân tích 24h.
// Trong thực tế, bạn có thể lấy dữ liệu này từ One Call API của OWM.
class AnalyticsData {
  final DateTime time;
  final double temp;
  final double humidity;
  final double pressure;

  AnalyticsData(this.time, this.temp, this.humidity, this.pressure);
}

class WeatherAnalyticsPage extends StatelessWidget {
  final String cityName;

  const WeatherAnalyticsPage({super.key, required this.cityName});

  // Sinh dữ liệu giả lập cho 24 giờ tới (8 mốc x 3 tiếng)
  List<AnalyticsData> get _mockData {
    final now = DateTime.now();
    return List.generate(8, (index) {
      double t = 22.0 + (index % 4) * 2.5 - (index > 4 ? 3 : 0);
      double h = 60.0 + (index % 3) * 10;
      double p = 1010.0 + (index % 2) * 5;
      return AnalyticsData(now.add(Duration(hours: index * 3)), t, h, p);
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = _mockData;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Phân tích: $cityName',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CHỈ SỐ CHẤT LƯỢNG KHÔNG KHÍ (AQI)
                _buildAQICard(),
                const SizedBox(height: 24),

                // 2. BIỂU ĐỒ NHIỆT ĐỘ (Nóng/Lạnh)
                _buildSectionTitle('Biến thiên Nhiệt độ (°C)'),
                const SizedBox(height: 12),
                _buildChartCard(_buildTemperatureChart(data)),
                const SizedBox(height: 24),

                // 3. BIỂU ĐỒ ĐỘ ẨM (Area Chart)
                _buildSectionTitle('Độ ẩm không khí (%)'),
                const SizedBox(height: 12),
                _buildChartCard(_buildHumidityChart(data)),
                const SizedBox(height: 24),

                // 4. BIỂU ĐỒ ÁP SUẤT (Dashed Line)
                _buildSectionTitle('Áp suất khí quyển (hPa)'),
                const SizedBox(height: 12),
                _buildChartCard(_buildPressureChart(data)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET: THẺ AQI (AIR QUALITY INDEX)
  // ==========================================
  Widget _buildAQICard() {
    // Giả lập AQI mức 42 (Tốt)
    int aqiValue = 42;
    Color aqiColor = Colors.greenAccent;
    String aqiStatus = 'TỐT';
    String aqiDesc =
        'Chất lượng không khí lý tưởng. Bạn có thể thoải mái tham gia các hoạt động ngoài trời.';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: aqiColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: aqiColor.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: aqiColor, width: 4),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        aqiValue.toString(),
                        style: TextStyle(
                          color: aqiColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Text(
                        'AQI',
                        style: TextStyle(
                          color: aqiColor.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: aqiColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        aqiStatus,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      aqiDesc,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildChartCard(Widget chart) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 200,
          padding: const EdgeInsets.only(
            top: 30,
            bottom: 10,
            left: 10,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: chart,
        ),
      ),
    );
  }

  // ==========================================
  // CHART 1: NHIỆT ĐỘ (LINE CHART VÀNG)
  // ==========================================
  Widget _buildTemperatureChart(List<AnalyticsData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
        ),
        titlesData: _buildTitles(data),
        borderData: FlBorderData(show: false),
        minY: data.map((e) => e.temp).reduce((a, b) => a < b ? a : b) - 2,
        maxY: data.map((e) => e.temp).reduce((a, b) => a > b ? a : b) + 2,
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.temp))
                .toList(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: Colors.amberAccent,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: Colors.amberAccent,
                    strokeWidth: 2,
                    strokeColor: Colors.black,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.amberAccent.withOpacity(0.3),
                  Colors.transparent,
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

  // ==========================================
  // CHART 2: ĐỘ ẨM (AREA CHART XANH)
  // ==========================================
  Widget _buildHumidityChart(List<AnalyticsData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
        ),
        titlesData: _buildTitles(data),
        borderData: FlBorderData(show: false),
        minY: 40,
        maxY: 100, // Độ ẩm %
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.humidity))
                .toList(),
            isCurved: true,
            color: Colors.lightBlueAccent,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlueAccent.withOpacity(0.5),
                  Colors.lightBlueAccent.withOpacity(0.0),
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

  // ==========================================
  // CHART 3: ÁP SUẤT (LINE CHART TÍM)
  // ==========================================
  Widget _buildPressureChart(List<AnalyticsData> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
        ),
        titlesData: _buildTitles(data),
        borderData: FlBorderData(show: false),
        minY: 1000,
        maxY: 1025, // Áp suất chuẩn hPa
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.pressure))
                .toList(),
            isCurved: true,
            color: Colors.deepPurpleAccent,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: Colors.deepPurpleAccent,
                    strokeWidth: 0,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // Cấu hình chung cho trục X (thời gian) và Y (giá trị)
  FlTitlesData _buildTitles(List<AnalyticsData> data) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 2,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < data.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('HH:mm').format(data[value.toInt()].time),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
