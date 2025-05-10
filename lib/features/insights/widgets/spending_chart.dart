import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpendingChart extends StatelessWidget {
  final Map<String, double> monthlySpending;

  const SpendingChart({super.key, required this.monthlySpending});

  @override
  Widget build(BuildContext context) {
    if (monthlySpending.isEmpty) {
      return Center(
        child: Text(
          'No spending data available',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    }

    final maxAmount = monthlySpending.values.reduce((a, b) => a > b ? a : b);
    final sortedMonths =
        monthlySpending.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key));
    final lastSixMonths = sortedMonths.take(6).toList().reversed.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Bar spacing and dimensions
        final availableWidth = constraints.maxWidth;
        final barCount = lastSixMonths.length;
        final barSpacing = 8.w;
        final barWidth =
            (availableWidth - (barSpacing * (barCount + 1))) / barCount;

        // Height calculations
        final verticalPadding = 40.h;
        final maxBarHeight = constraints.maxHeight - verticalPadding;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: constraints.maxHeight - 30.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children:
                    lastSixMonths.map((entry) {
                      final barHeight =
                          (entry.value / maxAmount) * maxBarHeight;
                      final amount = entry.value;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$${amount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            width: barWidth.clamp(20.w, 60.w),
                            height: barHeight.clamp(0.0, maxBarHeight),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4.r),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  lastSixMonths.map((entry) {
                    return SizedBox(
                      width: barWidth.clamp(20.w, 60.w),
                      child: Text(
                        entry.key.substring(0, 3),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }).toList(),
            ),
          ],
        );
      },
    );
  }
}
