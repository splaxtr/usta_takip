import '../../data/models/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getAll({bool includeDeleted = false});
  Future<Employee?> getById(String id);
  Future<void> add(Employee employee);
  Future<void> update(Employee employee);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> hardDelete(String id);
  Future<void> archive(String id);
  Future<List<Employee>> getArchived();
  Future<List<Employee>> getDeleted();
}
