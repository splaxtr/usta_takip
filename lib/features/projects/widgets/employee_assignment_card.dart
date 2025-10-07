import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/hive_service.dart';

/// Çalışan atama kartı widget'ı
///
/// Projeye atanan çalışanları gösterir ve yeni çalışan ekleme/çıkarma
class EmployeeAssignmentCard extends StatefulWidget {
  final ProjectModel project;
  final Function(ProjectModel)? onEmployeesChanged;

  const EmployeeAssignmentCard({
    super.key,
    required this.project,
    this.onEmployeesChanged,
  });

  @override
  State<EmployeeAssignmentCard> createState() => _EmployeeAssignmentCardState();
}

class _EmployeeAssignmentCardState extends State<EmployeeAssignmentCard> {
  late List<String> _assignedEmployeeIds;
  List<EmployeeModel> _assignedEmployees = [];
  List<EmployeeModel> _availableEmployees = [];

  @override
  void initState() {
    super.initState();
    _assignedEmployeeIds = List.from(widget.project.employeeIds);
    _loadEmployees();
  }

  void _loadEmployees() {
    final allEmployees = HiveService.getActiveEmployees();

    setState(() {
      _assignedEmployees = allEmployees
          .where((e) => _assignedEmployeeIds.contains(e.id))
          .toList();

      _availableEmployees = allEmployees
          .where((e) => !_assignedEmployeeIds.contains(e.id))
          .toList();
    });
  }

  Future<void> _showAddEmployeeDialog() async {
    if (_availableEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eklenebilecek aktif çalışan yok'),
        ),
      );
      return;
    }

    final selectedEmployee = await showDialog<EmployeeModel>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çalışan Ekle'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _availableEmployees.length,
            itemBuilder: (context, index) {
              final employee = _availableEmployees[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    employee.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(employee.fullName),
                subtitle: Text(employee.position),
                trailing: Text(
                  NumberHelper.formatCurrency(employee.dailyWage),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, employee);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );

    if (selectedEmployee != null) {
      _addEmployee(selectedEmployee);
    }
  }

  Future<void> _addEmployee(EmployeeModel employee) async {
    setState(() {
      _assignedEmployeeIds.add(employee.id);
    });

    _loadEmployees();
    await _updateProject();
  }

  Future<void> _removeEmployee(String employeeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çalışanı Çıkar'),
        content: const Text(
            'Bu çalışanı projeden çıkarmak istediğinizden emin misiniz?'),
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
            child: const Text('Çıkar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _assignedEmployeeIds.remove(employeeId);
      });

      _loadEmployees();
      await _updateProject();
    }
  }

  Future<void> _updateProject() async {
    final updatedProject = widget.project.copyWith(
      employeeIds: _assignedEmployeeIds,
      updatedAt: DateTime.now(),
    );

    await HiveService.updateProject(updatedProject);

    if (widget.onEmployeesChanged != null) {
      widget.onEmployeesChanged!(updatedProject);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proje ekibi güncellendi'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Expanded(
                  child: Text(
                    'Proje Ekibi (${_assignedEmployees.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _showAddEmployeeDialog,
                  icon: const Icon(Icons.add, size: AppSizes.iconSm),
                  label: const Text('Ekle'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Liste
          if (_assignedEmployees.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingXl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.group_off,
                      size: 60,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(height: AppSizes.spaceSm),
                    Text(
                      'Henüz çalışan atanmadı',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spaceSm),
                    ElevatedButton.icon(
                      onPressed: _showAddEmployeeDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('İlk Çalışanı Ekle'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _assignedEmployees.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final employee = _assignedEmployees[index];
                return _buildEmployeeListTile(employee);
              },
            ),

          // Footer - Özet
          if (_assignedEmployees.isNotEmpty) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMd),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Toplam Günlük Maliyet:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    NumberHelper.formatCurrency(_calculateTotalDailyWage()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmployeeListTile(EmployeeModel employee) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.success.withOpacity(0.1),
        backgroundImage: employee.avatarUrl != null
            ? NetworkImage(employee.avatarUrl!)
            : null,
        child: employee.avatarUrl == null
            ? Text(
                employee.name[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        employee.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(employee.position),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberHelper.formatCurrency(employee.dailyWage),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
              const Text(
                'günlük',
                style: TextStyle(
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.error,
            onPressed: () => _removeEmployee(employee.id),
            tooltip: 'Çıkar',
          ),
        ],
      ),
    );
  }

  double _calculateTotalDailyWage() {
    return _assignedEmployees.fold(
      0.0,
      (sum, employee) => sum + employee.dailyWage,
    );
  }
}
