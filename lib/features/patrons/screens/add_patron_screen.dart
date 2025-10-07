import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/patron_model.dart';
import '../../../data/services/hive_service.dart';
import '../../auth/widgets/name_input_field.dart';

/// Patron (İşveren) ekleme ekranı
class AddPatronScreen extends StatefulWidget {
  const AddPatronScreen({super.key});

  @override
  State<AddPatronScreen> createState() => _AddPatronScreenState();
}

class _AddPatronScreenState extends State<AddPatronScreen> {
  final _formKey = GlobalKey<FormState>();

  // Ortak alanlar
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxOfficeController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _ibanController = TextEditingController();
  final _notesController = TextEditingController();

  // Şahıs için
  final _tcKimlikController = TextEditingController();

  // Şirket için
  final _companyNameController = TextEditingController();
  final _authorizedPersonController = TextEditingController();

  PatronType _patronType = PatronType.individual;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _taxOfficeController.dispose();
    _taxNumberController.dispose();
    _ibanController.dispose();
    _notesController.dispose();
    _tcKimlikController.dispose();
    _companyNameController.dispose();
    _authorizedPersonController.dispose();
    super.dispose();
  }

  Future<void> _savePatron() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patron = PatronModel(
        id: 'patron_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        surname: _patronType == PatronType.individual
            ? _surnameController.text.trim()
            : null,
        type: _patronType,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        taxOffice: _taxOfficeController.text.trim().isEmpty
            ? null
            : _taxOfficeController.text.trim(),
        taxNumber: _taxNumberController.text.trim().isEmpty
            ? null
            : _taxNumberController.text.trim(),
        tcKimlikNo: _patronType == PatronType.individual &&
                _tcKimlikController.text.trim().isNotEmpty
            ? _tcKimlikController.text.trim()
            : null,
        companyName: _patronType == PatronType.company
            ? _companyNameController.text.trim()
            : null,
        authorizedPerson: _patronType == PatronType.company &&
                _authorizedPersonController.text.trim().isNotEmpty
            ? _authorizedPersonController.text.trim()
            : null,
        iban: _ibanController.text.trim().isEmpty
            ? null
            : _ibanController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
        isActive: true,
      );

      await HiveService.addPatron(patron);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patron başarıyla eklendi'),
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
        title: const Text('Yeni Patron/İşveren Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          children: [
            // Tip Seçimi
            _buildSectionTitle('İşveren Tipi'),
            const SizedBox(height: AppSizes.spaceMd),

            Row(
              children: [
                Expanded(
                  child: _buildTypeCard(
                    type: PatronType.individual,
                    icon: Icons.person,
                    title: 'Şahıs',
                    subtitle: 'Bireysel işveren',
                  ),
                ),
                const SizedBox(width: AppSizes.spaceMd),
                Expanded(
                  child: _buildTypeCard(
                    type: PatronType.company,
                    icon: Icons.business,
                    title: 'Şirket',
                    subtitle: 'Kurumsal işveren',
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Şahıs için formlar
            if (_patronType == PatronType.individual) ...[
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
            ],

            // Şirket için formlar
            if (_patronType == PatronType.company) ...[
              _buildSectionTitle('Şirket Bilgileri'),
              const SizedBox(height: AppSizes.spaceMd),
              CustomTextField(
                controller: _companyNameController,
                label: 'Şirket Adı *',
                hint: 'Şirket unvanını girin',
                prefixIcon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),
              CustomTextField(
                controller: _nameController,
                label: 'Kısa Ad *',
                hint: 'Görünüm adı',
                prefixIcon: Icons.label,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceMd),
              CustomTextField(
                controller: _authorizedPersonController,
                label: 'Yetkili Kişi',
                hint: 'Yetkili adı',
                prefixIcon: Icons.person,
              ),
            ],

            const SizedBox(height: AppSizes.spaceXl),

            // İletişim Bilgileri (Her iki tip için ortak)
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

            // Mali Bilgiler
            _buildSectionTitle('Mali Bilgiler'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _taxOfficeController,
              label: 'Vergi Dairesi',
              hint: 'Vergi dairesi adı',
              prefixIcon: Icons.account_balance,
            ),

            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _taxNumberController,
              label: 'Vergi Numarası',
              hint: _patronType == PatronType.company
                  ? '1234567890'
                  : 'TC Kimlik No',
              prefixIcon: Icons.numbers,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _ibanController,
              label: 'IBAN',
              hint: 'TR00 0000 0000 0000 0000 0000 00',
              prefixIcon: Icons.credit_card,
              maxLength: 34,
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
              onPressed: _isLoading ? null : _savePatron,
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
                  : const Text('Patronu Kaydet'),
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

  Widget _buildTypeCard({
    required PatronType type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _patronType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _patronType = type;
          // Tip değiştiğinde formları temizle
          if (type == PatronType.individual) {
            _companyNameController.clear();
            _authorizedPersonController.clear();
          } else {
            _surnameController.clear();
            _tcKimlikController.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontMd,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spaceXs),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
