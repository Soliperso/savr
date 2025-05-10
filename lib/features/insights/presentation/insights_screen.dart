import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../models/financial_insight.dart';
import '../widgets/insight_card.dart';
import '../../../providers/bill_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  List<FinancialInsight> _generateInsights(
    BuildContext context,
    BillProvider billProvider,
  ) {
    // Get the current date for the insights
    final now = DateTime.now();

    // Example insights based on bill data
    final insights = <FinancialInsight>[];

    // Calculate spending trends
    final bills = billProvider.bills;
    if (bills.isNotEmpty) {
      // Get monthly spending totals for the last 6 months
      final spendingTrend =
          List.generate(6, (index) {
            final month = now.month - index;
            final year = now.year - (month <= 0 ? 1 : 0);
            final adjustedMonth = month <= 0 ? month + 12 : month;

            return bills
                .where((bill) {
                  final billDate = bill.dueDate;
                  return billDate.year == year &&
                      billDate.month == adjustedMonth;
                })
                .fold<double>(0, (sum, bill) => sum + bill.amount);
          }).reversed.toList();

      insights.add(
        FinancialInsight(
          title: 'Monthly Spending Trend',
          description:
              'Your spending has ${spendingTrend.last > spendingTrend[spendingTrend.length - 2] ? 'increased' : 'decreased'} compared to last month.',
          trendData: spendingTrend,
          date: now,
          type: InsightType.spending,
        ),
      );

      // Calculate bill categories distribution
      if (bills.length >= 2) {
        insights.add(
          FinancialInsight(
            title: 'Bill Distribution',
            description:
                'Most of your expenses are shared bills. Consider reviewing your individual expenses.',
            trendData: List.generate(6, (index) => (index + 1) * 10.0),
            date: now,
            type: InsightType.budgeting,
          ),
        );
      }

      // Savings potential insight
      final totalSpending = bills.fold<double>(
        0,
        (sum, bill) => sum + bill.amount,
      );
      if (totalSpending > 0) {
        insights.add(
          FinancialInsight(
            title: 'Savings Opportunity',
            description:
                'You could save \$${(totalSpending * 0.15).toStringAsFixed(2)} by optimizing your monthly bills.',
            trendData: List.generate(6, (index) => totalSpending / (index + 1)),
            date: now,
            type: InsightType.saving,
          ),
        );
      }

      // Payment trends insight
      final unpaidBills = bills.where((bill) => !bill.paid).length;
      if (unpaidBills > 0) {
        insights.add(
          FinancialInsight(
            title: 'Payment Behavior',
            description:
                'You have $unpaidBills unpaid bills. Setting up reminders can help you stay on track.',
            trendData: List.generate(6, (index) => (5 - index) * 20.0),
            date: now,
            type: InsightType.trending,
          ),
        );
      }
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Insights',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, child) {
          final insights = _generateInsights(context, billProvider);

          return insights.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No insights available yet',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add more bills to get personalized insights',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount: insights.length,
                itemBuilder:
                    (context, index) => InsightCard(insight: insights[index]),
              );
        },
      ),
    );
  }
}
