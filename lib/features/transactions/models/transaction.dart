import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'transaction.g.dart';

/// Represents a transaction in SavvySplit.
/// This consolidated model combines fields from both the core and feature-specific Transaction models.
@JsonSerializable()
class Transaction {
  // Core fields for API interaction
  final String? id;
  final String? billId;
  final String? payerId;

  // UI-specific fields
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  const Transaction({
    this.id,
    this.billId,
    this.payerId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  Transaction copyWith({
    String? id,
    String? billId,
    String? payerId,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      billId: billId ?? this.billId,
      payerId: payerId ?? this.payerId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  // Helper properties for UI
  bool get isExpense => amount < 0;
  bool get isIncome => amount > 0;

  /// Returns a color-coded icon for the transaction type (expense/income).
  IconData get summaryIcon =>
      isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

  /// Returns a color for the icon based on transaction type.
  Color get summaryIconColor =>
      isExpense ? Colors.redAccent : Colors.greenAccent;

  /// Returns a linear gradient for the summary card background.
  LinearGradient get summaryGradient => LinearGradient(
    colors:
        isExpense
            ? [Colors.redAccent.withOpacity(0.85), Colors.red.withOpacity(0.65)]
            : [
              Colors.greenAccent.withOpacity(0.85),
              Colors.green.withOpacity(0.65),
            ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns a formatted amount string with currency symbol and sign.
  String get formattedAmount {
    final prefix = isExpense ? '-\$' : '\$';
    return '$prefix${amount.abs().toStringAsFixed(2)}';
  }

  /// Returns a formatted date string for display.
  String get formattedDate => DateFormat('MMM d').format(date);

  /// Returns full formatted date string (day/month/year)
  String get fullFormattedDate => '${date.day}/${date.month}/${date.year}';
}
