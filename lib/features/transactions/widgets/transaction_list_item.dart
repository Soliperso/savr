import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final amount = transaction['amount'] as double;
    final isNegative = amount < 0;
    final displayAmount = '\$${amount.abs().toStringAsFixed(1)}';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isNegative
                ? AppColors.expenseRed.withOpacity(0.1)
                : AppColors.incomeGreen.withOpacity(0.1),
        child: Icon(
          isNegative ? Icons.shopping_cart : Icons.account_balance_wallet,
          color: isNegative ? AppColors.expenseRed : AppColors.incomeGreen,
        ),
      ),
      title: Text(
        transaction['title'] as String,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        transaction['date'] as String,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.sp,
          color: AppColors.gray,
        ),
      ),
      trailing: Text(
        isNegative ? '- $displayAmount' : '+ $displayAmount',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: isNegative ? AppColors.expenseRed : AppColors.incomeGreen,
        ),
      ),
    );
  }
}
