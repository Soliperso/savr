// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String?,
  billId: json['billId'] as String?,
  payerId: json['payerId'] as String?,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'billId': instance.billId,
      'payerId': instance.payerId,
      'title': instance.title,
      'amount': instance.amount,
      'category': instance.category,
      'date': instance.date.toIso8601String(),
    };
