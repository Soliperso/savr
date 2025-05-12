import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class PendingBillsList extends StatelessWidget {
  final List<Map<String, dynamic>> bills;

  const PendingBillsList({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bills.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final bill = bills[index];
        double amount = bill['amount'] as double;
        String displayAmount = '\$${amount.toStringAsFixed(1)}';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.warningOrange.withOpacity(0.1),
            child: Icon(Icons.receipt_long, color: AppColors.warningOrange),
          ),
          title: Text(
            bill['title'] as String,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Due: ${bill['due'] as String}',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: AppColors.gray,
            ),
          ),
          trailing: Text(
            displayAmount,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              color:
                  isDark
                      ? AppColors.warningOrangeDark
                      : AppColors.warningOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}
