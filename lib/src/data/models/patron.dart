import 'package:hive/hive.dart';

import 'trackable_entity.dart';

part 'patron.g.dart';

@HiveType(typeId: 4)
class Patron extends HiveObject with TrackableEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String phone;
  @HiveField(3)
  final String description;

  Patron({
    required this.id,
    required this.name,
    this.phone = '',
    this.description = '',
  });

  Patron copyWith({
    String? id,
    String? name,
    String? phone,
    String? description,
    bool? isDeleted,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final updated = Patron(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      description: description ?? this.description,
    );
    updated.isDeleted = isDeleted ?? this.isDeleted;
    updated.isArchived = isArchived ?? this.isArchived;
    updated.createdAt = createdAt ?? this.createdAt;
    updated.updatedAt = updatedAt ?? this.updatedAt;
    updated.deletedAt = deletedAt ?? this.deletedAt;
    return updated;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'description': description,
      'isDeleted': isDeleted,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Patron.fromJson(Map<String, dynamic> json) {
    final patron = Patron(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
    patron.isDeleted = json['isDeleted'] as bool? ?? false;
    patron.isArchived = json['isArchived'] as bool? ?? false;
    patron.createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    patron.updatedAt =
        DateTime.tryParse(json['updatedAt'] as String? ?? '');
    patron.deletedAt =
        DateTime.tryParse(json['deletedAt'] as String? ?? '');
    return patron;
  }
}
