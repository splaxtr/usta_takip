import '../repositories/employee_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/project_repository.dart';
import '../repositories/wage_repository.dart';

class RestoreFromTrash {
  RestoreFromTrash({
    required ProjectRepository projectRepository,
    required EmployeeRepository employeeRepository,
    required WageRepository wageRepository,
    required ExpenseRepository expenseRepository,
  })  : _projectRepository = projectRepository,
        _employeeRepository = employeeRepository,
        _wageRepository = wageRepository,
        _expenseRepository = expenseRepository;

  final ProjectRepository _projectRepository;
  final EmployeeRepository _employeeRepository;
  final WageRepository _wageRepository;
  final ExpenseRepository _expenseRepository;

  Future<void> project(String id) => _projectRepository.restore(id);

  Future<void> employee(String id) => _employeeRepository.restore(id);

  Future<void> wage(String id) async {
    final entry = await _wageRepository.getById(id);
    if (entry != null && entry.isDeleted) {
      entry.isDeleted = false;
      entry.deletedAt = null;
      entry.updatedAt = DateTime.now();
      await _wageRepository.update(entry);
    }
  }

  Future<void> expense(String id) async {
    final exp = await _expenseRepository.getById(id);
    if (exp != null && exp.isDeleted) {
      final restored = exp.copyWith(
        isDeleted: false,
        deletedAt: null,
        updatedAt: DateTime.now(),
      );
      await _expenseRepository.update(restored);
    }
  }
}
