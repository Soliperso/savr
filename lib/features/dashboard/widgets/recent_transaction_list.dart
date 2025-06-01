import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:savr/features/transactions/models/transaction.dart'; // Updated import
import '../../../core/theme/app_colors.dart';

class RecentTransactionList extends StatelessWidget {
  final List<Transaction> transactions; // Updated type

  const RecentTransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64.sp,
              color: Theme.of(context).hintColor.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No transactions yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Tap + to add your first transaction',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

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
        String displayAmount = tx.formattedAmount; // Use formattedAmount getter

        IconData icon = tx.summaryIcon; // Use summaryIcon getter
        Color iconColor = tx.summaryIconColor; // Use summaryIconColor getter

        // Date formatting: show Today, Yesterday, or formatted date
        String dateLabel;
        final txDate = tx.date;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final txDay = DateTime(txDate.year, txDate.month, txDate.day);

        if (txDay == today) {
          dateLabel = 'Today';
        } else if (txDay == today.subtract(const Duration(days: 1))) {
          dateLabel = 'Yesterday';
        } else {
          dateLabel =
              tx.formattedDate; // Use formattedDate getter from Transaction model
        }

        return InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            // TODO: Navigate to transaction details
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.13),
              child: Icon(icon, color: iconColor),
            ),
            title: Text(
              tx.title, // Use title from Transaction object
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${tx.category} • $dateLabel', // Use category string and formatted dateLabel
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
                    tx.isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
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
