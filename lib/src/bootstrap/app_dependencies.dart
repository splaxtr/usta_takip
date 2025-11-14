import '../domain/repositories/employee_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/ledger_repository.dart';
import '../domain/repositories/patron_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/wage_repository.dart';
import '../domain/services/backup_service.dart';

class AppDependencies {
  const AppDependencies({
    required this.projectRepository,
    required this.employeeRepository,
    required this.patronRepository,
    required this.wageRepository,
    required this.expenseRepository,
    required this.ledgerRepository,
    required this.backupService,
  });

  final ProjectRepository projectRepository;
  final EmployeeRepository employeeRepository;
  final PatronRepository patronRepository;
  final WageRepository wageRepository;
  final ExpenseRepository expenseRepository;
  final LedgerRepository ledgerRepository;
  final BackupService backupService;
}
