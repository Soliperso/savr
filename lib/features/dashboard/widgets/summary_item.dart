import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double valueFontSize;

  const SummaryItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.valueFontSize = 20,
  });

  IconData get _icon {
    switch (label.toLowerCase()) {
      case 'income':
        return Icons.arrow_upward_rounded;
      case 'expenses':
        return Icons.arrow_downward_rounded;
      case 'savings':
        return Icons.savings_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    double? amount = double.tryParse(
      value.replaceAll(',', '').replaceAll(' ', ''),
    );
    String displayValue =
        amount != null ? '\$${amount.toStringAsFixed(1)}' : value;

    return SizedBox.expand(
      child: Container(
        constraints: BoxConstraints(
          minHeight: 86.h,
        ), // match observed overflow size
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
        padding: EdgeInsets.symmetric(
          vertical: 8.h,
          horizontal: 8.w,
        ), // reduce vertical padding
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                radius: 20.r,
                child: Icon(_icon, color: color, size: 22.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                displayValue,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: valueFontSize.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
