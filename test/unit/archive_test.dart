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
  const projectBoxName = 'archive_project_box';
  const employeeBoxName = 'archive_employee_box';
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

  test('project archive and restore flow works', () async {
    final project = Project(
      id: 'p1',
      name: 'Restorasyon',
      patronId: 'patron-1',
      totalBudget: 1000,
      defaultDailyWage: 200,
      startDate: DateTime(2024, 1, 1),
    );
    await projectRepository.add(project);

    await projectRepository.archive(project.id);
    final archived = await projectRepository.getArchived();
    expect(archived, isNotEmpty);

    await projectRepository.restore(project.id);
    final afterRestore = await projectRepository.getArchived();
    expect(afterRestore, isEmpty);
  });

  test('employee archive uses archive flag and restoration', () async {
    final employee = Employee(
      id: 'e1',
      name: 'Mehmet',
      dailyWage: 500,
      phone: '555',
      projectId: 'p1',
    );
    await employeeRepository.add(employee);
    await employeeRepository.archive(employee.id);

    expect((await employeeRepository.getArchived()).length, 1);

    await employeeRepository.restore(employee.id);
    expect(await employeeRepository.getArchived(), isEmpty);
  });
}
