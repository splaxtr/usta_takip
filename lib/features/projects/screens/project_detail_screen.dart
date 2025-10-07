import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_helper.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/patron_model.dart';
import '../../../data/services/hive_service.dart';
import '../widgets/project_info_card.dart';
import '../widgets/employee_assignment_card.dart';
import '../widgets/financial_summary_card.dart';

/// Proje detay ekranı
class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late ProjectModel _project;
  late TabController _tabController;
  PatronModel? _patron;

  @override
  void initState() {
    super.initState();
    _project = widget.project;
    _tabController = TabController(length: 3, vsync: this);
    _loadPatronInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPatronInfo() {
    final patron = HiveService.getPatron(_project.patronId);
    setState(() {
      _patron = patron;
    });
  }

  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Projeyi Sil'),
        content: Text(
          '${_project.name} isimli projeyi silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (result == true) {
      await HiveService.deleteProject(_project.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _changeStatus(ProjectStatus newStatus) async {
    setState(() {
      _project = _project.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
    });
    await HiveService.updateProject(_project);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Proje durumu güncellendi: ${_getStatusText(newStatus)}'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project.name),
        actions: [
          // Durum değiştirme menüsü
          PopupMenuButton<ProjectStatus>(
            icon: const Icon(Icons.more_vert),
            onSelected: _changeStatus,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ProjectStatus.planning,
                child: Row(
                  children: [
                    Icon(Icons.schedule,
                        color: _getStatusColor(ProjectStatus.planning)),
                    const SizedBox(width: AppSizes.spaceSm),
                    const Text('Planlamaya Al'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ProjectStatus.inProgress,
                child: Row(
                  children: [
                    Icon(Icons.play_arrow,
                        color: _getStatusColor(ProjectStatus.inProgress)),
                    const SizedBox(width: AppSizes.spaceSm),
                    const Text('Başlat'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ProjectStatus.onHold,
                child: Row(
                  children: [
                    Icon(Icons.pause,
                        color: _getStatusColor(ProjectStatus.onHold)),
                    const SizedBox(width: AppSizes.spaceSm),
                    const Text('Beklet'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ProjectStatus.completed,
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: _getStatusColor(ProjectStatus.completed)),
                    const SizedBox(width: AppSizes.spaceSm),
                    const Text('Tamamla'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: ProjectStatus.cancelled,
                child: Row(
                  children: [
                    Icon(Icons.cancel,
                        color: _getStatusColor(ProjectStatus.cancelled)),
                    const SizedBox(width: AppSizes.spaceSm),
                    const Text('İptal Et'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Düzenleme özelliği yakında...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Genel', icon: Icon(Icons.info_outline)),
            Tab(text: 'Ekip', icon: Icon(Icons.people_outline)),
            Tab(text: 'Finans', icon: Icon(Icons.payments_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Genel Bilgiler Sekmesi
          _buildGeneralTab(),

          // Ekip Sekmesi
          _buildTeamTab(),

          // Finans Sekmesi
          _buildFinanceTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Proje Bilgi Kartı
          ProjectInfoCard(
            project: _project,
            patron: _patron,
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // Tarih Bilgileri
          _buildSection(
            title: 'Tarih Bilgileri',
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.calendar_today,
                  label: 'Başlangıç',
                  value: DateHelper.formatDate(_project.startDate),
                ),
                if (_project.endDate != null) ...[
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.event,
                    label: 'Bitiş',
                    value: DateHelper.formatDate(_project.endDate),
                  ),
                ],
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.timelapse,
                  label: 'Süre',
                  value: '${_project.durationInDays} gün',
                ),
              ],
            ),
          ),

          if (_project.notes != null && _project.notes!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.spaceMd),
            _buildSection(
              title: 'Notlar',
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                child: Text(
                  _project.notes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: EmployeeAssignmentCard(
        project: _project,
        onEmployeesChanged: (updatedProject) {
          setState(() {
            _project = updatedProject;
          });
        },
      ),
    );
  }

  Widget _buildFinanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: FinancialSummaryCard(
        project: _project,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconSm,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planlama';
      case ProjectStatus.inProgress:
        return 'Devam Ediyor';
      case ProjectStatus.onHold:
        return 'Beklemede';
      case ProjectStatus.completed:
        return 'Tamamlandı';
      case ProjectStatus.cancelled:
        return 'İptal';
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return AppColors.info;
      case ProjectStatus.inProgress:
        return AppColors.success;
      case ProjectStatus.onHold:
        return AppColors.warning;
      case ProjectStatus.completed:
        return AppColors.primary;
      case ProjectStatus.cancelled:
        return AppColors.error;
    }
  }
}
