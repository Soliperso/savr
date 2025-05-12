import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

/// Represents a group in SavvySplit.
@JsonSerializable()
class Group {
  final String id;
  final String name;
  final List<String> members;
  final String? description;
  final int? color;
  final DateTime? createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.members,
    this.description,
    this.color,
    this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);

  Group copyWith({
    String? id,
    String? name,
    List<String>? members,
    String? description,
    int? color,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      members: members ?? this.members,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
