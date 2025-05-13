import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class PendingBillsList extends StatelessWidget {
  final List<Map<String, dynamic>> bills;

  const PendingBillsList({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: bills.length,
              separatorBuilder:
                  (_, __) => Divider(
                    height: 1,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                  ),
              itemBuilder: (context, index) {
                final bill = bills[index];
                double amount = bill['amount'] as double;
                String displayAmount = '\$${amount.toStringAsFixed(1)}';

                final dueRaw = bill['due'] as String;
                DateTime? dueDate;
                try {
                  dueDate = DateTime.parse(dueRaw);
                } catch (_) {
                  dueDate = null;
                }
                String formattedDue =
                    dueDate != null
                        ? DateFormat.yMMMd().format(dueDate)
                        : dueRaw;

                // Use enhanced summary card style for each bill
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warningOrange.withOpacity(0.14),
                        AppColors.warningOrangeDark.withOpacity(0.10),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.warningOrange.withOpacity(
                        0.13,
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppColors.warningOrange,
                      ),
                    ),
                    title: Text(
                      bill['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      'Due: $formattedDue',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    trailing: Text(
                      displayAmount,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.sp,
                        color:
                            isDark
                                ? AppColors.warningOrangeDark
                                : AppColors.warningOrange,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 2,
                          ),
                        ],
                      ),
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
