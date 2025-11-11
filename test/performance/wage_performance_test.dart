import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:usta_takip_app/src/data/models/wage_entry.dart';
import 'package:usta_takip_app/src/data/models/wage_entry.g.dart';
import 'package:usta_takip_app/src/data/repositories/hive_wage_repository.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  late HiveWageRepository repository;
  late Box<WageEntry> wageBox;

  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive.registerAdapter(WageEntryAdapter());
  });

  tearDownAll(() async => HiveTestHelper.closeHive());

  setUp(() async {
    wageBox = await HiveTestHelper.openBox<WageEntry>('performance_wages');
    repository = HiveWageRepository(wageBox);
  });

  tearDown(() async {
    await wageBox.clear();
  });

  test('pending wage listing remains performant with 500 entries', () async {
    for (var i = 0; i < 500; i++) {
      await repository.add(
        WageEntry(
          id: 'w$i',
          employeeId: 'emp$i',
          projectId: 'p${i % 5}',
          date: DateTime(2024, 1, 1).add(Duration(days: i)),
          amount: 300 + i.toDouble(),
        ),
      );
    }

    final stopwatch = Stopwatch()..start();
    final pending = await repository.getPendingByProject('p1');
    stopwatch.stop();

    expect(pending.length, greaterThan(0));
    expect(stopwatch.elapsedMilliseconds, lessThan(150));
  });
}
