import 'package:mocktail/mocktail.dart';
import 'package:usta_takip_app/core/repositories/project_repository.dart';

import '../fixtures/test_data.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

/// Mocktail için fallback value kayıtlarını toplu yönetir.
void registerMockFallbacks() {
  try {
    registerFallbackValue(TestData.project());
  } on StateError {
    // Aynı tip ikinci kez kaydedilmeye çalışılırsa sessizce yoksay.
  }
}
