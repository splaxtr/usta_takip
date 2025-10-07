import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/patron_model.dart';

/// Patron kartı widget'ı
///
/// Liste görünümünde her patron için gösterilen kart
class PatronCard extends StatelessWidget {
  final PatronModel patron;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PatronCard({
    super.key,
    required this.patron,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kısım: İsim, tip badge, aktiflik
              Row(
                children: [
                  // İkon
                  _buildIcon(),

                  const SizedBox(width: AppSizes.spaceMd),

                  // İsim ve bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İsim ve tip badge
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                patron.displayName,
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
                            _buildTypeBadge(),
                          ],
                        ),

                        const SizedBox(height: AppSizes.spaceXs),

                        // Şirket ise - Yetkili kişi
                        if (patron.type == PatronType.company &&
                            patron.authorizedPerson != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: AppSizes.iconXs,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: AppSizes.spaceXs),
                              Expanded(
                                child: Text(
                                  'Yetkili: ${patron.authorizedPerson}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
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
                        ],

                        // Telefon
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: AppSizes.iconXs,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSizes.spaceXs),
                            Text(
                              NumberHelper.formatPhone(patron.phone),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Aktif/Pasif badge
                  _buildStatusIndicator(),
                ],
              ),

              // Alt kısım: Proje sayısı ve diğer bilgiler
              if (patron.projectIds.isNotEmpty ||
                  patron.email != null ||
                  patron.taxNumber != null) ...[
                const SizedBox(height: AppSizes.spaceMd),
                const Divider(height: 1),
                const SizedBox(height: AppSizes.spaceMd),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Proje sayısı
                    if (patron.projectIds.isNotEmpty)
                      _buildInfoChip(
                        icon: Icons.work_outline,
                        label: '${patron.projectIds.length} Proje',
                        color: AppColors.success,
                      ),

                    // Email varsa göster
                    if (patron.email != null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: AppSizes.iconXs,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppSizes.spaceXs),
                            Expanded(
                              child: Text(
                                patron.email!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Vergi no varsa göster
                    if (patron.taxNumber != null && patron.email == null)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.numbers,
                              size: AppSizes.iconXs,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(width: AppSizes.spaceXs),
                            Expanded(
                              child: Text(
                                'VN: ${patron.taxNumber}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingSm),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Icon(
        patron.type == PatronType.company ? Icons.business : Icons.person,
        color: _getTypeColor(),
        size: AppSizes.iconLg,
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(
          color: _getTypeColor().withOpacity(0.3),
        ),
      ),
      child: Text(
        patron.type == PatronType.company ? 'Şirket' : 'Şahıs',
        style: TextStyle(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w600,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: patron.isActive ? AppColors.success : AppColors.grey400,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: AppSizes.paddingXs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconXs, color: color),
          const SizedBox(width: AppSizes.spaceXs),
          Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.fontXs,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor() {
    return patron.type == PatronType.company
        ? AppColors.primary
        : AppColors.secondary;
  }
}

/// Kompakt patron kartı (küçük liste için)
class CompactPatronCard extends StatelessWidget {
  final PatronModel patron;
  final VoidCallback? onTap;

  const CompactPatronCard({
    super.key,
    required this.patron,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: _getTypeColor().withOpacity(0.1),
        child: Icon(
          patron.type == PatronType.company ? Icons.business : Icons.person,
          color: _getTypeColor(),
        ),
      ),
      title: Text(
        patron.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(NumberHelper.formatPhone(patron.phone)),
          if (patron.projectIds.isNotEmpty)
            Text(
              '${patron.projectIds.length} proje',
              style: const TextStyle(fontSize: AppSizes.fontSm),
            ),
        ],
      ),
      trailing: patron.isActive
          ? null
          : Icon(
              Icons.cancel_outlined,
              color: AppColors.error,
              size: AppSizes.iconSm,
            ),
    );
  }

  Color _getTypeColor() {
    return patron.type == PatronType.company
        ? AppColors.primary
        : AppColors.secondary;
  }
}

/// Patron seçici widget'ı (Dropdown gibi)
class PatronSelector extends StatelessWidget {
  final List<PatronModel> patrons;
  final PatronModel? selectedPatron;
  final ValueChanged<PatronModel?> onChanged;
  final String? hintText;
  final bool showOnlyActive;

  const PatronSelector({
    super.key,
    required this.patrons,
    this.selectedPatron,
    required this.onChanged,
    this.hintText,
    this.showOnlyActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final filteredPatrons =
        showOnlyActive ? patrons.where((p) => p.isActive).toList() : patrons;

    return DropdownButtonFormField<PatronModel>(
      value: selectedPatron,
      decoration: InputDecoration(
        labelText: hintText ?? 'Patron Seçin',
        prefixIcon: const Icon(Icons.business),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),
      items: filteredPatrons.map((patron) {
        return DropdownMenuItem<PatronModel>(
          value: patron,
          child: Row(
            children: [
              Icon(
                patron.type == PatronType.company
                    ? Icons.business
                    : Icons.person,
                size: AppSizes.iconSm,
                color: patron.type == PatronType.company
                    ? AppColors.primary
                    : AppColors.secondary,
              ),
              const SizedBox(width: AppSizes.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      patron.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      NumberHelper.formatPhone(patron.phone),
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

/// Patron detay özeti kartı (Proje detayında kullanım için)
class PatronSummaryCard extends StatelessWidget {
  final PatronModel patron;
  final VoidCallback? onTap;

  const PatronSummaryCard({
    super.key,
    required this.patron,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _getTypeColor().withOpacity(0.1),
                child: Icon(
                  patron.type == PatronType.company
                      ? Icons.business
                      : Icons.person,
                  color: _getTypeColor(),
                ),
              ),
              const SizedBox(width: AppSizes.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patron.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spaceXs),
                    Text(
                      NumberHelper.formatPhone(patron.phone),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    if (patron.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        patron.email!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
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

  Color _getTypeColor() {
    return patron.type == PatronType.company
        ? AppColors.primary
        : AppColors.secondary;
  }
}
