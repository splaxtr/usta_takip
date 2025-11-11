import 'package:usta_takip_app/core/models/project_model.dart';

/// Test için tip güvenli ve JSON tabanlı fixture üreticileri.
class TestData {
  /// Proje modeli için varsayılan factory.
  static Project project({
    int? id,
    String? name,
    String? startDate,
    int? patronKey,
    String? status,
    String? imageUrl,
  }) {
    return Project(
      id: id,
      name: name ?? 'Test Projesi',
      startDate: startDate ?? '2024-01-01',
      patronKey: patronKey,
      status: status ?? 'active',
      imageUrl: imageUrl,
    );
  }

  /// JSON karşılığına ihtiyaç duyan testler için helper.
  static Map<String, dynamic> projectJson({
    String? name,
    String? startDate,
    int? patronKey,
    String? status,
    String? imageUrl,
  }) {
    return project(
      name: name,
      startDate: startDate,
      patronKey: patronKey,
      status: status,
      imageUrl: imageUrl,
    ).toJson();
  }

  /// Birden fazla proje modeli üretir.
  static List<Project> projectList() {
    return [
      project(name: 'Villa İnşaatı', startDate: '2024-01-15'),
      project(name: 'Apartman Tadilat', startDate: '2024-02-01', status: 'completed'),
      project(name: 'Ofis Yenileme', startDate: '2024-03-10'),
    ];
  }

  /// JSON formatında birden fazla proje.
  static List<Map<String, dynamic>> projectJsonList() {
    return projectList().map((p) => p.toJson()).toList();
  }

  /// Null veya boş alanlar içeren proje JSON'u (edge case).
  static Map<String, dynamic> projectJsonWithNulls() {
    return {
      'name': '',
      'startDate': '',
      'patronKey': null,
      'status': null,
      'imageUrl': null,
    };
  }

  /// Çok uzun metin, Türkçe karakter ve özel karakter içeren proje isimleri.
  static String longMultilingualProjectName() {
    return 'Şehir İçi İnşaat Çalışması – Çok Uzun Başlık ' * 5;
  }

  /// Finansal testler için ekstrem değerler.
  static double extremePositiveAmount() => 999999999999.99;
  static double extremeNegativeAmount() => -999999.99;

  // Bölümler arasında geriye dönük uyumluluk için mevcut fonksiyonlar.
  static Map<String, dynamic> sampleProject({
    String? name,
    String? startDate,
    int? patronKey,
    String? status,
  }) =>
      projectJson(name: name, startDate: startDate, patronKey: patronKey, status: status);

  static List<Map<String, dynamic>> multipleProjects() => projectJsonList();

  // --- Çalışan verileri ---
  static Map<String, dynamic> sampleEmployee({
    String? name,
    String? phone,
    String? createdAt,
  }) {
    return {
      'name': name ?? 'Ahmet Yılmaz',
      'phone': phone ?? '05551234567',
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> multipleEmployees() {
    return [
      sampleEmployee(name: 'Mehmet Demir', phone: '05551111111'),
      sampleEmployee(name: 'Ali Kara', phone: '05552222222'),
      sampleEmployee(name: 'Veli Ak', phone: '05553333333'),
    ];
  }

  // --- Patron verileri ---
  static Map<String, dynamic> samplePatron({
    String? name,
    String? company,
    String? phone,
    String? email,
  }) {
    return {
      'name': name ?? 'İbrahim Bey',
      'company': company ?? 'ABC İnşaat',
      'phone': phone ?? '05559876543',
      'email': email ?? 'ibrahim@example.com',
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // --- Mesai verileri ---
  static Map<String, dynamic> sampleShift({
    int? projectKey,
    int? employeeKey,
    List<Map<String, dynamic>>? workDetails,
    List<Map<String, dynamic>>? payments,
  }) {
    return {
      'projectKey': projectKey ?? 0,
      'employeeKey': employeeKey ?? 0,
      'workDays': workDetails?.length ?? 0,
      'createdAt': DateTime.now().toIso8601String(),
      'workDetails': workDetails ?? [],
      'payments': payments ?? [],
      'isPaid': false,
      'totalPaid': 0.0,
    };
  }

  static Map<String, dynamic> sampleWorkDetail({
    String? date,
    String? type,
    double? wage,
    String? note,
  }) {
    return {
      'date': date ?? '2024-01-01',
      'type': type ?? 'full',
      'wage': wage ?? 500.0,
      'note': note ?? '',
    };
  }

  // --- Finans verileri ---
  static Map<String, dynamic> sampleIncome({
    int? projectKey,
    double? amount,
    String? date,
    String? description,
    String? category,
  }) {
    return {
      'projectKey': projectKey ?? 0,
      'type': 'gelir',
      'amount': amount ?? 10000.0,
      'date': date ?? DateTime.now().toIso8601String(),
      'description': description ?? 'Patron ödemesi',
      'category': category ?? 'Ödeme',
    };
  }

  static Map<String, dynamic> sampleExpense({
    int? projectKey,
    double? amount,
    String? category,
    String? date,
    String? description,
  }) {
    return {
      'projectKey': projectKey ?? 0,
      'type': 'gider',
      'amount': amount ?? 5000.0,
      'date': date ?? DateTime.now().toIso8601String(),
      'description': description ?? 'Malzeme alımı',
      'category': category ?? 'Malzeme',
    };
  }
}
