import 'package:flutter/material.dart';

/// Project Status Enum
enum ProjectStatus {
  planning('Planlamada', Colors.orange),
  inProgress('Devam Ediyor', Colors.blue),
  onHold('Beklemede', Colors.grey),
  completed('Tamamlandı', Colors.green),
  cancelled('İptal', Colors.red);

  final String label;
  final Color color;
  const ProjectStatus(this.label, this.color);
}

/// Standart Project Card
///
/// Kullanım:
/// ```dart
/// ProjectCard(
///   projectName: 'Konut Projesi A',
///   location: 'İstanbul, Türkiye',
///   status: ProjectStatus.inProgress,
///   progress: 0.65,
///   teamSize: 12,
///   dueDate: DateTime.now().add(Duration(days: 30)),
///   onTap: () => _openProject(),
/// )
/// ```
class ProjectCard extends StatelessWidget {
  final String projectName;
  final String? location;
  final ProjectStatus status;
  final double? progress;
  final int? teamSize;
  final DateTime? dueDate;
  final String? budget;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const ProjectCard({
    super.key,
    required this.projectName,
    this.location,
    required this.status,
    this.progress,
    this.teamSize,
    this.dueDate,
    this.budget,
    this.onTap,
    this.onMoreTap,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: status.color,
                      ),
                    ),
                  ),
                  if (onMoreTap != null)
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: onMoreTap,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
              if (progress != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'İlerleme',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${(progress! * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: status.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: status.color.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                status.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  if (teamSize != null) ...[
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$teamSize',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (dueDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(dueDate!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (budget != null) ...[
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      budget!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact Project Card (Liste görünümü için)
///
/// Kullanım:
/// ```dart
/// CompactProjectCard(
///   projectName: 'Ofis Binası B',
///   status: ProjectStatus.planning,
///   progress: 0.25,
///   onTap: () => _openProject(),
/// )
/// ```
class CompactProjectCard extends StatelessWidget {
  final String projectName;
  final ProjectStatus status;
  final double? progress;
  final VoidCallback? onTap;

  const CompactProjectCard({
    super.key,
    required this.projectName,
    required this.status,
    this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: status.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (progress != null) ...[
                const SizedBox(width: 12),
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: status.color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(status.color),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: status.color,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid Project Card (Grid görünümü için)
///
/// Kullanım:
/// ```dart
/// GridProjectCard(
///   projectName: 'Alışveriş Merkezi',
///   status: ProjectStatus.inProgress,
///   progress: 0.55,
///   imageUrl: 'https://example.com/image.jpg',
///   onTap: () => _openProject(),
/// )
/// ```
class GridProjectCard extends StatelessWidget {
  final String projectName;
  final ProjectStatus status;
  final double? progress;
  final String? imageUrl;
  final IconData? placeholderIcon;
  final VoidCallback? onTap;

  const GridProjectCard({
    super.key,
    required this.projectName,
    required this.status,
    this.progress,
    this.imageUrl,
    this.placeholderIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: status.color.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : Center(
                        child: Icon(
                          placeholderIcon ?? Icons.apartment,
                          size: 48,
                          color: status.color.withOpacity(0.5),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (progress != null)
                        Text(
                          '${(progress! * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: status.color,
                          ),
                        ),
                    ],
                  ),
                  if (progress != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: status.color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(status.color),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detailed Project Card (Detaylı bilgi ile)
///
/// Kullanım:
/// ```dart
/// DetailedProjectCard(
///   projectName: 'Rezidans Projesi',
///   description: 'Lüks konut projesi',
///   status: ProjectStatus.inProgress,
///   progress: 0.68,
///   manager: 'Ahmet Yılmaz',
///   teamMembers: ['Ali', 'Ayşe', 'Mehmet'],
///   startDate: DateTime(2024, 1, 15),
///   dueDate: DateTime(2024, 12, 30),
///   budget: '₺5.000.000',
///   onTap: () => _openProject(),
/// )
/// ```
class DetailedProjectCard extends StatelessWidget {
  final String projectName;
  final String? description;
  final ProjectStatus status;
  final double? progress;
  final String? manager;
  final List<String>? teamMembers;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String? budget;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;

  const DetailedProjectCard({
    super.key,
    required this.projectName,
    this.description,
    required this.status,
    this.progress,
    this.manager,
    this.teamMembers,
    this.startDate,
    this.dueDate,
    this.budget,
    this.onTap,
    this.onEditTap,
  });

  String _formatDate(DateTime date) {
    final months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      projectName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (onEditTap != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: onEditTap,
                    ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: status.color,
                      ),
                    ),
                  ),
                  if (progress != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      '${(progress! * 100).toInt()}% tamamlandı',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              if (progress != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: status.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(status.color),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              if (manager != null)
                _buildInfoRow(
                  Icons.person_outline,
                  'Proje Müdürü',
                  manager!,
                ),
              if (teamMembers != null && teamMembers!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.people_outline,
                  'Ekip',
                  '${teamMembers!.length} üye',
                ),
              ],
              if (startDate != null || dueDate != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Tarih',
                  '${startDate != null ? _formatDate(startDate!) : "?"} - ${dueDate != null ? _formatDate(dueDate!) : "?"}',
                ),
              ],
              if (budget != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.payments_outlined,
                  'Bütçe',
                  budget!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Minimal Project Card
///
/// Kullanım:
/// ```dart
/// MinimalProjectCard(
///   projectName: 'Proje Adı',
///   status: ProjectStatus.inProgress,
///   onTap: () => _openProject(),
/// )
/// ```
class MinimalProjectCard extends StatelessWidget {
  final String projectName;
  final ProjectStatus status;
  final VoidCallback? onTap;

  const MinimalProjectCard({
    super.key,
    required this.projectName,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  projectName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kullanım örnekleri:
///
/// ```dart
/// // Standart project card
/// ProjectCard(
///   projectName: 'Konut Projesi A',
///   location: 'İstanbul, Kadıköy',
///   status: ProjectStatus.inProgress,
///   progress: 0.65,
///   teamSize: 12,
///   dueDate: DateTime.now().add(Duration(days: 30)),
///   budget: '₺2.500.000',
///   onTap: () => Navigator.push(...),
/// )
///
/// // Compact card (liste için)
/// CompactProjectCard(
///   projectName: 'Ofis Binası B',
///   status: ProjectStatus.planning,
///   progress: 0.25,
///   onTap: () => _openProject(),
/// )
///
/// // Grid card
/// GridProjectCard(
///   projectName: 'Alışveriş Merkezi',
///   status: ProjectStatus.inProgress,
///   progress: 0.55,
///   imageUrl: 'https://example.com/project.jpg',
///   onTap: () => _openProject(),
/// )
///
/// // Detailed card
/// DetailedProjectCard(
///   projectName: 'Rezidans Projesi',
///   description: 'Lüks 150 daireli konut projesi',
///   status: ProjectStatus.inProgress,
///   progress: 0.68,
///   manager: 'Ahmet Yılmaz',
///   teamMembers: ['Ali', 'Ayşe', 'Mehmet'],
///   budget: '₺5.000.000',
///   onTap: () => _openProject(),
/// )
///
/// // Minimal card
/// MinimalProjectCard(
///   projectName: 'Köprü Projesi',
///   status: ProjectStatus.planning,
///   onTap: () => _openProject(),
/// )
/// ```
