🌦️ Weather Forecast App (Flutter)

Ứng dụng dự báo thời tiết thông minh được phát triển bằng Flutter, cung cấp thông tin thời tiết theo thời gian thực, dự báo nhiều ngày và phân tích bằng AI.

🚀 Features
🌍 Xem thời tiết theo vị trí hiện tại
🔍 Tìm kiếm thành phố
📅 Dự báo thời tiết theo ngày & giờ
🗺️ Bản đồ thời tiết trực quan
🤖 AI phân tích & tóm tắt thời tiết
⚠️ Cảnh báo thời tiết (mưa, bão, sương mù…)
📊 Phân tích dữ liệu thời tiết
❤️ Quản lý nhiều địa điểm yêu thích
⚙️ Tùy chỉnh (theme, đơn vị °C/°F...)
🧠 Technologies Used
Flutter (Dart)
REST API (Weather API)
Provider (State Management)
Clean Architecture
JSON & HTTP
AI Summary (custom logic / API)
📁 Project Structure
lib/
│
├── core/                # Base config, theme, widgets chung
├── features/
│   └── weather/
│       ├── data/        # API, model
│       ├── domain/      # entity, repository
│       └── presentation/
│           ├── pages/   # UI screens
│           ├── widgets/
│           └── providers/
│
└── main.dart
📸 Screenshots

(Bạn nên thêm ảnh vào đây để ăn điểm 👇)

assets/screenshots/
⚙️ Installation
1. Clone project
git clone https://github.com/minhbsdz05/AppXemDuBaoThoiTiett.git
cd app_xem_du_bao_thoi_tiet
2. Cài dependencies
flutter pub get
3. Chạy app
flutter run
🔑 API Configuration
Sử dụng Weather API (ví dụ: OpenWeatherMap)
Thêm API Key vào file:
lib/core/config/api_config.dart
📊 AI Feature

Ứng dụng có tích hợp AI Weather Summary:

Tóm tắt thời tiết dễ hiểu
Phân tích xu hướng
Gợi ý hoạt động (nếu bạn mở rộng)
🎯 Future Improvements
🔔 Push Notification cảnh báo thời tiết
🌐 Multi-language (VN/EN)
☁️ Đồng bộ cloud
📈 Machine Learning dự đoán thời tiết
👨‍💻 Author
Minh Hoàng Anh
GitHub: https://github.com/minhbsdz05
📄 License

This project is for educational purposes.

⭐ Nếu thấy hay hãy star repo nhé!
🔥 Gợi ý nâng cấp (rất nên làm để ăn điểm cao)

Bạn nên thêm:

1. Badge xịn

Thêm vào đầu README:

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Platform](https://img.shields.io/badge/platform-android%20|%20ios-green)
![License](https://img.shields.io/badge/license-MIT-orange)
2. Demo video
## 🎥 Demo
https://youtu.be/your-video
3. UI đẹp hơn
