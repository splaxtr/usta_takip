import 'package:uuid/uuid.dart';

import '../../data/models/expense.dart';
import '../../data/models/wage_entry.dart';
import '../repositories/expense_repository.dart';
import '../repositories/wage_repository.dart';

class RecordWorkDayParams {
  RecordWorkDayParams({
    required this.employeeId,
    required this.projectId,
    required this.date,
    required this.amount,
    this.description,
  });

  final String employeeId;
  final String projectId;
  final DateTime date;
  final double amount;
  final String? description;
}

class RecordWorkDayResult {
  RecordWorkDayResult({
    required this.wageEntry,
    required this.expense,
  });

  final WageEntry wageEntry;
  final Expense expense;
}

class RecordWorkDay {
  RecordWorkDay(this._wageRepository, this._expenseRepository);

  final WageRepository _wageRepository;
  final ExpenseRepository _expenseRepository;
  final _uuid = const Uuid();

  Future<RecordWorkDayResult> call(RecordWorkDayParams params) async {
    final id = _uuid.v4();
    final wageEntry = WageEntry(
      id: id,
      employeeId: params.employeeId,
      projectId: params.projectId,
      date: params.date,
      amount: params.amount,
      status: 'recorded',
    );
    final expense = Expense(
      id: id,
      projectId: params.projectId,
      description: params.description ?? 'Yevmiye Ödemesi',
      amount: params.amount,
      isPaid: false,
      category: 'yevmiye',
    );
    await _wageRepository.add(wageEntry);
    await _expenseRepository.add(expense);
    return RecordWorkDayResult(wageEntry: wageEntry, expense: expense);
  }
}
