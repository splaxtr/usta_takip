import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/patron_model.dart';
import '../../../data/services/hive_service.dart';
import '../widgets/patron_card.dart';
import 'add_patron_screen.dart';

/// Patronlar (İşverenler) listesi ekranı
class PatronsListScreen extends StatefulWidget {
  const PatronsListScreen({super.key});

  static const String routeName = '/patrons';

  @override
  State<PatronsListScreen> createState() => _PatronsListScreenState();
}

class _PatronsListScreenState extends State<PatronsListScreen> {
  List<PatronModel> _patrons = [];
  List<PatronModel> _filteredPatrons = [];
  final TextEditingController _searchController = TextEditingController();
  PatronType? _selectedType;
  bool _showOnlyActive = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatrons();
    _searchController.addListener(_filterPatrons);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatrons() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final patrons = HiveService.getPatrons();

    setState(() {
      _patrons = patrons;
      _filteredPatrons = patrons;
      _isLoading = false;
    });

    _filterPatrons();
  }

  void _filterPatrons() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPatrons = _patrons.where((patron) {
        // Arama filtresi
        final matchesSearch =
            patron.displayName.toLowerCase().contains(query) ||
                patron.phone.contains(query) ||
                (patron.email?.toLowerCase().contains(query) ?? false) ||
                (patron.taxNumber?.contains(query) ?? false);

        // Tip filtresi
        final matchesType =
            _selectedType == null || patron.type == _selectedType;

        // Aktiflik filtresi
        final matchesActive = !_showOnlyActive || patron.isActive;

        return matchesSearch && matchesType && matchesActive;
      }).toList();
    });
  }

  void _onTypeFilterChanged(PatronType? type) {
    setState(() {
      _selectedType = type;
      _filterPatrons();
    });
  }

  void _toggleActiveFilter() {
    setState(() {
      _showOnlyActive = !_showOnlyActive;
      _filterPatrons();
    });
  }

  Future<void> _navigateToAddPatron() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPatronScreen(),
      ),
    );

    if (result == true) {
      _loadPatrons();
    }
  }

  Future<void> _navigateToPatronDetail(PatronModel patron) async {
    // TODO: Detay ekranı oluşturulduğunda aktif edilecek
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${patron.displayName} detayı'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patronlar / İşverenler'),
        actions: [
          // Aktif/Tümü toggle
          IconButton(
            icon: Icon(
              _showOnlyActive ? Icons.filter_alt : Icons.filter_alt_off,
              color:
                  _showOnlyActive ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: _toggleActiveFilter,
            tooltip: _showOnlyActive ? 'Tümünü Göster' : 'Sadece Aktifler',
          ),
          // Patron sayısı
          if (_patrons.isNotEmpty)
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
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    '${_patrons.where((p) => p.isActive).length} Aktif',
                    style: const TextStyle(
                      color: AppColors.primary,
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
                    hintText: 'İsim, telefon, email veya vergi no ara...',
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

                // Tip filtreleri
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tümü', null),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('Şahıs', PatronType.individual),
                      const SizedBox(width: AppSizes.spaceSm),
                      _buildFilterChip('Şirket', PatronType.company),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // İstatistikler
          if (_patrons.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMd,
                vertical: AppSizes.paddingSm,
              ),
              color: AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.business,
                    label: 'Şirket',
                    value: _patrons
                        .where((p) => p.type == PatronType.company)
                        .length
                        .toString(),
                    color: AppColors.primary,
                  ),
                  _buildStatItem(
                    icon: Icons.person,
                    label: 'Şahıs',
                    value: _patrons
                        .where((p) => p.type == PatronType.individual)
                        .length
                        .toString(),
                    color: AppColors.secondary,
                  ),
                  _buildStatItem(
                    icon: Icons.work_outline,
                    label: 'Proje',
                    value: _patrons
                        .fold<int>(0, (sum, p) => sum + p.projectIds.length)
                        .toString(),
                    color: AppColors.success,
                  ),
                ],
              ),
            ),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatrons.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadPatrons,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSizes.paddingMd),
                          itemCount: _filteredPatrons.length,
                          itemBuilder: (context, index) {
                            final patron = _filteredPatrons[index];
                            return PatronCard(
                              patron: patron,
                              onTap: () => _navigateToPatronDetail(patron),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPatron,
        icon: const Icon(Icons.add),
        label: const Text('Patron Ekle'),
      ),
    );
  }

  Widget _buildFilterChip(String label, PatronType? type) {
    final isSelected = _selectedType == type;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _onTypeFilterChanged(selected ? type : null);
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSizes.iconMd),
        const SizedBox(height: AppSizes.spaceXs),
        Text(
          value,
          style: TextStyle(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppSizes.fontXs,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
              hasSearchQuery ? 'Sonuç bulunamadı' : 'Henüz patron kaydı yok',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSizes.spaceSm),
            Text(
              hasSearchQuery
                  ? 'Farklı bir arama terimi deneyin'
                  : 'İlk işvereni ekleyerek başlayın',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearchQuery) ...[
              const SizedBox(height: AppSizes.spaceLg),
              ElevatedButton.icon(
                onPressed: _navigateToAddPatron,
                icon: const Icon(Icons.add),
                label: const Text('İlk Patronu Ekle'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
