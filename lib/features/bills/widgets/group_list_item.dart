import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../models/group.dart';
import '../../../providers/bill_provider.dart';

class GroupListItem extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final VoidCallback onAddBill;
  final VoidCallback onInvite;

  const GroupListItem({
    super.key,
    required this.group,
    required this.onTap,
    required this.onAddBill,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final bills =
        Provider.of<BillProvider>(
          context,
        ).bills.where((bill) => bill.groupId == group.id).toList();
    final totalAmount = bills.fold<double>(0, (sum, bill) => sum + bill.amount);
    final pendingAmount = bills
        .where((bill) => !bill.paid)
        .fold<double>(0, (sum, bill) => sum + bill.amount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Color(group.color ?? 0xFF000000).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(
                      group.color ?? 0xFF000000,
                    ).withOpacity(0.1),
                    child: Icon(
                      Icons.group,
                      color: Color(group.color ?? 0xFF000000),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${group.members.length} members',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: onInvite,
                    tooltip: 'Invite Members',
                  ),
                ],
              ),
              if (bills.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmountInfo(
                      'Total',
                      totalAmount,
                      Color(group.color ?? 0xFF000000),
                    ),
                    _buildAmountInfo(
                      'Pending',
                      pendingAmount,
                      pendingAmount > 0 ? Colors.orange : Colors.green,
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Color(group.color ?? 0xFF000000),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: Color(group.color ?? 0xFF000000),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: onAddBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(group.color ?? 0xFF000000),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 16),
                        SizedBox(width: 4.w),
                        Text(
                          'Add Bill',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
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

  Widget _buildAmountInfo(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(1)}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
