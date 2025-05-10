class CategoryAnalysis {
  final String category;
  final double amount;
  final double percentage;

  CategoryAnalysis({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryAnalysis.fromAmount({
    required String category,
    required double amount,
    required double total,
  }) {
    return CategoryAnalysis(
      category: category,
      amount: amount,
      percentage: total > 0 ? (amount / total) * 100 : 0,
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}
