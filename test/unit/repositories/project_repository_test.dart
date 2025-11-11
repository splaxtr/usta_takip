import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:usta_takip_app/core/models/project_model.dart';
import 'package:usta_takip_app/core/repositories/project_repository.dart';

import '../../fixtures/test_data.dart';
import '../../helpers/hive_test_helper.dart';

void main() {
  const boxName = 'projects_test_box';
  late Box<dynamic> projectBox;
  late ProjectRepository repository;

  setUpAll(() async {
    await HiveTestHelper.initHive();
  });

  tearDownAll(() async {
    await HiveTestHelper.closeHive();
  });

  setUp(() async {
    projectBox = await HiveTestHelper.openBox(boxName);
    repository = ProjectRepository(projectBox);
  });

  tearDown(() async {
    await projectBox.clear();
  });

  group('createProject', () {
    test('Yeni proje başarıyla oluşturulmalı ve pozitif ID dönmeli', () async {
      // Arrange
      final project = TestData.project(name: 'Test Projesi');

      // Act
      final id = await repository.createProject(project);

      // Assert
      expect(id, isA<int>());
      expect(id, greaterThanOrEqualTo(0));
      expect(projectBox.length, equals(1));
    });

    test('Proje Hive kutusunda toJson formatıyla saklanmalı', () async {
      // Arrange
      final project = TestData.project(name: 'Json Kontrolü', patronKey: 42);

      // Act
      final id = await repository.createProject(project);
      final stored = projectBox.get(id) as Map<String, dynamic>;

      // Assert
      expect(stored, equals(project.toJson()));
    });
  });

  group('getProject', () {
    test('Var olan projeyi ID ile getirmeli ve model ID alanını set etmeli', () async {
      // Arrange
      final id = await projectBox.add(TestData.projectJson(name: 'Kaydedilen Proje'));

      // Act
      final project = repository.getProject(id);

      // Assert
      expect(project, isNotNull);
      expect(project!.id, equals(id));
      expect(project.name, equals('Kaydedilen Proje'));
    });

    test('Eksik status alanı olduğunda varsayılan olarak active dönmeli', () async {
      // Arrange
      final id = await projectBox.add({
        'name': 'Statüsüz Proje',
        'startDate': '2024-03-01',
        'patronKey': 7,
      });

      // Act
      final project = repository.getProject(id);

      // Assert
      expect(project, isNotNull);
      expect(project!.status, equals('active'));
    });

    test('Olmayan ID için null döndürmeli', () {
      // Act
      final project = repository.getProject(9999);

      // Assert
      expect(project, isNull);
    });
  });

  group('getAllProjects', () {
    test('Projeleri ekleme sırasına göre döndürmeli', () async {
      // Arrange
      final inserted = [
        await projectBox.add(TestData.projectJson(name: 'Bir')),
        await projectBox.add(TestData.projectJson(name: 'İki')),
        await projectBox.add(TestData.projectJson(name: 'Üç')),
      ];

      // Act
      final projects = repository.getAllProjects();

      // Assert
      expect(projects.map((p) => p.id), containsAllInOrder(inserted));
    });

    test('Dönen liste kutudan bağımsız olmalı (mutasyon izolasyonu)', () async {
      // Arrange
      await repository.createProject(TestData.project(name: 'Orijinal'));

      // Act
      final projects = repository.getAllProjects();
      projects[0] = projects[0].copyWith(name: 'Mutasyona Uğradı');
      final fetchedAgain = repository.getAllProjects().first;

      // Assert
      expect(fetchedAgain.name, equals('Orijinal'));
    });
  });

  group('getActiveProjects', () {
    test('Sadece status active olanları döndürmeli', () async {
      // Arrange
      await repository.createProject(TestData.project(name: 'Aktif 1'));
      await repository.createProject(TestData.project(name: 'Tamamlanan', status: 'completed'));
      await repository.createProject(TestData.project(name: 'Aktif 2', status: 'active'));

      // Act
      final activeProjects = repository.getActiveProjects();

      // Assert
      expect(activeProjects, hasLength(2));
      expect(activeProjects.map((p) => p.status).toSet(), equals({'active'}));
    });

    test('Aktif proje yoksa boş liste döndürmeli', () async {
      // Arrange
      await repository.createProject(TestData.project(name: 'Tamamlanan', status: 'completed'));

      // Act
      final activeProjects = repository.getActiveProjects();

      // Assert
      expect(activeProjects, isEmpty);
    });
  });

  group('updateProject', () {
    test('Projeyi verilen bilgilerle güncellemeli', () async {
      // Arrange
      final id = await repository.createProject(TestData.project(name: 'Eski', status: 'active'));
      final updated = TestData.project(id: id, name: 'Yeni', status: 'completed');

      // Act
      await repository.updateProject(id, updated);
      final result = repository.getProject(id)!;

      // Assert
      expect(result.name, equals('Yeni'));
      expect(result.status, equals('completed'));
    });

    test('copyWith kullanarak yapılan güncelleme diğer alanları korumalı', () async {
      // Arrange
      final id = await repository.createProject(
        TestData.project(name: 'Orijinal', startDate: '2024-04-01', patronKey: 5),
      );
      final existing = repository.getProject(id)!;

      // Act
      await repository.updateProject(id, existing.copyWith(name: 'Güncellendi'));
      final updated = repository.getProject(id)!;

      // Assert
      expect(updated.name, equals('Güncellendi'));
      expect(updated.startDate, equals('2024-04-01'));
      expect(updated.patronKey, equals(5));
    });

    test('Olmayan ID için update çağrısı yeni kayıt oluşturmalı (Hive put davranışı)', () async {
      // Arrange
      final phantomId = 777;
      final project = TestData.project(id: phantomId, name: 'Yeni Kayıt', status: 'active');

      // Act
      await repository.updateProject(phantomId, project);

      // Assert
      final stored = repository.getProject(phantomId);
      expect(stored, isNotNull);
      expect(stored!.name, equals('Yeni Kayıt'));
    });
  });

  group('deleteProject', () {
    test('Projeyi kutudan kaldırmalı', () async {
      // Arrange
      final id = await repository.createProject(TestData.project(name: 'Silinecek'));

      // Act
      await repository.deleteProject(id);

      // Assert
      expect(repository.getProject(id), isNull);
      expect(projectBox.length, equals(0));
    });

    test('Birden fazla projeden sadece hedef silinmeli', () async {
      // Arrange
      final ids = await Future.wait([
        repository.createProject(TestData.project(name: 'P1')),
        repository.createProject(TestData.project(name: 'P2')),
        repository.createProject(TestData.project(name: 'P3')),
      ]);

      // Act
      await repository.deleteProject(ids[1]);

      // Assert
      expect(repository.getProject(ids[0]), isNotNull);
      expect(repository.getProject(ids[1]), isNull);
      expect(repository.getProject(ids[2]), isNotNull);
      expect(projectBox.length, equals(2));
    });

    test('Olmayan ID silinmeye çalışıldığında hata fırlatmamalı', () async {
      // Act & Assert
      expect(repository.deleteProject(999), completes);
      expect(projectBox.length, equals(0));
    });
  });

  group('searchProjects', () {
    test('İsme göre arama case-insensitive çalışmalı', () async {
      // Arrange
      await repository.createProject(TestData.project(name: 'Villa İnşaatı'));
      await repository.createProject(TestData.project(name: 'Apartman Tadilat'));
      await repository.createProject(TestData.project(name: 'VİLLA Yenileme'));

      // Act
      final results = repository.searchProjects('villa');

      // Assert
      expect(results, hasLength(2));
      expect(results.every((p) => p.name.toLowerCase().contains('villa')), isTrue);
    });

    test('Boş string sorgusu tüm projeleri döndürmeli', () async {
      // Arrange
      await repository.createProject(TestData.project(name: 'Proje 1'));
      await repository.createProject(TestData.project(name: 'Proje 2'));

      // Act
      final results = repository.searchProjects('');

      // Assert
      expect(results, hasLength(2));
    });

    test('Eşleşme yoksa boş liste dönmeli', () async {
      // Arrange
      await repository.createProject(TestData.project(name: 'Sadece Bu'));

      // Act
      final results = repository.searchProjects('Bulunamayacak');

      // Assert
      expect(results, isEmpty);
    });
  });

  group('getProjectCount', () {
    test('Boş kutu için 0 döndürmeli', () {
      // Act & Assert
      expect(repository.getProjectCount(), equals(0));
    });

    test('Ekleme ve silme sonrası sayı güncel olmalı', () async {
      // Arrange
      final id1 = await repository.createProject(TestData.project(name: 'Proje A'));
      final id2 = await repository.createProject(TestData.project(name: 'Proje B'));
      expect(repository.getProjectCount(), equals(2));

      // Act
      await repository.deleteProject(id1);

      // Assert
      expect(repository.getProjectCount(), equals(1));

      await repository.deleteProject(id2);
      expect(repository.getProjectCount(), equals(0));
    });
  });

  group('Edge cases', () {
    test('Çok uzun ve çok dilli isimler sorunsuz kaydedilmeli', () async {
      // Arrange
      final longName = TestData.longMultilingualProjectName();

      // Act
      final id = await repository.createProject(
        TestData.project(name: longName, startDate: '2024-01-01'),
      );
      final stored = repository.getProject(id)!;

      // Assert
      expect(stored.name, equals(longName));
    });

    test('Start date boş olduğunda bile veri saklanmalı', () async {
      // Arrange
      final project = Project(name: 'Boş Tarihli', startDate: '');

      // Act
      final id = await repository.createProject(project);

      // Assert
      final stored = repository.getProject(id)!;
      expect(stored.startDate, equals(''));
    });

    test('Paralel eklenen projelerin sayısı doğru olmalı', () async {
      // Arrange
      final futures = List.generate(
        10,
        (index) => repository.createProject(TestData.project(name: 'Proje $index')),
      );

      // Act
      await Future.wait(futures);

      // Assert
      expect(repository.getProjectCount(), equals(10));
    });

    test('Büyük veri seti performansı kabul edilebilir olmalı', () async {
      // Arrange
      final count = 250;
      for (var i = 0; i < count; i++) {
        await repository.createProject(
          TestData.project(name: 'Proje $i', startDate: '2024-01-01'),
        );
      }

      // Act
      final stopwatch = Stopwatch()..start();
      final projects = repository.getAllProjects();
      stopwatch.stop();

      // Assert
      expect(projects, hasLength(count));
      expect(stopwatch.elapsedMilliseconds, lessThan(750));
    });

    test('Random ID ile create çağrısı sonrası veriler tutarlı kalmalı', () async {
      // Arrange
      final random = Random();
      final project = TestData.project(name: 'Rastgele', patronKey: random.nextInt(1000));

      // Act
      final id = await repository.createProject(project);

      // Assert
      final stored = repository.getProject(id)!;
      expect(stored.patronKey, equals(project.patronKey));
    });
  });
}
