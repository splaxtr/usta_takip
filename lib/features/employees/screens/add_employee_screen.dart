import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/hive_service.dart';
import '../../auth/widgets/name_input_field.dart';

/// Çalışan ekleme ekranı
class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _tcKimlikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _positionController = TextEditingController();
  final _dailyWageController = TextEditingController();
  final _notesController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  DateTime? _birthDate;
  DateTime _hireDate = DateTime.now();
  EmployeeStatus _status = EmployeeStatus.active;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _tcKimlikController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _positionController.dispose();
    _dailyWageController.dispose();
    _notesController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );

    if (date != null) {
      setState(() {
        _birthDate = date;
      });
    }
  }

  Future<void> _selectHireDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _hireDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (date != null) {
      setState(() {
        _hireDate = date;
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final employee = EmployeeModel(
        id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        tcKimlikNo: _tcKimlikController.text.trim().isEmpty
            ? null
            : _tcKimlikController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        birthDate: _birthDate,
        position: _positionController.text.trim(),
        dailyWage: double.tryParse(_dailyWageController.text) ?? 0.0,
        status: _status,
        hireDate: _hireDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim().isEmpty
            ? null
            : _emergencyNameController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty
            ? null
            : _emergencyPhoneController.text.trim(),
        createdAt: DateTime.now(),
      );

      await HiveService.addEmployee(employee);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Çalışan başarıyla eklendi'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Çalışan Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          children: [
            // Kişisel Bilgiler
            _buildSectionTitle('Kişisel Bilgiler'),
            const SizedBox(height: AppSizes.spaceMd),

            NameInputField(
              controller: _nameController,
              label: 'Ad *',
              hint: 'Adını girin',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: AppSizes.spaceMd),

            NameInputField(
              controller: _surnameController,
              label: 'Soyad *',
              hint: 'Soyadını girin',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _tcKimlikController,
              label: 'TC Kimlik No',
              hint: '12345678901',
              prefixIcon: Icons.badge,
              keyboardType: TextInputType.number,
              maxLength: 11,
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length != 11) {
                  return 'TC Kimlik No 11 haneli olmalıdır';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Doğum tarihi
            InkWell(
              onTap: _selectBirthDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi',
                  prefixIcon: const Icon(Icons.cake),
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}'
                      : 'Tarih seçin',
                  style: TextStyle(
                    color: _birthDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // İletişim Bilgileri
            _buildSectionTitle('İletişim Bilgileri'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _phoneController,
              label: 'Telefon *',
              hint: '5551234567',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _emailController,
              label: 'E-posta',
              hint: 'ornek@email.com',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _addressController,
              label: 'Adres',
              hint: 'Açık adres',
              prefixIcon: Icons.location_on,
              maxLines: 3,
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // İş Bilgileri
            _buildSectionTitle('İş Bilgileri'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _positionController,
              label: 'Pozisyon *',
              hint: 'Ör: Usta, Kalfa, İşçi',
              prefixIcon: Icons.work,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _dailyWageController,
              label: 'Günlük Ücret *',
              hint: '0.00',
              prefixIcon: Icons.payments,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                if (double.tryParse(value) == null) {
                  return 'Geçerli bir sayı girin';
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // İşe başlama tarihi
            InkWell(
              onTap: _selectHireDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'İşe Başlama Tarihi *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: const Icon(Icons.edit_calendar),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
                child: Text(
                  '${_hireDate.day.toString().padLeft(2, '0')}.${_hireDate.month.toString().padLeft(2, '0')}.${_hireDate.year}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Durum
            DropdownButtonFormField<EmployeeStatus>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Durum',
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              items: EmployeeStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Acil Durum İletişim
            _buildSectionTitle('Acil Durum İletişim'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _emergencyNameController,
              label: 'Acil Durum Kişisi',
              hint: 'İsim Soyisim',
              prefixIcon: Icons.person,
            ),

            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _emergencyPhoneController,
              label: 'Acil Durum Telefonu',
              hint: '5551234567',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Notlar
            _buildSectionTitle('Notlar'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _notesController,
              label: 'Notlar',
              hint: 'Ek bilgiler...',
              prefixIcon: Icons.note,
              maxLines: 4,
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Kaydet butonu
            ElevatedButton(
              onPressed: _isLoading ? null : _saveEmployee,
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, AppSizes.buttonHeightLg),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Çalışanı Kaydet'),
            ),

            const SizedBox(height: AppSizes.spaceLg),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
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
}
