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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'patronId': patronId,
      'totalBudget': totalBudget,
      'defaultDailyWage': defaultDailyWage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isDeleted': isDeleted,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    final project = Project(
      id: json['id'] as String,
      name: json['name'] as String,
      patronId: json['patronId'] as String? ?? '',
      totalBudget: (json['totalBudget'] as num).toDouble(),
      defaultDailyWage: (json['defaultDailyWage'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)
          : null,
    );
    project.isDeleted = json['isDeleted'] as bool? ?? false;
    project.isArchived = json['isArchived'] as bool? ?? false;
    project.createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    project.updatedAt =
        DateTime.tryParse(json['updatedAt'] as String? ?? '');
    project.deletedAt =
        DateTime.tryParse(json['deletedAt'] as String? ?? '');
    return project;
  }
}
