import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:usta_takip_app/src/data/models/employee.dart';
import 'package:usta_takip_app/src/data/models/employee.g.dart';
import 'package:usta_takip_app/src/data/models/expense.dart';
import 'package:usta_takip_app/src/data/models/expense.g.dart';
import 'package:usta_takip_app/src/data/models/project.dart';
import 'package:usta_takip_app/src/data/models/project.g.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.g.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive
      ..registerAdapter(ProjectAdapter())
      ..registerAdapter(EmployeeAdapter())
      ..registerAdapter(WageEntryAdapter())
      ..registerAdapter(ExpenseAdapter());
  });

  tearDownAll(() async {
    await HiveTestHelper.closeHive();
  });

  group('Hive model serialization', () {
    test('Project persists and restores with tracking fields', () async {
      final box = await HiveTestHelper.openBox<Project>('projects_model_test');
      final project = Project(
        id: 'project-1',
        name: 'Test Projesi',
        patronId: 'patron-1',
        totalBudget: 10000,
        defaultDailyWage: 750,
        startDate: DateTime(2024, 1, 10),
      );
      project.isArchived = true;
      await box.put(project.id, project);

      final restored = box.get(project.id) as Project?;
      expect(restored, isNotNull);
      expect(restored!.name, equals('Test Projesi'));
      expect(restored.isArchived, isTrue);
    });

    test('WageEntry copyWith keeps audit metadata', () {
      final entry = WageEntry(
        id: 'wage-1',
        employeeId: 'employee-1',
        projectId: 'project-1',
        date: DateTime(2024, 1, 1),
        amount: 500,
      );
      entry.isDeleted = true;
      entry.deletedAt = DateTime(2024, 1, 2);

      final restored = entry.copyWith(status: 'paid');
      expect(restored.status, equals('paid'));
      expect(restored.isDeleted, isTrue);
      expect(restored.deletedAt, equals(entry.deletedAt));
    });
  });
}
