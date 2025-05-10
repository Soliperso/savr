class Group {
  final String id;
  final String name;
  final List<String> members;
  final String description;
  final int color;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.description,
    required this.color,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      members: List<String>.from(json['members']),
      description: json['description'] as String,
      color: json['color'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'description': description,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

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
