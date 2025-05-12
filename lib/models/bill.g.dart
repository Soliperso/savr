// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) => Bill(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  amount: (json['amount'] as num).toDouble(),
  dueDate: DateTime.parse(json['dueDate'] as String),
  status: json['status'] as String,
  splitWith:
      (json['splitWith'] as List<dynamic>).map((e) => e as String).toList(),
  customSplits: (json['customSplits'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  paid: json['paid'] as bool,
  paidBy: (json['paidBy'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'title': instance.title,
  'description': instance.description,
  'amount': instance.amount,
  'dueDate': instance.dueDate.toIso8601String(),
  'status': instance.status,
  'splitWith': instance.splitWith,
  'customSplits': instance.customSplits,
  'paid': instance.paid,
  'paidBy': instance.paidBy,
};
