import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/insights_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../widgets/insight_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
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
      body: Consumer3<InsightsProvider, TransactionProvider, BillProvider>(
        builder: (
          context,
          insightsProvider,
          transactionProvider,
          billProvider,
          _,
        ) {
          // Prepare data for each card
          final expenseInsights = insightsProvider.getExpensePatternInsights(
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

          // If no data, show empty state
          if (expenseInsights.isEmpty && billAdvice.isEmpty) {
            return Center(
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
            );
          }

          // Three beautiful, detailed, interactive cards
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            children: [
              _DetailedInsightCard(
                title: 'Spending Patterns',
                description:
                    expenseInsights.isNotEmpty
                        ? expenseInsights.first
                        : 'No spending pattern insights available yet.',
                color: Colors.blueAccent.withOpacity(0.7),
                icon: Icons.trending_up,
                chartData:
                    transactionProvider.transactions
                        .map((t) => (t['amount'] as double))
                        .toList(),
                customChart: InsightChart(
                  data:
                      transactionProvider.transactions
                          .map((t) => (t['amount'] as double))
                          .toList(),
                  lineColor: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 20.h),
              _DetailedInsightCard(
                title: 'Bill Management',
                description:
                    billAdvice.isNotEmpty
                        ? billAdvice.first
                        : 'No bill advice available yet.',
                color: Colors.purpleAccent.withOpacity(0.7),
                icon: Icons.receipt_long,
                chartData:
                    billProvider.bills.map((b) => b.amount as double).toList(),
                customChart: InsightChart(
                  data:
                      billProvider.bills
                          .map((b) => b.amount as double)
                          .toList(),
                  lineColor: Colors.purpleAccent,
                ),
              ),
              SizedBox(height: 20.h),
              _DetailedInsightCard(
                title: 'Budgeting Tips',
                description:
                    billAdvice.length > 1
                        ? billAdvice[1]
                        : 'No additional budgeting tips available yet.',
                color: Colors.greenAccent.withOpacity(0.7),
                icon: Icons.savings,
                chartData:
                    billProvider.bills.map((b) => b.amount as double).toList(),
                customChart: InsightChart(
                  data:
                      billProvider.bills
                          .map((b) => b.amount as double)
                          .toList(),
                  lineColor: Colors.greenAccent,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Add a new widget for the detailed, interactive card
class _DetailedInsightCard extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final List<double> chartData;
  final Widget? customChart;

  const _DetailedInsightCard({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.chartData,
    this.customChart,
  });

  @override
  State<_DetailedInsightCard> createState() => _DetailedInsightCardState();
}

class _DetailedInsightCardState extends State<_DetailedInsightCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            widget.color.withOpacity(0.7),
            Colors.white.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.2),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: widget.color.withOpacity(0.3), width: 1.5),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: widget.color.withOpacity(0.2),
                child: Icon(widget.icon, color: widget.color, size: 28.sp),
                radius: 28.r,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  color: widget.color,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15.sp,
              color: Colors.black87,
            ),
          ),
          if (_expanded) ...[
            SizedBox(height: 18.h),
            widget.customChart ??
                Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Chart coming soon',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      color: widget.color,
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}
