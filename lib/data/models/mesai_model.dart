import 'package:hive/hive.dart';

part 'mesai_model.g.dart';

@HiveType(typeId: 8)
class MesaiModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String employeeId; // Çalışan ID

  @HiveField(2)
  String projectId; // Proje ID

  @HiveField(3)
  DateTime date; // Mesai tarihi

  @HiveField(4)
  DateTime? checkInTime; // Giriş saati

  @HiveField(5)
  DateTime? checkOutTime; // Çıkış saati

  @HiveField(6)
  double? workHours; // Çalışma saati

  @HiveField(7)
  double dailyWage; // O gün için geçerli günlük ücret

  @HiveField(8)
  double totalPay; // Toplam ödeme

  @HiveField(9)
  MesaiType type; // Mesai tipi

  @HiveField(10)
  MesaiStatus status; // Mesai durumu

  @HiveField(11)
  String? notes; // Notlar

  @HiveField(12)
  bool isPaid; // Ödendi mi?

  @HiveField(13)
  DateTime? paidDate; // Ödeme tarihi

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime? updatedAt;

  @HiveField(16)
  String? location; // Çalışma yeri/konum

  MesaiModel({
    required this.id,
    required this.employeeId,
    required this.projectId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.workHours,
    required this.dailyWage,
    this.totalPay = 0.0,
    this.type = MesaiType.regular,
    this.status = MesaiStatus.pending,
    this.notes,
    this.isPaid = false,
    this.paidDate,
    required this.createdAt,
    this.updatedAt,
    this.location,
  });

  // JSON'dan model oluştur
  factory MesaiModel.fromJson(Map<String, dynamic> json) {
    return MesaiModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      projectId: json['projectId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'] as String)
          : null,
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'] as String)
          : null,
      workHours: (json['workHours'] as num?)?.toDouble(),
      dailyWage: (json['dailyWage'] as num?)?.toDouble() ?? 0.0,
      totalPay: (json['totalPay'] as num?)?.toDouble() ?? 0.0,
      type: MesaiType.values.firstWhere(
        (e) => e.toString() == 'MesaiType.${json['type']}',
        orElse: () => MesaiType.regular,
      ),
      status: MesaiStatus.values.firstWhere(
        (e) => e.toString() == 'MesaiStatus.${json['status']}',
        orElse: () => MesaiStatus.pending,
      ),
      notes: json['notes'] as String?,
      isPaid: json['isPaid'] as bool? ?? false,
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      location: json['location'] as String?,
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'projectId': projectId,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'workHours': workHours,
      'dailyWage': dailyWage,
      'totalPay': totalPay,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'notes': notes,
      'isPaid': isPaid,
      'paidDate': paidDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'location': location,
    };
  }

  // Model kopyalama
  MesaiModel copyWith({
    String? id,
    String? employeeId,
    String? projectId,
    DateTime? date,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    double? workHours,
    double? dailyWage,
    double? totalPay,
    MesaiType? type,
    MesaiStatus? status,
    String? notes,
    bool? isPaid,
    DateTime? paidDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
  }) {
    return MesaiModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      workHours: workHours ?? this.workHours,
      dailyWage: dailyWage ?? this.dailyWage,
      totalPay: totalPay ?? this.totalPay,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
    );
  }

  // Çalışma saatini hesapla
  double calculateWorkHours() {
    if (checkInTime == null || checkOutTime == null) return 0.0;
    final duration = checkOutTime!.difference(checkInTime!);
    return duration.inMinutes / 60.0;
  }

  // Toplam ücreti hesapla
  double calculateTotalPay() {
    double hours = workHours ?? calculateWorkHours();

    // Mesai tipine göre katsayı
    double multiplier = 1.0;
    switch (type) {
      case MesaiType.regular:
        multiplier = 1.0;
        break;
      case MesaiType.overtime:
        multiplier = 1.5; // Fazla mesai %50 fazla
        break;
      case MesaiType.weekend:
        multiplier = 2.0; // Hafta sonu çift ücret
        break;
      case MesaiType.holiday:
        multiplier = 2.5; // Tatil günleri 2.5x ücret
        break;
    }

    return (dailyWage / 8.0) *
        hours *
        multiplier; // 8 saatlik iş günü varsayımı
  }

  // Onaylandı mı?
  bool get isApproved => status == MesaiStatus.approved;

  // Reddedildi mi?
  bool get isRejected => status == MesaiStatus.rejected;

  // Beklemede mi?
  bool get isPending => status == MesaiStatus.pending;

  @override
  String toString() {
    return 'MesaiModel(id: $id, employeeId: $employeeId, date: $date, workHours: $workHours, totalPay: $totalPay)';
  }
}

@HiveType(typeId: 9)
enum MesaiType {
  @HiveField(0)
  regular, // Normal mesai

  @HiveField(1)
  overtime, // Fazla mesai

  @HiveField(2)
  weekend, // Hafta sonu

  @HiveField(3)
  holiday, // Tatil günü
}

@HiveType(typeId: 10)
enum MesaiStatus {
  @HiveField(0)
  pending, // Beklemede

  @HiveField(1)
  approved, // Onaylandı

  @HiveField(2)
  rejected, // Reddedildi
}
