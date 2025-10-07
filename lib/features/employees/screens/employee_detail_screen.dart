import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/utils/number_helper.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/hive_service.dart';

/// Çalışan detay ekranı
class EmployeeDetailScreen extends StatefulWidget {
  final EmployeeModel employee;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  late EmployeeModel _employee;

  @override
  void initState() {
    super.initState();
    _employee = widget.employee;
  }

  Future<void> _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çalışanı Sil'),
        content: Text(
          '${_employee.fullName} isimli çalışanı silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.btnCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.btnDelete),
          ),
        ],
      ),
    );

    if (result == true) {
      await HiveService.deleteEmployee(_employee.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _callPhone() async {
    // TODO: Telefon arama özelliği eklenebilir
    // await launch('tel:${_employee.phone}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aranıyor: ${_employee.phone}'),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label kopyalandı'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_employee.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Düzenleme ekranına yönlendir
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil Header
            _buildProfileHeader(),

            const SizedBox(height: AppSizes.spaceMd),

            // İletişim Bilgileri
            _buildSection(
              title: 'İletişim Bilgileri',
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.phone,
                    label: 'Telefon',
                    value: NumberHelper.formatPhone(_employee.phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.call, color: AppColors.success),
                      onPressed: _callPhone,
                    ),
                    onLongPress: () => _copyToClipboard(
                      _employee.phone,
                      'Telefon numarası',
                    ),
                  ),
                  if (_employee.email != null) ...[
                    const Divider(height: 1),
                    _buildInfoTile(
                      icon: Icons.email,
                      label: 'E-posta',
                      value: _employee.email!,
                      onLongPress: () => _copyToClipboard(
                        _employee.email!,
                        'E-posta',
                      ),
                    ),
                  ],
                  if (_employee.address != null) ...[
                    const Divider(height: 1),
                    _buildInfoTile(
                      icon: Icons.location_on,
                      label: 'Adres',
                      value: _employee.address!,
                      maxLines: 3,
                      onLongPress: () => _copyToClipboard(
                        _employee.address!,
                        'Adres',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Kişisel Bilgiler
            _buildSection(
              title: 'Kişisel Bilgiler',
              child: Column(
                children: [
                  if (_employee.tcKimlikNo != null) ...[
                    _buildInfoTile(
                      icon: Icons.badge,
                      label: 'TC Kimlik No',
                      value: NumberHelper.formatTCKN(_employee.tcKimlikNo!),
                      onLongPress: () => _copyToClipboard(
                        _employee.tcKimlikNo!,
                        'TC Kimlik No',
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  if (_employee.birthDate != null) ...[
                    _buildInfoTile(
                      icon: Icons.cake,
                      label: 'Doğum Tarihi',
                      value:
                          '${DateHelper.formatDate(_employee.birthDate)} (${_employee.age} yaş)',
                    ),
                    const Divider(height: 1),
                  ],
                  _buildInfoTile(
                    icon: Icons.work,
                    label: 'Pozisyon',
                    value: _employee.position,
                  ),
                ],
              ),
            ),

            // İş Bilgileri
            _buildSection(
              title: 'İş Bilgileri',
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.calendar_today,
                    label: 'İşe Başlama',
                    value: DateHelper.formatDate(_employee.hireDate),
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.timer,
                    label: 'Çalışma Süresi',
                    value: '${_employee.workingDays} gün',
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.payments,
                    label: 'Günlük Ücret',
                    value: NumberHelper.formatCurrency(_employee.dailyWage),
                  ),
                  const Divider(height: 1),
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    label: 'Durum',
                    value: _getStatusText(_employee.status),
                    valueColor: _getStatusColor(_employee.status),
                  ),
                ],
              ),
            ),

            // Acil Durum İletişim
            if (_employee.emergencyContactName != null ||
                _employee.emergencyContactPhone != null)
              _buildSection(
                title: 'Acil Durum İletişim',
                child: Column(
                  children: [
                    if (_employee.emergencyContactName != null) ...[
                      _buildInfoTile(
                        icon: Icons.person,
                        label: 'İsim',
                        value: _employee.emergencyContactName!,
                      ),
                      if (_employee.emergencyContactPhone != null)
                        const Divider(height: 1),
                    ],
                    if (_employee.emergencyContactPhone != null)
                      _buildInfoTile(
                        icon: Icons.phone,
                        label: 'Telefon',
                        value: NumberHelper.formatPhone(
                          _employee.emergencyContactPhone!,
                        ),
                        onLongPress: () => _copyToClipboard(
                          _employee.emergencyContactPhone!,
                          'Acil telefon',
                        ),
                      ),
                  ],
                ),
              ),

            // Notlar
            if (_employee.notes != null && _employee.notes!.isNotEmpty)
              _buildSection(
                title: 'Notlar',
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMd),
                  child: Text(
                    _employee.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

            const SizedBox(height: AppSizes.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
      ),
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surface,
            backgroundImage: _employee.avatarUrl != null
                ? NetworkImage(_employee.avatarUrl!)
                : null,
            child: _employee.avatarUrl == null
                ? Text(
                    _employee.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),

          const SizedBox(height: AppSizes.spaceMd),

          // İsim
          Text(
            _employee.fullName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: AppSizes.spaceSm),

          // Pozisyon
          Text(
            _employee.position,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textLight.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.marginMd,
        vertical: AppSizes.marginSm,
      ),
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
    Widget? trailing,
    Color? valueColor,
    int maxLines = 1,
    VoidCallback? onLongPress,
  }) {
    return InkWell(
      onLongPress: onLongPress,
      child: Padding(
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
                          color: valueColor,
                        ),
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
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
        return 'İşten Ayrıldı';
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
