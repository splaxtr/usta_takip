import '../../data/models/expense.dart';

abstract class ExpenseRepository {
  Future<Expense?> getById(String id);
  Future<List<Expense>> getAll({bool includeDeleted = false});
  Future<List<Expense>> getByProject(
    String projectId, {
    bool includeDeleted = false,
  });
  Future<void> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
  Future<List<Expense>> getArchived();
  Future<List<Expense>> getDeleted();
  Future<void> markPaid(String id);
}
