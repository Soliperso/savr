import 'package:json_annotation/json_annotation.dart';

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
}
