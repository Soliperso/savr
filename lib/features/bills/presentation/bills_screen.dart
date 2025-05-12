import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../models/group.dart';
import '../../../providers/bill_provider.dart';
import 'add_bill_screen.dart';
import 'group_detail_screen.dart';
import '../widgets/group_list_item.dart';
import 'create_group_screen.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<BillProvider>().groups;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Groups & Bills',
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
            onPressed: () => _showInviteDialog(context),
            tooltip: 'Invite Friends',
          ),
        ],
      ),
      body: Column(
        children: [
          // Groups list section
          Expanded(
            child:
                groups.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 64.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No groups yet',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Create a group to start splitting bills',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToCreateGroup(context),
                            icon: const Icon(Icons.add),
                            label: Text(
                              'Create Group',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
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
                      itemCount: groups.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return GroupListItem(
                          group: group,
                          onTap: () => _navigateToGroupDetail(context, group),
                          onAddBill: () => _navigateToAddBill(context, group),
                          onInvite: () => _shareGroupInvite(context, group),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          groups.isEmpty
              ? null
              : FloatingActionButton.extended(
                onPressed: () => _navigateToCreateGroup(context),
                icon: const Icon(Icons.add),
                label: Text(
                  'New Group',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                ),
              ),
    );
  }

  void _navigateToCreateGroup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }

  void _navigateToGroupDetail(BuildContext context, Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(groupId: group.id),
      ),
    );
  }

  void _navigateToAddBill(BuildContext context, Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBillScreen(groupId: group.id)),
    );
  }

  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Invite Friends',
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
                  'Share the app with your friends to start splitting bills together!',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareAppInvite(context),
                        icon: const Icon(Icons.share),
                        label: Text(
                          'Share App',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
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

  void _shareAppInvite(BuildContext context) {
    const message = """
Join me on SavvySplit!

Make splitting bills with friends and roommates easy. Track shared expenses, settle up quickly, and keep everyone in the loop.

Download the app here: [App Store/Play Store Link]
""";

    Share.share(message, subject: 'Join me on SavvySplit!');
  }

  void _shareGroupInvite(BuildContext context, Group group) {
    final message = """
Join my group "${group.name}" on SavvySplit!

${group.description}

Members: ${group.members.join(', ')}

Download SavvySplit and use this invite code to join: ${group.id}
""";

    Share.share(message, subject: 'Join my bill-splitting group!');
  }
}
