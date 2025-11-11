import '../domain/repositories/employee_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/wage_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.projectRepository,
    required this.employeeRepository,
    required this.wageRepository,
    required this.expenseRepository,
  });

  final ProjectRepository projectRepository;
  final EmployeeRepository employeeRepository;
  final WageRepository wageRepository;
  final ExpenseRepository expenseRepository;
}
