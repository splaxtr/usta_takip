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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'description': description,
      'amount': amount,
      'isPaid': isPaid,
      'category': category,
      'isDeleted': isDeleted,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    final expense = Expense(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool? ?? false,
      category: json['category'] as String? ?? 'genel',
    );
    expense.isDeleted = json['isDeleted'] as bool? ?? false;
    expense.isArchived = json['isArchived'] as bool? ?? false;
    expense.createdAt =
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    expense.updatedAt =
        DateTime.tryParse(json['updatedAt'] as String? ?? '');
    expense.deletedAt =
        DateTime.tryParse(json['deletedAt'] as String? ?? '');
    return expense;
  }
}
