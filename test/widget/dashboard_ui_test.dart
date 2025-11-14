import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:usta_takip_app/src/data/models/employee.dart';
import 'package:usta_takip_app/src/data/models/expense.dart';
import 'package:usta_takip_app/src/data/models/patron.dart';
import 'package:usta_takip_app/src/data/models/project.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.dart';
import 'package:usta_takip_app/src/domain/repositories/employee_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/patron_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/project_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/expense_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/wage_repository.dart';
import 'package:usta_takip_app/src/domain/entities/ledger_summary.dart';
import 'package:usta_takip_app/src/domain/repositories/ledger_repository.dart';
import 'package:usta_takip_app/src/domain/usecases/record_work_day.dart';
import 'package:usta_takip_app/src/presentation/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:usta_takip_app/src/presentation/features/dashboard/cubit/dashboard_state.dart';
import 'package:usta_takip_app/src/presentation/features/dashboard/view/dashboard_page.dart';
import 'package:usta_takip_app/src/domain/services/backup_service.dart';

void main() {
  testWidgets('Dashboard shows metric grid and chart', (tester) async {
    final cubit = _TestDashboardCubit();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<EmployeeRepository>(
            create: (_) => _DummyEmployeeRepository(),
          ),
          RepositoryProvider<ProjectRepository>(
            create: (_) => _DummyProjectRepository(),
          ),
          RepositoryProvider<PatronRepository>(
            create: (_) => _DummyPatronRepository(),
          ),
        ],
        child: MaterialApp(
          home: BlocProvider<DashboardCubit>.value(
            value: cubit,
            child: const DashboardPage(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Toplam Gelir'), findsOneWidget);
    expect(find.text('Toplam Gider'), findsOneWidget);
    expect(find.text('Bekleyen Yevmiye'), findsOneWidget);
    expect(find.text('Hatırlatmalar'), findsOneWidget);

    addTearDown(cubit.close);
  });
}

class _TestDashboardCubit extends DashboardCubit {
  _TestDashboardCubit()
      : super(
          ledgerRepository: _FakeLedgerRepository(),
          backupService: _FakeBackupService(),
          recordWorkDay: RecordWorkDay(
            _DummyWageRepository(),
            _DummyExpenseRepository(),
          ),
        ) {
    emit(
      DashboardState(
        isLoading: false,
        totalIncome: 120000,
        totalExpenses: 45000,
        pendingWages: 15000,
        outstandingPayments: 30000,
        activeProjects: 4,
        lastBackup: DateTime(2024, 5, 1),
        weeklyTrend: const [5, 6, 7, 8, 7, 9, 10],
        reminders: const ['Ödenmemiş yevmiye: 15.000₺'],
      ),
    );
  }
}

class _DummyEmployeeRepository implements EmployeeRepository {
  @override
  Future<void> add(Employee employee) async {}

  @override
  Future<void> archive(String id) async {}

  @override
  Future<List<Employee>> getAll({bool includeDeleted = false}) async => [];

  @override
  Future<List<Employee>> getArchived() async => [];

  @override
  Future<Employee?> getById(String id) async => null;

  @override
  Future<List<Employee>> getDeleted() async => [];

  @override
  Future<void> hardDelete(String id) async {}

  @override
  Future<void> restore(String id) async {}

  @override
  Future<void> softDelete(String id) async {}

  @override
  Future<void> update(Employee employee) async {}
}

class _DummyProjectRepository implements ProjectRepository {
  @override
  Future<void> add(Project project) async {}

  @override
  Future<void> archive(String id) async {}

  @override
  Future<List<Project>> getAll({bool includeArchived = false}) async => [];

  @override
  Future<List<Project>> getArchived() async => [];

  @override
  Future<Project?> getById(String id) async => null;

  @override
  Future<List<Project>> getDeleted() async => [];

  @override
  Future<void> hardDelete(String id) async {}

  @override
  Future<void> restore(String id) async {}

  @override
  Future<void> softDelete(String id) async {}

  @override
  Future<void> update(Project project) async {}
}

class _DummyPatronRepository implements PatronRepository {
  @override
  Future<void> add(Patron patron) async {}

  @override
  Future<List<Patron>> getAll({bool includeDeleted = false}) async => [];

  @override
  Future<Patron?> getById(String id) async => null;

  @override
  Future<List<Patron>> getDeleted() async => [];

  @override
  Future<void> hardDelete(String id) async {}

  @override
  Future<void> restore(String id) async {}

  @override
  Future<void> softDelete(String id) async {}

  @override
  Future<void> update(Patron patron) async {}
}

class _DummyExpenseRepository implements ExpenseRepository {
  @override
  Future<void> add(Expense expense) async {}

  @override
  Future<List<Expense>> getAll({bool includeDeleted = false}) async => [];

  @override
  Future<Expense?> getById(String id) async => null;

  @override
  Future<List<Expense>> getByProject(String projectId,
          {bool includeDeleted = false}) async =>
      [];

  @override
  Future<List<Expense>> getArchived() async => [];

  @override
  Future<List<Expense>> getDeleted() async => [];

  @override
  Future<void> hardDelete(String id) async {}

  @override
  Future<void> markPaid(String id) async {}

  @override
  Future<void> softDelete(String id) async {}

  @override
  Future<void> update(Expense expense) async {}
}

class _DummyWageRepository implements WageRepository {
  @override
  Future<void> add(WageEntry entry) async {}

  @override
  Future<void> hardDelete(String id) async {}

  @override
  Future<List<WageEntry>> getArchived() async => [];

  @override
  Future<WageEntry?> getById(String id) async => null;

  @override
  Future<List<WageEntry>> getByEmployee(String employeeId) async => [];

  @override
  Future<List<WageEntry>> getByProject(String projectId) async => [];

  @override
  Future<List<WageEntry>> getDeleted() async => [];

  @override
  Future<List<WageEntry>> getPendingByProject(String projectId) async => [];

  @override
  Future<double> getPendingTotal() async => 0;

  @override
  Future<void> softDelete(String id) async {}

  @override
  Future<void> update(WageEntry entry) async {}
}

class _FakeLedgerRepository implements LedgerRepository {
  @override
  Future<LedgerSummary> loadSummary() async {
    return const LedgerSummary(
      totalIncome: 120000,
      paidExpenses: 45000,
      pendingWages: 15000,
      outstandingPatronPayments: 30000,
      activeProjects: 4,
      lastBackup: null,
    );
  }

  @override
  Future<List<WageEntry>> pendingWages() async => <WageEntry>[];

  @override
  Future<List<Project>> outstandingPatronPayments() async => <Project>[];

  @override
  Future<List<Expense>> paidExpenses() async => <Expense>[];
}

class _FakeBackupService implements BackupService {
  @override
  Future<void> backupNow() async {}

  @override
  Future<DateTime?> lastBackupTime() async => DateTime(2024, 5, 1);

  @override
  Future<void> restoreLatest() async {}
}
