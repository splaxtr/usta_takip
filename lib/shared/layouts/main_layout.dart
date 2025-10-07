import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

/// Ana layout widget'ı
///
/// Bottom navigation bar ile birlikte çalışır ve ekranlar arası geçişi yönetir
///
/// Kullanım:
/// ```dart
/// MaterialApp(
///   home: MainLayout(),
/// )
/// ```
class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // TODO: Ekranları gerçek ekranlarla değiştirin
  final List<Widget> _screens = [
    const _PlaceholderScreen(title: 'Ana Sayfa', icon: Icons.home),
    const _PlaceholderScreen(title: 'Projeler', icon: Icons.work),
    const _PlaceholderScreen(title: 'Çalışanlar', icon: Icons.people),
    const _PlaceholderScreen(title: 'Finans', icon: Icons.payments),
    const _PlaceholderScreen(title: 'Profil', icon: Icons.person),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// IndexedStack kullanan alternatif layout (sayfa state'i korunur)
///
/// PageView'dan farklı olarak, tüm sayfalar bellekte tutulur ve
/// state korunur. Formlar, scroll pozisyonları vb. kaybolmaz.
///
/// Kullanım:
/// ```dart
/// MaterialApp(
///   home: MainLayoutWithStack(),
/// )
/// ```
class MainLayoutWithStack extends StatefulWidget {
  const MainLayoutWithStack({super.key});

  @override
  State<MainLayoutWithStack> createState() => _MainLayoutWithStackState();
}

class _MainLayoutWithStackState extends State<MainLayoutWithStack> {
  int _currentIndex = 0;

  // TODO: Ekranları gerçek ekranlarla değiştirin
  final List<Widget> _screens = [
    const _PlaceholderScreen(title: 'Ana Sayfa', icon: Icons.home),
    const _PlaceholderScreen(title: 'Projeler', icon: Icons.work),
    const _PlaceholderScreen(title: 'Çalışanlar', icon: Icons.people),
    const _PlaceholderScreen(title: 'Finans', icon: Icons.payments),
    const _PlaceholderScreen(title: 'Profil', icon: Icons.person),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

/// Floating bottom nav bar ile layout
///
/// Modern floating tasarım ile bottom navigation kullanır
///
/// Not: extendBody: true kullanıldığı için bottom navigation
/// içeriğin üzerinde durur. İçerikte SafeArea veya padding kullanın.
///
/// Kullanım:
/// ```dart
/// MaterialApp(
///   home: MainLayoutWithFloating(),
/// )
/// ```
class MainLayoutWithFloating extends StatefulWidget {
  const MainLayoutWithFloating({super.key});

  @override
  State<MainLayoutWithFloating> createState() => _MainLayoutWithFloatingState();
}

class _MainLayoutWithFloatingState extends State<MainLayoutWithFloating> {
  int _currentIndex = 0;

  final List<NavItem> _navItems = [
    const NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Ana Sayfa',
      screen: _PlaceholderScreen(title: 'Ana Sayfa', icon: Icons.home),
    ),
    const NavItem(
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      label: 'Projeler',
      screen: _PlaceholderScreen(title: 'Projeler', icon: Icons.work),
    ),
    const NavItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Çalışanlar',
      screen: _PlaceholderScreen(title: 'Çalışanlar', icon: Icons.people),
    ),
    const NavItem(
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments,
      label: 'Finans',
      screen: _PlaceholderScreen(title: 'Finans', icon: Icons.payments),
    ),
    const NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      screen: _PlaceholderScreen(title: 'Profil', icon: Icons.person),
    ),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navItems.map((item) => item.screen).toList(),
      ),
      extendBody: true,
      bottomNavigationBar: FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _navItems,
      ),
    );
  }
}

/// Gerçek ekranlarla kullanım için esnek layout
///
/// Ekranları ve nav item'ları dışarıdan alır.
/// En esnek kullanım şekli, production için önerilir.
///
/// Kullanım:
/// ```dart
/// MainLayoutWithRealScreens(
///   screens: [
///     const HomeScreen(),
///     const ProjectsListScreen(),
///     const EmployeesListScreen(),
///   ],
///   navItems: [
///     NavItem(
///       icon: Icons.home_outlined,
///       activeIcon: Icons.home,
///       label: 'Ana Sayfa',
///       screen: const HomeScreen(),
///     ),
///     // ... diğer items
///   ],
/// )
/// ```
class MainLayoutWithRealScreens extends StatefulWidget {
  final List<Widget> screens;
  final List<NavItem>? navItems;
  final bool useStack;
  final bool useFloating;

