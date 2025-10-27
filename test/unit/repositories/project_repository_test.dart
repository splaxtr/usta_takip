import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:usta_takip_app/core/models/project_model.dart';
import 'package:usta_takip_app/core/repositories/project_repository.dart';
import '../../helpers/hive_test_helper.dart';
import '../../fixtures/test_data.dart';

void main() {
  late Box testBox;
  late ProjectRepository repository;

  setUpAll(() async {
    await HiveTestHelper.initHive();
  });

  setUp(() async {
    testBox = await HiveTestHelper.openBox('projects_test');
    repository = ProjectRepository(testBox);
  });

  tearDown(() async {
    await testBox.clear();
  });

  tearDownAll(() async {
    await HiveTestHelper.closeHive();
  });

  group('createProject', () {
    test('Yeni proje başarıyla oluşturulmalı', () async {
      // Arrange
      final project = Project(
        name: 'Test Projesi',
        startDate: '2024-01-01',
        patronKey: 1,
      );

      // Act
      final projectId = await repository.createProject(project);

      // Assert
      expect(projectId, isA<int>());
      expect(testBox.length, equals(1));
    });
  });

  group('getProject', () {
    test('Var olan projeyi getirmeli', () async {
      // Arrange
      final projectData = TestData.sampleProject();
      final projectId = await testBox.add(projectData);

      // Act
      final project = repository.getProject(projectId);

      // Assert
      expect(project, isNotNull);
      expect(project!.name, equals('Test Projesi'));
    });

    test('Olmayan ID için null döndürmeli', () {
      // Act
      final project = repository.getProject(999);

      // Assert
      expect(project, isNull);
    });
  });

  group('getAllProjects', () {
    test('Tüm projeleri listelemeli', () async {
      // Arrange
      final projects = TestData.multipleProjects();
      for (var p in projects) {
        await testBox.add(p);
      }

      // Act
      final result = repository.getAllProjects();

      // Assert
      expect(result.length, equals(3));
    });
  });

  group('updateProject', () {
    test('Projeyi güncellemeli', () async {
      // Arrange
      final project = Project(name: 'Eski', startDate: '2024-01-01');
      final id = await repository.createProject(project);

      // Act
      final updated = Project(name: 'Yeni', startDate: '2024-01-01');
      await repository.updateProject(id, updated);

      // Assert
      final result = repository.getProject(id);
      expect(result!.name, equals('Yeni'));
    });
  });

  group('deleteProject', () {
    test('Projeyi silmeli', () async {
      // Arrange
      final project = Project(name: 'Test', startDate: '2024-01-01');
      final id = await repository.createProject(project);

      // Act
      await repository.deleteProject(id);

      // Assert
      expect(repository.getProject(id), isNull);
    });

    test('Birden fazla projeden sadece belirtilen silinmeli', () async {
      // Arrange
      final id1 = await repository.createProject(Project(name: 'P1', startDate: '2024-01-01'));
      final id2 = await repository.createProject(Project(name: 'P2', startDate: '2024-01-02'));
      final id3 = await repository.createProject(Project(name: 'P3', startDate: '2024-01-03'));

      // Act
      await repository.deleteProject(id2);

      // Assert
      expect(repository.getProject(id1), isNotNull);
      expect(repository.getProject(id2), isNull);
      expect(repository.getProject(id3), isNotNull);
      expect(testBox.length, equals(2));
    });
  });

  group('getActiveProjects', () {
    test('Sadece aktif projeleri getirmeli', () async {
      // Arrange
      await repository.createProject(Project(name: 'Aktif 1', startDate: '2024-01-01', status: 'active'));
      await repository.createProject(Project(name: 'Tamamlanan', startDate: '2024-01-02', status: 'completed'));
      await repository.createProject(Project(name: 'Aktif 2', startDate: '2024-01-03', status: 'active'));

      // Act
      final activeProjects = repository.getActiveProjects();

      // Assert
      expect(activeProjects.length, equals(2));
      expect(activeProjects.every((p) => p.status == 'active'), isTrue);
    });

    test('Aktif proje yoksa boş liste döndürmeli', () async {
      // Arrange
      await repository.createProject(Project(name: 'Tamamlanan', startDate: '2024-01-01', status: 'completed'));

      // Act
      final activeProjects = repository.getActiveProjects();

      // Assert
      expect(activeProjects, isEmpty);
    });
  });

  group('searchProjects', () {
    test('İsme göre arama yapmalı (case-insensitive)', () async {
      // Arrange
      await repository.createProject(Project(name: 'Villa İnşaatı', startDate: '2024-01-01'));
      await repository.createProject(Project(name: 'Apartman Tadilat', startDate: '2024-01-02'));
      await repository.createProject(Project(name: 'Villa Yenileme', startDate: '2024-01-03'));

      // Act
      final results = repository.searchProjects('villa');

      // Assert
      expect(results.length, equals(2));
    });

    test('Eşleşme yoksa boş liste döndürmeli', () async {
      // Arrange
      await repository.createProject(Project(name: 'Test', startDate: '2024-01-01'));

      // Act
      final results = repository.searchProjects('Bulunamaz');

      // Assert
      expect(results, isEmpty);
    });

    test('Boş string ile tüm projeleri döndürmeli', () async {
      // Arrange
      await repository.createProject(Project(name: 'P1', startDate: '2024-01-01'));
      await repository.createProject(Project(name: 'P2', startDate: '2024-01-02'));

      // Act
      final results = repository.searchProjects('');

      // Assert
      expect(results.length, equals(2));
    });
  });

  group('Edge Cases', () {
    test('Çok uzun proje ismi kaydedilebilmeli', () async {
      // Arrange
      final longName = 'A' * 500;
      final project = Project(name: longName, startDate: '2024-01-01');

      // Act
      final id = await repository.createProject(project);
      final retrieved = repository.getProject(id);

      // Assert
      expect(retrieved!.name.length, equals(500));
    });

    test('Türkçe karakterler doğru işlenmeli', () async {
      // Arrange
      final project = Project(name: 'Şehir İçi İnşaat Çalışması', startDate: '2024-01-01');

      // Act
      final id = await repository.createProject(project);
      final retrieved = repository.getProject(id);

      // Assert
      expect(retrieved!.name, equals('Şehir İçi İnşaat Çalışması'));
    });

    test('Özel karakterler kaydedilebilmeli', () async {
      // Arrange
      final project = Project(name: 'Test!@#\$%^&*()', startDate: '2024-01-01');

      // Act
      final id = await repository.createProject(project);
      final retrieved = repository.getProject(id);

      // Assert
      expect(retrieved!.name, contains('!@#'));
    });

    test('Büyük veri seti - 100 proje performans testi', () async {
      // Arrange
      for (int i = 0; i < 100; i++) {
        await repository.createProject(Project(name: 'Proje $i', startDate: '2024-01-01'));
      }

      // Act
      final stopwatch = Stopwatch()..start();
      final projects = repository.getAllProjects();
      stopwatch.stop();

      // Assert
      expect(projects.length, equals(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Aynı isimde birden fazla proje oluşturulabilmeli', () async {
      // Arrange & Act
      final id1 = await repository.createProject(Project(name: 'Aynı', startDate: '2024-01-01'));
      final id2 = await repository.createProject(Project(name: 'Aynı', startDate: '2024-01-02'));

      // Assert
      expect(id1, isNot(equals(id2)));
      expect(testBox.length, equals(2));
    });

    test('copyWith metodunu kullanarak güncelleme', () async {
      // Arrange
      final project = Project(
        name: 'Orijinal',
        startDate: '2024-01-01',
        patronKey: 1,
        status: 'active',
      );
      final id = await repository.createProject(project);

      // Act
      final original = repository.getProject(id)!;
      final updated = original.copyWith(name: 'Değişti');
      await repository.updateProject(id, updated);

      // Assert
      final result = repository.getProject(id)!;
      expect(result.name, equals('Değişti'));
      expect(result.patronKey, equals(1)); // Değişmemeli
      expect(result.startDate, equals('2024-01-01')); // Değişmemeli
    });

    test('Olmayan projeyi silmeye çalışmak hata vermemeli', () async {
      // Act & Assert
      expect(() async => await repository.deleteProject(999), returnsNormally);
    });
  });

  group('getProjectCount', () {
    test('Boş box için 0 döndürmeli', () {
      expect(repository.getProjectCount(), equals(0));
    });

    test('Doğru sayıyı döndürmeli', () async {
      // Arrange
      for (int i = 0; i < 5; i++) {
        await repository.createProject(Project(name: 'P$i', startDate: '2024-01-01'));
      }

      // Act & Assert
      expect(repository.getProjectCount(), equals(5));
    });

    test('Ekleme/silme sonrası sayı güncel olmalı', () async {
      // Arrange & Act
      expect(repository.getProjectCount(), equals(0));

      final id = await repository.createProject(Project(name: 'Test', startDate: '2024-01-01'));
      expect(repository.getProjectCount(), equals(1));

      await repository.deleteProject(id);
      expect(repository.getProjectCount(), equals(0));
    });
  });
}
