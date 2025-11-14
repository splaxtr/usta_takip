import 'package:hive/hive.dart';

import '../../domain/repositories/patron_repository.dart';
import '../models/patron.dart';

class HivePatronRepository implements PatronRepository {
  HivePatronRepository(this._box);

  final Box<Patron> _box;

  @override
  Future<void> add(Patron patron) async {
    await _box.put(patron.id, patron);
  }

  @override
  Future<List<Patron>> getAll({bool includeDeleted = false}) async {
    return _box.values
        .where((patron) => includeDeleted ? true : !patron.isDeleted)
        .map(_clone)
        .toList();
  }

  @override
  Future<Patron?> getById(String id) async {
    final patron = _box.get(id);
    return patron == null ? null : _clone(patron);
  }

  @override
  Future<void> hardDelete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<Patron>> getDeleted() async {
    return _box.values.where((patron) => patron.isDeleted).map(_clone).toList();
  }

  @override
  Future<void> restore(String id) async {
    final patron = _box.get(id);
    if (patron != null) {
      patron
        ..isDeleted = false
        ..deletedAt = null
        ..updatedAt = DateTime.now();
      await patron.save();
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final patron = _box.get(id);
    if (patron != null) {
      patron
        ..isDeleted = true
        ..deletedAt = DateTime.now();
      await patron.save();
    }
  }

  @override
  Future<void> update(Patron patron) async {
    patron.updatedAt = DateTime.now();
    await _box.put(patron.id, patron);
  }

  Patron _clone(Patron patron) {
    return patron.copyWith(
      isDeleted: patron.isDeleted,
      isArchived: patron.isArchived,
      createdAt: patron.createdAt,
      updatedAt: patron.updatedAt,
      deletedAt: patron.deletedAt,
    );
  }
}
