import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

/// Represents a user in SavvySplit.
@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
