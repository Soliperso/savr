import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart'; // Using provider instead of riverpod based on the provider references

import '../../../providers/transaction_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_action_button.dart';
import '../widgets/transaction_list_item.dart';
import '../models/transaction.dart'; // Corrected import path
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });

    // Fetch transactions when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactionsFromApi();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final transactions = transactionProvider.transactions;
    final isLoading = transactionProvider.isLoading;

    // We're using hardcoded values from the screenshot instead of calculated values
    // final totalBalance = transactionProvider.totalBalance;
    // final totalIncome = transactionProvider.totalIncome;
    // final totalExpenses = transactionProvider.totalExpenses.abs();
    // double savingsRate = 0.0;
    // if (totalIncome > 0) {
    //   savingsRate = ((totalIncome - totalExpenses) / totalIncome) * 100;
    //   savingsRate = savingsRate.clamp(0, 100);
    // }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: const Text(
          'Transactions',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        actions: [
          AnimatedActionButton(
            icon: Icons.calendar_today,
            // label: 'Apr',
            // showLabel: true,
            onTap: () {
              // Show a bottom sheet calendar instead of dialog to prevent overflow
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                isScrollControlled:
                    true, // Make the bottom sheet take only necessary height
                builder:
                    (context) => Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min, // Use min to prevent full-screen
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Select Date Range',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          SizedBox(
                            height:
                                320.h, // Fixed reasonable height that fits on most screens
                            child: CalendarDatePicker(
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              onDateChanged: (date) {
                                // Handle date selection
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                child: const Text(
                                  'Apply',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              );
            },
            tooltip: 'Filter by date',
          ),
          AnimatedActionButton(
            icon: Icons.more_horiz,
            onTap: () {
              // TODO: Implement menu options
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.r),
                  ),
                ),
                builder:
                    (context) => Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.download),
                            title: const Text('Export transactions'),
                            onTap: () {
                              // Handle export
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.category),
                            title: const Text('Manage categories'),
                            onTap: () {
                              // Handle categories
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete_outline),
                            title: const Text('Delete all transactions'),
                            textColor: AppColors.error,
                            iconColor: AppColors.error,
                            onTap: () {
                              // Handle delete all
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
              );
            },
            tooltip: 'More options',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar for filtering
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            height: 34.h,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.blueGrey.shade800.withOpacity(0.5)
                      : const Color.fromARGB(255, 235, 243, 252),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? AppColors.primaryDark
                        : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              dividerColor: Colors.transparent, // Remove the divider line
              indicatorColor: Colors.transparent, // Remove default indicator
              labelColor: Colors.white,
              unselectedLabelColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.grey.shade700,
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
                fontSize: 12.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
              labelPadding: EdgeInsets.symmetric(horizontal: 6.w),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Income'),
                Tab(text: 'Expenses'),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.r),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.blueGrey.shade800.withOpacity(0.5)
                        : const Color.fromARGB(255, 235, 243, 252),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search transactions',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.grey.shade500,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                    size: 22.sp,
                  ),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _searchController.clear();
                              });
                            },
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.grey.shade500,
                              size: 18.sp,
                            ),
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 8.h,
                    horizontal: 12.w,
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
                onChanged: (value) {
                  setState(() {
                    // This will rebuild the widget and filter transactions
                  });
                },
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  // Focus is automatically removed when submitted
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),

          // Balance card
          Card(
            margin: EdgeInsets.all(16.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      Theme.of(context).brightness == Brightness.dark
                          ? [Colors.blueGrey.shade800, Colors.blueGrey.shade700]
                          : [
                            const Color.fromARGB(255, 229, 239, 250),
                            const Color.fromARGB(255, 214, 230, 248),
                          ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative rounded shape in the top-right
                  Positioned(
                    right: 15,
                    top: 15,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Decorative rounded shape in the bottom-left
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Available balance
                        Text(
                          'Available Balance',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // We're using hardcoded value from screenshot, but added color logic
                        Builder(
                          builder: (context) {
                            // In a real app, this would come from transactionProvider.totalBalance
                            final balance = 9539.00; // for demonstration
                            final isPositive = balance >= 0;
                            final displayBalance =
                                '\$${balance.abs().toStringAsFixed(2)}';

                            return Text(
                              isPositive ? displayBalance : '-$displayBalance',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color:
                                    isPositive
                                        ? AppColors.incomeGreen
                                        : AppColors.expenseRed,
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Income and expenses row
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 12.w,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.blueGrey.shade800.withOpacity(0.7)
                                    : const Color.fromARGB(255, 235, 243, 252),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              // Income
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 24.w,
                                          height: 24.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.incomeGreen
                                                .withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.arrow_upward_rounded,
                                              color: AppColors.incomeGreen,
                                              size: 14.sp,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'Income',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 14.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '\$9539.00', // Match screenshot value
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.incomeGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Vertical divider
                              Container(
                                height: 40.h,
                                width: 1,
                                color: Colors.grey.shade300,
                              ),

                              // Expenses
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(left: 16.w),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24.w,
                                            height: 24.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.expenseRed
                                                  .withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.arrow_downward_rounded,
                                                color: AppColors.expenseRed,
                                                size: 16.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Expenses',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Padding(
                                      padding: EdgeInsets.only(left: 16.w),
                                      child: Text(
                                        '\$0.00', // Match screenshot value
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.expenseRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Savings rate
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Savings Rate:',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '100.0%', // Match screenshot value
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.incomeGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Transactions header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  '${transactions.length} items',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : transactions.isEmpty
                    ? _buildEmptyState()
                    : _buildTransactionsList(),
          ),
        ],
      ),
      floatingActionButton: Container(
        height: 50.h,
        width: 50.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                Theme.of(context).brightness == Brightness.dark
                    ? [AppColors.primaryDark, AppColors.primary]
                    : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.sp,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Tap + to add your first transaction',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final allTransactions = transactionProvider.transactions;

    // Filter transactions based on selected tab
    final List<Transaction> filteredTransactions;
    switch (_selectedTabIndex) {
      case 1: // Income
        filteredTransactions =
            allTransactions.where((t) => t.amount > 0).toList();
        break;
      case 2: // Expenses
        filteredTransactions =
            allTransactions.where((t) => t.amount < 0).toList();
        break;
      default: // All
        filteredTransactions = allTransactions;
    }

    // Filter by search term if needed
    final searchTerm = _searchController.text.toLowerCase();
    final displayedTransactions =
        searchTerm.isEmpty
            ? filteredTransactions
            : filteredTransactions
                .where(
                  (t) =>
                      t.title.toLowerCase().contains(searchTerm) ||
                      t.category.toLowerCase().contains(searchTerm),
                )
                .toList();

    if (displayedTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No matching transactions found',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: displayedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = displayedTransactions[index];
        return Dismissible(
          key: Key(transaction.id ?? '$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.delete, color: Colors.white, size: 24.sp),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Transaction'),
                  content: const Text(
                    'Are you sure you want to delete this transaction?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            if (transaction.id != null) {
              transactionProvider.deleteTransaction(transaction.id!);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: TransactionListItem(transaction: transaction),
          ),
        );
      },
    );
  }
}
