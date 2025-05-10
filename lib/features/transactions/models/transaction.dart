import 'package:intl/intl.dart';

class Transaction {
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Transaction({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      title: json['title'] as String,
      amount: json['amount'] as double,
      category: json['category'] as String,
      date: DateTime.parse(json['fullDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': DateFormat('MMM d').format(date),
      'fullDate': date.toIso8601String(),
    };
  }

  Transaction copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
  }) {
    return Transaction(
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  bool get isExpense => amount < 0;
  bool get isIncome => amount > 0;

  String get formattedAmount {
    final prefix = isExpense ? '-\$' : '\$';
    return '$prefix${amount.abs().toStringAsFixed(2)}';
  }

  String get formattedDate => DateFormat('MMM d').format(date);
}
