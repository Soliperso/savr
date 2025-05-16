import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import '../models/financial_insight.dart';
import 'insight_chart.dart';

class InsightCard extends StatefulWidget {
  final FinancialInsight insight;
  const InsightCard({super.key, required this.insight});

  @override
  State<InsightCard> createState() => _InsightCardState();
}

class _InsightCardState extends State<InsightCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _iconAnimController;

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      lowerBound: 1.0,
      upperBound: 1.13,
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
    // Optionally: HapticFeedback.lightImpact();
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.spending:
        return Colors.orange;
      case InsightType.saving:
        return Colors.green;
      case InsightType.budgeting:
        return Colors.blue;
      case InsightType.trending:
        return Colors.purple.shade400;
    }
  }

  IconData _getInsightIcon(InsightType type) {
    switch (type) {
      case InsightType.spending:
        return Icons.trending_up;
      case InsightType.saving:
        return Icons.emoji_events;
      case InsightType.budgeting:
        return Icons.schedule;
      case InsightType.trending:
        return Icons.insights;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.insight;
    final insightColor = _getInsightColor(insight.type);
    final iconData = _getInsightIcon(insight.type);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: insight.title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              insightColor.withOpacity(isExpanded ? 0.75 : 0.13),
              Colors.white.withOpacity(
                isDark
                    ? (isExpanded ? 0.18 : 0.08)
                    : (isExpanded ? 0.18 : 0.13),
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: insightColor.withOpacity(0.13),
              blurRadius: isExpanded ? 18 : 14,
              offset: Offset(0, isExpanded ? 6 : 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.13), width: 1.1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Stack(
            children: [
              if (isExpanded)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(color: Colors.white.withOpacity(0.13)),
                  ),
                ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.r),
                  onTap: _handleTap,
                  splashColor: insightColor.withOpacity(0.07),
                  highlightColor: insightColor.withOpacity(0.03),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Accent bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: isExpanded ? 6.w : 5.w,
                          decoration: BoxDecoration(
                            color: insightColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(18.r),
                              bottomLeft: Radius.circular(18.r),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: isExpanded ? 18.h : 14.h,
                              horizontal: 13.w,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ScaleTransition(
                                      scale: _iconAnimController,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: insightColor.withOpacity(0.13),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            if (isExpanded)
                                              BoxShadow(
                                                color: insightColor.withOpacity(
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
                                          color: insightColor,
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
                                            insight.title,
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17.sp,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                              letterSpacing: 0.15,
                                            ),
                                          ),
                                          SizedBox(height: 6.h),
                                          // Animated details section
                                          AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 350,
                                            ),
                                            curve: Curves.easeInOut,
                                            child:
                                                isExpanded
                                                    ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (insight
                                                            .trendData
                                                            .isNotEmpty) ...[
                                                          SizedBox(height: 8.h),
                                                          InsightChart(
                                                            data:
                                                                insight
                                                                    .trendData,
                                                            lineColor:
                                                                insightColor,
                                                          ),
                                                          SizedBox(
                                                            height: 14.h,
                                                          ),
                                                        ],
                                                        // Details
                                                        Text(
                                                          insight.description,
                                                          style: TextStyle(
                                                            fontFamily: 'Inter',
                                                            fontSize: 14.sp,
                                                            color:
                                                                isDark
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black87,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 1.32,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16.h),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              insight.date
                                                                  .toString()
                                                                  .split(
                                                                    ' ',
                                                                  )[0],
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Inter',
                                                                fontSize: 12.sp,
                                                                color:
                                                                    Theme.of(
                                                                      context,
                                                                    ).hintColor,
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons.share,
                                                              ),
                                                              onPressed:
                                                                  () => Share.share(
                                                                    'Financial Insight from SavvySplit:\n\n${insight.title}\n${insight.description}\n\nGenerated on ${insight.date.toString().split(' ')[0]}',
                                                                    subject:
                                                                        insight
                                                                            .title,
                                                                  ),
                                                              color:
                                                                  insightColor,
                                                              tooltip:
                                                                  'Share Insight',
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    )
                                                    : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 20,
                                      color: insightColor.withOpacity(0.7),
                                      semanticLabel:
                                          isExpanded ? 'Collapse' : 'Expand',
                                    ),
                                  ],
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
