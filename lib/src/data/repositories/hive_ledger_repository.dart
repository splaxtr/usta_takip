import 'package:hive/hive.dart';

import '../../domain/entities/ledger_summary.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../models/expense.dart';
import '../models/project.dart';
import '../models/wage_entry.dart';

class HiveLedgerRepository implements LedgerRepository {
  HiveLedgerRepository({
    required Box<Project> projectBox,
    required Box<WageEntry> wageBox,
    required Box<Expense> expenseBox,
    required Box settingsBox,
  })  : _projectBox = projectBox,
        _wageBox = wageBox,
        _expenseBox = expenseBox,
        _settingsBox = settingsBox;

  final Box<Project> _projectBox;
  final Box<WageEntry> _wageBox;
  final Box<Expense> _expenseBox;
  final Box _settingsBox;

  @override
  Future<LedgerSummary> loadSummary() async {
    final projects = _projectBox.values
        .where((project) => !project.isDeleted && !project.isArchived)
        .toList();
    final totalIncome =
        projects.fold<double>(0, (sum, project) => sum + project.totalBudget);

    final paidExpenses = _expenseBox.values
        .where((expense) => expense.isPaid && !expense.isDeleted)
        .fold<double>(0, (sum, expense) => sum + expense.amount);

    final pendingWages = _wageBox.values
        .where((wage) => wage.status != 'paid' && !wage.isDeleted)
        .fold<double>(0, (sum, wage) => sum + wage.amount);

    final outstanding =
        (totalIncome - paidExpenses).clamp(0, double.infinity).toDouble();

    final lastBackupRaw = _settingsBox.get('lastBackup') as String?;

    return LedgerSummary(
      totalIncome: totalIncome,
      paidExpenses: paidExpenses,
      pendingWages: pendingWages,
      outstandingPatronPayments: outstanding,
      activeProjects: projects.length,
      lastBackup:
          lastBackupRaw != null ? DateTime.tryParse(lastBackupRaw) : null,
    );
  }

  @override
  Future<List<WageEntry>> pendingWages() async {
    return _wageBox.values
        .where((wage) => wage.status != 'paid' && !wage.isDeleted)
        .map(_cloneWage)
        .toList();
  }

  @override
  Future<List<Expense>> paidExpenses() async {
    return _expenseBox.values
        .where((expense) => expense.isPaid && !expense.isDeleted)
        .map(_cloneExpense)
        .toList();
  }

  @override
  Future<List<Project>> outstandingPatronPayments() async {
    return _projectBox.values
        .where((project) {
          final projectExpenses = _expenseBox.values
              .where((expense) => expense.projectId == project.id)
              .fold<double>(0, (sum, expense) => sum + expense.amount);
          return !project.isDeleted &&
              !project.isArchived &&
              projectExpenses < project.totalBudget;
        })
        .map(_cloneProject)
        .toList();
  }

  Project _cloneProject(Project source) => source.copyWith(
        isDeleted: source.isDeleted,
        isArchived: source.isArchived,
        createdAt: source.createdAt,
        updatedAt: source.updatedAt,
        deletedAt: source.deletedAt,
      );

  WageEntry _cloneWage(WageEntry source) => source.copyWith(
        isDeleted: source.isDeleted,
        isArchived: source.isArchived,
        createdAt: source.createdAt,
        updatedAt: source.updatedAt,
        deletedAt: source.deletedAt,
      );

  Expense _cloneExpense(Expense source) => source.copyWith(
        isDeleted: source.isDeleted,
        isArchived: source.isArchived,
        createdAt: source.createdAt,
        updatedAt: source.updatedAt,
        deletedAt: source.deletedAt,
      );
}
