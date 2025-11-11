import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/models/employee.dart';
import '../data/models/employee.g.dart';
import '../data/models/expense.dart';
import '../data/models/expense.g.dart';
import '../data/models/project.dart';
import '../data/models/project.g.dart';
import '../data/models/wage_entry.dart';
import '../data/models/wage_entry.g.dart';
import '../data/repositories/hive_employee_repository.dart';
import '../data/repositories/hive_expense_repository.dart';
import '../data/repositories/hive_project_repository.dart';
import '../data/repositories/hive_wage_repository.dart';
import 'app_dependencies.dart';

Future<AppDependencies> bootstrapApplication() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  _registerAdapters();

  final projectsBox = await Hive.openBox<Project>('projects');
  final employeesBox = await Hive.openBox<Employee>('employees');
  final wagesBox = await Hive.openBox<WageEntry>('wage_entries');
  final expensesBox = await Hive.openBox<Expense>('expenses');

  final projectRepository = HiveProjectRepository(projectsBox);
  final employeeRepository = HiveEmployeeRepository(employeesBox);
  final wageRepository = HiveWageRepository(wagesBox);
  final expenseRepository = HiveExpenseRepository(expensesBox);

  return AppDependencies(
    projectRepository: projectRepository,
    employeeRepository: employeeRepository,
    wageRepository: wageRepository,
    expenseRepository: expenseRepository,
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
}
