import 'package:hive/hive.dart';

import '../../domain/repositories/wage_repository.dart';
import '../models/wage_entry.dart';

class HiveWageRepository implements WageRepository {
  HiveWageRepository(this._box);

  final Box<WageEntry> _box;

  @override
  Future<void> add(WageEntry entry) async {
    await _box.put(entry.id, entry);
  }

  @override
  Future<WageEntry?> getById(String id) async {
    final entry = _box.get(id);
    return entry == null ? null : _copyEntry(entry);
  }

  @override
  Future<List<WageEntry>> getByProject(String projectId) async {
    return _box.values
        .where((entry) => entry.projectId == projectId && !entry.isDeleted)
        .map(_copyEntry)
        .toList();
  }

  @override
  Future<List<WageEntry>> getByEmployee(String employeeId) async {
    return _box.values
        .where((entry) => entry.employeeId == employeeId && !entry.isDeleted)
        .map(_copyEntry)
        .toList();
  }

  @override
  Future<List<WageEntry>> getPendingByProject(String projectId) async {
    return _box.values
        .where(
          (entry) =>
              entry.projectId == projectId &&
              entry.status != 'paid' &&
              !entry.isDeleted,
        )
        .map(_copyEntry)
        .toList();
  }

  @override
  Future<double> getPendingTotal() async {
    return _box.values
        .where((entry) => entry.status != 'paid' && !entry.isDeleted)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
  }

  @override
  Future<List<WageEntry>> getArchived() async {
    return _box.values
        .where((entry) => entry.isArchived && !entry.isDeleted)
        .map(_copyEntry)
        .toList();
  }

  @override
  Future<List<WageEntry>> getDeleted() async {
    return _box.values
        .where((entry) => entry.isDeleted)
        .map(_copyEntry)
        .toList();
  }

  @override
  Future<void> softDelete(String id) async {
    final entry = _box.get(id);
    if (entry != null) {
      entry
        ..isDeleted = true
        ..deletedAt = DateTime.now();
      await entry.save();
    }
  }

  @override
  Future<void> hardDelete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> update(WageEntry entry) async {
    entry.updatedAt = DateTime.now();
    await _box.put(entry.id, entry);
  }

  WageEntry _copyEntry(WageEntry source) {
    return source.copyWith(
      isDeleted: source.isDeleted,
      isArchived: source.isArchived,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      deletedAt: source.deletedAt,
    );
  }
}
