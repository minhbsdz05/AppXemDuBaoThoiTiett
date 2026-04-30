// lib/features/weather/presentation/providers/weather_ai_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/entities/weather_entity.dart';
import '../widgets/daily_forecast_section.dart';

// --- MODEL KẾT QUẢ AI ---
class AiSummaryInfo {
  final String todaySummary;
  final String weekTrend;
  final int confidenceScore;
  final String confidenceLabel;

  AiSummaryInfo({
    required this.todaySummary,
    required this.weekTrend,
    required this.confidenceScore,
    required this.confidenceLabel,
  });

  factory AiSummaryInfo.fromJson(Map<String, dynamic> json) {
    return AiSummaryInfo(
      todaySummary: json['todaySummary'] ?? 'Không có dữ liệu',
      weekTrend: json['weekTrend'] ?? 'Không có dữ liệu',
      confidenceScore: json['confidenceScore'] ?? 0,
      confidenceLabel: json['confidenceLabel'] ?? 'Không rõ',
    );
  }
}

// --- PROVIDER QUẢN LÝ TRẠNG THÁI AI (Loading, Error, Success) ---
final aiSummaryProvider =
    StateNotifierProvider<AiSummaryNotifier, AsyncValue<AiSummaryInfo?>>((ref) {
      return AiSummaryNotifier();
    });

class AiSummaryNotifier extends StateNotifier<AsyncValue<AiSummaryInfo?>> {
  AiSummaryNotifier()
    : super(
        const AsyncValue.data(null),
      ); // Khởi tạo ban đầu là null (chưa phân tích)

  // TODO: THAY API KEY CỦA BẠN VÀO ĐÂY LÚC CHẠY THẬT
  static const _apiKey = 'AIzaSyCzX16OLUlevp_l5cZyrojVzuqRfKOIxZw';

  Future<void> analyzeWeather(
    WeatherEntity weather,
    List<DailyForecast> weekData,
  ) async {
    state = const AsyncValue.loading(); // Chuyển sang trạng thái đang tải

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      // Tạo prompt truyền dữ liệu thời tiết hiện tại vào cho AI
      final prompt =
          '''
      Bạn là một chuyên gia khí tượng học người Việt Nam. Hãy phân tích các số liệu sau:
      - Thành phố: ${weather.city}
      - Hiện tại: Nhiệt độ ${weather.temperature.round()}°C, cảm giác ${weather.feelsLike.round()}°C, thời tiết: ${weather.condition}, độ ẩm ${weather.humidity}%, sức gió ${weather.windSpeed}km/h.
      - Dự báo 7 ngày có ${weekData.where((d) => d.rainChance > 30).length} ngày khả năng mưa cao. Nhiệt độ max trung bình: ${weekData.map((d) => d.maxTemp).reduce((a, b) => a + b) / weekData.length}°C.

      Dựa vào dữ liệu trên, hãy trả về kết quả TUYỆT ĐỐI dưới dạng JSON với cấu trúc sau (không thêm bất kỳ ký tự nào ngoài JSON):
      {
        "todaySummary": "Viết 2-3 câu tự nhiên mô tả thời tiết hôm nay và đưa ra lời khuyên",
        "weekTrend": "Viết 1-2 câu tổng hợp xu hướng tuần tới",
        "confidenceScore": (điểm tin cậy từ 50 đến 99 dựa trên sự biến động của dữ liệu),
        "confidenceLabel": "Rất cao / Cao / Trung bình / Thấp"
      }
      ''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      // Xử lý chuỗi JSON trả về (Gemini đôi khi bọc trong ```json...```)
      String rawJson = response.text ?? '{}';
      rawJson = rawJson.replaceAll('```json', '').replaceAll('```', '').trim();

      final Map<String, dynamic> jsonMap = jsonDecode(rawJson);
      final aiInfo = AiSummaryInfo.fromJson(jsonMap);

      state = AsyncValue.data(aiInfo); // Lưu kết quả thành công
    } catch (e, stack) {
      state = AsyncValue.error('Lỗi khi phân tích AI: $e', stack); // Xử lý lỗi
    }
  }
}
