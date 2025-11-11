import 'package:hive/hive.dart';

import 'trackable_entity.dart';

@HiveType(typeId: 1)
class Employee extends HiveObject with TrackableEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double dailyWage;
  @HiveField(3)
  final String phone;
  @HiveField(4)
  final String projectId;

  Employee({
    required this.id,
    required this.name,
    required this.dailyWage,
    required this.phone,
    required this.projectId,
  });

  Employee copyWith({
    String? id,
    String? name,
    double? dailyWage,
    String? phone,
    String? projectId,
    bool? isDeleted,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final updated = Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      dailyWage: dailyWage ?? this.dailyWage,
      phone: phone ?? this.phone,
      projectId: projectId ?? this.projectId,
    );
    updated.isDeleted = isDeleted ?? this.isDeleted;
    updated.isArchived = isArchived ?? this.isArchived;
    updated.createdAt = createdAt ?? this.createdAt;
    updated.updatedAt = updatedAt ?? this.updatedAt;
    updated.deletedAt = deletedAt ?? this.deletedAt;
    return updated;
  }
}
