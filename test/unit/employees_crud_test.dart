import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:usta_takip_app/src/data/models/employee.dart';
import 'package:usta_takip_app/src/data/models/employee.g.dart';
import 'package:usta_takip_app/src/data/repositories/hive_employee_repository.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  const boxName = 'employees_crud_box';
  late Box<Employee> employeeBox;
  late HiveEmployeeRepository repository;

  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive.registerAdapter(EmployeeAdapter());
  });

  tearDownAll(() async => HiveTestHelper.closeHive());

  setUp(() async {
    employeeBox = await HiveTestHelper.openBox<Employee>(boxName);
    repository = HiveEmployeeRepository(employeeBox);
  });

  tearDown(() async => employeeBox.clear());

  test('adds and reads employees sorted by insertion', () async {
    final ali = Employee(
      id: 'ali',
      name: 'Ali Usta',
      dailyWage: 700,
      phone: '111',
      projectId: 'p1',
    );
    final veli = Employee(
      id: 'veli',
      name: 'Veli',
      dailyWage: 650,
      phone: '222',
      projectId: 'p2',
    );

    await repository.add(ali);
    await repository.add(veli);

    final employees = await repository.getAll();
    expect(employees.map((e) => e.id), containsAll(['ali', 'veli']));
  });

  test('soft delete hides employee from default queries', () async {
    final emp = Employee(
      id: 'soft',
      name: 'Soft Delete',
      dailyWage: 500,
      phone: '',
      projectId: '',
    );
    await repository.add(emp);

    await repository.softDelete(emp.id);
    final active = await repository.getAll();
    expect(active, isEmpty);
  });

  test('restore brings employee back', () async {
    final emp = Employee(
      id: 'restore',
      name: 'Restore',
      dailyWage: 500,
      phone: '',
      projectId: '',
    );
    await repository.add(emp);
    await repository.softDelete(emp.id);

    await repository.restore(emp.id);
    final active = await repository.getAll();
    expect(active.single.id, equals('restore'));
  });
}
