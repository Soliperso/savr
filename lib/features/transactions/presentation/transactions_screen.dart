import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../widgets/transaction_list_item.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String _filter = 'All';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch real transactions from API on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchTransactionsFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final allTransactions = transactionProvider.transactions;

    // Apply filters
    var filteredTransactions = allTransactions;

    // Filter by type
    if (_filter == 'Expenses') {
      filteredTransactions =
          filteredTransactions
              .where((tx) => (tx['amount'] as double) < 0)
              .toList();
    } else if (_filter == 'Income') {
      filteredTransactions =
          filteredTransactions
              .where((tx) => (tx['amount'] as double) > 0)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredTransactions =
          filteredTransactions
              .where(
                (tx) => tx['title'].toString().toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Section header
          Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 24.h,
              bottom: 0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.swap_horiz,
                  color: Theme.of(context).primaryColor,
                  size: 22.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {}, // Placeholder for filter action
                  tooltip: 'Filter',
                ),
              ],
            ),
          ),

          // Search and filter bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[900]
                            : Colors.grey[100],
                    hintText: 'Search transactions',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Theme.of(context).hintColor,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
                  ),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 16.h),

                // Filter buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Income'),
                      SizedBox(width: 8.w),
                      _buildFilterChip('Expenses'),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Total balance card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.18),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.18),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        ' 24${transactionProvider.totalBalance.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _buildBalanceItem(
                            'Income',
                            ' 24${transactionProvider.totalIncome.toStringAsFixed(1)}',
                            Colors.green,
                            Icons.arrow_upward,
                          ),
                          SizedBox(width: 16.w),
                          _buildBalanceItem(
                            'Expenses',
                            ' 24${transactionProvider.totalExpenses.toStringAsFixed(1)}',
                            Colors.red,
                            Icons.arrow_downward,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child:
                filteredTransactions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                    : Card(
                      margin: EdgeInsets.only(
                        top: 8.h,
                        bottom: 24.h,
                        left: 8.w,
                        right: 8.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 2,
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 8.h,
                        ),
                        itemCount: filteredTransactions.length,
                        separatorBuilder:
                            (context, index) => Divider(
                              height: 1,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[800]
                                      : Colors.grey[200],
                            ),
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return Dismissible(
                            key: Key(
                              '${transaction['title']}_${transaction['fullDate']}_${transaction['amount']}',
                            ),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 16.w),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              final deletedTransaction =
                                  filteredTransactions[index];
                              Provider.of<TransactionProvider>(
                                context,
                                listen: false,
                              ).deleteTransaction(
                                transaction['id'] ?? transaction['_id'] ?? '',
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 16.h,
                                  ),
                                  backgroundColor: Colors.red[600],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  elevation: 8,
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_forever,
                                        color: Colors.white,
                                        size: 22.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          'Transaction deleted',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      Provider.of<TransactionProvider>(
                                        context,
                                        listen: false,
                                      ).addTransaction(
                                        deletedTransaction['title'] ?? '',
                                        (deletedTransaction['amount']
                                                as double?) ??
                                            0.0,
                                        deletedTransaction['category'] ??
                                            'General',
                                        DateTime.tryParse(
                                              deletedTransaction['fullDate'] ??
                                                  '',
                                            ) ??
                                            DateTime.now(),
                                        deletedTransaction['note'] ??
                                            deletedTransaction['description'] ??
                                            '',
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: TransactionListItem(
                              transaction: transaction,
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        tooltip: 'Add Transaction',
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filter = label;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.18),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color:
                isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
    String label,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            radius: 14.r,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 14.sp),
          ),
          SizedBox(width: 8.w),
          Column(
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
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
