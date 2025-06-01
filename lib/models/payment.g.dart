// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => Payment(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  date: DateTime.parse(json['date'] as String),
  paidBy: json['paidBy'] as String?,
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'date': instance.date.toIso8601String(),
  'paidBy': instance.paidBy,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.creditCard: 'creditCard',
  PaymentMethod.debitCard: 'debitCard',
  PaymentMethod.cash: 'cash',
  PaymentMethod.bankTransfer: 'bankTransfer',
  PaymentMethod.paypal: 'paypal',
  PaymentMethod.other: 'other',
};
