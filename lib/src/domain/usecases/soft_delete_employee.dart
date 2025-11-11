import '../repositories/employee_repository.dart';
import '../repositories/wage_repository.dart';

class SoftDeleteEmployee {
  SoftDeleteEmployee(this._employeeRepository, this._wageRepository);

  final EmployeeRepository _employeeRepository;
  final WageRepository _wageRepository;

  Future<void> call(String employeeId, {bool cascadeWages = true}) async {
    await _employeeRepository.softDelete(employeeId);
    if (cascadeWages) {
      final entries = await _wageRepository.getByEmployee(employeeId);
      for (final entry in entries) {
        await _wageRepository.softDelete(entry.id);
      }
    }
  }
}
