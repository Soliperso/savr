import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:savr/features/transactions/models/transaction.dart';

class TransactionSummaryCard extends StatelessWidget {
  final Transaction transaction;
  const TransactionSummaryCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.isExpense;
    final Color gradientStart =
        isExpense
            ? Colors.redAccent.withOpacity(0.85)
            : Colors.greenAccent.withOpacity(0.85);
    final Color gradientEnd =
        isExpense
            ? Colors.red.withOpacity(0.65)
            : Colors.green.withOpacity(0.65);
    final Color iconColor = isExpense ? Colors.redAccent : Colors.greenAccent;
    final IconData icon =
        isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      width: double.infinity,
      height: 110.h,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28.w),
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    transaction.formattedDate,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              transaction.formattedAmount,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
                color: isExpense ? Colors.red[100] : Colors.green[100],
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.12), blurRadius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
