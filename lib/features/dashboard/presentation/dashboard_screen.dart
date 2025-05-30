import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/insights_provider.dart';
import '../../bills/presentation/add_bill_screen.dart';
import '../../bills/presentation/bills_screen.dart';
import '../../transactions/presentation/add_transaction_screen.dart';
import '../../transactions/presentation/transactions_screen.dart';
import '../../insights/presentation/insights_screen.dart';
import '../widgets/summary_item.dart';
import '../widgets/recent_transaction_list.dart';
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
        backgroundColor: Colors.transparent,
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
              '${authProvider.userName?.split(' ').first ?? 'User'}!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18.sp,
                fontWeight: FontWeight.w500, // Changed from bold to medium
                color: Theme.of(context).textTheme.titleMedium?.color,
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
                      HapticFeedback.lightImpact();
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder:
                            (context) => _PendingBillsBottomSheet(
                              pendingBills: pendingBills,
                              isDark: isDark,
                            ),
                      );
                    },
                    tooltip: 'Notifications',
                  ),
                  if (pendingBills.isNotEmpty)
                    Positioned(
                      top: 0,
                      right: 4,
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        builder: (context, value, child) {
                          return Transform.scale(scale: value, child: child);
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.errorDark : AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
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
                    ),
                ],
              ),
            ),
          ),
          // Menu button with improved feedback
          Semantics(
            label: 'Menu',
            child: Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded),
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
                    Theme.of(context).primaryColor.withValues(alpha: .22),
                    Theme.of(context).colorScheme.secondary.withValues(
                      alpha: 0.22,
                    ), // more visible bottom right
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              margin: EdgeInsets.only(bottom: 20.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 110.w,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionsScreen(),
                      ),
                    );
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BillsScreen(),
                      ),
                    );
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
              elevation: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Empty state
                  if (pendingBills.isEmpty)
                    SizedBox(
                      height: 200.h,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 40.sp,
                              color: Colors.green.withOpacity(0.6),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'All caught up!',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            Text(
                              'No pending bills at the moment',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.sp,
                                color: Theme.of(
                                  context,
                                ).hintColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Bills list with header
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 160.h, // Adjusted height
                          child: ListView.separated(
                            padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
                            itemCount: pendingBills.length,
                            separatorBuilder:
                                (context, index) => Divider(
                                  height: 1,
                                  thickness: 0.7,
                                  indent: 16.w,
                                  endIndent: 16.w,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                            itemBuilder: (context, index) {
                              final bill = pendingBills[index];
                              final dueDate = DateTime.tryParse(
                                bill['due']?.toString() ?? '',
                              );

                              // Determine due status
                              Color iconColor = Theme.of(context).hintColor;
                              String dueStatus = '';
                              if (dueDate != null) {
                                final now = DateTime.now();
                                final days = dueDate.difference(now).inDays;
                                if (dueDate.isBefore(now)) {
                                  iconColor = Colors.red;
                                  dueStatus = 'Overdue';
                                } else if (days <= 3) {
                                  iconColor = Colors.orange;
                                  dueStatus = 'Due soon';
                                } else {
                                  dueStatus = '$days days left';
                                  iconColor = Colors.green;
                                }
                              }

                              return IntrinsicHeight(
                                child: Stack(
                                  children: [
                                    // Add subtle highlight effect
                                    Positioned(
                                      top: 0,
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              iconColor.withOpacity(0.05),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.3],
                                          ),
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      leading: Container(
                                        width: 40.w,
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          color: iconColor.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: iconColor.withOpacity(
                                                0.15,
                                              ),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            dueDate?.isBefore(DateTime.now()) ??
                                                    false
                                                ? Icons.warning_amber_rounded
                                                : Icons.calendar_today_rounded,
                                            color: iconColor,
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Left section: Title
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              bill['title'] as String? ?? '',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12.sp,
                                                color:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                          // Middle section: Date info
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                dueDate != null
                                                    ? DateFormat(
                                                      'MMM d',
                                                    ).format(dueDate)
                                                    : '--',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: iconColor,
                                                ),
                                              ),
                                              SizedBox(width: 6.w),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 3.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: iconColor.withOpacity(
                                                    0.12,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        4.r,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: iconColor
                                                          .withOpacity(0.1),
                                                      blurRadius: 2,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  dueStatus,
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: iconColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Right section: Monetary value
                                          SizedBox(width: 10.w),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.r),
                                              color: AppColors.expenseRed
                                                  .withOpacity(0.08),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.expenseRed
                                                      .withOpacity(0.08),
                                                  blurRadius: 4,
                                                  spreadRadius: 0,
                                                ),
                                              ],
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 4.h,
                                            ),
                                            child: Text(
                                              '\$${(bill['amount'] as num?)?.toStringAsFixed(2) ?? '--'}',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.sp,
                                                color: AppColors.expenseRed,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: null,
                                      trailing: null,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const BillsScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                ],
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InsightsScreen(),
                      ),
                    );
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
            // Data-driven: Three beautiful, interactive AI Insights cards (dashboard style)
            Consumer3<InsightsProvider, TransactionProvider, BillProvider>(
              builder: (
                context,
                insightsProvider,
                transactionProvider,
                billProvider,
                _,
              ) {
                final expenseInsights = insightsProvider
                    .getExpensePatternInsights(
                      transactionProvider.transactions,
                    );
                final billAdvice = insightsProvider.getBillAdvice(
                  billProvider.bills
                      .map(
                        (b) => {
                          'amount': b.amount,
                          'paid': b.paid,
                          'splitWith': b.splitWith,
                          'title': b.title,
                        },
                      )
                      .toList(),
                );
                final savingsMilestone =
                    savings > 0
                        ? 'Your savings increased by  24${savings.toStringAsFixed(0)} compared to last month. Keep up the good work!'
                        : 'Try to save more this month!';
                final cards = [
                  {
                    'title': 'Spending Spike',
                    'summary':
                        expenseInsights.isNotEmpty
                            ? expenseInsights.first
                            : 'No spending pattern insights available yet.',
                    'details':
                        expenseInsights.length > 1
                            ? expenseInsights[1]
                            : 'Track your spending to get more insights.',
                    'color': Colors.orange.shade50,
                    'icon': Icons.trending_up,
                    'iconColor': Colors.orange,
                  },
                  {
                    'title': 'Upcoming Bill',
                    'summary':
                        billAdvice.isNotEmpty
                            ? billAdvice.first
                            : 'No upcoming bill advice available yet.',
                    'details':
                        billAdvice.length > 1
                            ? billAdvice[1]
                            : 'Pay your bills on time to avoid late fees.',
                    'color': Colors.blue.shade50,
                    'icon': Icons.schedule,
                    'iconColor': Colors.blue,
                  },
                  {
                    'title': 'Savings Milestone',
                    'summary':
                        savings > 0
                            ? 'You saved more than last month! Great job.'
                            : 'No savings milestone yet.',
                    'details': savingsMilestone,
                    'color': Colors.green.shade50,
                    'icon': Icons.emoji_events,
                    'iconColor': Colors.green,
                  },
                ];
                return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: 3,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: _ExpandableInsightCard(insight: cards[index]),
                    );
                  },
                );
              },
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

