import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../bills/presentation/add_bill_screen.dart';
import '../../transactions/presentation/add_transaction_screen.dart';
import '../widgets/summary_item.dart';
import '../widgets/recent_transaction_list.dart';
import '../widgets/pending_bills_list.dart';
import '../widgets/ai_insight_card.dart';
import '../../../features/auth/presentation/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bellAnimationController;
  late Animation<double> _bellAnimation;
  int _previousBillCount = 0;

  @override
  void initState() {
    super.initState();
    _bellAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bellAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _bellAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _bellAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactions = context.watch<TransactionProvider>().transactions;
    final billProvider = context.watch<BillProvider>();
    final authProvider = context.watch<AuthProvider>();

    // Convert Bill objects to Map<String, dynamic> for PendingBillsList
    final pendingBills =
        billProvider.pendingBills
            .map(
              (bill) => {
                'title': bill.title,
                'amount': bill.amount,
                'due': bill.dueDate.toString(),
              },
            )
            .toList();

    // Animate bell when pending bill count changes
    if (_previousBillCount != pendingBills.length) {
      _previousBillCount = pendingBills.length;
      if (pendingBills.isNotEmpty) {
        _bellAnimationController.forward().then(
          (_) => _bellAnimationController.reverse(),
        );
      }
    }

    // Calculate summary values
    final income = transactions
        .where((t) => (t['amount'] as double) > 0)
        .fold<double>(0, (sum, t) => sum + (t['amount'] as double));
    final expenses =
        transactions
            .where((t) => (t['amount'] as double) < 0)
            .fold<double>(0, (sum, t) => sum + (t['amount'] as double))
            .abs();
    final savings = income - expenses;

    // Get current time for greeting
    final hour = DateTime.now().hour;
    String greeting = '';
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.sp,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              authProvider.userName?.split(' ').first ?? 'User',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Profile Avatar with border and hero animation
          Semantics(
            label: 'Profile',
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Hero(
                  tag: 'profile-avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: _buildProfileAvatar(authProvider),
                  ),
                ),
              ),
            ),
          ),
          // Notification bell with improved badge
          Semantics(
            label: 'Notifications',
            child: ScaleTransition(
              scale: _bellAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications_outlined),
                    onPressed: () {
                      Navigator.pushNamed(context, '/bills');
                    },
                    tooltip: 'Notifications',
                  ),
                  if (pendingBills.isNotEmpty)
                    Positioned(
                      top: 6.h,
                      right: 6.w,
                      child: Container(
                        padding: EdgeInsets.all(5.r),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.errorDark : AppColors.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18.w,
                          minHeight: 18.h,
                        ),
                        child: Text(
                          pendingBills.length.toString(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Menu button with improved feedback
          Semantics(
            label: 'Menu',
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              tooltip: 'Menu',
              onSelected: (value) {
                switch (value) {
                  case 'add_transaction':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTransactionScreen(),
                      ),
                    );
                    break;
                  case 'create_bill':
                    final billProvider = Provider.of<BillProvider>(
                      context,
                      listen: false,
                    );
                    final groups = billProvider.groups;
                    if (groups.isNotEmpty) {
                      final defaultGroupId = groups.first.id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  AddBillScreen(groupId: defaultGroupId),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No groups available. Please create a group first.',
                          ),
                        ),
                      );
                    }
                    break;
                  case 'profile':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                    break;
                  case 'share':
                    Share.share(
                      'Check out SavvySplit! Download now: https://savvysplit.app',
                    );
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    _buildMenuItem(
                      Icons.add_circle_outline,
                      'Add Transaction',
                      'add_transaction',
                    ),
                    _buildMenuItem(
                      Icons.receipt_long,
                      'Create Bill',
                      'create_bill',
                    ),
                    _buildMenuItem(
                      Icons.person_outline,
                      'View Profile',
                      'profile',
                    ),
                    _buildMenuItem(Icons.share, 'Share App', 'share'),
                  ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              color: Theme.of(context).cardColor,
              elevation: 8,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.22),
                    Theme.of(context).colorScheme.secondary.withOpacity(
                      0.22,
                    ), // more visible bottom right
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 24.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100.w,
                      height: 130.h,
                      child: SummaryItem(
                        label: 'Income',
                        value: income.toString(),
                        color: Colors.green,
                        valueFontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 100.w,
                      height: 130.h,
                      child: SummaryItem(
                        label: 'Expenses',
                        value: expenses.toString(),
                        color: Colors.red,
                        valueFontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 100.w,
                      height: 130.h,
                      child: SummaryItem(
                        label: 'Savings',
                        value: savings.toString(),
                        color: Colors.blue,
                        valueFontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Recent Transactions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).primaryColor,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transactions');
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              margin: EdgeInsets.only(top: 8.h, bottom: 24.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 16.h,
                ), // Increased bottom padding
                child: SizedBox(
                  height: 200.h, // Increased height for full visibility
                  child: RecentTransactionList(transactions: transactions),
                ),
              ),
            ),

            // Pending Bills Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).primaryColor,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Pending Bills',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/bills');
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              margin: EdgeInsets.only(top: 8.h, bottom: 24.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: SizedBox(
                  height: 140.h,
                  child: PendingBillsList(bills: pendingBills),
                ),
              ),
            ),

            // AI Insight Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Theme.of(context).primaryColor,
                      size: 22.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'AI Insights',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/insights');
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 16.sp,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
            Card(
              margin: EdgeInsets.only(top: 8.h, bottom: 24.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
              child: SizedBox(height: 120.h, child: AIInsightCard()),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build menu items
  PopupMenuItem<String> _buildMenuItem(
    IconData icon,
    String label,
    String value,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 12.w),
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp)),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(AuthProvider authProvider) {
    final photoUrl = authProvider.profileImage;
    final userName = authProvider.userName;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18.r,
        backgroundImage: NetworkImage(photoUrl),
      );
    } else {
      final firstLetter =
          (userName?.isNotEmpty == true)
              ? userName!.trim().split(' ').first[0].toUpperCase()
              : 'U';
      return CircleAvatar(
        radius: 18.r,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
        child: Text(
          firstLetter,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
  }
}
