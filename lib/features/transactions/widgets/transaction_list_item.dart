import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    // Parse transaction data
    final title = transaction['title'] as String;
    final amount = transaction['amount'] as double;
    final isIncome = amount >= 0;
    final category = transaction['category'] as String? ?? 'Uncategorized';

    // Format date
    String formattedDate;
    try {
      final date =
          transaction['date'] is DateTime
              ? transaction['date'] as DateTime
              : DateTime.tryParse(transaction['date'] as String) ??
                  DateTime.now();
      formattedDate = DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      formattedDate = transaction['date'] as String? ?? 'Unknown date';
    }

    final formattedAmount = '\$${amount.abs().toStringAsFixed(2)}';

    // Get category icon
    IconData categoryIcon = _getCategoryIcon(category, isIncome);
    Color categoryColor = _getCategoryColor(category, isIncome);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              Theme.of(context).brightness == Brightness.dark
                  ? [
                    isIncome
                        ? AppColors.incomeGreenDark.withOpacity(0.2)
                        : AppColors.expenseRedDark.withOpacity(0.2),
                    Colors.transparent,
                  ]
                  : [
                    isIncome
                        ? AppColors.incomeGreen.withOpacity(0.05)
                        : AppColors.expenseRed.withOpacity(0.05),
                    Colors.white,
                  ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: () {
            // Navigate to transaction details
            // TODO: Implement navigation to transaction details
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            child: Row(
              children: [
                // Category indicator
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 24.sp),
                ),
                SizedBox(width: 16.w),

                // Transaction details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          // Category pill
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.sp,
                                color: categoryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // Date
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount
                Text(
                  isIncome ? '+ $formattedAmount' : '- $formattedAmount',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isIncome ? AppColors.incomeGreen : AppColors.expenseRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category, bool isIncome) {
    if (isIncome) {
      switch (category.toLowerCase()) {
        case 'salary':
          return Icons.work_outline_rounded;
        case 'investment':
          return Icons.trending_up_rounded;
        case 'bonus':
          return Icons.star_outline_rounded;
        default:
          return Icons.arrow_upward_rounded;
      }
    } else {
      switch (category.toLowerCase()) {
        case 'food':
          return Icons.restaurant_outlined;
        case 'shopping':
          return Icons.shopping_bag_outlined;
        case 'transport':
          return Icons.directions_car_outlined;
        case 'entertainment':
          return Icons.movie_outlined;
        case 'utilities':
          return Icons.power_outlined;
        case 'health':
          return Icons.medical_services_outlined;
        case 'education':
          return Icons.school_outlined;
        case 'rent':
          return Icons.home_outlined;
        case 'travel':
          return Icons.flight_outlined;
        default:
          return Icons.arrow_downward_rounded;
      }
    }
  }

  Color _getCategoryColor(String category, bool isIncome) {
    if (isIncome) {
      return AppColors.incomeGreen;
    } else {
      switch (category.toLowerCase()) {
        case 'food':
          return Colors.orange;
        case 'shopping':
          return Colors.purple;
        case 'transport':
          return Colors.blue;
        case 'entertainment':
          return Colors.pinkAccent;
        case 'utilities':
          return Colors.teal;
        case 'health':
          return Colors.redAccent;
        case 'education':
          return Colors.blueAccent;
        case 'rent':
          return Colors.brown;
        case 'travel':
          return Colors.green;
        default:
          return AppColors.expenseRed;
      }
    }
  }
}
