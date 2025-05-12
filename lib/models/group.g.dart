// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
  id: json['id'] as String,
  name: json['name'] as String,
  members: (json['members'] as List<dynamic>).map((e) => e as String).toList(),
  description: json['description'] as String?,
  color: (json['color'] as num?)?.toInt(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'members': instance.members,
  'description': instance.description,
  'color': instance.color,
  'createdAt': instance.createdAt?.toIso8601String(),
};
