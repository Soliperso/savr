class SpendingTrend {
  final DateTime date;
  final double amount;
  final double changeFromPrevious;
  final bool isIncrease;

  SpendingTrend({
    required this.date,
    required this.amount,
    required this.changeFromPrevious,
    required this.isIncrease,
  });

  factory SpendingTrend.fromAmounts({
    required DateTime date,
    required double amount,
    required double previousAmount,
  }) {
    final change =
        previousAmount > 0
            ? ((amount - previousAmount) / previousAmount) * 100
            : 0.0;

    return SpendingTrend(
      date: date,
      amount: amount,
      changeFromPrevious: change.abs(),
      isIncrease: change > 0,
    );
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get formattedChange => '${changeFromPrevious.toStringAsFixed(1)}%';
  String get trendIndicator => isIncrease ? '↑' : '↓';
}
