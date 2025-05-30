import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';

class PendingBillsList extends StatelessWidget {
  final List<Map<String, dynamic>> bills;

  const PendingBillsList({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  bills.length >= 4
                      ? (bills.length > 4 ? 4 : bills.length)
                      : bills.length,
              itemBuilder: (context, index) {
                final bill = bills[index];
                double amount = bill['amount'] as double;
                double paid = (bill['paidAmount'] ?? 0).toDouble();
                String displayAmount = '\$${amount.toStringAsFixed(2)}';
                final dueRaw = bill['due'] as String;
                DateTime? dueDate;
                try {
                  dueDate = DateTime.parse(dueRaw);
                } catch (_) {
                  dueDate = null;
                }
                String dueLabel = dueRaw;
                if (dueDate != null) {
                  final now = DateTime(2025, 5, 13);
                  final today = DateTime(now.year, now.month, now.day);
                  final dueDay = DateTime(
                    dueDate.year,
                    dueDate.month,
                    dueDate.day,
                  );
                  final days = dueDay.difference(today).inDays;
                  if (days == 0) {
                    dueLabel = 'Today';
                  } else if (days == 1) {
                    dueLabel = 'Tomorrow';
                  } else if (days < 0) {
                    dueLabel = 'Overdue by ${-days} day${-days > 1 ? 's' : ''}';
                  } else {
                    dueLabel = 'In $days day${days > 1 ? 's' : ''}';
                  }
                }
                Color chipColor;
                if (dueDate != null && dueDate.isBefore(DateTime.now())) {
                  chipColor = Colors.redAccent;
                } else if (dueDate != null &&
                    dueDate.difference(DateTime.now()).inDays <= 2) {
                  chipColor = Colors.orangeAccent;
                } else {
                  chipColor = AppColors.warningOrange;
                }
                final isPartiallyPaid = paid > 0 && paid < amount;
                final progress = (paid / amount).clamp(0.0, 1.0);
                return InkWell(
                  borderRadius: BorderRadius.circular(12.r),
                  onTap: () {
                    // TODO: Navigate to bill details/payment
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: chipColor.withValues(alpha: .13),
                      child: Icon(Icons.receipt_long, color: chipColor),
                    ),
                    title: Text(
                      bill['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          dueLabel,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: chipColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isPartiallyPaid) ...[
                          SizedBox(width: 8.w),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: chipColor.withValues(alpha: .10),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                chipColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Text(
                      displayAmount,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: chipColor,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
