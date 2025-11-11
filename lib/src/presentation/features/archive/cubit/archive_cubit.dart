import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/repositories/employee_repository.dart';
import '../../../../domain/repositories/project_repository.dart';
import 'archive_state.dart';

class ArchiveCubit extends Cubit<ArchiveState> {
  ArchiveCubit(this._projectRepository, this._employeeRepository)
      : super(const ArchiveState());

  final ProjectRepository _projectRepository;
  final EmployeeRepository _employeeRepository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final projects = await _projectRepository.getArchived();
      final employees = await _employeeRepository.getArchived();
      emit(
        state.copyWith(
          projects: projects,
          employees: employees,
          isLoading: false,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> restoreProject(String id) async {
    await _projectRepository.restore(id);
    await load();
  }

  Future<void> restoreEmployee(String id) async {
    await _employeeRepository.restore(id);
    await load();
  }
}
