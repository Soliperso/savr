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
      itemCount: transactions.length > 5 ? 5 : transactions.length,
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
            (isNegative ? '- ' : '+ ') + '\$${amount.abs().toStringAsFixed(2)}';
        IconData icon;
        Color iconColor;
        // Simple category icon logic (expand as needed)
        switch ((tx['category'] ?? '').toString().toLowerCase()) {
          case 'food & groceries':
            icon = Icons.shopping_cart;
            iconColor = Colors.orangeAccent;
            break;
          case 'income':
            icon = Icons.attach_money;
            iconColor = Colors.green;
            break;
          case 'transportation':
            icon = Icons.directions_car;
            iconColor = Colors.blueAccent;
            break;
          case 'entertainment':
            icon = Icons.movie;
            iconColor = Colors.purple;
            break;
          case 'health & fitness':
            icon = Icons.fitness_center;
            iconColor = Colors.redAccent;
            break;
          default:
            icon = isNegative ? Icons.arrow_downward : Icons.arrow_upward;
            iconColor =
                isNegative ? AppColors.expenseRed : AppColors.incomeGreen;
        }
        // Date formatting: show Today, Yesterday, or date
        String dateLabel = tx['fullDate'] == null ? tx['date'] as String : '';
        if (tx['fullDate'] != null) {
          final txDate = DateTime.tryParse(tx['fullDate']);
          if (txDate != null) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final txDay = DateTime(txDate.year, txDate.month, txDate.day);
            if (txDay == today) {
              dateLabel = 'Today';
            } else if (txDay == today.subtract(const Duration(days: 1))) {
              dateLabel = 'Yesterday';
            } else {
              dateLabel = tx['date'] as String;
            }
          }
        }
        return InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            // TODO: Navigate to transaction details
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: .13),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              tx['title'] as String,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${tx['category'] ?? ''} • $dateLabel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                color: Theme.of(context).hintColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              displayAmount,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color:
                    isNegative ? AppColors.expenseRed : AppColors.incomeGreen,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 2.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onLongPress: () {
              // TODO: Add swipe/long-press actions if desired
            },
          ),
        );
      },
    );
  }
}
