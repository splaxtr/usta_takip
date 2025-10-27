/// Proje model sınıfı
class Project {
  final int? id;
  final String name;
  final String startDate;
  final int? patronKey;
  final String status;
  final String? imageUrl;

  Project({
    this.id,
    required this.name,
    required this.startDate,
    this.patronKey,
    this.status = 'active',
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate,
      'patronKey': patronKey,
      'status': status,
      'imageUrl': imageUrl,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json, {int? id}) {
    return Project(
      id: id,
      name: json['name'] as String,
      startDate: json['startDate'] as String,
      patronKey: json['patronKey'] as int?,
      status: json['status'] as String? ?? 'active',
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Project copyWith({
    int? id,
    String? name,
    String? startDate,
    int? patronKey,
    String? status,
    String? imageUrl,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      patronKey: patronKey ?? this.patronKey,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
