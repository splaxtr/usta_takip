import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/gelir_gider_model.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/hive_service.dart';
import '../../auth/widgets/name_input_field.dart';

/// Gider ekleme ekranı
class AddExpenseScreen extends StatefulWidget {
  final ProjectModel? project;
  final EmployeeModel? employee;

  const AddExpenseScreen({
    super.key,
    this.project,
    this.employee,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = TransactionCategories.expenseCategories.first;
  DateTime _date = DateTime.now();
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  ProjectModel? _selectedProject;
  EmployeeModel? _selectedEmployee;
  List<ProjectModel> _projects = [];
  List<EmployeeModel> _employees = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedProject = widget.project;
    _selectedEmployee = widget.employee;
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _invoiceNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadData() {
    final projects = HiveService.getProjects();
    final employees = HiveService.getEmployees();

    setState(() {
      _projects = projects;
      _employees = employees;
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );

    if (date != null) {
      setState(() {
        _date = date;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final expense = GelirGiderModel(
        id: 'expense_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.expense,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        projectId: _selectedProject?.id,
        employeeId: _selectedEmployee?.id,
        date: _date,
        description: _descriptionController.text.trim(),
        paymentMethod: _paymentMethod,
        invoiceNumber: _invoiceNumberController.text.trim().isEmpty
            ? null
            : _invoiceNumberController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await HiveService.addGelirGider(expense);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gider kaydı başarıyla eklendi'),
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
        title: const Text('Gider Ekle'),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMd),
          children: [
            // Tutar (En önemli alan - En üstte ve büyük)
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withOpacity(0.1),
                    AppColors.error.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Gider Tutarı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spaceSm),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: '₺',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
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
                ],
              ),
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Kategori
            _buildSectionTitle('Gider Kategorisi'),
            const SizedBox(height: AppSizes.spaceMd),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori *',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              items: TransactionCategories.expenseCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Açıklama
            CustomTextField(
              controller: _descriptionController,
              label: 'Açıklama *',
              hint: 'Gider açıklaması',
              prefixIcon: Icons.description,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.requiredField;
                }
                return null;
              },
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Tarih
            _buildSectionTitle('Tarih'),
            const SizedBox(height: AppSizes.spaceMd),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'İşlem Tarihi *',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: const Icon(Icons.edit_calendar),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                ),
                child: Text(
                  '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Proje ve Çalışan
            _buildSectionTitle('İlişkili Kayıtlar'),
            const SizedBox(height: AppSizes.spaceMd),

            // Proje Seçimi
            DropdownButtonFormField<ProjectModel>(
              value: _selectedProject,
              decoration: InputDecoration(
                labelText: 'Proje (Opsiyonel)',
                prefixIcon: const Icon(Icons.work_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              hint: const Text('Proje seçin'),
              items: [
                const DropdownMenuItem<ProjectModel>(
                  value: null,
                  child: Text('Seçilmedi'),
                ),
                ..._projects.map((project) {
                  return DropdownMenuItem<ProjectModel>(
                    value: project,
                    child: Text(project.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedProject = value;
                });
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Çalışan Seçimi (Maaş ödemesi için)
            DropdownButtonFormField<EmployeeModel>(
              value: _selectedEmployee,
              decoration: InputDecoration(
                labelText: 'Çalışan (Maaş ödemesi için)',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              hint: const Text('Çalışan seçin'),
              items: [
                const DropdownMenuItem<EmployeeModel>(
                  value: null,
                  child: Text('Seçilmedi'),
                ),
                ..._employees.map((employee) {
                  return DropdownMenuItem<EmployeeModel>(
                    value: employee,
                    child: Text(employee.fullName),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedEmployee = value;
                  // Eğer maaş ödemesi seçiliyse ve çalışan seçildiyse
                  if (_selectedCategory == 'Maaş Ödemesi' &&
                      value != null &&
                      _amountController.text.isEmpty) {
                    _amountController.text = value.dailyWage.toString();
                  }
                });
              },
            ),

            // Çalışan seçiliyse bilgi göster
            if (_selectedEmployee != null) ...[
              const SizedBox(height: AppSizes.spaceSm),
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingSm),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppColors.info, size: 16),
                    const SizedBox(width: AppSizes.spaceSm),
                    Expanded(
                      child: Text(
                        'Günlük ücret: ${_selectedEmployee!.dailyWage} ₺',
                        style: const TextStyle(
                          fontSize: AppSizes.fontSm,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSizes.spaceXl),

            // Ödeme Yöntemi
            _buildSectionTitle('Ödeme Detayları'),
            const SizedBox(height: AppSizes.spaceMd),

            DropdownButtonFormField<PaymentMethod>(
              value: _paymentMethod,
              decoration: InputDecoration(
                labelText: 'Ödeme Yöntemi',
                prefixIcon: const Icon(Icons.payment),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
              ),
              items: PaymentMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(_getPaymentMethodText(method)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _paymentMethod = value;
                  });
                }
              },
            ),

            const SizedBox(height: AppSizes.spaceMd),

            // Fatura Numarası
            CustomTextField(
              controller: _invoiceNumberController,
              label: 'Fatura/Fiş Numarası',
              hint: 'Ör: FIS-2024-001',
              prefixIcon: Icons.receipt_long,
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Notlar
            _buildSectionTitle('Notlar'),
            const SizedBox(height: AppSizes.spaceMd),

            CustomTextField(
              controller: _notesController,
              label: 'Ek Notlar',
              hint: 'Ek bilgiler...',
              prefixIcon: Icons.note,
              maxLines: 3,
            ),

            const SizedBox(height: AppSizes.spaceXl),

            // Kaydet butonu
            ElevatedButton(
              onPressed: _isLoading ? null : _saveExpense,
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, AppSizes.buttonHeightLg),
                backgroundColor: AppColors.error,
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
                  : const Text(
                      'Gideri Kaydet',
                      style: TextStyle(color: Colors.white),
                    ),
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
    );
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Nakit';
      case PaymentMethod.bankTransfer:
        return 'Banka Havalesi';
      case PaymentMethod.creditCard:
        return 'Kredi Kartı';
      case PaymentMethod.check:
        return 'Çek';
      case PaymentMethod.other:
        return 'Diğer';
    }
  }
}
