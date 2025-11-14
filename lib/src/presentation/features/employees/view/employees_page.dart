import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/employee.dart';
import '../../../../data/models/project.dart';
import '../../../../domain/repositories/employee_repository.dart';
import '../../../../domain/repositories/project_repository.dart';

class EmployeesPage extends StatefulWidget {
  const EmployeesPage({super.key});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  late final EmployeeRepository _employeeRepository =
      context.read<EmployeeRepository>();
  late final ProjectRepository _projectRepository =
      context.read<ProjectRepository>();

  final TextEditingController _searchController = TextEditingController();
  final Uuid _uuid = const Uuid();

  List<Employee> _employees = [];
  List<Project> _projects = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final employees = await _employeeRepository.getAll();
    final projects = await _projectRepository.getAll(includeArchived: true);
    employees.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _employees = employees;
      _projects = projects;
      _isLoading = false;
    });
  }

  List<Employee> get _filteredEmployees {
    if (_query.isEmpty) return _employees;
    return _employees
        .where((employee) =>
            employee.name.toLowerCase().contains(_query) ||
            employee.phone.toLowerCase().contains(_query))
        .toList();
  }

  Future<void> _upsertEmployee({Employee? employee}) async {
    final nameController = TextEditingController(text: employee?.name ?? '');
    final wageController = TextEditingController(
      text: employee?.dailyWage.toString() ?? '',
    );
    final phoneController =
        TextEditingController(text: employee?.phone ?? '');
    String? selectedProjectId = employee?.projectId.isNotEmpty == true
        ? employee?.projectId
        : (_projects.isNotEmpty ? _projects.first.id : null);

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  employee == null ? 'Yeni Çalışan' : 'Çalışanı Düzenle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Ad zorunlu'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: wageController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Günlük Ücret (₺)'),
                  validator: (value) =>
                      (double.tryParse(value ?? '') ?? 0) <= 0
                          ? 'Geçerli ücret girin'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Bağlı Proje',
                  ),
                  items: _projects
                      .map(
                        (project) => DropdownMenuItem(
                          value: project.id,
                          child: Text(project.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedProjectId = value;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final model = Employee(
                        id: employee?.id ?? _uuid.v4(),
                        name: nameController.text.trim(),
                        dailyWage:
                            double.parse(wageController.text.trim()),
                        phone: phoneController.text.trim(),
                        projectId: selectedProjectId ?? '',
                      );
                      if (employee == null) {
                        await _employeeRepository.add(model);
                      } else {
                        await _employeeRepository.update(model.copyWith(
                          createdAt: employee.createdAt,
                        ));
                      }
                      if (mounted) {
                        Navigator.pop(context);
                      }
                      await _loadData();
                    },
                    child: Text(employee == null ? 'Kaydet' : 'Güncelle'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çalışanı Sil'),
        content: Text('${employee.name} çöp kutusuna taşınacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _employeeRepository.softDelete(employee.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Çalışanlar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'İsim veya telefon ara',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _filteredEmployees.isEmpty
                  ? const Center(child: Text('Çalışan bulunamadı'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        final projectName = _projects
                                .firstWhere(
                                  (project) => project.id == employee.projectId,
                                  orElse: () => Project(
                                    id: '',
                                    name: 'Atanmadı',
                                    patronId: '',
                                    totalBudget: 0,
                                    defaultDailyWage: 0,
                                    startDate: DateTime.now(),
                                  ),
                                )
                                .name;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2563EB),
                              child: Text(
                                employee.name.isNotEmpty
                                    ? employee.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(employee.name),
                            subtitle: Text(
                              'Ücret: ${employee.dailyWage.toStringAsFixed(0)} ₺ • Proje: $projectName',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _upsertEmployee(employee: employee);
                                } else if (value == 'delete') {
                                  _deleteEmployee(employee);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Düzenle'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Sil'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _filteredEmployees.length,
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _upsertEmployee(),
        icon: const Icon(Icons.person_add_alt),
        label: const Text('Çalışan Ekle'),
      ),
    );
  }
}
