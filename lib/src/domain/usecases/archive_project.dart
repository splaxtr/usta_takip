import '../repositories/project_repository.dart';

class ArchiveProject {
  ArchiveProject(this._projectRepository);

  final ProjectRepository _projectRepository;

  Future<void> call(String projectId) async {
    await _projectRepository.archive(projectId);
  }
}
