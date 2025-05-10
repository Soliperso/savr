enum TransactionCategory {
  foodAndGroceries('Food & Groceries'),
  foodAndDrinks('Food & Drinks'),
  transportation('Transportation'),
  entertainment('Entertainment'),
  healthAndFitness('Health & Fitness'),
  income('Income'),
  utilities('Utilities'),
  rent('Rent'),
  shopping('Shopping'),
  other('Other');

  final String label;
  const TransactionCategory(this.label);

  factory TransactionCategory.fromString(String value) {
    return TransactionCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionCategory.other,
    );
  }

  bool get isExpenseCategory => this != TransactionCategory.income;
}
