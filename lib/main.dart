// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo trước khi gọi async
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dữ liệu định dạng ngày tháng cho Tiếng Việt
  await initializeDateFormatting('vi', null);

  // Chạy app bọc trong ProviderScope của Riverpod
  runApp(const ProviderScope(child: WeatherApp()));
}
