import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/models/patron.dart';
import '../../../../data/models/project.dart';
import '../../../../domain/repositories/patron_repository.dart';
import '../../../../domain/repositories/project_repository.dart';

class PatronsPage extends StatefulWidget {
  const PatronsPage({super.key});

  @override
  State<PatronsPage> createState() => _PatronsPageState();
}

class _PatronsPageState extends State<PatronsPage> {
  late final PatronRepository _patronRepository =
      context.read<PatronRepository>();
  late final ProjectRepository _projectRepository =
      context.read<ProjectRepository>();
  final TextEditingController _searchController = TextEditingController();
  final Uuid _uuid = const Uuid();

  List<Patron> _patrons = [];
  List<Project> _projects = [];
  bool _isLoading = true;
  bool _onlyActive = false;
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
    final patrons = await _patronRepository.getAll();
    final projects = await _projectRepository.getAll();
    patrons.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _patrons = patrons;
      _projects = projects;
      _isLoading = false;
    });
  }

  int _activeProjectCount(String patronId) {
    return _projects
        .where((project) => project.patronId == patronId && !project.isArchived)
        .length;
  }

  List<Patron> get _filteredPatrons {
    var list = _patrons.where(
      (patron) =>
          patron.name.toLowerCase().contains(_query) ||
          patron.phone.toLowerCase().contains(_query),
    );
    if (_onlyActive) {
      list = list.where((patron) => _activeProjectCount(patron.id) > 0);
    }
    return list.toList();
  }

  Future<void> _upsertPatron({Patron? patron}) async {
    final nameController = TextEditingController(text: patron?.name ?? '');
    final phoneController = TextEditingController(text: patron?.phone ?? '');
    final descriptionController =
        TextEditingController(text: patron?.description ?? '');
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
                  patron == null ? 'Yeni Patron' : 'Patronu Düzenle',
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
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Açıklama / Notlar'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final model = Patron(
                        id: patron?.id ?? _uuid.v4(),
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        description: descriptionController.text.trim(),
                      );
                      if (patron == null) {
                        await _patronRepository.add(model);
                      } else {
                        await _patronRepository.update(
                          model.copyWith(createdAt: patron.createdAt),
                        );
                      }
                      if (mounted) Navigator.pop(context);
                      await _loadData();
                    },
                    child: Text(patron == null ? 'Kaydet' : 'Güncelle'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePatron(Patron patron) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patronu Sil'),
        content: Text('${patron.name} çöp kutusuna taşınacak.'),
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
      await _patronRepository.softDelete(patron.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Patronlar'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Patron ara',
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: const Text('Aktif Projeler'),
              selected: _onlyActive,
              onSelected: (value) {
                setState(() => _onlyActive = value);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _filteredPatrons.isEmpty
                  ? const Center(child: Text('Patron bulunamadı'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final patron = _filteredPatrons[index];
                        final activeCount = _activeProjectCount(patron.id);
                        return Card(
                          child: ListTile(
                            title: Text(patron.name),
                            subtitle: Text(
                              '${patron.phone.isNotEmpty ? patron.phone : 'Telefon yok'} • Aktif Proje: $activeCount',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _upsertPatron(patron: patron);
                                } else if (value == 'delete') {
                                  _deletePatron(patron);
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
                      itemCount: _filteredPatrons.length,
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _upsertPatron(),
        icon: const Icon(Icons.handshake),
        label: const Text('Patron Ekle'),
      ),
    );
  }
}
