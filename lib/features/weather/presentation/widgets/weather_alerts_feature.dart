// lib/features/weather/presentation/widgets/weather_alerts_feature.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// ==========================================
// 1. MODEL & STATE (Giả lập SQLite Local DB)
// ==========================================
enum AlertSeverity { extreme, severe, moderate }

class WeatherAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final DateTime time;
  final String source;

  WeatherAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.time,
    required this.source,
  });
}

// Provider quản lý danh sách cảnh báo (Thay thế cho việc gọi SQLite)
final weatherAlertsProvider = StateProvider<List<WeatherAlert>>((ref) {
  return [
    WeatherAlert(
      id: '1',
      title: 'CẢNH BÁO DÔNG LỐC VÀ MƯA ĐÁ',
      description:
          'Qua theo dõi trên ảnh mây vệ tinh, số liệu định vị sét và radar thời tiết cho thấy các vùng mây đối lưu đang phát triển và gây mưa rào. Cảnh báo cấp độ rủi ro thiên tai do lốc, sét, mưa đá: cấp 1. Người dân cần tìm nơi trú ẩn an toàn, tránh xa các trạm điện, cây thụ.',
      severity: AlertSeverity.severe,
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      source: 'Trung tâm Dự báo KTTV Quốc gia',
    ),
    WeatherAlert(
      id: '2',
      title: 'Cảnh báo chỉ số UV ở mức nguy hại',
      description:
          'Chỉ số tia cực tím (UV) vào buổi trưa có thể đạt mức 10-11. Khuyến cáo hạn chế ra đường từ 11h đến 14h, sử dụng kem chống nắng và đồ bảo hộ khi di chuyển ngoài trời.',
      severity: AlertSeverity.moderate,
      time: DateTime.now().subtract(const Duration(hours: 2)),
      source: 'Hệ thống quan trắc Môi trường',
    ),
  ];
});

// ==========================================
// 2. WIDGET: BANNER CẢNH BÁO Ở TRANG CHỦ
// ==========================================
class WeatherAlertBanner extends ConsumerWidget {
  const WeatherAlertBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(weatherAlertsProvider);
    if (alerts.isEmpty) return const SizedBox.shrink();

    final latestAlert = alerts.first; // Lấy cảnh báo mới nhất

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WeatherAlertsListPage()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2), // Màu nền cảnh báo
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amberAccent,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CẢNH BÁO THỜI TIẾT',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          latestAlert.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. PAGE: DANH SÁCH CẢNH BÁO (LIST VIEW)
// ==========================================
class WeatherAlertsListPage extends ConsumerWidget {
  const WeatherAlertsListPage({super.key});

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.extreme:
        return Colors.red;
      case AlertSeverity.severe:
        return Colors.orange;
      case AlertSeverity.moderate:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(weatherAlertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027), // Cùng tone màu nền
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Lịch sử cảnh báo',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          final color = _getSeverityColor(alert.severity);

          return Card(
            color: Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: color.withOpacity(0.5)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Icon(Icons.warning_rounded, color: color, size: 32),
              title: Text(
                alert.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  DateFormat('HH:mm - dd/MM/yyyy').format(alert.time),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
              onTap: () {
                // Mở trang chi tiết
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeatherAlertDetailPage(alert: alert),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. PAGE: CHI TIẾT CẢNH BÁO
// ==========================================
class WeatherAlertDetailPage extends StatelessWidget {
  final WeatherAlert alert;
  const WeatherAlertDetailPage({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orangeAccent,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              alert.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm - dd/MM/yyyy').format(alert.time),
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'NỘI DUNG CẢNH BÁO:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                alert.description,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nguồn: ${alert.source}',
              style: const TextStyle(
                color: Colors.white38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
