import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class AIInsightCard extends StatelessWidget {
  const AIInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color:
          isDark
              ? AppColors.primaryDark.withOpacity(0.1)
              : AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              Icons.insights,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
              size: 32.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'Your savings increased by 15% this month! Keep up the great work.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  color:
                      isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
