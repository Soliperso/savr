import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InsightsProvider extends ChangeNotifier {
  // Function to group transactions by category and calculate total amounts
  Map<String, double> getCategoryAnalysis(
    List<Map<String, dynamic>> transactions,
  ) {
    final Map<String, double> categoryTotals = {};

    for (var transaction in transactions.where(
      (t) => (t['amount'] as double) < 0,
    )) {
      final amount = (transaction['amount'] as double).abs();
      final category = transaction['category'] as String? ?? 'Other';
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return categoryTotals;
  }

  // Function to group spending by month
  Map<String, double> getMonthlySpending(
    List<Map<String, dynamic>> transactions,
  ) {
    final Map<String, double> monthlySpending = {};
    final dateFormat = DateFormat('MMM yyyy');

    for (var transaction in transactions.where(
      (t) => (t['amount'] as double) < 0,
    )) {
      final amount = (transaction['amount'] as double).abs();
      final date = DateTime.parse(transaction['fullDate'] as String);
      final monthKey = dateFormat.format(date);
      monthlySpending[monthKey] = (monthlySpending[monthKey] ?? 0) + amount;
    }

    return monthlySpending;
  }

  // Function to calculate split bills insights
  Map<String, dynamic> getSplitBillsInsights(List<Map<String, dynamic>> bills) {
    double totalOwed = 0;
    double totalPending = 0;
    Map<String, double> personDebts = {};

    for (var bill in bills) {
      if (bill['paid'] != true) {
        final amount = bill['amount'] as double;
        final splitWith = bill['splitWith'] as List;
        final sharePerPerson = amount / (splitWith.length + 1);

        totalPending += amount;
        for (var person in splitWith) {
          personDebts[person] = (personDebts[person] ?? 0) + sharePerPerson;
          totalOwed += sharePerPerson;
        }
      }
    }

    return {
      'totalOwed': totalOwed,
      'totalPending': totalPending,
      'personDebts': personDebts,
    };
  }

  // Function to get spending trend analysis
  Map<String, dynamic> getSpendingTrends(
    List<Map<String, dynamic>> transactions,
  ) {
    double totalSpent = 0;
    double avgDailySpend = 0;
    Map<String, double> dayOfWeekSpending = {};

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Filter transactions from last 30 days
    final recentTransactions =
        transactions.where((t) {
          final date = DateTime.parse(t['fullDate'] as String);
          final amount = t['amount'] as double;
          return date.isAfter(thirtyDaysAgo) && amount < 0;
        }).toList();

    if (recentTransactions.isNotEmpty) {
      // Calculate total spending
      totalSpent = recentTransactions.fold(
        0,
        (sum, t) => sum + (t['amount'] as double).abs(),
      );

      // Calculate average daily spend
      avgDailySpend = totalSpent / 30;

      // Analyze spending by day of week
      for (var transaction in recentTransactions) {
        final date = DateTime.parse(transaction['fullDate'] as String);
        final dayName = DateFormat('EEEE').format(date);
        final amount = (transaction['amount'] as double).abs();
        dayOfWeekSpending[dayName] = (dayOfWeekSpending[dayName] ?? 0) + amount;
      }
    }

    return {
      'totalSpent': totalSpent,
      'avgDailySpend': avgDailySpend,
      'dayOfWeekSpending': dayOfWeekSpending,
    };
  }

  // Function to get expense pattern insights
  List<String> getExpensePatternInsights(
    List<Map<String, dynamic>> transactions,
  ) {
    final insights = <String>[];
    final spendingTrends = getSpendingTrends(transactions);
    final categoryAnalysis = getCategoryAnalysis(transactions);

    // Find the day with highest spending
    final dayOfWeekSpending =
        spendingTrends['dayOfWeekSpending'] as Map<String, double>;
    if (dayOfWeekSpending.isNotEmpty) {
      final highestDay = dayOfWeekSpending.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      insights.add(
        'You tend to spend more on ${highestDay.key}s'
        ' (\$${highestDay.value.toStringAsFixed(1)} on average).',
      );
    }

    // Find the top spending category
    if (categoryAnalysis.isNotEmpty) {
      final topCategory = categoryAnalysis.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      insights.add(
        'Your highest spending category is ${topCategory.key}'
        ' (\$${topCategory.value.toStringAsFixed(1)}).',
      );
    }

    // Daily spending insight
    final avgDailySpend = spendingTrends['avgDailySpend'] as double;
    if (avgDailySpend > 0) {
      insights.add(
        'Your average daily spending is \$${avgDailySpend.toStringAsFixed(1)}.',
      );
    }

    return insights;
  }

  // Function to get bill-related advice
  List<String> getBillAdvice(List<Map<String, dynamic>> bills) {
    final advice = <String>[];
    final insights = getSplitBillsInsights(bills);

    final totalOwed = insights['totalOwed'] as double;
    final personDebts = insights['personDebts'] as Map<String, double>;

    if (totalOwed > 0) {
      advice.add(
        'You have \$${totalOwed.toStringAsFixed(1)} to collect from friends.',
      );
    }

    // Find who owes the most
    if (personDebts.isNotEmpty) {
      final highestDebtor = personDebts.entries.reduce(
        (a, b) => a.value > b.value ? a : b,
      );
      advice.add(
        '${highestDebtor.key} owes you the most'
        ' (\$${highestDebtor.value.toStringAsFixed(1)}).',
      );
    }

    return advice;
  }
}
