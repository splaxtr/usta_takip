import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:usta_takip_app/src/data/models/expense.dart';
import 'package:usta_takip_app/src/data/models/expense.g.dart';
import 'package:usta_takip_app/src/data/models/project.dart';
import 'package:usta_takip_app/src/data/models/project.g.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.g.dart';
import 'package:usta_takip_app/src/data/repositories/hive_ledger_repository.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  late Box<Project> projectBox;
  late Box<Expense> expenseBox;
  late Box<WageEntry> wageBox;
  late Box settingsBox;
  late HiveLedgerRepository repository;

  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive
      ..registerAdapter(ProjectAdapter())
      ..registerAdapter(ExpenseAdapter())
      ..registerAdapter(WageEntryAdapter());
  });

  tearDownAll(() async => HiveTestHelper.closeHive());

  setUp(() async {
    projectBox = await HiveTestHelper.openBox<Project>('ledger_project');
    expenseBox = await HiveTestHelper.openBox<Expense>('ledger_expense');
    wageBox = await HiveTestHelper.openBox<WageEntry>('ledger_wage');
    settingsBox = await HiveTestHelper.openBox('ledger_settings');
    repository = HiveLedgerRepository(
      projectBox: projectBox,
      wageBox: wageBox,
      expenseBox: expenseBox,
      settingsBox: settingsBox,
    );
  });

  tearDown(() async {
    await projectBox.clear();
    await expenseBox.clear();
    await wageBox.clear();
    await settingsBox.clear();
  });

  test('summary aggregates totals correctly', () async {
    await projectBox.put(
      'p1',
      Project(
        id: 'p1',
        name: 'Şantiye',
        patronId: 'patron1',
        totalBudget: 10000,
        defaultDailyWage: 500,
        startDate: DateTime(2024, 1, 1),
      ),
    );
    await expenseBox.put(
      'e1',
      Expense(
        id: 'e1',
        projectId: 'p1',
        description: 'Malzeme',
        amount: 2500,
        isPaid: true,
        category: 'malzeme',
      ),
    );
    await wageBox.put(
      'w1',
      WageEntry(
        id: 'w1',
        employeeId: 'emp1',
        projectId: 'p1',
        date: DateTime(2024, 1, 2),
        amount: 600,
        status: 'recorded',
      ),
    );

    final summary = await repository.loadSummary();

    expect(summary.totalIncome, 10000);
    expect(summary.paidExpenses, 2500);
    expect(summary.pendingWages, 600);
    expect(summary.outstandingPatronPayments, greaterThan(0));

    final pending = await repository.pendingWages();
    expect(pending, hasLength(1));

    final paid = await repository.paidExpenses();
    expect(paid, hasLength(1));
  });
}
