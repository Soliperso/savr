class FinancialInsight {
  final String title;
  final String description;
  final List<double> trendData;
  final DateTime date;
  final InsightType type;

  FinancialInsight({
    required this.title,
    required this.description,
    required this.trendData,
    required this.date,
    required this.type,
  });
}

enum InsightType { spending, saving, budgeting, trending }
