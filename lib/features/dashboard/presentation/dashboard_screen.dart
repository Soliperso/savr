import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/transaction_provider.dart';
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
        title: Text(
          '$greeting, ${authProvider.userName?.split(' ').first ?? 'User'}!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Search icon
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search coming soon')),
              );
            },
            tooltip: 'Search',
          ),
          // Notification bell with badge
          ScaleTransition(
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
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.errorDark : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.w,
                        minHeight: 16.h,
                      ),
                      child: Text(
                        pendingBills.length.toString(),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.sp,
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
          // Menu button
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            tooltip: 'Menu',
            onSelected: (value) {
              switch (value) {
                case 'add_transaction':
                  Navigator.pushNamed(context, '/add_transaction');
                  break;
                case 'create_bill':
                  Navigator.pushNamed(context, '/bills');
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
                  // TODO: Implement share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SummaryItem(
                      label: 'Income',
                      value: income.toString(),
                      color: Colors.green,
                    ),
                    SummaryItem(
                      label: 'Expenses',
                      value: expenses.toString(),
                      color: Colors.red,
                    ),
                    SummaryItem(
                      label: 'Savings',
                      value: savings.toString(),
                      color: Colors.blue,
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
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/transactions');
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 180.h,
              child: RecentTransactionList(transactions: transactions),
            ),

            SizedBox(height: 24.h),

            // Pending Bills Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending Bills',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/bills');
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            PendingBillsList(bills: pendingBills),

            // AI Insights
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'AI Insights',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            const AIInsightCard(),
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
}
