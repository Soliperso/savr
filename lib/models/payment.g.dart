// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  method: json['method'] as String,
  date: DateTime.parse(json['date'] as String),
  paidBy: json['paidBy'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'method': instance.method,
  'date': instance.date.toIso8601String(),
  'paidBy': instance.paidBy,
};
