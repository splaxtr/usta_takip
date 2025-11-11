import '../../data/models/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getAll({bool includeArchived = false});
  Future<Project?> getById(String id);
  Future<void> add(Project project);
  Future<void> update(Project project);
  Future<void> softDelete(String id);
  Future<void> archive(String id);
  Future<void> restore(String id);
}
