import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class RecentTransactionList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const RecentTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder:
          (_, __) => Divider(
            height: 1,
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
          ),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        double amount = tx['amount'] as double;
        bool isNegative = amount < 0;
        String displayAmount =
            (isNegative ? '- ' : '+ ') + '\$${amount.abs().toStringAsFixed(1)}';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(Icons.monetization_on, color: AppColors.primary),
          ),
          title: Text(
            tx['title'] as String,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            tx['date'] as String,
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
              fontWeight: FontWeight.w600,
              color: isNegative ? AppColors.expenseRed : AppColors.incomeGreen,
            ),
          ),
        );
      },
    );
  }
}