  const MainLayoutWithRealScreens({
    super.key,
    required this.screens,
    this.navItems,
    this.useStack = true,
    this.useFloating = false,
  });

  @override
  State<MainLayoutWithRealScreens> createState() =>
      _MainLayoutWithRealScreensState();
}

class _MainLayoutWithRealScreensState extends State<MainLayoutWithRealScreens> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    if (!widget.useStack) {
      _pageController = PageController();
    }
  }

  @override
  void dispose() {
    if (!widget.useStack) {
      _pageController.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (!widget.useStack) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.useStack
          ? IndexedStack(
              index: _currentIndex,
              children: widget.screens,
            )
          : PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: widget.screens,
            ),
      extendBody: widget.useFloating,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    if (widget.navItems != null && widget.useFloating) {
      return FloatingBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: widget.navItems!,
      );
    }

    if (widget.navItems != null) {
      return FlexibleBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: widget.navItems!,
      );
    }

    return CustomBottomNavBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
    );
  }
}

/// Minimal layout (Sadece ikonlar ile)
///
/// Label'lar olmadan, sadece ikonlarla bottom navigation
///
/// Kullanım:
/// ```dart
/// MaterialApp(
///   home: MainLayoutMinimal(),
/// )
/// ```
class MainLayoutMinimal extends StatefulWidget {
  final List<NavItem> navItems;

  const MainLayoutMinimal({
    super.key,
    required this.navItems,
  });

  @override
  State<MainLayoutMinimal> createState() => _MainLayoutMinimalState();
}

class _MainLayoutMinimalState extends State<MainLayoutMinimal> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: widget.navItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: MinimalBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: widget.navItems,
      ),
    );
  }
}

/// Placeholder ekran (geliştirme için)
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Bu ekran henüz oluşturulmadı',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layout kullanım örnekleri (main.dart için)
/// 
/// ```dart
/// void main() {
///   runApp(const MyApp());
/// }
/// 
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
/// 
///   @override
///   Widget build(BuildContext context) {
///     // Örnek 1: Basit kullanım
///     return MaterialApp(
///       title: 'İnşaat Yönetim',
///       theme: AppTheme.lightTheme,
///       home: const MainLayout(),
///     );
///     
///     // Örnek 2: State korumalı (IndexedStack)
///     return MaterialApp(
///       title: 'İnşaat Yönetim',
///       theme: AppTheme.lightTheme,
///       home: const MainLayoutWithStack(),
///     );
///     
///     // Örnek 3: Floating navigation
///     return MaterialApp(
///       title: 'İnşaat Yönetim',
///       theme: AppTheme.lightTheme,
///       home: const MainLayoutWithFloating(),
///     );
///     
///     // Örnek 4: Gerçek ekranlarla (Production)
///     return MaterialApp(
///       title: 'İnşaat Yönetim',
///       theme: AppTheme.lightTheme,
///       home: MainLayoutWithRealScreens(
///         useStack: true, // State korumak için
///         useFloating: false, // Normal veya floating nav
///         screens: [
///           const HomeScreen(),
///           const ProjectsListScreen(),
///           const EmployeesListScreen(),
///           const FinancialsScreen(),
///           const ProfileScreen(),
///         ],
///         navItems: [
///           const NavItem(
///             icon: Icons.home_outlined,
///             activeIcon: Icons.home,
///             label: 'Ana Sayfa',
///             screen: HomeScreen(),
///           ),
///           const NavItem(
///             icon: Icons.work_outline,
///             activeIcon: Icons.work,
///             label: 'Projeler',
///             screen: ProjectsListScreen(),
///           ),
///           const NavItem(
///             icon: Icons.people_outline,
///             activeIcon: Icons.people,
///             label: 'Çalışanlar',
///             screen: EmployeesListScreen(),
///           ),
///           const NavItem(
///             icon: Icons.payments_outlined,
///             activeIcon: Icons.payments,
///             label: 'Finans',
///             screen: FinancialsScreen(),
///           ),
///           const NavItem(
///             icon: Icons.person_outline,
///             activeIcon: Icons.person,
///             label: 'Profil',
///             screen: ProfileScreen(),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// ```
/// 
/// Layout Seçim Rehberi:
/// - MainLayout: Basit projeler için, animasyonlu geçişler
/// - MainLayoutWithStack: State korunması gerekiyorsa (formlar, scroll)
/// - MainLayoutWithFloating: Modern, floating tasarım istiyorsanız
/// - MainLayoutWithRealScreens: Production için, en esnek seçenek
/// - MainLayoutMinimal: Minimalist tasarım, sadece ikonlar