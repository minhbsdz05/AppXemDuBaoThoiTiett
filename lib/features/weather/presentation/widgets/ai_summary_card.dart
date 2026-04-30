// lib/features/weather/presentation/widgets/ai_summary_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/weather_ai_provider.dart';

class AiSummaryCard extends ConsumerWidget {
  const AiSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe trạng thái từ Gemini
    final aiState = ref.watch(aiSummaryProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purpleAccent.withOpacity(0.15),
                Colors.blueAccent.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.purpleAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER TĨNH
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.purpleAccent,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'GEMINI AI PHÂN TÍCH',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.purpleAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // XỬ LÝ 3 TRẠNG THÁI CỦA AI (Loading, Error, Success)
              aiState.when(
                // 1. TRẠNG THÁI LOADING (Đang gọi API)
                loading: () => _buildLoadingSkeleton(),

                // 2. TRẠNG THÁI LỖI
                error: (err, stack) => Text(
                  'Có lỗi xảy ra khi gọi AI.\n$err',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),

                // 3. TRẠNG THÁI CÓ DATA (Hoặc chưa phân tích)
                data: (aiInfo) {
                  if (aiInfo == null) {
                    // Trạng thái ban đầu khi chưa bấm nút
                    return const Text(
                      'Nhấn biểu tượng ✨ ở góc phải trên cùng để Gemini AI tổng hợp thời tiết cho bạn nhé!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }

                  // HIỂN THỊ KẾT QUẢ TỪ GEMINI
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aiInfo.todaySummary,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Divider(color: Colors.white.withOpacity(0.1), height: 1),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              aiInfo.weekTrend,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    height: 1.4,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Độ tin cậy: ${aiInfo.confidenceScore}% (${aiInfo.confidenceLabel})',
                          style: TextStyle(
                            color: _getConfidenceColor(aiInfo.confidenceScore),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Khung xương (Skeleton) khi AI đang suy nghĩ
  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.1),
      highlightColor: Colors.white.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(int score) {
    if (score >= 90) return Colors.greenAccent;
    if (score >= 75) return Colors.amberAccent;
    return Colors.redAccent;
  }
}
