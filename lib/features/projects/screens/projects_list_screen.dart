import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/project_model.dart';
import '../../../data/services/hive_service.dart';
import 'add_project_screen.dart';
import 'project_detail_screen.dart';

/// Projeler listesi ekranı
class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  static const String routeName = '/projects';

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];
  final TextEditingController _searchController = TextEditingController();
  ProjectStatus? _selectedStatus;
  bool _showOnlyActive = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
    _searchController.addListener(_filterProjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final projects = HiveService.getProjects();

    setState(() {
      _projects = projects;
      _filteredProjects = projects;
      _isLoading = false;
    });

    _filterProjects();
  }

  void _filterProjects() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProjects = _projects.where((project) {
        final matchesSearch = project.name.toLowerCase().contains(query) ||
            (project.location?.toLowerCase().contains(query) ?? false) ||
            (project.description?.toLowerCase().contains(query) ?? false);

        final matchesStatus =
            _selectedStatus == null || project.status == _selectedStatus;

        final matchesActive = !_showOnlyActive || project.isActive;

        return matchesSearch && matchesStatus && matchesActive;
      }).toList();
    });
  }

  void _onStatusFilterChanged(ProjectStatus? status) {
    setState(() {
      _selectedStatus = status;
      _filterProjects();
    });
  }

  void _toggleActiveFilter() {
    setState(() {
      _showOnlyActive = !_showOnlyActive;
      _filterProjects();
    });
  }

  Future<void> _navigateToAddProject() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProjectScreen(),
      ),
    );

    if (result == true) {
      _loadProjects();
    }
  }

  Future<void> _navigateToProjectDetail(ProjectModel project) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );

    if (result == true) {
      _loadProjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projeler'),
        actions: [
          IconButton(
            icon: Icon(
              _showOnlyActive ? Icons.filter_alt : Icons.filter_alt_off,
              color:
                  _showOnlyActive ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: _toggleActiveFilter,
            tooltip: _showOnlyActive ? 'Tümünü Göster' : 'Sadece Aktifler',
          ),
          if (_projects.isNotEmpty)
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingSm,
                    vertical: AppSizes.paddingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    '${_projects.where((p) => p.isActive).length} Aktif',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: AppSizes.fontSm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve filtre
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            color: AppColors.surface,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Proje adı, konum veya açıklama ara...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: AppSizes.spaceSm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tümü', null),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('Planlama', ProjectStatus.planning),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip(
                          'Devam Ediyor', ProjectStatus.inProgress),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('Beklemede', ProjectStatus.onHold),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('Tamamlandı', ProjectStatus.completed),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // İstatistikler
          if (_projects.isNotEmpty) _buildStatistics(),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProjects.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingMd),
                          itemCount: _filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = _filteredProjects[index];
                            return _buildProjectCard(project);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProject,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Proje'),
      ),
    );
  }

  Widget _buildFilterChip(String label, ProjectStatus? status) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _onStatusFilterChanged(selected ? status : null);
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatistics() {
    final totalBudget = _projects.fold<double>(
      0.0,
      (sum, project) => sum + project.budget,
    );

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.work_outline,
            label: 'Toplam',
            value: _projects.length.toString(),
            color: AppColors.primary,
          ),
          _buildStatItem(
            icon: Icons.trending_up,
            label: 'Devam Eden',
            value: _projects
                .where((p) => p.status == ProjectStatus.inProgress)
                .length
                .toString(),
            color: AppColors.success,
          ),
          _buildStatItem(
            icon: Icons.payments,
            label: 'Bütçe',
            value: NumberHelper.formatCompactShort(totalBudget),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSizes.iconMd),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontXs,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: () => _navigateToProjectDetail(project),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spaceSm),
                  _buildStatusBadge(project.status),
                ],
              ),
              if (project.description != null) ...[
                const SizedBox(height: AppSizes.spaceXs),
                Text(
                  project.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                children: [
                  if (project.location != null) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: AppSizes.iconXs,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSizes.spaceXs),
                    Expanded(
                      child: Text(
                        project.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSizes.spaceSm),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: AppSizes.iconSm,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.spaceXs),
                      Text(
                        '${project.employeeIds.length} Çalışan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Text(
                    NumberHelper.formatCurrency(project.budget),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ProjectStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
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

  Widget _buildEmptyState() {
    final hasSearchQuery = _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off : Icons.work_outline,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              hasSearchQuery ? 'Sonuç bulunamadı' : 'Henüz proje kaydı yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              hasSearchQuery
                  ? 'Farklı bir arama terimi deneyin'
                  : 'İlk projeyi ekleyerek başlayın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearchQuery) ...[
              const SizedBox(height: AppSizes.spaceLg),
              ElevatedButton.icon(
                onPressed: _navigateToAddProject,
                icon: const Icon(Icons.add),
                label: const Text('İlk Projeyi Ekle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
