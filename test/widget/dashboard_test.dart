import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:usta_takip_app/src/data/models/expense.dart';
import 'package:usta_takip_app/src/data/models/project.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.dart';
import 'package:usta_takip_app/src/domain/repositories/expense_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/project_repository.dart';
import 'package:usta_takip_app/src/domain/repositories/wage_repository.dart';
import 'package:usta_takip_app/src/domain/usecases/record_work_day.dart';
import 'package:usta_takip_app/src/presentation/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:usta_takip_app/src/presentation/features/dashboard/view/dashboard_page.dart';

void main() {
  testWidgets('Dashboard shows metric cards after refresh', (tester) async {
    final projectRepository = _InMemoryProjectRepository();
    final expenseRepository = _InMemoryExpenseRepository();
    final wageRepository = _InMemoryWageRepository();

    await projectRepository.add(
      Project(
        id: 'project-1',
        name: 'Şantiye',
        patronId: 'patron-1',
        totalBudget: 100000,
        defaultDailyWage: 750,
        startDate: DateTime(2024, 1, 1),
      ),
    );

    await expenseRepository.add(
      Expense(
        id: 'expense-1',
        projectId: 'project-1',
        description: 'Malzeme',
        amount: 5000,
        isPaid: true,
        category: 'malzeme',
      ),
    );

    final cubit = DashboardCubit(
      projectRepository: projectRepository,
      expenseRepository: expenseRepository,
      wageRepository: wageRepository,
      recordWorkDay: RecordWorkDay(wageRepository, expenseRepository),
    );
    await cubit.refresh();

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<DashboardCubit>.value(
          value: cubit,
          child: const DashboardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Toplam Gelir'), findsOneWidget);
    expect(find.textContaining('₺'), findsWidgets);

    addTearDown(cubit.close);
  });
}

class _InMemoryProjectRepository implements ProjectRepository {
  final Map<String, Project> _storage = {};

  @override
  Future<void> add(Project project) async {
    _storage[project.id] = project;
  }

  @override
  Future<void> archive(String id) async {
    final project = _storage[id];
    if (project != null) {
      _storage[id] = project.copyWith(isArchived: true);
    }
  }

  @override
  Future<List<Project>> getAll({bool includeArchived = false}) async {
    return _storage.values
        .where(
          (project) =>
              !project.isDeleted &&
              (includeArchived ? true : !project.isArchived),
        )
        .toList();
  }

  @override
  Future<Project?> getById(String id) async => _storage[id];

  @override
  Future<void> restore(String id) async {
    final project = _storage[id];
    if (project != null) {
      _storage[id] = project.copyWith(
        isArchived: false,
        isDeleted: false,
      );
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final project = _storage[id];
    if (project != null) {
      _storage[id] = project.copyWith(isDeleted: true);
    }
  }

  @override
  Future<void> update(Project project) async {
    _storage[project.id] = project;
  }
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
}
