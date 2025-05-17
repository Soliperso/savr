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
import '../../transactions/presentation/add_transaction_screen.dart';
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
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
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
                      top: 2,
                      right: 2,
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
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
              child: SizedBox(
                height: 200.h,
                child: ListView.separated(
                  padding: EdgeInsets.only(
                    top: 4.h,
                    bottom: 4.h,
                  ), // reduced vertical padding
                  itemCount: pendingBills.length,
                  separatorBuilder:
                      (context, index) => Divider(
                        height: 1,
                        thickness: 0.7, // thinner divider
                        color: Colors.grey[300], // lighter divider color
                      ),
                  itemBuilder: (context, index) {
                    final bill = pendingBills[index];
                    final dueDate = DateTime.tryParse(
                      bill['due']?.toString() ?? '',
                    );
                    Color iconColor = Theme.of(context).hintColor;
                    if (dueDate != null) {
                      final now = DateTime.now();
                      final days = dueDate.difference(now).inDays;
                      if (dueDate.isBefore(now)) {
                        iconColor = Colors.red; // Overdue
                      } else if (days <= 3) {
                        iconColor = Colors.orange; // Due soon
                      }
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.15),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: iconColor,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 6.h, // reduced vertical padding
                        horizontal: 16.w,
                      ),
                      title: Text(
                        bill['title'] as String? ?? '',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.white, // set title color to white
                        ),
                      ),
                      subtitle: Text(
                        'Due: ' +
                            (bill['due'] != null
                                ? DateFormat(
                                  'MMM d, yyyy',
                                ).format(DateTime.parse(bill['due'] as String))
                                : '--'),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          color: Theme.of(context).hintColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: Text(
                        '\$${(bill['amount'] as num?)?.toStringAsFixed(2) ?? '--'}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () {},
                    );
                  },
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 0),
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

class _PendingBillsBottomSheetState extends State<_PendingBillsBottomSheet> {
  String _search = '';
  String _sort = 'due';

  List<Map<String, dynamic>> get _filteredSortedBills {
    List<Map<String, dynamic>> bills = widget.pendingBills;
    if (_search.isNotEmpty) {
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
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    final headerColor = isDark ? Colors.grey[850] : Colors.grey[100];
    return SafeArea(
      top: true,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: constraints.maxHeight),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
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
                  // Top section with background color (handler + header)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: headerColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 8),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color:
                                    isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pending Bills',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Divider(
                  //   height: .7,
                  //   thickness: .7,
                  //   color: Colors.grey[200],
                  // ),
                  Divider(
                    height: 1,
                    thickness: 0.7,
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child:
                          _filteredSortedBills.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.celebration,
                                      color: theme.primaryColor,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'No pending bills!',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        color: theme.hintColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 10,
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
                                  return ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.h,
                                      horizontal: 16.w,
                                    ),
                                    title: Text(
                                      bill['title'] as String? ?? '',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.sp,
                                        color:
                                            theme.textTheme.titleLarge?.color,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Due: ${bill['due'] != null ? DateFormat('MMM d, yyyy').format(DateTime.parse(bill['due'] as String)) : '--'}',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13.sp,
                                            color: theme.hintColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        Text(
                                          '\$${(bill['amount'] as num?)?.toStringAsFixed(2) ?? '--'}',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.sp,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Removed trailing IconButton (checkmark)
                                    onTap: () {},
                                  );
                                },
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

class _ExpandableInsightCardState extends State<_ExpandableInsightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _iconAnimController;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _iconAnimController.forward();
      } else {
        _iconAnimController.reverse();
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final Color cardColor = insight['color'] as Color;
    final IconData iconData = insight['icon'] as IconData;
    final Color iconColor = insight['iconColor'] as Color;
    final String title = insight['title'] as String;
    final String summary = insight['summary'] as String;
    final String details = insight['details'] as String;
    final String date = DateFormat('MMM d, yyyy').format(DateTime.now());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Semantics(
      label: title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor.withOpacity(isExpanded ? 0.85 : 0.95),
              Colors.white.withOpacity(isExpanded ? 0.22 : 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.13),
              blurRadius: isExpanded ? 22 : 10,
              offset: Offset(0, isExpanded ? 8 : 3),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.13), width: 1.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Stack(
            children: [
              if (isExpanded)
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(color: Colors.white.withOpacity(0.13)),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.r),
                  onTap: _handleTap,
                  splashColor: iconColor.withOpacity(0.09),
                  highlightColor: iconColor.withOpacity(0.04),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Accent bar for visual association
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: isExpanded ? 7.w : 4.w,
                          decoration: BoxDecoration(
                            color: iconColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18.r),
                              bottomLeft: Radius.circular(18.r),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isExpanded ? 18.h : 10.h,
                              horizontal: 13.w,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedScale(
                                      scale: isExpanded ? 1.13 : 1.0,
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      curve: Curves.elasticOut,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: iconColor.withOpacity(0.13),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            if (isExpanded)
                                              BoxShadow(
                                                color: iconColor.withOpacity(
                                                  0.13,
                                                ),
                                                blurRadius: 10,
                                                offset: Offset(0, 3),
                                              ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(8.r),
                                        child: Icon(
                                          iconData,
                                          color: iconColor,
                                          size: 22.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                              fontSize:
                                                  15.sp, // Reduced from 17.sp to 15.sp
                                              letterSpacing: 0.15,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          Text(
                                            summary,
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 13.sp,
                                              color: theme.hintColor,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Animated expand/collapse icon
                                    GestureDetector(
                                      onTap: _handleTap,
                                      child: RotationTransition(
                                        turns: _iconRotation,
                                        child: Icon(
                                          Icons.expand_more,
                                          size: 22,
                                          color: iconColor.withOpacity(0.7),
                                          semanticLabel:
                                              isExpanded
                                                  ? 'Collapse'
                                                  : 'Expand',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Date pill
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: 8.h,
                                    bottom: 2.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: iconColor.withOpacity(0.13),
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: Text(
                                          date,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 12.sp,
                                            color: iconColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Divider between summary and details
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  child:
                                      isExpanded
                                          ? Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.h,
                                            ),
                                            child: Divider(
                                              color: iconColor.withOpacity(
                                                0.18,
                                              ),
                                              thickness: 1.1,
                                              height: 1,
                                            ),
                                          )
                                          : const SizedBox.shrink(),
                                ),
                                // Animated details section
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  child:
                                      isExpanded
                                          ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 8.h),
                                              Text(
                                                details,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 14.sp,
                                                  color:
                                                      isDark
                                                          ? Colors.white
                                                          : Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.32,
                                                ),
                                              ),
                                              SizedBox(height: 16.h),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/insights',
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.analytics,
                                                    size: 16,
                                                    semanticLabel:
                                                        'View Analytics',
                                                  ),
                                                  label: Text(
                                                    'View Analytics',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: iconColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 2.5,
                                                    minimumSize: Size(0, 36.h),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 12.w,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    shadowColor: iconColor
                                                        .withOpacity(0.18),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                          : const SizedBox.shrink(),
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
            ],
          ),
        ),
      ),
    );
  }
}
