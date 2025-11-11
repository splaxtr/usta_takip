import '../entities/ledger_summary.dart';
import '../../data/models/expense.dart';
import '../../data/models/project.dart';
import '../../data/models/wage_entry.dart';

abstract class LedgerRepository {
  Future<LedgerSummary> loadSummary();
  Future<List<WageEntry>> pendingWages();
  Future<List<Expense>> paidExpenses();
  Future<List<Project>> outstandingPatronPayments();
}
