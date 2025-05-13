import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

/// Represents a payment made towards a bill.
@JsonSerializable()
class Payment {
  final String id;
  final double amount;
  final String method;
  final DateTime date;
  final String? paidBy;

  const Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    this.paidBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);
}
