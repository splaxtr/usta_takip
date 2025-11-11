import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:usta_takip_app/src/data/models/employee.dart';
import 'package:usta_takip_app/src/data/models/employee.g.dart';
import 'package:usta_takip_app/src/data/models/project.dart';
import 'package:usta_takip_app/src/data/models/project.g.dart';
import 'package:usta_takip_app/src/data/repositories/hive_employee_repository.dart';
import 'package:usta_takip_app/src/data/repositories/hive_project_repository.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  const projectBoxName = 'projects_repo_test';
  const employeeBoxName = 'employees_repo_test';
  late Box<Project> projectBox;
  late Box<Employee> employeeBox;
  late HiveProjectRepository projectRepository;
  late HiveEmployeeRepository employeeRepository;

  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive
      ..registerAdapter(ProjectAdapter())
      ..registerAdapter(EmployeeAdapter());
  });

  tearDownAll(() async {
    await HiveTestHelper.closeHive();
  });

  setUp(() async {
    projectBox = await HiveTestHelper.openBox<Project>(projectBoxName);
    employeeBox = await HiveTestHelper.openBox<Employee>(employeeBoxName);
    projectRepository = HiveProjectRepository(projectBox);
    employeeRepository = HiveEmployeeRepository(employeeBox);
  });

  tearDown(() async {
    await projectBox.clear();
    await employeeBox.clear();
  });

  test('soft deleted project is hidden from active list but restorable', () async {
    final project = Project(
      id: 'project-1',
      name: 'Villa',
      patronId: 'patron-1',
      totalBudget: 200000,
      defaultDailyWage: 900,
      startDate: DateTime(2024, 1, 1),
    );
    await projectRepository.add(project);

    await projectRepository.softDelete(project.id);
    expect(await projectRepository.getAll(), isEmpty);

    await projectRepository.restore(project.id);
    final restored = await projectRepository.getById(project.id);
    expect(restored, isNotNull);
    expect(restored!.isDeleted, isFalse);
  });

  test('soft deleting employee toggles deletion flag', () async {
    final employee = Employee(
      id: 'employee-1',
      name: 'Ahmet',
      dailyWage: 700,
      phone: '555-555',
      projectId: 'project-1',
    );
    await employeeRepository.add(employee);

    await employeeRepository.softDelete(employee.id);
    final stored = await employeeRepository.getById(employee.id);
    expect(stored, isNotNull);
    expect(stored!.isDeleted, isTrue);
  });
}
