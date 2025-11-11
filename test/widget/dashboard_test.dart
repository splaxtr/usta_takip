import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:usta_takip_app/src/data/models/expense.dart';
import 'package:usta_takip_app/src/data/models/project.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.dart';
import 'package:usta_takip_app/src/domain/entities/ledger_summary.dart';
import 'package:usta_takip_app/src/domain/repositories/expense_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/ledger_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/wage_repository.dart';
import 'package:usta_takip_app/src/domain/services/backup_service.dart';
import 'package:usta_takip_app/src/domain/usecases/record_work_day.dart';
import 'package:usta_takip_app/src/presentation/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:usta_takip_app/src/presentation/features/dashboard/view/dashboard_page.dart';

void main() {
  testWidgets('Dashboard shows metric cards after refresh', (tester) async {
    final expenseRepository = _InMemoryExpenseRepository();
    final wageRepository = _InMemoryWageRepository();
    final ledgerRepository = _FakeLedgerRepository();
    final backupService = _FakeBackupService();

    final cubit = DashboardCubit(
      ledgerRepository: ledgerRepository,
      backupService: backupService,
      recordWorkDay: RecordWorkDay(wageRepository, expenseRepository),
    );
    await cubit.refresh();

    await tester.pumpWidget(
      RepositoryProvider<LedgerRepository>.value(
        value: ledgerRepository,
        child: RepositoryProvider<BackupService>.value(
          value: backupService,
          child: MaterialApp(
            home: BlocProvider<DashboardCubit>.value(
              value: cubit,
              child: const DashboardPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toplam Gelir'), findsOneWidget);
    expect(find.textContaining('₺'), findsWidgets);

    addTearDown(cubit.close);
  });
}

class _InMemoryExpenseRepository implements ExpenseRepository {
  final Map<String, Expense> _storage = {};

  @override
  Future<void> add(Expense expense) async {
    _storage[expense.id] = expense;
  }

  @override
  Future<List<Expense>> getByProject(String projectId,
          {bool includeDeleted = false}) async =>
      _storage.values
          .where(
            (expense) =>
                expense.projectId == projectId &&
                (includeDeleted ? true : !expense.isDeleted),
          )
          .toList();

  @override
  Future<List<Expense>> getAll({bool includeDeleted = false}) async =>
      _storage.values
          .where((expense) => includeDeleted ? true : !expense.isDeleted)
          .toList();

  @override
  Future<Expense?> getById(String id) async => _storage[id];

  @override
  Future<void> markPaid(String id) async {
    final expense = _storage[id];
    if (expense != null) {
      _storage[id] = expense.copyWith(isPaid: true);
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final expense = _storage[id];
    if (expense != null) {
      _storage[id] = expense.copyWith(isDeleted: true);
    }
  }

  @override
  Future<void> update(Expense expense) async {
    _storage[expense.id] = expense;
  }

  @override
  Future<void> hardDelete(String id) async {
    _storage.remove(id);
  }

  @override
  Future<List<Expense>> getArchived() async => const [];

  @override
  Future<List<Expense>> getDeleted() async => const [];
}

class _InMemoryWageRepository implements WageRepository {
  final Map<String, WageEntry> _storage = {};

  @override
  Future<void> add(WageEntry entry) async {
    _storage[entry.id] = entry;
  }

  @override
  Future<WageEntry?> getById(String id) async => _storage[id];

  @override
  Future<List<WageEntry>> getByEmployee(String employeeId) async =>
      _storage.values
          .where(
            (entry) =>
                entry.employeeId == employeeId && entry.isDeleted == false,
          )
          .toList();

  @override
  Future<List<WageEntry>> getByProject(String projectId) async =>
      _storage.values
          .where(
            (entry) =>
                entry.projectId == projectId && entry.isDeleted == false,
          )
          .toList();

  @override
  Future<List<WageEntry>> getPendingByProject(String projectId) async =>
      _storage.values
          .where(
            (entry) =>
                entry.projectId == projectId &&
                entry.status != 'paid' &&
                entry.isDeleted == false,
          )
          .toList();

  @override
  Future<double> getPendingTotal() async => _storage.values
      .where((entry) => entry.status != 'paid' && !entry.isDeleted)
      .fold<double>(0.0, (sum, entry) => sum + entry.amount);

  @override
  Future<void> softDelete(String id) async {
    final entry = _storage[id];
    if (entry != null) {
      _storage[id] = entry.copyWith(isDeleted: true);
    }
  }

  @override
  Future<void> update(WageEntry entry) async {
    _storage[entry.id] = entry;
  }

  @override
  Future<void> hardDelete(String id) async {
    _storage.remove(id);
  }

  @override
  Future<List<WageEntry>> getArchived() async => const [];

  @override
  Future<List<WageEntry>> getDeleted() async => const [];
}

class _FakeLedgerRepository implements LedgerRepository {
  final LedgerSummary summary = const LedgerSummary(
    totalIncome: 100000,
    paidExpenses: 5000,
    pendingWages: 2500,
    outstandingPatronPayments: 95000,
    activeProjects: 3,
    lastBackup: null,
  );

  final List<Expense> paid = [
    Expense(
      id: 'expense-1',
      projectId: 'project-1',
      description: 'Malzeme',
      amount: 5000,
      isPaid: true,
      category: 'malzeme',
    )
  ];

  final List<WageEntry> pending = [
    WageEntry(
      id: 'wage-1',
      employeeId: 'emp-1',
      projectId: 'project-1',
      date: DateTime(2024, 1, 10),
      amount: 2500,
    )
  ];

  final List<Project> outstanding = [
    Project(
      id: 'project-1',
      name: 'Şantiye',
      patronId: 'patron-1',
      totalBudget: 100000,
      defaultDailyWage: 750,
      startDate: DateTime(2024, 1, 1),
    )
  ];

  @override
  Future<LedgerSummary> loadSummary() async => summary;

  @override
  Future<List<Expense>> paidExpenses() async => paid;

  @override
  Future<List<Project>> outstandingPatronPayments() async => outstanding;

  @override
  Future<List<WageEntry>> pendingWages() async => pending;
}

class _FakeBackupService implements BackupService {
  DateTime? _lastBackup;

  @override
  Future<void> backupNow() async {
    _lastBackup = DateTime(2024, 1, 10);
  }

  @override
  Future<DateTime?> lastBackupTime() async => _lastBackup;

  @override
  Future<void> restoreLatest() async {}
}
