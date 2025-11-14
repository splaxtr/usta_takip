import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/employee.dart';
import '../data/models/employee.g.dart';
import '../data/models/expense.dart';
import '../data/models/expense.g.dart';
import '../data/models/patron.dart';
import '../data/models/patron.g.dart';
import '../data/models/project.dart';
import '../data/models/project.g.dart';
import '../data/models/wage_entry.dart';
import '../data/models/wage_entry.g.dart';
import '../data/repositories/hive_employee_repository.dart';
import '../data/repositories/hive_expense_repository.dart';
import '../data/repositories/hive_ledger_repository.dart';
import '../data/repositories/hive_patron_repository.dart';
import '../data/repositories/hive_project_repository.dart';
import '../data/repositories/hive_wage_repository.dart';
import '../data/services/local_backup_service.dart';
import '../domain/repositories/ledger_repository.dart';
import 'app_dependencies.dart';
import 'encryption_helper.dart';

Future<AppDependencies> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  _registerAdapters();

  final encryptionHelper = EncryptionHelper();
  final encryptionKey = await encryptionHelper.loadKey();
  final cipher = HiveAesCipher(encryptionKey);

  final projectsBox =
      await Hive.openBox<Project>('projects', encryptionCipher: cipher);
  final employeesBox =
      await Hive.openBox<Employee>('employees', encryptionCipher: cipher);
  final patronsBox =
      await Hive.openBox<Patron>('patrons', encryptionCipher: cipher);
  final wagesBox =
      await Hive.openBox<WageEntry>('wage_entries', encryptionCipher: cipher);
  final expensesBox =
      await Hive.openBox<Expense>('expenses', encryptionCipher: cipher);
  final settingsBox = await Hive.openBox('settings', encryptionCipher: cipher);

  final projectRepository = HiveProjectRepository(projectsBox);
  final employeeRepository = HiveEmployeeRepository(employeesBox);
  final patronRepository = HivePatronRepository(patronsBox);
  final wageRepository = HiveWageRepository(wagesBox);
  final expenseRepository = HiveExpenseRepository(expensesBox);
  final ledgerRepository = HiveLedgerRepository(
    projectBox: projectsBox,
    wageBox: wagesBox,
    expenseBox: expensesBox,
    settingsBox: settingsBox,
  );
  final backupService = LocalBackupService(
    projectBox: projectsBox,
    employeeBox: employeesBox,
    patronBox: patronsBox,
    wageBox: wagesBox,
    expenseBox: expensesBox,
    settingsBox: settingsBox,
    encryptionKey: encryptionKey,
  );

  return AppDependencies(
    projectRepository: projectRepository,
    employeeRepository: employeeRepository,
    wageRepository: wageRepository,
    expenseRepository: expenseRepository,
    patronRepository: patronRepository,
    ledgerRepository: ledgerRepository,
    backupService: backupService,
  );
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(ProjectAdapter().typeId)) {
    Hive.registerAdapter(ProjectAdapter());
  }
  if (!Hive.isAdapterRegistered(EmployeeAdapter().typeId)) {
    Hive.registerAdapter(EmployeeAdapter());
  }
  if (!Hive.isAdapterRegistered(WageEntryAdapter().typeId)) {
    Hive.registerAdapter(WageEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(ExpenseAdapter().typeId)) {
    Hive.registerAdapter(ExpenseAdapter());
  }
  if (!Hive.isAdapterRegistered(PatronAdapter().typeId)) {
    Hive.registerAdapter(PatronAdapter());
  }
}
