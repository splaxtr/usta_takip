import 'package:hive/hive.dart';

import 'trackable_entity.dart';

@HiveType(typeId: 0)
class Project extends HiveObject with TrackableEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String patronId;
  @HiveField(3)
  final double totalBudget;
  @HiveField(4)
  final double defaultDailyWage;
  @HiveField(5)
  final DateTime startDate;
  @HiveField(6)
  final DateTime? endDate;

  Project({
    required this.id,
    required this.name,
    required this.patronId,
    required this.totalBudget,
    required this.defaultDailyWage,
    required this.startDate,
    this.endDate,
  });

  Project copyWith({
    String? id,
    String? name,
    String? patronId,
    double? totalBudget,
    double? defaultDailyWage,
    DateTime? startDate,
    DateTime? endDate,
    bool? isDeleted,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final updated = Project(
      id: id ?? this.id,
      name: name ?? this.name,
      patronId: patronId ?? this.patronId,
      totalBudget: totalBudget ?? this.totalBudget,
      defaultDailyWage: defaultDailyWage ?? this.defaultDailyWage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );

    updated.isDeleted = isDeleted ?? this.isDeleted;
    updated.isArchived = isArchived ?? this.isArchived;
    updated.createdAt = createdAt ?? this.createdAt;
    updated.updatedAt = updatedAt ?? this.updatedAt;
    updated.deletedAt = deletedAt ?? this.deletedAt;
    return updated;
  }
}
