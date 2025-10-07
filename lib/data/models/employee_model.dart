import 'package:hive/hive.dart';

part 'employee_model.g.dart';

@HiveType(typeId: 4)
class EmployeeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String surname;

  @HiveField(3)
  String? tcKimlikNo;

  @HiveField(4)
  String phone;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? address;

  @HiveField(7)
  DateTime? birthDate;

  @HiveField(8)
  String? avatarUrl;

  @HiveField(9)
  String position; // Pozisyon/Görev (Ör: Usta, Kalfa, İşçi)

  @HiveField(10)
  double dailyWage; // Günlük ücret

  @HiveField(11)
  EmployeeStatus status;

  @HiveField(12)
  DateTime hireDate; // İşe başlama tarihi

  @HiveField(13)
  DateTime? terminationDate; // İşten çıkış tarihi

  @HiveField(14)
  String? notes; // Notlar

  @HiveField(15)
  DateTime createdAt;

  @HiveField(16)
  DateTime? updatedAt;

  @HiveField(17)
  String? emergencyContactName; // Acil durum kişisi

  @HiveField(18)
  String? emergencyContactPhone; // Acil durum telefonu

  EmployeeModel({
    required this.id,
    required this.name,
    required this.surname,
    this.tcKimlikNo,
    required this.phone,
    this.email,
    this.address,
    this.birthDate,
    this.avatarUrl,
    required this.position,
    this.dailyWage = 0.0,
    this.status = EmployeeStatus.active,
    required this.hireDate,
    this.terminationDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.emergencyContactName,
    this.emergencyContactPhone,
  });

  // JSON'dan model oluştur
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String,
      tcKimlikNo: json['tcKimlikNo'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      position: json['position'] as String,
      dailyWage: (json['dailyWage'] as num?)?.toDouble() ?? 0.0,
      status: EmployeeStatus.values.firstWhere(
        (e) => e.toString() == 'EmployeeStatus.${json['status']}',
        orElse: () => EmployeeStatus.active,
      ),
      hireDate: DateTime.parse(json['hireDate'] as String),
      terminationDate: json['terminationDate'] != null
          ? DateTime.parse(json['terminationDate'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'tcKimlikNo': tcKimlikNo,
      'phone': phone,
      'email': email,
      'address': address,
      'birthDate': birthDate?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'position': position,
      'dailyWage': dailyWage,
      'status': status.toString().split('.').last,
      'hireDate': hireDate.toIso8601String(),
      'terminationDate': terminationDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
    };
  }

  // Model kopyalama
  EmployeeModel copyWith({
    String? id,
    String? name,
    String? surname,
    String? tcKimlikNo,
    String? phone,
    String? email,
    String? address,
    DateTime? birthDate,
    String? avatarUrl,
    String? position,
    double? dailyWage,
    EmployeeStatus? status,
    DateTime? hireDate,
    DateTime? terminationDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      tcKimlikNo: tcKimlikNo ?? this.tcKimlikNo,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      position: position ?? this.position,
      dailyWage: dailyWage ?? this.dailyWage,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
      terminationDate: terminationDate ?? this.terminationDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }

  // Tam ad
  String get fullName => '$name $surname';

  // Aktif mi?
  bool get isActive => status == EmployeeStatus.active;

  // Çalışma süresi (gün)
  int get workingDays {
    final endDate = terminationDate ?? DateTime.now();
    return endDate.difference(hireDate).inDays;
  }

  // Yaş hesapla
  int? get age {
    if (birthDate == null) return null;
    final today = DateTime.now();
    int age = today.year - birthDate!.year;
    if (today.month < birthDate!.month ||
        (today.month == birthDate!.month && today.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, fullName: $fullName, position: $position, status: $status)';
  }
}

@HiveType(typeId: 5)
enum EmployeeStatus {
  @HiveField(0)
  active, // Aktif

  @HiveField(1)
  onLeave, // İzinli

  @HiveField(2)
  terminated, // İşten ayrıldı

  @HiveField(3)
  suspended, // Askıda
}
