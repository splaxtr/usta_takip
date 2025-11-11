import 'package:hive/hive.dart';

import '../../domain/repositories/employee_repository.dart';
import '../models/employee.dart';

class HiveEmployeeRepository implements EmployeeRepository {
  HiveEmployeeRepository(this._box);

  final Box<Employee> _box;

  @override
  Future<void> add(Employee employee) async {
    await _box.put(employee.id, employee);
  }

  @override
  Future<List<Employee>> getAll({bool includeDeleted = false}) async {
    return _box.values
        .where(
          (employee) =>
              includeDeleted ? true : (!employee.isDeleted && !employee.isArchived),
        )
        .map(_copyEmployee)
        .toList();
  }

  @override
  Future<Employee?> getById(String id) async {
    final employee = _box.get(id);
    return employee == null ? null : _copyEmployee(employee);
  }

  @override
  Future<void> restore(String id) async {
    final employee = _box.get(id);
    if (employee != null) {
      employee
        ..isDeleted = false
        ..deletedAt = null
        ..updatedAt = DateTime.now();
      await employee.save();
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final employee = _box.get(id);
    if (employee != null) {
      employee
        ..isDeleted = true
        ..deletedAt = DateTime.now();
      await employee.save();
    }
  }

  @override
  Future<void> update(Employee employee) async {
    employee.updatedAt = DateTime.now();
    await _box.put(employee.id, employee);
  }

  Employee _copyEmployee(Employee source) {
    return source.copyWith(
      isDeleted: source.isDeleted,
      isArchived: source.isArchived,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      deletedAt: source.deletedAt,
    );
  }
}
