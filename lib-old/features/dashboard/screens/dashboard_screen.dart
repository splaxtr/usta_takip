import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../projects/screens/add_project_screen.dart';
import '../../projects/screens/project_detail_screen.dart';
import '../../projects/screens/projects_list_screen.dart';
import '../../employees/screens/employees_list_screen.dart';
import '../../patrons/screens/patrons_list_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/number_formatter.dart';

class DashboardScreen extends StatelessWidget {
  final Box userBox = Hive.box('user');
  final Box projeBox = Hive.box('projeler');
  final Box calisanBox = Hive.box('calisanlar');
  final Box gelirGiderBox = Hive.box('gelirgider');
  final Box mesaiBox = Hive.box('mesailer');

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String fullName = userBox.get('fullName', defaultValue: 'Usta');

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: Text(
                  "Dashboard",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hoş geldin, $fullName!",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Özet kartlar bölümü
                    ValueListenableBuilder(
                      valueListenable: Hive.box('projeler').listenable(),
                      builder: (context, Box projeBox, _) {
                        return ValueListenableBuilder(
                          valueListenable: Hive.box('gelirgider').listenable(),
                          builder: (context, Box gelirGiderBox, _) {
                            return ValueListenableBuilder(
                              valueListenable:
                                  Hive.box('mesailer').listenable(),
                              builder: (context, Box mesaiBox, _) {
                                // Aktif proje sayısı
                                int totalProjects = projeBox.values
                                    .where((p) => p['status'] == 'active')
                                    .length;

                                // Net Bakiye - gelir/gider
                                double totalIncome = 0.0;
                                double totalExpense = 0.0;

                                // Gelir/Gider hesapla
                                for (var item in gelirGiderBox.values) {
                                  if (item['type'] == 'gelir' ||
                                      item['type'] == 'income') {
                                    totalIncome +=
                                        ((item['amount'] ?? 0.0) as num)
                                            .toDouble();
                                  } else if (item['type'] == 'gider' ||
                                      item['type'] == 'expense') {
                                    totalExpense +=
                                        ((item['amount'] ?? 0.0) as num)
                                            .toDouble();
                                  }
                                }

                                // Sadece ÖDENMİŞ maaşları gidere ekle
                                for (var mesai in mesaiBox.values) {
                                  if (mesai['totalPaid'] != null &&
                                      mesai['totalPaid'] > 0) {
                                    totalExpense +=
                                        ((mesai['totalPaid'] ?? 0.0) as num)
                                            .toDouble();
                                  }
                                }

                                double netBalance = totalIncome - totalExpense;

                                // TOPLAM ÇALIŞAN SAYISI - ✅ DÜZELTME BURASI
                                Set<int> uniqueEmployeeKeys = {};
                                for (var mesai in mesaiBox.values) {
                                  if (mesai['employeeKey'] != null) {
                                    uniqueEmployeeKeys
                                        .add(mesai['employeeKey'] as int);
                                  }
                                }
                                int totalEmployees = uniqueEmployeeKeys.length;

                                return Column(
                                  children: [
                                    _buildSummaryCard(
                                      title: "Aktif Projeler",
                                      value: "$totalProjects",
                                      subtitle: "Devam eden projeler",
                                      icon: Icons.construction,
                                    ),
                                    _buildSummaryCard(
                                      title: "Toplam Çalışan Sayısı",
                                      value: "$totalEmployees",
                                      subtitle: "Çalışan var",
                                      icon: Icons.groups,
                                    ),
                                    _buildSummaryCard(
                                      title: "Net Bakiye",
                                      value: NumberFormatter.formatCurrency(
                                          netBalance),
                                      subtitle:
                                          netBalance >= 0 ? "Kazanç" : "Zarar",
                                      icon: Icons.account_balance_wallet,
                                      valueColor: netBalance >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Aktif Projeler Başlık
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Aktif Projeler",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (projeBox.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProjectsListScreen()),
                              );
                            },
                            child: const Text(
                              "Tümünü Gör",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Proje listesi
                    _buildProjectsList(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Alt Menü
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF101922).withOpacity(0.9),
          border: Border(top: BorderSide(color: Colors.grey.shade800)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(
              Icons.business_center,
              "Patronlar",
              false,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PatronsListScreen()),
                );
              },
            ),
            _buildBottomNavItem(
              Icons.engineering,
              "Çalışanlar",
              false,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EmployeesListScreen()),
                );
              },
            ),
            _buildBottomNavItem(
              Icons.home,
              "Ana Sayfa",
              true,
              () {},
            ),
            _buildBottomNavItem(
              Icons.work,
              "Projeler",
              false,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProjectsListScreen()),
                );
              },
            ),
            _buildBottomNavItem(
              Icons.attach_money,
              "Gelir&Gider",
              false,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Gelir & Gider özeti Dashboard\'da görüntülenir'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProjectScreen()),
          );

          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Proje başarıyla eklendi!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: projeBox.listenable(),
      builder: (context, Box projelerBox, _) {
        return ValueListenableBuilder(
          valueListenable: mesaiBox.listenable(),
          builder: (context, Box mesaiBox, _) {
            return ValueListenableBuilder(
              valueListenable: gelirGiderBox.listenable(),
              builder: (context, Box gelirGiderBox, _) {
                // ✅ Sadece aktif projeleri filtrele
                List<Map<String, dynamic>> activeProjects = [];

                for (int index = 0; index < projelerBox.length; index++) {
                  final project = projelerBox.getAt(index) as Map;

                  // Sadece aktif projeleri ekle
                  if (project['status'] == 'active') {
                    int employeeCount = 0;
                    double projectIncome = 0;
                    double projectExpenses = 0;

                    for (var mesai in mesaiBox.values) {
                      if (mesai is Map && mesai['projectKey'] == index) {
                        employeeCount++;
                      }
                    }

                    for (var item in gelirGiderBox.values) {
                      if (item is Map && item['projectKey'] == index) {
                        if (item['type'] == 'gelir') {
                          projectIncome += (item['amount'] ?? 0.0);
                        } else if (item['type'] == 'gider') {
                          projectExpenses += (item['amount'] ?? 0.0);
                        }
                      }
                    }

                    for (var mesai in mesaiBox.values) {
                      if (mesai is Map && mesai['projectKey'] == index) {
                        if (mesai['workDetails'] != null) {
                          List workDetails = mesai['workDetails'];
                          for (var detail in workDetails) {
                            projectExpenses += (detail['wage'] ?? 0.0);
                          }
                        }
                      }
                    }

                    activeProjects.add({
                      'index': index,
                      'data': {
                        ...project,
                        'employeeCount': employeeCount,
                        'income': projectIncome,
                        'expenses': projectExpenses,
                      }
                    });
                  }
                }

                if (activeProjects.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeProjects.length,
                  itemBuilder: (context, index) {
                    return _buildProjectCard(
                      context,
                      activeProjects[index]['data'],
                      activeProjects[index]['index'],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, dynamic project, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectKey: index),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.blueGrey,
                image: project['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(project['imageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: project['imageUrl'] == null
                  ? const Icon(Icons.construction, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project['name'] ?? 'Proje',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Başlama: ${project['startDate'] ?? '-'}",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 14, color: Colors.blue[300]),
                      const SizedBox(width: 4),
                      Text(
                        "${project['employeeCount'] ?? 0}",
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.arrow_upward,
                          size: 14, color: Colors.green[300]),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormatter.formatCurrency(double.tryParse(
                                    project['income']?.toString() ?? '0') ??
                                0.0 // ✅ Güvenli parse
                            ),
                        style: TextStyle(
                          color: Colors.green[300],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.arrow_downward,
                          size: 14, color: Colors.red[300]),
                      const SizedBox(width: 4),
                      Text(
                        NumberFormatter.formatCurrency(double.tryParse(
                                    project['expenses']?.toString() ?? '0') ??
                                0.0 // ✅ Güvenli parse
                            ),
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz proje yok',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni bir proje eklemek için + butonuna tıklayın',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
