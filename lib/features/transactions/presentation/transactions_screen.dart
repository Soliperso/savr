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
                    hintText: 'Search transactions',
                    hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 16.w,
                    ),
                  ),
                  style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '\$${transactionProvider.totalBalance.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _buildBalanceItem(
                            'Income',
                            '\$${transactionProvider.totalIncome.toStringAsFixed(1)}',
                            Colors.green,
                            Icons.arrow_upward,
                          ),
                          SizedBox(width: 16.w),
                          _buildBalanceItem(
                            'Expenses',
                            '\$${transactionProvider.totalExpenses.toStringAsFixed(1)}',
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
                      child: Text(
                        'No transactions found',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                      ),
                    )
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: filteredTransactions.length,
                      separatorBuilder:
                          (context, index) => Divider(height: 1.h),
                      itemBuilder: (context, index) {
                        final originalIndex = allTransactions.indexOf(
                          filteredTransactions[index],
                        );
                        return Dismissible(
                          key: Key('transaction-${originalIndex}'),
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
                            Provider.of<TransactionProvider>(
                              context,
                              listen: false,
                            ).deleteTransaction(originalIndex);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Transaction deleted',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                  ),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: TransactionListItem(
                            transaction: filteredTransactions[index],
                          ),
                        );
                      },
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
        child: const Icon(Icons.add),
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : Colors.black87,
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
