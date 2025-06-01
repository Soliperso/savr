import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart'; // For @immutable

part 'payment.g.dart';

/// Enum for payment methods.
enum PaymentMethod { creditCard, debitCard, cash, bankTransfer, paypal, other }

/// Represents a payment made towards a bill.
@immutable
@JsonSerializable()
class Payment {
  final String id;
  final double amount;
  final PaymentMethod method; // Changed from String to PaymentMethod
  final DateTime date;
  final String? paidBy;

  const Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.date,
    this.paidBy,
  }) : assert(
         amount > 0,
         'Payment amount must be positive',
       ); // Added validation

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  /// Creates a new Payment instance with updated fields.
  Payment copyWith({
    String? id,
    double? amount,
    PaymentMethod? method,
    DateTime? date,
    String? paidBy,
    bool setPaidByToNull = false, // To explicitly set paidBy to null
  }) {
    return Payment(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      date: date ?? this.date,
      paidBy: setPaidByToNull ? null : (paidBy ?? this.paidBy),
    );
  }

  @override
  String toString() {
    return 'Payment(id: $id, amount: $amount, method: $method, date: $date, paidBy: $paidBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Payment &&
        other.id == id &&
        other.amount == amount &&
        other.method == method &&
        other.date == date &&
        other.paidBy == paidBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        method.hashCode ^
        date.hashCode ^
        paidBy.hashCode;
  }
}
