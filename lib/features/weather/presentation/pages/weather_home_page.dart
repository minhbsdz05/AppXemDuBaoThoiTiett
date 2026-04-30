// lib/features/weather/presentation/pages/weather_home_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// --- IMPORT CORE THEME VÀ WIDGET CHUNG ---
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/state_widgets.dart';

// --- IMPORT CÁC FEATURE & PROVIDER ---
import '../providers/weather_notifier.dart';
import '../providers/location_provider.dart';
import '../providers/weather_ai_provider.dart'; // Provider cho Gemini AI
import '../../domain/entities/weather_entity.dart';
import '../widgets/hourly_forecast_section.dart';
import '../widgets/daily_forecast_section.dart';
import '../widgets/weather_alerts_feature.dart';
import '../widgets/ai_summary_card.dart'; // Card hiển thị kết quả AI
import 'weather_map_page.dart';
import 'manage_locations_page.dart';
import 'weather_analytics_page.dart';
import 'settings_page.dart';

class WeatherHomePage extends ConsumerStatefulWidget {
  const WeatherHomePage({super.key});

  @override
  ConsumerState<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends ConsumerState<WeatherHomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0; // Biến lưu vết thành phố đang hiển thị

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy danh sách thành phố từ Local Storage
    final locations = ref.watch(savedLocationsProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Nền Gradient chuẩn Material 3
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryMedium,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===============================================
              // 2. THANH TOP BAR ĐIỀU HƯỚNG
              // ===============================================
              _buildTopBar(context, ref, locations),

              // ===============================================
              // 3. NỘI DUNG CHÍNH (VUỐT NGANG)
              // ===============================================
              Expanded(
                child: locations.isEmpty
                    ? const AppEmptyState(
                        message:
                            'Chưa có thành phố nào.\nHãy nhấn nút Menu góc trái để thêm nhé!',
                      )
                    : PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                          // Xóa Data AI của thành phố cũ khi vuốt sang thành phố mới
                          ref.invalidate(aiSummaryProvider);
                        },
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final city = locations[index];
                          // Lắng nghe API Weather cho từng thành phố
                          final weatherAsyncValue = ref.watch(
                            weatherProvider(city),
                          );

                          return RefreshIndicator(
                            color: AppColors.textPrimary,
                            backgroundColor: AppColors.primaryDark,
                            onRefresh: () async {
                              ref.invalidate(weatherProvider(city));
                              ref.invalidate(
                                aiSummaryProvider,
                              ); // Reset AI khi pull-to-refresh
                            },
                            child: weatherAsyncValue.when(
                              loading: () => const _WeatherSkeletonLoader(),
                              error: (error, stack) => AppErrorState(
                                error: error.toString(),
                                onRetry: () =>
                                    ref.invalidate(weatherProvider(city)),
                              ),
                              // Chia layout tự động cho Điện thoại và Tablet
                              data: (weather) => ResponsiveLayout(
                                mobile: _buildMobileLayout(context, weather),
                                tablet: _buildTabletLayout(context, weather),
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ===============================================
              // 4. DẤU CHẤM CHỈ THỊ TRANG (PAGE INDICATOR)
              // ===============================================
              if (locations.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: locations.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.textPrimary,
                      dotColor: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===================================================================
  // WIDGET: THANH TOP BAR (Có Nút Gemini AI)
  // ===================================================================
  Widget _buildTopBar(
    BuildContext context,
    WidgetRef ref,
    List<String> locations,
  ) {
    // Xác định tên thành phố đang hiển thị trên màn hình hiện tại
    final currentCity = locations.isNotEmpty && _currentPage < locations.length
        ? locations[_currentPage]
        : 'Hanoi';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // NÚT QUẢN LÝ THÀNH PHỐ (Mở Drawer/Trang List)
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: AppColors.textPrimary,
              size: 28,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageLocationsPage()),
            ),
          ),

          // CỤM 4 NÚT CHỨC NĂNG BÊN PHẢI
          Row(
            children: [
              // 1. NÚT GEMINI AI ✨
              IconButton(
                icon: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purpleAccent,
                  size: 26,
                ),
                tooltip: 'Phân tích AI',
                onPressed: () {
                  if (locations.isEmpty) return;
                  final weatherState = ref.read(weatherProvider(currentCity));
                  if (weatherState.hasValue && weatherState.value != null) {
                    final mockWeekData = const DailyForecastSection()
                        .getMockData(); // Tạm lấy mock 7 ngày do OWM Free không có
                    // Kích hoạt Provider gọi API Gemini
                    ref
                        .read(aiSummaryProvider.notifier)
                        .analyzeWeather(weatherState.value!, mockWeekData);
                  }
                },
              ),
              // 2. NÚT PHÂN TÍCH CHUYÊN SÂU (CHARTS)
              IconButton(
                icon: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeatherAnalyticsPage(cityName: currentCity),
                  ),
                ),
              ),
              // 3. NÚT BẢN ĐỒ RADAR MAP
              IconButton(
                icon: const Icon(
                  Icons.map_outlined,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WeatherMapPage(
                      lat: 21.0285,
                      lon: 105.8542,
                      cityName: currentCity,
                    ),
                  ),
                ),
              ),
              // 4. NÚT CÀI ĐẶT
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.textPrimary,
                  size: 26,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // WIDGET: LAYOUT MOBILE
  // ===================================================================
  Widget _buildMobileLayout(BuildContext context, WeatherEntity weather) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMainInfo(context, weather),
          const SizedBox(height: AppSpacing.xl),

          // Thẻ AI Gemini (Sẽ hiện dữ liệu khi bấm nút ✨ ở Top Bar)
          const AiSummaryCard(),
          const SizedBox(height: AppSpacing.xl),

          HourlyForecastSection(forecasts: weather.hourlyForecasts),
          const SizedBox(height: AppSpacing.xl),

          const DailyForecastSection(),
          const SizedBox(height: AppSpacing.xl),

          _buildDetailGrid(weather),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // ===================================================================
  // WIDGET: LAYOUT TABLET (Chia 2 cột)
  // ===================================================================
  Widget _buildTabletLayout(BuildContext context, WeatherEntity weather) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CỘT TRÁI (Main Info + Detail Grid)
          Expanded(
            flex: 4,
            child: Column(
              children: [
                _buildMainInfo(context, weather),
                const SizedBox(height: AppSpacing.xl),
                const AiSummaryCard(), // Thẻ AI trên Tablet
                const SizedBox(height: AppSpacing.xl),
                _buildDetailGrid(weather),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          // CỘT PHẢI (Charts & Daily Forecast)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                HourlyForecastSection(forecasts: weather.hourlyForecasts),
                const SizedBox(height: AppSpacing.xl),
                const DailyForecastSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // KHỐI WIDGET BỔ TRỢ ĐƯỢC TÁCH NHỎ
  // ===================================================================

  // Khối thông tin thời tiết chính (Nhiệt độ lớn, Hình Lottie)
  Widget _buildMainInfo(BuildContext context, WeatherEntity weather) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        if (weather.isCachedData) _buildOfflineBanner(),
        const SizedBox(height: AppSpacing.sm),

        Text(weather.city, style: textTheme.headlineLarge),
        Text(
          DateFormat('EEEE, dd MMM yyyy', 'vi').format(DateTime.now()),
          style: textTheme.bodyMedium,
        ),

        const WeatherAlertBanner(), // Banner cảnh báo đỏ
        const SizedBox(height: AppSpacing.sm),

        SizedBox(
          height: ResponsiveLayout.isTablet(context) ? 220 : 180,
          child: Lottie.asset(
            _getWeatherAnimation(weather.iconCode),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.cloud_queue,
              size: 100,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        Text('${weather.temperature.round()}°', style: textTheme.displayLarge),
        Text(weather.condition.toUpperCase(), style: textTheme.titleLarge),
      ],
    );
  }

  // Lưới thẻ thông số chi tiết (Grid 2 cột)
  Widget _buildDetailGrid(WeatherEntity weather) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.6,
      children: [
        _GlassmorphicCard(
          icon: Icons.thermostat,
          title: 'Cảm giác',
          value: '${weather.feelsLike.round()}°C',
        ),
        _GlassmorphicCard(
          icon: Icons.water_drop_outlined,
          title: 'Độ ẩm',
          value: '${weather.humidity}%',
        ),
        _GlassmorphicCard(
          icon: Icons.air,
          title: 'Sức gió',
          value: '${weather.windSpeed} km/h',
        ),
        const _GlassmorphicCard(
          icon: Icons.wb_sunny_outlined,
          title: 'Chỉ số UV',
          value: 'Cao (8)',
        ),
        _GlassmorphicCard(
          icon: Icons.brightness_high,
          title: 'Bình minh',
          value: DateFormat('HH:mm').format(weather.sunrise),
          isValueSmall: true,
        ),
        _GlassmorphicCard(
          icon: Icons.brightness_4,
          title: 'Hoàng hôn',
          value: DateFormat('HH:mm').format(weather.sunset),
          isValueSmall: true,
        ),
      ],
    );
  }

  // Banner màu cam báo trạng thái Offline
  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: AppColors.textPrimary, size: 16),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Đang hiển thị dữ liệu cũ (Offline)',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // Hàm Map Icon Code từ OWM sang file Lottie
  String _getWeatherAnimation(String iconCode) {
    if (iconCode.contains('01d')) return 'assets/animations/sunny.json';
    if (iconCode.contains('01n')) return 'assets/animations/night.json';
    if (iconCode.contains('02') ||
        iconCode.contains('03') ||
        iconCode.contains('04'))
      return 'assets/animations/cloudy.json';
    if (iconCode.contains('09') || iconCode.contains('10'))
      return 'assets/animations/rainy.json';
    if (iconCode.contains('11')) return 'assets/animations/thunderstorm.json';
    if (iconCode.contains('13')) return 'assets/animations/snow.json';
    if (iconCode.contains('50')) return 'assets/animations/mist.json';
    return 'assets/animations/sunny.json';
  }
}

// ===================================================================
// WIDGET GLOBAL: SKELETON LOADER
// ===================================================================
class _WeatherSkeletonLoader extends StatelessWidget {
  const _WeatherSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.textPrimary.withOpacity(0.1),
      highlightColor: AppColors.textPrimary.withOpacity(0.3),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          children: [
            Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 180,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// WIDGET GLOBAL: THẺ KÍNH MỜ
// ===================================================================
class _GlassmorphicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isValueSmall;

  const _GlassmorphicCard({
    required this.icon,
    required this.title,
    required this.value,
    this.isValueSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isValueSmall ? 14 : 22,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
