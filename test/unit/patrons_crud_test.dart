import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:usta_takip_app/src/data/models/patron.dart';
import 'package:usta_takip_app/src/data/models/patron.g.dart';
import 'package:usta_takip_app/src/data/repositories/hive_patron_repository.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  const boxName = 'patron_crud_box';
  late Box<Patron> patronBox;
  late HivePatronRepository repository;

  setUpAll(() async {
    await HiveTestHelper.initHive();
    Hive.registerAdapter(PatronAdapter());
  });

  tearDownAll(() async => HiveTestHelper.closeHive());

  setUp(() async {
    patronBox = await HiveTestHelper.openBox<Patron>(boxName);
    repository = HivePatronRepository(patronBox);
  });

  tearDown(() async => patronBox.clear());

  test('create and update patron works', () async {
    final patron = Patron(
      id: 'patron-1',
      name: 'İşveren',
      phone: '555',
      description: 'Test açıklaması',
    );
    await repository.add(patron);

    final stored = await repository.getById(patron.id);
    expect(stored, isNotNull);

    await repository.update(
      patron.copyWith(description: 'Güncellendi'),
    );
    final updated = await repository.getById(patron.id);
    expect(updated!.description, equals('Güncellendi'));
  });

  test('soft delete removes from active list and restore returns it', () async {
    final patron = Patron(
      id: 'to-delete',
      name: 'Silinecek',
      phone: '',
      description: '',
    );
    await repository.add(patron);
    await repository.softDelete(patron.id);

    expect(await repository.getAll(), isEmpty);
    await repository.restore(patron.id);
    expect(await repository.getAll(), isNotEmpty);
  });
}
