import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/patron_model.dart';

/// Proje bilgi kartı widget'ı
///
/// Proje detaylarını gösteren kart
class ProjectInfoCard extends StatelessWidget {
  final ProjectModel project;
  final PatronModel? patron;

  const ProjectInfoCard({
    super.key,
    required this.project,
    this.patron,
  });

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
          // Header - Durum Badge
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor(project.status).withOpacity(0.8),
                  _getStatusColor(project.status),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSizes.radiusMd),
                topRight: Radius.circular(AppSizes.radiusMd),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(project.status),
                  color: Colors.white,
                  size: AppSizes.iconLg,
                ),
                const SizedBox(width: AppSizes.spaceSm),
                Text(
                  _getStatusText(project.status),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Proje Adı
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),

                if (project.description != null) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  Text(
                    project.description!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],

                const SizedBox(height: AppSizes.spaceMd),
                const Divider(),
                const SizedBox(height: AppSizes.spaceMd),

                // Konum
                if (project.location != null)
                  _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Konum',
                    value: project.location!,
                  ),

                // Bütçe
                _buildInfoRow(
                  icon: Icons.payments_outlined,
                  label: 'Bütçe',
                  value: NumberHelper.formatCurrency(project.budget),
                  valueColor: AppColors.success,
                ),

                // Patron Bilgisi
                if (patron != null) ...[
                  const SizedBox(height: AppSizes.spaceSm),
                  _buildPatronInfo(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceSm),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppSizes.iconSm,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatronInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              patron!.type == PatronType.company
                  ? Icons.business
                  : Icons.person,
              color: AppColors.primary,
              size: AppSizes.iconSm,
            ),
          ),
          const SizedBox(width: AppSizes.spaceSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patron/İşveren',
                  style: TextStyle(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  patron!.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textTertiary,
            size: AppSizes.iconSm,
          ),
        ],
      ),
    );
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planlama Aşamasında';
      case ProjectStatus.inProgress:
        return 'Devam Ediyor';
      case ProjectStatus.onHold:
        return 'Beklemede';
      case ProjectStatus.completed:
        return 'Tamamlandı';
      case ProjectStatus.cancelled:
        return 'İptal Edildi';
    }
  }

  IconData _getStatusIcon(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Icons.schedule;
      case ProjectStatus.inProgress:
        return Icons.trending_up;
      case ProjectStatus.onHold:
        return Icons.pause_circle_outline;
      case ProjectStatus.completed:
        return Icons.check_circle_outline;
      case ProjectStatus.cancelled:
        return Icons.cancel_outlined;
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
