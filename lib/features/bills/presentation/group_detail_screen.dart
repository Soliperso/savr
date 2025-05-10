import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../providers/bill_provider.dart';
import '../models/group.dart';
import '../widgets/bill_list_item.dart';
import 'add_bill_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final billProvider = Provider.of<BillProvider>(context);
    final group = billProvider.getGroupById(groupId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group Details')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final groupBills = billProvider.getBillsByGroupId(groupId);
    final totalAmount = groupBills.fold<double>(
      0,
      (sum, bill) => sum + bill.amount,
    );
    final pendingAmount = groupBills
        .where((bill) => !bill.paid)
        .fold<double>(0, (sum, bill) => sum + bill.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          group.name,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberDialog(context, group, billProvider),
            tooltip: 'Add Member',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareGroup(context, group),
            tooltip: 'Share Group',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary card
          Card(
            margin: EdgeInsets.all(16.w),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildAmountInfo(
                        'Total',
                        totalAmount,
                        Color(group.color),
                      ),
                      _buildAmountInfo(
                        'Pending',
                        pendingAmount,
                        pendingAmount > 0 ? Colors.orange : Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const Divider(),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(Icons.group, color: Colors.grey, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Members: ${group.members.join(', ')}',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.grey, size: 20.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          group.description,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bills list
          Expanded(
            child:
                groupBills.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No bills yet',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Add your first bill to start tracking expenses',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAddBill(context),
                            icon: const Icon(Icons.add),
                            label: Text(
                              'Add Bill',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(group.color),
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: groupBills.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final bill = groupBills[index];
                        return BillListItem(
                          bill: bill,
                          onPayPressed: () {
                            billProvider.markAsPaid(bill.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Bill marked as paid',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          onDeletePressed: () {
                            billProvider.deleteBill(bill.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Bill deleted',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddBill(context),
        backgroundColor: Color(group.color),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Bill',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
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

  void _navigateToAddBill(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBillScreen(groupId: groupId)),
    );
  }

  void _showAddMemberDialog(
    BuildContext context,
    Group group,
    BillProvider billProvider,
  ) {
    final currentMembers = group.members;
    final availableFriends =
        [
          'John',
          'Sarah',
          'Mike',
          'Lisa',
          'David',
        ].where((friend) => !currentMembers.contains(friend)).toList();

    if (availableFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All friends are already in this group')),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Add Member',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select friends to add to the group',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                ...availableFriends.map(
                  (friend) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      friend,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                    ),
                    onTap: () {
                      billProvider.addMemberToGroup(groupId, friend);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$friend added to the group',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                ),
              ),
            ],
          ),
    );
  }

  void _shareGroup(BuildContext context, Group group) {
    final message = """
Join my group "${group.name}" on SavvySplit!

${group.description}

Members: ${group.members.join(', ')}

Download SavvySplit and use this invite code to join: ${group.id}
""";

    Share.share(message, subject: 'Join my bill-splitting group!');
  }
}
