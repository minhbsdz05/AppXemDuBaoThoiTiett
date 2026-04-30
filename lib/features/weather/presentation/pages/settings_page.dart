// lib/features/weather/presentation/pages/settings_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Cài đặt',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Giao diện & Thông báo'),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      // TOGGLE DARK/LIGHT MODE
                      SwitchListTile(
                        activeColor: Colors.amberAccent,
                        title: const Text(
                          'Chế độ tối (Dark Mode)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        secondary: const Icon(
                          Icons.dark_mode,
                          color: Colors.white70,
                        ),
                        value: settings.isDarkMode,
                        onChanged: (value) => ref
                            .read(settingsProvider.notifier)
                            .toggleTheme(value),
                      ),
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),

                      // TOGGLE THÔNG BÁO
                      SwitchListTile(
                        activeColor: Colors.amberAccent,
                        title: const Text(
                          'Nhận cảnh báo thời tiết',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Gửi thông báo đẩy khi có thời tiết xấu',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        secondary: const Icon(
                          Icons.notifications_active,
                          color: Colors.white70,
                        ),
                        value: settings.notificationsEnabled,
                        onChanged: (value) => ref
                            .read(settingsProvider.notifier)
                            .toggleNotifications(value),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
                _buildSectionTitle('Đơn vị đo lường'),
                _buildGlassContainer(
                  child: Column(
                    children: [
                      // CHỌN ĐƠN VỊ NHIỆT ĐỘ
                      ListTile(
                        leading: const Icon(
                          Icons.thermostat,
                          color: Colors.white70,
                        ),
                        title: const Text(
                          'Nhiệt độ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: SegmentedButton<TempUnit>(
                          segments: const [
                            ButtonSegment(
                              value: TempUnit.celsius,
                              label: Text('°C'),
                            ),
                            ButtonSegment(
                              value: TempUnit.fahrenheit,
                              label: Text('°F'),
                            ),
                          ],
                          selected: {settings.tempUnit},
                          onSelectionChanged: (Set<TempUnit> newSelection) {
                            ref
                                .read(settingsProvider.notifier)
                                .setTempUnit(newSelection.first);
                          },
                          style: _segmentedStyle(),
                        ),
                      ),
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),

                      // CHỌN ĐƠN VỊ GIÓ
                      ListTile(
                        leading: const Icon(Icons.air, color: Colors.white70),
                        title: const Text(
                          'Sức gió',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: SegmentedButton<WindUnit>(
                          segments: const [
                            ButtonSegment(
                              value: WindUnit.kmh,
                              label: Text('km/h'),
                            ),
                            ButtonSegment(
                              value: WindUnit.mph,
                              label: Text('mph'),
                            ),
                            ButtonSegment(
                              value: WindUnit.ms,
                              label: Text('m/s'),
                            ),
                          ],
                          selected: {settings.windUnit},
                          onSelectionChanged: (Set<WindUnit> newSelection) {
                            ref
                                .read(settingsProvider.notifier)
                                .setWindUnit(newSelection.first);
                          },
                          style: _segmentedStyle(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Phiên bản giới hạn \nHoang Xiaolin Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET BỔ TRỢ ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }

  ButtonStyle _segmentedStyle() {
    return SegmentedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      selectedForegroundColor: Colors.black,
      selectedBackgroundColor: Colors.amberAccent,
      side: BorderSide(color: Colors.white.withOpacity(0.2)),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    );
  }
}
