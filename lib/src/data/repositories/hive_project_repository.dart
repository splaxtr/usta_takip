import 'package:hive/hive.dart';

import '../../domain/repositories/project_repository.dart';
import '../models/project.dart';

class HiveProjectRepository implements ProjectRepository {
  HiveProjectRepository(this._box);

  final Box<Project> _box;

  @override
  Future<void> add(Project project) async {
    await _box.put(project.id, project);
  }

  @override
  Future<void> archive(String id) async {
    final project = _box.get(id);
    if (project != null) {
      project
        ..isArchived = true
        ..updatedAt = DateTime.now();
      await project.save();
    }
  }

  @override
  Future<List<Project>> getAll({bool includeArchived = false}) async {
    return _box.values
        .where(
          (project) =>
              !project.isDeleted &&
              (includeArchived ? true : !project.isArchived),
        )
        .map(_copyProject)
        .toList();
  }

  @override
  Future<List<Project>> getArchived() async {
    return _box.values
        .where((project) => project.isArchived && !project.isDeleted)
        .map(_copyProject)
        .toList();
  }

  @override
  Future<List<Project>> getDeleted() async {
    return _box.values
        .where((project) => project.isDeleted)
        .map(_copyProject)
        .toList();
  }

  @override
  Future<Project?> getById(String id) async {
    final project = _box.get(id);
    return project == null ? null : _copyProject(project);
  }

  @override
  Future<void> restore(String id) async {
    final project = _box.get(id);
    if (project != null) {
      project
        ..isDeleted = false
        ..isArchived = false
        ..deletedAt = null
        ..updatedAt = DateTime.now();
      await project.save();
    }
  }

  @override
  Future<void> softDelete(String id) async {
    final project = _box.get(id);
    if (project != null) {
      project
        ..isDeleted = true
        ..deletedAt = DateTime.now();
      await project.save();
    }
  }

  @override
  Future<void> hardDelete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> update(Project project) async {
    project.updatedAt = DateTime.now();
    await _box.put(project.id, project);
  }

  Project _copyProject(Project source) {
    return source.copyWith(
      isDeleted: source.isDeleted,
      isArchived: source.isArchived,
      createdAt: source.createdAt,
      updatedAt: source.updatedAt,
      deletedAt: source.deletedAt,
    );
  }
}
