import 'package:hive/hive.dart';

import '../../domain/repositories/expense_repository.dart';
import '../models/expense.dart';

class HiveExpenseRepository implements ExpenseRepository {
  HiveExpenseRepository(this._box);

  final Box<Expense> _box;

  @override
  Future<void> add(Expense expense) async {
    await _box.put(expense.id, expense);
  }

  @override
  Future<Expense?> getById(String id) async {
    final expense = _box.get(id);
    return expense == null ? null : _copyExpense(expense);
  }

  @override
  Future<List<Expense>> getAll({bool includeDeleted = false}) async {
    return _box.values
        .where((expense) => includeDeleted ? true : !expense.isDeleted)
        .map(_copyExpense)
        .toList();
  }

  @override
  Future<List<Expense>> getByProject(
    String projectId, {
    bool includeDeleted = false,
  }) async {
    return _box.values
        .where(
          (expense) =>
              expense.projectId == projectId &&
              (includeDeleted ? true : !expense.isDeleted),
        )
        .map(_copyExpense)
        .toList();
  }

  @override
  Future<void> markPaid(String id) async {
    final expense = _box.get(id);
    if (expense != null) {
      final updated = expense.copyWith(
        isPaid: true,
        updatedAt: DateTime.now(),
      );
      await _box.put(id, updated);
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final expense = _box.get(id);
    if (expense != null) {
      expense
        ..isDeleted = true
        ..deletedAt = DateTime.now();
      await expense.save();
    }
  }

  @override
  Future<void> update(Expense expense) async {
    expense.updatedAt = DateTime.now();
    await _box.put(expense.id, expense);
  }

  @override
  Future<void> hardDelete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<Expense>> getArchived() async {
    return _box.values
        .where((expense) => expense.isArchived && !expense.isDeleted)
        .map(_copyExpense)
        .toList();
  }

  @override
  Future<List<Expense>> getDeleted() async {
    return _box.values
        .where((expense) => expense.isDeleted)
        .map(_copyExpense)
        .toList();
  }

  Expense _copyExpense(Expense source) {
    return source.copyWith(
      isDeleted: source.isDeleted,
      isArchived: source.isArchived,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      deletedAt: source.deletedAt,
    );
  }
}
