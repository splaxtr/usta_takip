import '../../data/models/patron.dart';

abstract class PatronRepository {
  Future<List<Patron>> getAll({bool includeDeleted = false});
  Future<Patron?> getById(String id);
  Future<void> add(Patron patron);
  Future<void> update(Patron patron);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> hardDelete(String id);
  Future<List<Patron>> getDeleted();
}
