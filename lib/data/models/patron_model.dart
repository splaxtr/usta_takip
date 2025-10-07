import 'package:hive/hive.dart';

part 'patron_model.g.dart';

@HiveType(typeId: 6)
class PatronModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name; // Şirket adı veya şahıs adı

  @HiveField(2)
  String? surname; // Şahıs ise soyadı

  @HiveField(3)
  PatronType type; // Şahıs veya şirket

  @HiveField(4)
  String phone;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? address;

  @HiveField(7)
  String? taxOffice; // Vergi dairesi

  @HiveField(8)
  String? taxNumber; // Vergi numarası

  @HiveField(9)
  String? tcKimlikNo; // TC Kimlik No (şahıs ise)

  @HiveField(10)
  String? companyName; // Şirket adı (firma ise)

  @HiveField(11)
  String? authorizedPerson; // Yetkili kişi (firma ise)

  @HiveField(12)
  String? iban; // IBAN

  @HiveField(13)
  String? notes; // Notlar

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime? updatedAt;

  @HiveField(16)
  bool isActive; // Aktif mi?

  @HiveField(17)
  List<String> projectIds; // Patron'un projeleri

  PatronModel({
    required this.id,
    required this.name,
    this.surname,
    this.type = PatronType.individual,
    required this.phone,
    this.email,
    this.address,
    this.taxOffice,
    this.taxNumber,
    this.tcKimlikNo,
    this.companyName,
    this.authorizedPerson,
    this.iban,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    List<String>? projectIds,
  }) : projectIds = projectIds ?? [];

  // JSON'dan model oluştur
  factory PatronModel.fromJson(Map<String, dynamic> json) {
    return PatronModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String?,
      type: PatronType.values.firstWhere(
        (e) => e.toString() == 'PatronType.${json['type']}',
        orElse: () => PatronType.individual,
      ),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      taxOffice: json['taxOffice'] as String?,
      taxNumber: json['taxNumber'] as String?,
      tcKimlikNo: json['tcKimlikNo'] as String?,
      companyName: json['companyName'] as String?,
      authorizedPerson: json['authorizedPerson'] as String?,
      iban: json['iban'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      projectIds: (json['projectIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'type': type.toString().split('.').last,
      'phone': phone,
      'email': email,
      'address': address,
      'taxOffice': taxOffice,
      'taxNumber': taxNumber,
      'tcKimlikNo': tcKimlikNo,
      'companyName': companyName,
      'authorizedPerson': authorizedPerson,
      'iban': iban,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'projectIds': projectIds,
    };
  }

  // Model kopyalama
  PatronModel copyWith({
    String? id,
    String? name,
    String? surname,
    PatronType? type,
    String? phone,
    String? email,
    String? address,
    String? taxOffice,
    String? taxNumber,
    String? tcKimlikNo,
    String? companyName,
    String? authorizedPerson,
    String? iban,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? projectIds,
  }) {
    return PatronModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      taxOffice: taxOffice ?? this.taxOffice,
      taxNumber: taxNumber ?? this.taxNumber,
      tcKimlikNo: tcKimlikNo ?? this.tcKimlikNo,
      companyName: companyName ?? this.companyName,
      authorizedPerson: authorizedPerson ?? this.authorizedPerson,
      iban: iban ?? this.iban,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      projectIds: projectIds ?? this.projectIds,
    );
  }

  // Tam ad (şahıs ise)
  String get fullName {
    if (type == PatronType.individual && surname != null) {
      return '$name $surname';
    }
    return name;
  }

  // Görünüm adı
  String get displayName {
    if (type == PatronType.company) {
      return companyName ?? name;
    }
    return fullName;
  }

  // Şahıs mı?
  bool get isIndividual => type == PatronType.individual;

  // Şirket mi?
  bool get isCompany => type == PatronType.company;

  @override
  String toString() {
    return 'PatronModel(id: $id, displayName: $displayName, type: $type, isActive: $isActive)';
  }
}

@HiveType(typeId: 7)
enum PatronType {
  @HiveField(0)
  individual, // Şahıs

  @HiveField(1)
  company, // Şirket
}
