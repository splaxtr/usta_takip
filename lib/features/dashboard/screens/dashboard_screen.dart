import 'package:flutter/material.dart';
import '../widgets/greeting_header.dart';
import '../widgets/summary_card.dart';
import '../widgets/project_card.dart';

/// Standart Dashboard Screen
///
/// Kullanım:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const DashboardScreen(userName: 'Ahmet Yılmaz'),
///   ),
/// )
/// ```
class DashboardScreen extends StatefulWidget {
  final String userName;

  const DashboardScreen({
    super.key,
    required this.userName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header
              GreetingHeader(
                userName: widget.userName,
                subtitle: 'Bugün 5 aktif projeniz var',
                onNotificationTap: () => _showNotifications(),
                notificationCount: 3,
              ),

              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Genel Bakış',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Toplam Proje',
                            value: '24',
                            icon: Icons.work,
                            color: Colors.blue,
                            trend: '+12%',
                            trendUp: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Aktif Proje',
                            value: '5',
                            icon: Icons.trending_up,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            title: 'Çalışanlar',
                            value: '48',
                            icon: Icons.people,
                            color: Colors.orange,
                            trend: '+8%',
                            trendUp: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            title: 'Bu Ay',
                            value: '₺450K',
                            icon: Icons.payments,
                            color: Colors.purple,
                            trend: '+25%',
                            trendUp: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Recent Projects
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Aktif Projeler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _viewAllProjects(),
                      child: const Text('Tümünü Gör'),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ProjectCard(
                      projectName: 'Konut Projesi A',
                      location: 'İstanbul, Kadıköy',
                      status: ProjectStatus.inProgress,
                      progress: 0.65,
                      teamSize: 12,
                      dueDate: DateTime.now().add(const Duration(days: 30)),
                      budget: '₺2.500.000',
                      onTap: () => _openProject(1),
                    ),
                    const SizedBox(height: 12),
                    ProjectCard(
                      projectName: 'Ofis Binası B',
                      location: 'Ankara, Çankaya',
                      status: ProjectStatus.planning,
                      progress: 0.25,
                      teamSize: 8,
                      dueDate: DateTime.now().add(const Duration(days: 60)),
                      budget: '₺3.200.000',
                      onTap: () => _openProject(2),
                    ),
                    const SizedBox(height: 12),
                    ProjectCard(
                      projectName: 'Alışveriş Merkezi C',
                      location: 'İzmir, Konak',
                      status: ProjectStatus.inProgress,
                      progress: 0.82,
                      teamSize: 15,
                      dueDate: DateTime.now().add(const Duration(days: 15)),
                      budget: '₺5.800.000',
                      onTap: () => _openProject(3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotifications() {
    // TODO: Bildirimler sayfasına git
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bildirimler açılıyor...')),
    );
  }

  void _viewAllProjects() {
    // TODO: Tüm projeler sayfasına git
    Navigator.pushNamed(context, '/projects');
  }

  void _openProject(int id) {
    // TODO: Proje detay sayfasına git
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Proje $id açılıyor...')),
    );
  }
}

/// Compact Dashboard Screen (Daha basit görünüm)
///
/// Kullanım:
/// ```dart
/// CompactDashboardScreen(userName: 'Ahmet')
/// ```
class CompactDashboardScreen extends StatelessWidget {
  final String userName;

  const CompactDashboardScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              CompactGreetingHeader(
                userName: userName,
                onAvatarTap: () {},
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CompactSummaryCard(
                            title: 'Projeler',
                            value: '24',
                            icon: Icons.work,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CompactSummaryCard(
                            title: 'Çalışanlar',
                            value: '48',
                            icon: Icons.people,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  CompactProjectCard(
                    projectName: 'Konut Projesi A',
                    status: ProjectStatus.inProgress,
                    progress: 0.65,
                  ),
                  CompactProjectCard(
                    projectName: 'Ofis Binası B',
                    status: ProjectStatus.planning,
                    progress: 0.25,
                  ),
                  CompactProjectCard(
                    projectName: 'Alışveriş Merkezi C',
                    status: ProjectStatus.inProgress,
                    progress: 0.82,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extended Dashboard Screen (Detaylı görünüm)
///
/// Kullanım:
/// ```dart
/// ExtendedDashboardScreen(
///   userName: 'Ahmet Yılmaz',
///   role: 'Proje Müdürü',
/// )
/// ```
class ExtendedDashboardScreen extends StatefulWidget {
  final String userName;
  final String? role;

  const ExtendedDashboardScreen({
    super.key,
    required this.userName,
    this.role,
  });

  @override
  State<ExtendedDashboardScreen> createState() =>
      _ExtendedDashboardScreenState();
}

class _ExtendedDashboardScreenState extends State<ExtendedDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Gradient
          SliverToBoxAdapter(
            child: ExtendedGreetingHeader(
              userName: widget.userName,
              role: widget.role,
              stats: const [
                HeaderStat(label: 'Aktif', value: '5'),
                HeaderStat(label: 'Ekip', value: '48'),
                HeaderStat(label: 'Tamamlanan', value: '23'),
              ],
              onNotificationTap: () {},
              notificationCount: 3,
            ),
          ),

          // Summary Cards
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  GradientSummaryCard(
                    title: 'Toplam Gelir',
                    value: '₺12.5M',
                    icon: Icons.payments,
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                    subtitle: 'Bu yıl +35%',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ProgressSummaryCard(
                          title: 'Genel İlerleme',
                          value: '68%',
                          progress: 0.68,
                          icon: Icons.trending_up,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ListSummaryCard(
                          title: 'Bu Ay',
                          items: const [
                            SummaryItem(
                              label: 'Yeni',
                              value: '3',
                              color: Colors.green,
                            ),
                            SummaryItem(
                              label: 'Devam',
                              value: '5',
                              color: Colors.blue,
                            ),
                            SummaryItem(
                              label: 'Bitti',
                              value: '2',
                              color: Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Section Header
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Son Projeler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Tümünü Gör'),
                  ),
                ],
              ),
            ),
          ),

          // Project Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildListDelegate([
                GridProjectCard(
                  projectName: 'Konut Projesi A',
                  status: ProjectStatus.inProgress,
                  progress: 0.65,
                  placeholderIcon: Icons.apartment,
                ),
                GridProjectCard(
                  projectName: 'Ofis Binası B',
                  status: ProjectStatus.planning,
                  progress: 0.25,
                  placeholderIcon: Icons.business,
                ),
                GridProjectCard(
                  projectName: 'AVM C',
                  status: ProjectStatus.inProgress,
                  progress: 0.82,
                  placeholderIcon: Icons.shopping_bag,
                ),
                GridProjectCard(
                  projectName: 'Köprü Projesi',
                  status: ProjectStatus.planning,
                  progress: 0.15,
                  placeholderIcon: Icons.architecture,
                ),
              ]),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }
}

/// Minimal Dashboard Screen (Minimalist görünüm)
///
/// Kullanım:
/// ```dart
/// MinimalDashboardScreen(userName: 'Ahmet')
/// ```
class MinimalDashboardScreen extends StatelessWidget {
  final String userName;

  const MinimalDashboardScreen({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MinimalGreetingHeader(userName: userName),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Aktif Projeler',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  MinimalProjectCard(
                    projectName: 'Konut Projesi A',
                    status: ProjectStatus.inProgress,
                  ),
                  MinimalProjectCard(
                    projectName: 'Ofis Binası B',
                    status: ProjectStatus.planning,
                  ),
                  MinimalProjectCard(
                    projectName: 'Alışveriş Merkezi C',
                    status: ProjectStatus.inProgress,
                  ),
                  MinimalProjectCard(
                    projectName: 'Köprü Projesi D',
                    status: ProjectStatus.onHold,
                  ),
                  MinimalProjectCard(
                    projectName: 'Rezidans E',
                    status: ProjectStatus.completed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kullanım örnekleri:
///
/// ```dart
/// // main.dart içinde
/// void main() {
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'İnşaat Yönetim',
///       theme: ThemeData(
///         primarySwatch: Colors.blue,
///         useMaterial3: true,
///       ),
///       // Standart Dashboard
///       home: const DashboardScreen(userName: 'Ahmet Yılmaz'),
///       
///       // Veya Compact Dashboard
///       // home: const CompactDashboardScreen(userName: 'Ahmet'),
///       
///       // Veya Extended Dashboard
///       // home: const ExtendedDashboardScreen(
///       //   userName: 'Ahmet Yılmaz',
///       //   role: 'Proje Müdürü',
///       // ),
///       
///       // Veya Minimal Dashboard
///       // home: const MinimalDashboardScreen(userName: 'Ahmet'),
///     );
///   }
/// }
/// ```
///
/// Dashboard Seçim Rehberi:
/// - DashboardScreen: Standart, dengeli görünüm (önerilen)
/// - CompactDashboardScreen: Daha küçük ekranlar için
/// - ExtendedDashboardScreen: Zengin içerik ve detaylı bilgi
/// - MinimalDashboardScreen: Minimalist, temiz tasarım