import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../models/financial_insight.dart';
import 'insight_chart.dart';

class InsightCard extends StatelessWidget {
  final FinancialInsight insight;

  const InsightCard({super.key, required this.insight});

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.spending:
        return AppColors.error;
      case InsightType.saving:
        return AppColors.success;
      case InsightType.budgeting:
        return AppColors.primary;
      case InsightType.trending:
        return Colors.purple.shade400;
    }
  }

  void _shareInsight(BuildContext context) {
    final message = """
Financial Insight from SavvySplit:

${insight.title}
${insight.description}

Generated on ${insight.date.toString().split(' ')[0]}
""";

    Share.share(message, subject: insight.title);
  }

  @override
  Widget build(BuildContext context) {
    final insightColor = _getInsightColor(insight.type);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: insightColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Share button
            Row(
              children: [
                Expanded(
                  child: Text(
                    insight.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: insightColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareInsight(context),
                  color: insightColor,
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Description
            Text(
              insight.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontFamily: 'Inter'),
            ),

            SizedBox(height: 16.h),

            // Chart
            InsightChart(data: insight.trendData, lineColor: insightColor),

            SizedBox(height: 8.h),

            // Date
            Text(
              insight.date.toString().split(' ')[0],
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }
}
