import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/bill_provider.dart';
import '../presentation/bill_detail_screen.dart';
import '../models/bill.dart';
import '../models/bill_status.dart';

class BillListItem extends StatelessWidget {
  final Bill bill;
  final VoidCallback onPayPressed;
  final VoidCallback onDeletePressed;

  const BillListItem({
    super.key,
    required this.bill,
    required this.onPayPressed,
    required this.onDeletePressed,
  });

  String _getBillStatusString(BillStatus status) {
    switch (status) {
      case BillStatus.pending:
        return 'pending';
      case BillStatus.overdue:
        return 'overdue';
      case BillStatus.paid:
        return 'paid';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final double amount = bill.amount;
    final double myShare = billProvider.getMyShare(bill);
    final bool isPaid = bill.paid;
    final String status = _getBillStatusString(bill.status);

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;

    switch (bill.status) {
      case BillStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case BillStatus.overdue:
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        break;
      case BillStatus.paid:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () => _navigateToBillDetail(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(statusIcon, color: statusColor),
                  SizedBox(width: 8.w),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.title,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (bill.description.isNotEmpty)
                          Text(
                            bill.description,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${amount.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      Text(
                        'Your share: \$${myShare.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onDeletePressed,
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(
                      'Delete',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (!isPaid)
                    ElevatedButton(
                      onPressed: onPayPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                      ),
                      child: Text(
                        'Mark as Paid',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBillDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BillDetailScreen(billId: bill.id),
      ),
    );
  }
}
