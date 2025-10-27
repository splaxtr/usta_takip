/// Test için örnek veri setleri
class TestData {
  // Proje test verileri
  static Map<String, dynamic> sampleProject({
    String? name,
    String? startDate,
    int? patronKey,
    String? status,
  }) {
    return {
      'name': name ?? 'Test Projesi',
      'startDate': startDate ?? '2024-01-01',
      'patronKey': patronKey ?? 0,
      'status': status ?? 'active',
      'imageUrl': null,
    };
  }

  static List<Map<String, dynamic>> multipleProjects() {
    return [
      sampleProject(name: 'Villa İnşaatı', startDate: '2024-01-15'),
      sampleProject(name: 'Apartman Tadilat', startDate: '2024-02-01', status: 'completed'),
      sampleProject(name: 'Ofis Yenileme', startDate: '2024-03-10'),
    ];
  }

  // Çalışan test verileri
  static Map<String, dynamic> sampleEmployee({
    String? name,
    String? phone,
  }) {
    return {
      'name': name ?? 'Ahmet Yılmaz',
      'phone': phone ?? '05551234567',
      'createdAt': DateTime.now().toString(),
    };
  }

  static List<Map<String, dynamic>> multipleEmployees() {
    return [
      sampleEmployee(name: 'Mehmet Demir', phone: '05551111111'),
      sampleEmployee(name: 'Ali Kara', phone: '05552222222'),
      sampleEmployee(name: 'Veli Ak', phone: '05553333333'),
    ];
  }

  // Patron test verileri
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
      'createdAt': DateTime.now().toString(),
    };
  }

  // Mesai test verileri
  static Map<String, dynamic> sampleShift({
    int? projectKey,
    int? employeeKey,
    List? workDetails,
  }) {
    return {
      'projectKey': projectKey ?? 0,
      'employeeKey': employeeKey ?? 0,
      'workDays': workDetails?.length ?? 0,
      'createdAt': DateTime.now().toString(),
      'workDetails': workDetails ?? [],
      'payments': [],
      'isPaid': false,
      'totalPaid': 0.0,
    };
  }

  static Map<String, dynamic> sampleWorkDetail({
    String? date,
    String? type,
    double? wage,
  }) {
    return {
      'date': date ?? '01/01/2024',
      'type': type ?? 'full',
      'wage': wage ?? 500.0,
      'note': '',
    };
  }

  // Gelir/Gider test verileri
  static Map<String, dynamic> sampleIncome({
    int? projectKey,
    double? amount,
    String? date,
  }) {
    return {
      'projectKey': projectKey ?? 0,
      'type': 'gelir',
      'amount': amount ?? 10000.0,
      'date': date ?? DateTime.now().toString(),
      'description': 'Patron ödemesi',
      'category': 'Ödeme',
    };
  }

  static Map<String, dynamic> sampleExpense({
    int? projectKey,
    double? amount,
    String? category,
    String? date,
  }) {
    return {
      'projectKey': projectKey ?? 0,
      'type': 'gider',
      'amount': amount ?? 5000.0,
      'date': date ?? DateTime.now().toString(),
      'description': 'Malzeme alımı',
      'category': category ?? 'Malzeme',
    };
  }
}
