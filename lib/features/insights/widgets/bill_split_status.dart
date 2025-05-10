import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BillSplitStatus extends StatelessWidget {
  final Map<String, dynamic> insights;

  const BillSplitStatus({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final totalOwed = insights['totalOwed'] as double;
    final totalPending = insights['totalPending'] as double;
    final personDebts = insights['personDebts'] as Map<String, double>;

    if (totalPending == 0) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                'No pending split bills',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  context,
                  'Total Pending',
                  totalPending,
                  Colors.orange,
                ),
                _buildSummaryItem(
                  context,
                  'To Collect',
                  totalOwed,
                  Colors.green,
                ),
              ],
            ),

            if (personDebts.isNotEmpty) ...[
              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 16.h),
              Text(
                'Amount to Collect',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              ...personDebts.entries
                  .map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              entry.key[0],
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                // Progress bar
                                LinearProgressIndicator(
                                  value: entry.value / totalOwed,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            '\$${entry.value.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '\$${amount.toStringAsFixed(1)}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
