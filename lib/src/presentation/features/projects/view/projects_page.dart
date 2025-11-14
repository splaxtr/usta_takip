import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/patron.dart';
import '../../../../data/models/project.dart';
import '../../../../domain/repositories/patron_repository.dart';
import '../../../../domain/repositories/project_repository.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ProjectRepository _projectRepository =
      context.read<ProjectRepository>();
  late final PatronRepository _patronRepository =
      context.read<PatronRepository>();
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final Uuid _uuid = const Uuid();

  List<Project> _projects = [];
  List<Patron> _patrons = [];
  bool _isLoading = true;
  bool _showArchived = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final projects = await _projectRepository.getAll(includeArchived: true);
    final patrons = await _patronRepository.getAll();
    projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setState(() {
      _projects = projects;
      _patrons = patrons;
      _isLoading = false;
    });
  }

  String _patronName(Project project) {
    return _patrons
        .firstWhere(
          (patron) => patron.id == project.patronId,
          orElse: () => Patron(
            id: '',
            name: 'Belirtilmedi',
            phone: '',
            description: '',
          ),
        )
        .name;
  }

  Future<void> _toggleArchive(Project project) async {
    if (project.isArchived) {
      await _projectRepository.restore(project.id);
    } else {
      await _projectRepository.archive(project.id);
    }
    await _loadData();
  }

  Future<void> _openProjectDialog({Project? project}) async {
    final nameController = TextEditingController(text: project?.name ?? '');
    final budgetController = TextEditingController(
      text: project?.totalBudget.toString() ?? '',
    );
    final wageController = TextEditingController(
      text: project?.defaultDailyWage.toString() ?? '',
    );
    DateTime startDate = project?.startDate ?? DateTime.now();
    String? selectedPatronId =
        project?.patronId.isNotEmpty == true ? project?.patronId : null;
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project == null ? 'Yeni Proje' : 'Projeyi Düzenle',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Proje Adı'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Proje adı zorunlu'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPatronId,
                    items: _patrons
                        .map(
                          (patron) => DropdownMenuItem(
                            value: patron.id,
                            child: Text(patron.name),
                          ),
                        )
                        .toList(),
                    decoration: const InputDecoration(labelText: 'Patron'),
                    onChanged: (value) => selectedPatronId = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: budgetController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Toplam Bütçe (₺)'),
                    validator: (value) =>
                        (double.tryParse(value ?? '') ?? 0) <= 0
                            ? 'Geçerli bütçe girin'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: wageController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Varsayılan Yevmiye'),
                    validator: (value) =>
                        (double.tryParse(value ?? '') ?? 0) <= 0
                            ? 'Geçerli tutar girin'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Başlangıç Tarihi'),
                    subtitle: Text(_dateFormat.format(startDate)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setState(() => startDate = picked);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        final model = Project(
                          id: project?.id ?? _uuid.v4(),
                          name: nameController.text.trim(),
                          patronId: selectedPatronId ?? '',
                          totalBudget:
                              double.parse(budgetController.text.trim()),
                          defaultDailyWage:
                              double.parse(wageController.text.trim()),
                          startDate: startDate,
                          endDate: project?.endDate,
                        );
                        if (project == null) {
                          await _projectRepository.add(model);
                        } else {
                          await _projectRepository.update(
                            model.copyWith(
                              isArchived: project.isArchived,
                              isDeleted: project.isDeleted,
                              createdAt: project.createdAt,
                            ),
                          );
                        }
                        if (mounted) Navigator.pop(context);
                        await _loadData();
                      },
                      child: Text(project == null ? 'Kaydet' : 'Güncelle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Project> get _visibleProjects {
    return _showArchived
        ? _projects
        : _projects.where((project) => !project.isArchived).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Projeler'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: const Text('Arşivdekileri Göster'),
              selected: _showArchived,
              onSelected: (value) => setState(() => _showArchived = value),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _visibleProjects.isEmpty
                  ? const Center(child: Text('Proje bulunamadı'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _visibleProjects.length,
                      itemBuilder: (context, index) {
                        final project = _visibleProjects[index];
                        final patronName = _patronName(project);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      project.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    Chip(
                                      label: Text(
                                        project.isArchived
                                            ? 'Arşivde'
                                            : 'Aktif',
                                      ),
                                      backgroundColor: project.isArchived
                                          ? Colors.orange.shade100
                                          : Colors.green.shade100,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Patron: $patronName',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bütçe: ${project.totalBudget.toStringAsFixed(0)} ₺',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Başlangıç: ${_dateFormat.format(project.startDate)}',
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => _toggleArchive(project),
                                    icon: Icon(project.isArchived
                                        ? Icons.unarchive
                                        : Icons.archive),
                                    label: Text(project.isArchived
                                        ? 'Geri Al'
                                        : 'Arşivle'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProjectDialog(),
        icon: const Icon(Icons.add_business),
        label: const Text('Yeni Proje'),
      ),
    );
  }
}
