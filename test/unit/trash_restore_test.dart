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
  const projectBoxName = 'trash_project_box';
  const employeeBoxName = 'trash_employee_box';
  late HiveProjectRepository projectRepository;
  late HiveEmployeeRepository employeeRepository;
  late Box<Project> projectBox;
  late Box<Employee> employeeBox;

  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive
      ..registerAdapter(ProjectAdapter())
      ..registerAdapter(EmployeeAdapter());
  });

  tearDownAll(() async => HiveTestHelper.closeHive());

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

  test('soft delete pushes project into trash and hard delete removes it', () async {
    final project = Project(
      id: 'p-trash',
      name: 'Kentsel',
      patronId: 'patron',
      totalBudget: 5000,
      defaultDailyWage: 300,
      startDate: DateTime(2024, 2, 1),
    );
    await projectRepository.add(project);
    await projectRepository.softDelete(project.id);

    final deleted = await projectRepository.getDeleted();
    expect(deleted.map((e) => e.id), contains(project.id));

    await projectRepository.hardDelete(project.id);
    expect(await projectRepository.getDeleted(), isEmpty);
  });

  test('employee restore brings them back from trash', () async {
    final employee = Employee(
      id: 'trash-emp',
      name: 'Ayşe',
      dailyWage: 450,
      phone: '555-777',
      projectId: 'p1',
    );
    await employeeRepository.add(employee);
    await employeeRepository.softDelete(employee.id);

    expect(await employeeRepository.getDeleted(), isNotEmpty);

    await employeeRepository.restore(employee.id);
    expect(await employeeRepository.getDeleted(), isEmpty);
  });
}
