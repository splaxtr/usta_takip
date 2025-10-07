import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 2)
class ProjectModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String patronId; // İşveren/Patron ID

  @HiveField(4)
  String? location; // Proje konumu/adresi

  @HiveField(5)
  ProjectStatus status;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  double budget; // Proje bütçesi

  @HiveField(9)
  List<String> employeeIds; // Çalışan ID'leri

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime? updatedAt;

  @HiveField(12)
  String? imageUrl; // Proje görseli

  @HiveField(13)
  String? notes; // Notlar

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    required this.patronId,
    this.location,
    this.status = ProjectStatus.planning,
    required this.startDate,
    this.endDate,
    this.budget = 0.0,
    List<String>? employeeIds,
    required this.createdAt,
    this.updatedAt,
    this.imageUrl,
    this.notes,
  }) : employeeIds = employeeIds ?? [];

  // JSON'dan model oluştur
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      patronId: json['patronId'] as String,
      location: json['location'] as String?,
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == 'ProjectStatus.${json['status']}',
        orElse: () => ProjectStatus.planning,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      employeeIds: (json['employeeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      imageUrl: json['imageUrl'] as String?,
      notes: json['notes'] as String?,
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'patronId': patronId,
      'location': location,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'budget': budget,
      'employeeIds': employeeIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  // Model kopyalama
  ProjectModel copyWith({
    String? id,
    String? name,
    String? description,
    String? patronId,
    String? location,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    List<String>? employeeIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
    String? notes,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      patronId: patronId ?? this.patronId,
      location: location ?? this.location,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      employeeIds: employeeIds ?? this.employeeIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
    );
  }

  // Proje devam ediyor mu?
  bool get isActive =>
      status == ProjectStatus.inProgress || status == ProjectStatus.planning;

  // Proje tamamlandı mı?
  bool get isCompleted => status == ProjectStatus.completed;

  // Proje süresi (gün)
  int get durationInDays {
    final end = endDate ?? DateTime.now();
    return end.difference(startDate).inDays;
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, name: $name, status: $status, budget: $budget)';
  }
}

@HiveType(typeId: 3)
enum ProjectStatus {
  @HiveField(0)
  planning, // Planlama aşamasında

  @HiveField(1)
  inProgress, // Devam ediyor

  @HiveField(2)
  onHold, // Beklemede

  @HiveField(3)
  completed, // Tamamlandı

  @HiveField(4)
  cancelled, // İptal edildi
}
