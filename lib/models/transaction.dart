import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'transaction.g.dart';

/// Represents a transaction in SavvySplit.
@JsonSerializable()
class Transaction {
  final String id;
  final String billId;
  final String payerId;
  final double amount;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.billId,
    required this.payerId,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  /// Returns a color-coded icon for the transaction type (expense/income).
  IconData get summaryIcon =>
      amount < 0 ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

  /// Returns a color for the icon based on transaction type.
  Color get summaryIconColor =>
      amount < 0 ? Colors.redAccent : Colors.greenAccent;

  /// Returns a linear gradient for the summary card background.
  LinearGradient get summaryGradient => LinearGradient(
    colors:
        amount < 0
            ? [Colors.redAccent.withOpacity(0.85), Colors.red.withOpacity(0.65)]
            : [
              Colors.greenAccent.withOpacity(0.85),
              Colors.green.withOpacity(0.65),
            ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Returns a formatted amount string with currency symbol and sign.
  String get formattedAmount =>
      (amount < 0 ? '- ' : '+ ') + ' 24${amount.abs().toStringAsFixed(2)}';

  /// Returns a formatted date string for display.
  String get formattedDate => '${date.day}/${date.month}/${date.year}';
}
