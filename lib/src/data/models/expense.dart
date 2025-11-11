import 'package:hive/hive.dart';

import 'trackable_entity.dart';

@HiveType(typeId: 3)
class Expense extends HiveObject with TrackableEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String projectId;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final double amount;
  @HiveField(4)
  final bool isPaid;
  @HiveField(5)
  final String category; // yevmiye, malzeme, vb.

  Expense({
    required this.id,
    required this.projectId,
    required this.description,
    required this.amount,
    this.isPaid = false,
    this.category = 'genel',
  });

  Expense copyWith({
    String? id,
    String? projectId,
    String? description,
    double? amount,
    bool? isPaid,
    String? category,
    bool? isDeleted,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    final updated = Expense(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      category: category ?? this.category,
    );
    updated.isDeleted = isDeleted ?? this.isDeleted;
    updated.isArchived = isArchived ?? this.isArchived;
    updated.createdAt = createdAt ?? this.createdAt;
    updated.updatedAt = updatedAt ?? this.updatedAt;
    updated.deletedAt = deletedAt ?? this.deletedAt;
    return updated;
  }
}
