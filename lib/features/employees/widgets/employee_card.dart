import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/employee_model.dart';

/// Çalışan kartı widget'ı
///
/// Liste görünümünde her çalışan için gösterilen kart
class EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.marginMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),

              const SizedBox(width: AppSizes.spaceMd),

              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İsim ve durum
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            employee.fullName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSizes.spaceSm),
                        _buildStatusBadge(),
                      ],
                    ),

                    const SizedBox(height: AppSizes.spaceXs),

                    // Pozisyon
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: AppSizes.iconXs,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSizes.spaceXs),
                        Expanded(
                          child: Text(
                            employee.position,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSizes.spaceXs),

                    // Telefon ve Ücret
                    Row(
                      children: [
                        // Telefon
                        Icon(
                          Icons.phone_outlined,
                          size: AppSizes.iconXs,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSizes.spaceXs),
                        Text(
                          NumberHelper.formatPhone(employee.phone),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),

                        const SizedBox(width: AppSizes.spaceMd),

                        // Günlük ücret
                        Icon(
                          Icons.payments_outlined,
                          size: AppSizes.iconXs,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSizes.spaceXs),
                        Text(
                          NumberHelper.formatCurrency(employee.dailyWage),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ok ikonu
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: _getStatusColor(employee.status).withOpacity(0.1),
      backgroundImage:
          employee.avatarUrl != null ? NetworkImage(employee.avatarUrl!) : null,
      child: employee.avatarUrl == null
          ? Text(
              employee.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(employee.status),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(employee.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: _getStatusColor(employee.status).withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusText(employee.status),
        style: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(employee.status),
        ),
      ),
    );
  }

  String _getStatusText(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return 'Aktif';
      case EmployeeStatus.onLeave:
        return 'İzinli';
      case EmployeeStatus.terminated:
        return 'Ayrıldı';
      case EmployeeStatus.suspended:
        return 'Askıda';
    }
  }

  Color _getStatusColor(EmployeeStatus status) {
    switch (status) {
      case EmployeeStatus.active:
        return AppColors.success;
      case EmployeeStatus.onLeave:
        return AppColors.warning;
      case EmployeeStatus.terminated:
        return AppColors.error;
      case EmployeeStatus.suspended:
        return AppColors.textSecondary;
    }
  }
}

/// Kompakt çalışan kartı (daha küçük liste için)
class CompactEmployeeCard extends StatelessWidget {
  final EmployeeModel employee;
  final VoidCallback? onTap;
  final bool showPhone;
  final bool showWage;

  const CompactEmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
    this.showPhone = true,
    this.showWage = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        backgroundImage: employee.avatarUrl != null
            ? NetworkImage(employee.avatarUrl!)
            : null,
        child: employee.avatarUrl == null
            ? Text(
                employee.name[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
            : null,
      ),
      title: Text(
        employee.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(employee.position),
          if (showPhone)
            Text(
              NumberHelper.formatPhone(employee.phone),
              style: const TextStyle(fontSize: AppSizes.fontSm),
            ),
        ],
      ),
      trailing: showWage
          ? Column(
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
            )
          : null,
    );
  }
}

/// Çalışan seçici widget'ı (Dropdown gibi)
class EmployeeSelector extends StatelessWidget {
  final List<EmployeeModel> employees;
  final EmployeeModel? selectedEmployee;
  final ValueChanged<EmployeeModel?> onChanged;
  final String? hintText;
  final bool showOnlyActive;

  const EmployeeSelector({
    super.key,
    required this.employees,
    this.selectedEmployee,
    required this.onChanged,
    this.hintText,
    this.showOnlyActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final filteredEmployees = showOnlyActive
        ? employees.where((e) => e.isActive).toList()
        : employees;

    return DropdownButtonFormField<EmployeeModel>(
      value: selectedEmployee,
      decoration: InputDecoration(
        labelText: hintText ?? 'Çalışan Seçin',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
      items: filteredEmployees.map((employee) {
        return DropdownMenuItem<EmployeeModel>(
          value: employee,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  employee.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      employee.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      employee.position,
                      style: TextStyle(
                        fontSize: AppSizes.fontXs,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}
