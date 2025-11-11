import 'package:equatable/equatable.dart';

import '../../../../data/models/employee.dart';
import '../../../../data/models/project.dart';

class TrashState extends Equatable {
  const TrashState({
    this.projects = const [],
    this.employees = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Project> projects;
  final List<Employee> employees;
  final bool isLoading;
  final String? errorMessage;

  TrashState copyWith({
    List<Project>? projects,
    List<Employee>? employees,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TrashState(
      projects: projects ?? this.projects,
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [projects, employees, isLoading, errorMessage];
}
