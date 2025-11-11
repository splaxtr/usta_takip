import 'package:hive/hive.dart';

import 'trackable_entity.dart';

@HiveType(typeId: 2)
class WageEntry extends HiveObject with TrackableEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String employeeId;
  @HiveField(2)
  final String projectId;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final double amount;
  @HiveField(5)
  final String status; // recorded | approved | paid

  WageEntry({
    required this.id,
    required this.employeeId,
    required this.projectId,
    required this.date,
    required this.amount,
    this.status = 'recorded',
  });

  WageEntry copyWith({
    String? id,
    String? employeeId,
    String? projectId,
    DateTime? date,
    double? amount,
    String? status,
    bool? isDeleted,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final updated = WageEntry(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      status: status ?? this.status,
    );
    updated.isDeleted = isDeleted ?? this.isDeleted;
    updated.isArchived = isArchived ?? this.isArchived;
    updated.createdAt = createdAt ?? this.createdAt;
    updated.updatedAt = updatedAt ?? this.updatedAt;
    updated.deletedAt = deletedAt ?? this.deletedAt;
    return updated;
  }
}
