import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/patron_model.dart';
import '../../../data/services/hive_service.dart';
import '../../auth/widgets/name_input_field.dart';
import '../../patrons/widgets/patron_card.dart';

/// Proje ekleme ekranı
class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  ProjectStatus _status = ProjectStatus.planning;
  PatronModel? _selectedPatron;
  List<PatronModel> _patrons = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPatrons();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadPatrons() {
    final patrons = HiveService.getActivePatrons();
    setState(() {
      _patrons = patrons;
    });
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('tr', 'TR'),
    );

    if (date != null) {
      setState(() {
        _startDate = date;
        // Bitiş tarihi başlangıçtan önceyse sıfırla
        if (_endDate != null && _endDate!.isBefore(date)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('tr', 'TR'),
    );

    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatron == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir patron seçin'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final project = ProjectModel(
        id: 'project_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        patronId: _selectedPatron!.id,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        status: _status,
        startDate: _startDate,
        endDate: _endDate,
        budget: double.tryParse(_budgetController.text) ?? 0.0,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await HiveService.addProject(project);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proje başarıyla eklendi'),
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
        title: const Text('Yeni Proje Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          children: [
            // Proje Adı
            _buildSectionTitle('Proje Bilgileri'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _nameController,
              label: 'Proje Adı *',
              hint: 'Proje adını girin',
              prefixIcon: Icons.work_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Açıklama
            CustomTextField(
              controller: _descriptionController,
              label: 'Açıklama',
              hint: 'Proje açıklaması',
              prefixIcon: Icons.description,
              maxLines: 3,
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Konum
            CustomTextField(
              controller: _locationController,
              label: 'Konum',
              hint: 'Proje konumu/adresi',
              prefixIcon: Icons.location_on,
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Patron Seçimi
            _buildSectionTitle('Patron/İşveren'),
            const SizedBox(height: AppSizes.spaceMd),

            if (_patrons.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.warning),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: AppSizes.spaceSm),
                    Expanded(
                      child: Text(
                        'Henüz patron kaydı yok. Önce patron eklemelisiniz.',
                        style: TextStyle(color: AppColors.warning),
                      ),
                    ),
                  ],
                ),
              )
            else
              PatronSelector(
                patrons: _patrons,
                selectedPatron: _selectedPatron,
                onChanged: (patron) {
                  setState(() {
                    _selectedPatron = patron;
                  });
                },
                hintText: 'Patron Seçin *',
              ),

            const SizedBox(height: AppSizes.spaceXl),

            // Tarih Bilgileri
            _buildSectionTitle('Tarih Bilgileri'),
            const SizedBox(height: AppSizes.spaceMd),

            // Başlangıç Tarihi
            InkWell(
              onTap: _selectStartDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Başlangıç Tarihi *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: const Icon(Icons.edit_calendar),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
                child: Text(
                  '${_startDate.day.toString().padLeft(2, '0')}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.year}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Bitiş Tarihi
            InkWell(
              onTap: _selectEndDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Bitiş Tarihi (Tahmini)',
                  prefixIcon: const Icon(Icons.event),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                        ),
                      const Icon(Icons.edit_calendar),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
                child: Text(
                  _endDate != null
                      ? '${_endDate!.day.toString().padLeft(2, '0')}.${_endDate!.month.toString().padLeft(2, '0')}.${_endDate!.year}'
                      : 'Tarih seçin',
                  style: TextStyle(
                    color: _endDate != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Mali Bilgiler
            _buildSectionTitle('Mali Bilgiler'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _budgetController,
              label: 'Bütçe *',
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

            const SizedBox(height: AppSizes.spaceXl),

            // Durum
            _buildSectionTitle('Proje Durumu'),
            const SizedBox(height: AppSizes.spaceMd),

            DropdownButtonFormField<ProjectStatus>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Durum',
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              items: ProjectStatus.values.map((status) {
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
              onPressed: _isLoading ? null : _saveProject,
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
                  : const Text('Projeyi Kaydet'),
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
}
