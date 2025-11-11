import '../../data/models/expense.dart';
import '../../data/models/wage_entry.dart';
import '../repositories/expense_repository.dart';
import '../repositories/wage_repository.dart';

class ApproveWagePaymentParams {
  ApproveWagePaymentParams({required this.wageEntryId});

  final String wageEntryId;
}

class ApproveWagePaymentResult {
  ApproveWagePaymentResult({
    required this.updatedEntry,
    required this.updatedExpense,
  });

  final WageEntry updatedEntry;
  final Expense updatedExpense;
}

class ApproveWagePayment {
  ApproveWagePayment(this._wageRepository, this._expenseRepository);

  final WageRepository _wageRepository;
  final ExpenseRepository _expenseRepository;

  Future<ApproveWagePaymentResult> call(
    ApproveWagePaymentParams params,
  ) async {
    final entry = await _wageRepository.getById(params.wageEntryId);
    if (entry == null) {
      throw StateError('WageEntry ${params.wageEntryId} not found');
    }

    final updatedEntry = entry.copyWith(
      status: 'paid',
      updatedAt: DateTime.now(),
    );
    await _wageRepository.update(updatedEntry);

    final expense = await _expenseRepository.getById(params.wageEntryId);
    if (expense == null) {
      throw StateError('Expense ${params.wageEntryId} not found');
    }
    final updatedExpense = expense.copyWith(
      isPaid: true,
      updatedAt: DateTime.now(),
    );
    await _expenseRepository.update(updatedExpense);

    return ApproveWagePaymentResult(
      updatedEntry: updatedEntry,
      updatedExpense: updatedExpense,
    );
  }
}
