import 'bill_status.dart';

class Bill {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final DateTime dueDate;
  final double amount;
  final BillStatus status;
  final List<String> splitWith;
  final Map<String, double> customSplits;
  final bool paid;
  final List<String> paidBy;

  Bill({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.amount,
    required this.status,
    required this.splitWith,
    this.customSplits = const {},
    this.paid = false,
    this.paidBy = const [],
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due'] as String),
      amount: json['amount'] as double,
      status: BillStatus.fromString(json['status'] as String),
      splitWith: List<String>.from(json['splitWith']),
      customSplits: Map<String, double>.from(json['customSplits'] ?? {}),
      paid: json['paid'] as bool,
      paidBy: List<String>.from(json['paidBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'due': dueDate.toIso8601String(),
      'amount': amount,
      'status': status.label,
      'splitWith': splitWith,
      'customSplits': customSplits,
      'paid': paid,
      'paidBy': paidBy,
    };
  }

  Bill copyWith({
    String? id,
    String? groupId,
    String? title,
    String? description,
    DateTime? dueDate,
    double? amount,
    BillStatus? status,
    List<String>? splitWith,
    Map<String, double>? customSplits,
    bool? paid,
    List<String>? paidBy,
  }) {
    return Bill(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      splitWith: splitWith ?? this.splitWith,
      customSplits: customSplits ?? this.customSplits,
      paid: paid ?? this.paid,
      paidBy: paidBy ?? this.paidBy,
    );
  }
}
