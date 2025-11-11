import '../../data/models/wage_entry.dart';

abstract class WageRepository {
  Future<WageEntry?> getById(String id);
  Future<List<WageEntry>> getByEmployee(String employeeId);
  Future<List<WageEntry>> getByProject(String projectId);
  Future<List<WageEntry>> getPendingByProject(String projectId);
  Future<double> getPendingTotal();
  Future<void> add(WageEntry entry);
  Future<void> update(WageEntry entry);
  Future<void> softDelete(String id);
  Future<void> hardDelete(String id);
  Future<List<WageEntry>> getArchived();
  Future<List<WageEntry>> getDeleted();
}
