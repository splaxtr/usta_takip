import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/employee_model.dart';
import '../../../data/services/hive_service.dart';
import '../widgets/employee_card.dart';
import 'add_employee_screen.dart';
import 'employee_detail_screen.dart';

/// Çalışanlar listesi ekranı
class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  static const String routeName = '/employees';

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  List<EmployeeModel> _employees = [];
  List<EmployeeModel> _filteredEmployees = [];
  final TextEditingController _searchController = TextEditingController();
  EmployeeStatus? _selectedStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _searchController.addListener(_filterEmployees);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    // Simülasyon için gecikme
    await Future.delayed(const Duration(milliseconds: 500));

    // Çalışanları yükle
    final employees = HiveService.getEmployees();

    setState(() {
      _employees = employees;
      _filteredEmployees = employees;
      _isLoading = false;
    });
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final matchesSearch = employee.fullName.toLowerCase().contains(query) ||
            employee.phone.contains(query) ||
            (employee.position.toLowerCase().contains(query));

        final matchesStatus =
            _selectedStatus == null || employee.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _onStatusFilterChanged(EmployeeStatus? status) {
    setState(() {
      _selectedStatus = status;
      _filterEmployees();
    });
  }

  Future<void> _navigateToAddEmployee() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEmployeeScreen(),
      ),
    );

    if (result == true) {
      _loadEmployees();
    }
  }

  Future<void> _navigateToEmployeeDetail(EmployeeModel employee) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    );

    if (result == true) {
      _loadEmployees();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışanlar'),
        actions: [
          // Aktif çalışan sayısı
          if (_employees.isNotEmpty)
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
                    '${_employees.where((e) => e.isActive).length} Aktif',
                    style: TextStyle(
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
                // Arama çubuğu
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Ad, telefon veya pozisyon ara...',
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

                // Durum filtreleri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tümü', null),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('Aktif', EmployeeStatus.active),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('İzinli', EmployeeStatus.onLeave),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('Ayrıldı', EmployeeStatus.terminated),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadEmployees,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingMd),
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = _filteredEmployees[index];
                            return EmployeeCard(
                              employee: employee,
                              onTap: () => _navigateToEmployeeDetail(employee),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddEmployee,
        icon: const Icon(Icons.add),
        label: const Text('Çalışan Ekle'),
      ),
    );
  }

  Widget _buildFilterChip(String label, EmployeeStatus? status) {
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

  Widget _buildEmptyState() {
    final hasSearchQuery = _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearchQuery ? Icons.search_off : Icons.person_add_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSizes.spaceMd),
            Text(
              hasSearchQuery ? 'Sonuç bulunamadı' : AppStrings.emptyListTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              hasSearchQuery
                  ? 'Farklı bir arama terimi deneyin'
                  : 'Henüz çalışan kaydı yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearchQuery) ...[
              const SizedBox(height: AppSizes.spaceLg),
              ElevatedButton.icon(
                onPressed: _navigateToAddEmployee,
                icon: const Icon(Icons.add),
                label: const Text('İlk Çalışanı Ekle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
