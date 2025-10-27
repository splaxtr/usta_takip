import 'package:hive_flutter/hive_flutter.dart';
import '../models/project_model.dart';

/// Proje verilerini yöneten Repository sınıfı
class ProjectRepository {
  final Box _box;

  ProjectRepository(this._box);

  /// Yeni proje oluşturur
  Future<int> createProject(Project project) async {
    return await _box.add(project.toJson());
  }

  /// ID'ye göre proje getirir
  Project? getProject(int id) {
    final data = _box.get(id);
    if (data == null) return null;
    return Project.fromJson(data as Map<String, dynamic>, id: id);
  }

  /// Tüm projeleri getirir
  List<Project> getAllProjects() {
    return _box.keys
        .map((key) => Project.fromJson(_box.get(key) as Map<String, dynamic>, id: key as int))
        .toList();
  }

  /// Sadece aktif projeleri getirir
  List<Project> getActiveProjects() {
    return getAllProjects().where((p) => p.status == 'active').toList();
  }

  /// Projeyi günceller
  Future<void> updateProject(int id, Project project) async {
    await _box.put(id, project.toJson());
  }

  /// Projeyi siler
  Future<void> deleteProject(int id) async {
    await _box.delete(id);
  }

  /// Proje sayısını döner
  int getProjectCount() {
    return _box.length;
  }

  /// İsme göre proje arar
  List<Project> searchProjects(String query) {
    return getAllProjects()
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
