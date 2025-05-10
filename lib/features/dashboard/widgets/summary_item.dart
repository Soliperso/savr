import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const SummaryItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Try to parse value to double for formatting
    double? amount = double.tryParse(
      value.replaceAll(',', '').replaceAll(' ', ''),
    );
    String displayValue =
        amount != null ? '\$${amount.toStringAsFixed(1)}' : value;

    return Column(
      children: [
        Text(
          displayValue,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color:
                Theme.of(context).textTheme.bodyMedium?.color ??
                Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
