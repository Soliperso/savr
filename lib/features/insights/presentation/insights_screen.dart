import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/bill_provider.dart';
import '../../../providers/insights_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../widgets/insight_chart.dart';
import '../models/financial_insight.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

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
          final insights = [
            FinancialInsight(
              title: 'Spending Patterns',
              description:
                  insightsProvider
                      .getExpensePatternInsights(
                        transactionProvider.transactions,
                      )
                      .firstOrNull ??
                  'No spending pattern insights available yet.',
              trendData:
                  transactionProvider.transactions
                      .map((t) => double.tryParse(t.amount.toString()) ?? 0.0)
                      .toList(),
              date: DateTime.now(),
              type: InsightType.spending,
            ),
            FinancialInsight(
              title: 'Bill Management',
              description:
                  insightsProvider
                      .getBillAdvice(
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
                      )
                      .firstOrNull ??
                  'No bill advice available yet.',
              trendData:
                  billProvider.bills.map((b) => b.amount.toDouble()).toList(),
              date: DateTime.now(),
              type: InsightType.budgeting,
            ),
            FinancialInsight(
              title: 'Budgeting Tips',
              description:
                  insightsProvider
                      .getBillAdvice(
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
                      )
                      .skip(1)
                      .firstOrNull ??
                  'No additional budgeting tips available yet.',
              trendData:
                  billProvider.bills.map((b) => b.amount.toDouble()).toList(),
              date: DateTime.now(),
              type: InsightType.trending,
            ),
          ];

          // If no insights available, show empty state
          if (insights.every(
            (insight) =>
                insight.trendData.isEmpty ||
                insight.description.startsWith('No'),
          )) {
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
                    'Add more transactions and bills to get personalized insights',
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

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            itemCount: insights.length,
            separatorBuilder: (context, index) => SizedBox(height: 20.h),
            itemBuilder: (context, index) {
              final insight = insights[index];
              return _DetailedInsightCard(
                insight: insight,
                color: _getColorForInsightType(insight.type),
                icon: _getIconForInsightType(insight.type),
                customChart: InsightChart(
                  data: insight.trendData,
                  lineColor: _getColorForInsightType(insight.type),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getColorForInsightType(InsightType type) {
    switch (type) {
      case InsightType.spending:
        return Colors.blueAccent.withOpacity(0.7);
      case InsightType.budgeting:
        return Colors.purpleAccent.withOpacity(0.7);
      case InsightType.trending:
        return Colors.greenAccent.withOpacity(0.7);
      case InsightType.saving:
        return Colors.orangeAccent.withOpacity(0.7);
    }
  }

  IconData _getIconForInsightType(InsightType type) {
    switch (type) {
      case InsightType.spending:
        return Icons.trending_up;
      case InsightType.budgeting:
        return Icons.receipt_long;
      case InsightType.trending:
        return Icons.savings;
      case InsightType.saving:
        return Icons.account_balance_wallet;
    }
  }
}

class _DetailedInsightCard extends StatefulWidget {
  final FinancialInsight insight;
  final Color color;
  final IconData icon;
  final Widget? customChart;

  const _DetailedInsightCard({
    required this.insight,
    required this.color,
    required this.icon,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.insight.title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.insight.trendData.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        widget.insight.isIncreasing
                            ? 'Trending Up'
                            : 'Trending Down',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color:
                              widget.insight.isIncreasing
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ],
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
            widget.insight.description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15.sp,
              color: Colors.black87,
            ),
          ),
          if (_expanded) ...[
            SizedBox(height: 18.h),
            if (widget.insight.trendData.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Average',
                    value: widget.insight.average.toStringAsFixed(2),
                    color: widget.color,
                  ),
                  _StatItem(
                    label: 'Highest',
                    value: widget.insight.highestValue.toStringAsFixed(2),
                    color: widget.color,
                  ),
                  _StatItem(
                    label: 'Lowest',
                    value: widget.insight.lowestValue.toStringAsFixed(2),
                    color: widget.color,
                  ),
                ],
              ),
              SizedBox(height: 18.h),
            ],
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