// Add this widget at the end of the file (after DashboardScreen)
class _PendingBillsBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> pendingBills;
  final bool isDark;

  const _PendingBillsBottomSheet({
    required this.pendingBills,
    required this.isDark,
  });

  @override
  State<_PendingBillsBottomSheet> createState() =>
      _PendingBillsBottomSheetState();
}

class _PendingBillsBottomSheetState extends State<_PendingBillsBottomSheet>
    with SingleTickerProviderStateMixin {
  String _search = '';
  String _sort = 'due';
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredSortedBills {
    List<Map<String, dynamic>> bills = widget.pendingBills;
    if (_search.isNotEmpty) {
      bills =
          bills
              .where(
                (b) => (b['title'] ?? '').toLowerCase().contains(
                  _search.toLowerCase(),
                ),
              )
              .toList();
    }
    bills.sort((a, b) {
      if (_sort == 'due') {
        return (DateTime.tryParse(a['due'] ?? '') ?? DateTime.now()).compareTo(
          DateTime.tryParse(b['due'] ?? '') ?? DateTime.now(),
        );
      } else if (_sort == 'amount') {
        return ((b['amount'] as num?) ?? 0).compareTo(
          (a['amount'] as num?) ?? 0,
        );
      } else {
        return (a['title'] ?? '').compareTo(b['title'] ?? '');
      }
    });
    return bills;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final headerColor = isDark ? Colors.grey[850] : Colors.grey[100];
    final maxHeight =
        MediaQuery.of(context).size.height *
        0.85; // Maximum 85% of screen height
    final minHeight =
        MediaQuery.of(context).size.height *
        0.3; // Minimum 30% of screen height

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight, minHeight: minHeight),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle and Header Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                // Header Content
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 14.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (widget.pendingBills.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            // Search Field
                            Expanded(
                              child: Container(
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withOpacity(0.1),
                                  ),
                                ),
                                child: TextField(
                                  onChanged:
                                      (value) =>
                                          setState(() => _search = value),
                                  decoration: InputDecoration(
                                    hintText: 'Search bills...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      size: 20.sp,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Sort Button
                            Container(
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).dividerColor.withOpacity(0.1),
                                ),
                              ),
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.sort, size: 20.sp),
                                onSelected:
                                    (value) => setState(() => _sort = value),
                                itemBuilder:
                                    (context) => [
                                      const PopupMenuItem(
                                        value: 'due',
                                        child: Text('Sort by due date'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'amount',
                                        child: Text('Sort by amount'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'title',
                                        child: Text('Sort by name'),
                                      ),
                                    ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.7,
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
          // Bills List
          Flexible(
            child:
                _filteredSortedBills.isEmpty
                    ? Container(
                      margin: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48.sp,
                            color: Theme.of(context).hintColor.withOpacity(0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            _search.isEmpty
                                ? 'No pending bills'
                                : 'No bills match your search',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context).hintColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 10.h,
                      ),
                      itemCount: _filteredSortedBills.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            thickness: 0.7,
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.3),
                          ),
                      itemBuilder: (context, index) {
                        final bill = _filteredSortedBills[index];
                        final DateTime? dueDate = DateTime.tryParse(
                          bill['due'] ?? '',
                        );
                        final bool isOverdue =
                            dueDate != null && dueDate.isBefore(DateTime.now());
                        final int daysUntilDue =
                            dueDate != null
                                ? dueDate.difference(DateTime.now()).inDays
                                : 0;

                        return AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                (1 - _animation.value) * 20 * (index + 1),
                              ),
                              child: Opacity(
                                opacity: _animation.value,
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  title: Text(
                                    bill['title'] ?? 'Untitled Bill',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    dueDate != null
                                        ? '${isOverdue ? 'Overdue by' : 'Due in'} ${daysUntilDue.abs()} days'
                                        : 'No due date',
                                    style: TextStyle(
                                      color:
                                          isOverdue
                                              ? Colors.red
                                              : Theme.of(context).hintColor,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  trailing: Text(
                                    '\$${(bill['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ExpandableInsightCard extends StatefulWidget {
  final Map<String, dynamic> insight;

  const _ExpandableInsightCard({required this.insight});

  @override
  State<_ExpandableInsightCard> createState() => _ExpandableInsightCardState();
}

class _ExpandableInsightCardState extends State<_ExpandableInsightCard> {
  bool _isExpanded = false;

  String _getDateText(String title) {
    final now = DateTime.now();
    switch (title) {
      case 'Spending Spike':
        return 'Last 7 days';
      case 'Upcoming Bill':
        return 'Next week';
      case 'Savings Milestone':
        return '${now.month}/${now.year}';
      default:
        return 'Today';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(16.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).cardColor.withOpacity(0.45), // Reduced opacity from 0.7 to 0.45
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.insight['iconColor']?.withOpacity(0.12) ??
                        Colors.transparent, // Slightly reduced gradient opacity
                    widget.insight['iconColor']?.withOpacity(0.04) ??
                        Colors.transparent,
                  ],
                ),
                border: Border(
                  left: BorderSide(
                    color:
                        widget.insight['iconColor'] as Color? ??
                        Theme.of(context).primaryColor,
                    width: 4.w,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color:
                                widget.insight['iconColor']?.withOpacity(
                                  0.12,
                                ) ??
                                Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.insight['icon'] as IconData? ?? Icons.info,
                            color:
                                widget.insight['iconColor'] as Color? ??
                                Theme.of(context).primaryColor,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.insight['title'] as String? ?? '',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.color
                                      ?.withOpacity(0.75),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      widget.insight['iconColor']?.withOpacity(
                                        0.12,
                                      ) ??
                                      Colors.transparent,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  _getDateText(
                                    widget.insight['title'] as String? ?? '',
                                  ),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: widget.insight['iconColor']
                                        ?.withOpacity(0.75),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 24.sp,
                          color: Theme.of(context).hintColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState:
                          _isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                      firstChild: Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          widget.insight['summary'] as String? ?? '',
                          style: TextStyle(
                            height: 1.4,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.65),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      secondChild: Padding(
                        padding: EdgeInsets.only(top: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.insight['summary'] as String? ?? '',
                              style: TextStyle(
                                height: 1.4,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.65),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              widget.insight['details'] as String? ?? '',
                              style: TextStyle(
                                height: 1.4,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
