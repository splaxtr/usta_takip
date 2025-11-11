import '../domain/repositories/employee_repository.dart';
import '../domain/repositories/expense_repository.dart';
import '../domain/repositories/ledger_repository.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/repositories/wage_repository.dart';
import '../domain/services/auth_lock_service.dart';
import '../domain/services/backup_service.dart';

class AppDependencies {
  const AppDependencies({
    required this.projectRepository,
    required this.employeeRepository,
    required this.wageRepository,
    required this.expenseRepository,
    required this.ledgerRepository,
    required this.backupService,
    required this.authLockService,
  });

  final ProjectRepository projectRepository;
  final EmployeeRepository employeeRepository;
  final WageRepository wageRepository;
  final ExpenseRepository expenseRepository;
  final LedgerRepository ledgerRepository;
  final BackupService backupService;
  final AuthLockService authLockService;
}
