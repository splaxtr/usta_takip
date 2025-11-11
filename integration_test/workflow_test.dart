import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';

import 'package:usta_takip_app/src/data/models/expense.dart';
import 'package:usta_takip_app/src/data/models/expense.g.dart';
import 'package:usta_takip_app/src/data/models/project.dart';
import 'package:usta_takip_app/src/data/models/project.g.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.g.dart';
import 'package:usta_takip_app/src/data/repositories/hive_expense_repository.dart';
import 'package:usta_takip_app/src/data/repositories/hive_project_repository.dart';
import 'package:usta_takip_app/src/data/repositories/hive_wage_repository.dart';
import 'package:usta_takip_app/src/domain/usecases/record_work_day.dart';

import '../test/helpers/hive_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late HiveProjectRepository projectRepository;
  late HiveExpenseRepository expenseRepository;
  late HiveWageRepository wageRepository;
  late Box<Project> projectBox;
  late Box<Expense> expenseBox;
  late Box<WageEntry> wageBox;

  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive
      ..registerAdapter(ProjectAdapter())
      ..registerAdapter(ExpenseAdapter())
      ..registerAdapter(WageEntryAdapter());
  });

  tearDownAll(() async => HiveTestHelper.closeHive());

  setUp(() async {
    projectBox = await HiveTestHelper.openBox<Project>('int_projects');
    expenseBox = await HiveTestHelper.openBox<Expense>('int_expenses');
    wageBox = await HiveTestHelper.openBox<WageEntry>('int_wages');
    projectRepository = HiveProjectRepository(projectBox);
    expenseRepository = HiveExpenseRepository(expenseBox);
    wageRepository = HiveWageRepository(wageBox);
  });

  tearDown(() async {
    await projectBox.clear();
    await expenseBox.clear();
    await wageBox.clear();
  });

  testWidgets('record → pay → archive → restore', (tester) async {
    final recordWorkDay = RecordWorkDay(wageRepository, expenseRepository);
    final project = Project(
      id: 'integration',
      name: 'Entegrasyon',
      patronId: 'patron',
      totalBudget: 8000,
      defaultDailyWage: 400,
      startDate: DateTime(2024, 3, 1),
    );
    await projectRepository.add(project);

    await recordWorkDay(
      RecordWorkDayParams(
        employeeId: 'emp-int',
        projectId: project.id,
        date: DateTime(2024, 3, 2),
        amount: 450,
      ),
    );
    expect(await wageRepository.getByProject(project.id), isNotEmpty);

    await projectRepository.archive(project.id);
    expect(await projectRepository.getArchived(), isNotEmpty);

    await projectRepository.restore(project.id);
    expect(await projectRepository.getArchived(), isEmpty);
  });
}
