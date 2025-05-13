import 'package:json_annotation/json_annotation.dart';
import 'payment.dart';

part 'bill.g.dart';

/// Represents a bill in Savr.
@JsonSerializable()
class Bill {
  final String id;
  final String groupId;
  final String title;
  final String? description;
  final double amount;
  final DateTime dueDate;
  final String status;
  final List<String> splitWith;
  final Map<String, double>? customSplits;
  final bool paid;
  final List<String> paidBy;
  final String? category;
  final double? paidAmount;
  final List<Payment>? paymentHistory;

  const Bill({
    required this.id,
    required this.groupId,
    required this.title,
    this.description,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.splitWith,
    this.customSplits,
    required this.paid,
    required this.paidBy,
    this.category,
    this.paidAmount,
    this.paymentHistory,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
  Map<String, dynamic> toJson() => _$BillToJson(this);

  Bill copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    double? amount,
    DateTime? dueDate,
    String? status,
    List<String>? splitWith,
    Map<String, double>? customSplits,
    bool? paid,
    List<String>? paidBy,
    String? category,
    double? paidAmount,
    List<Payment>? paymentHistory,
  }) {
    return Bill(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      splitWith: splitWith ?? this.splitWith,
      customSplits: customSplits ?? this.customSplits,
      paid: paid ?? this.paid,
      paidBy: paidBy ?? this.paidBy,
      category: category ?? this.category,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }
}
