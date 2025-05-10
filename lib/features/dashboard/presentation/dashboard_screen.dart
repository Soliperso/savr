import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/bill_provider.dart';
import '../widgets/summary_item.dart';
import '../widgets/recent_transaction_list.dart';
import '../widgets/pending_bills_list.dart';
import '../widgets/ai_insight_card.dart';
import '../../../features/auth/presentation/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<TransactionProvider>().transactions;
    final billProvider = context.watch<BillProvider>();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ),
            tooltip: 'Profile',
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

            // Recent Transactions Header
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 180.h,
              child: RecentTransactionList(transactions: transactions),
            ),

            SizedBox(height: 24.h),

            // Pending Bills Header
            Text(
              'Pending Bills',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 120.h,
              child: PendingBillsList(bills: pendingBills),
            ),

            SizedBox(height: 24.h),

            // AI Insight Header
            Text(
              'AI Insight',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            const AIInsightCard(),
          ],
        ),
      ),
    );
  }
}
