import 'package:flutter/material.dart';

/// Navigation item modeli
///
/// Bottom navigation bar için kullanılan item yapısı
class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;
  final Color? color;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
    this.color,
  });
}

/// Standart Bottom Navigation Bar
///
/// Kullanım:
/// ```dart
/// CustomBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
/// )
/// ```
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Ana Sayfa',
                index: 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.work_outline,
                activeIcon: Icons.work,
                label: 'Projeler',
                index: 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Çalışanlar',
                index: 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.payments_outlined,
                activeIcon: Icons.payments,
                label: 'Finans',
                index: 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isActive = currentIndex == index;
    final color = isActive ? theme.primaryColor : Colors.grey[600];

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating Bottom Navigation Bar
///
/// Modern floating tasarım ile bottom navigation
///
/// Kullanım:
/// ```dart
/// FloatingBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
///   items: navItems,
/// )
/// ```
class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _buildFloatingNavItem(
              context: context,
              item: items[index],
              index: index,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required BuildContext context,
    required NavItem item,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isActive = currentIndex == index;
    final color = item.color ?? theme.primaryColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? color : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? color : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flexible Bottom Navigation Bar
///
/// NavItem listesi ile çalışan esnek bottom navigation
///
/// Kullanım:
/// ```dart
/// FlexibleBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
///   items: navItems,
/// )
/// ```
class FlexibleBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final bool showLabels;
  final double elevation;

  const FlexibleBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.showLabels = true,
    this.elevation = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _buildFlexibleNavItem(
                context: context,
                item: items[index],
                index: index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlexibleNavItem({
    required BuildContext context,
    required NavItem item,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isActive = currentIndex == index;
    final color = item.color ?? theme.primaryColor;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? color : Colors.grey[600],
                size: 24,
              ),
              if (showLabels) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? color : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal Bottom Navigation Bar (Sadece ikonlar)
///
/// Kullanım:
/// ```dart
/// MinimalBottomNavBar(
///   currentIndex: _currentIndex,
///   onTap: (index) => setState(() => _currentIndex = index),
///   items: navItems,
/// )
/// ```
class MinimalBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;

  const MinimalBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            items.length,
            (index) => _buildMinimalNavItem(
              context: context,
              item: items[index],
              index: index,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalNavItem({
    required BuildContext context,
    required NavItem item,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isActive = currentIndex == index;
    final color = item.color ?? theme.primaryColor;

    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        isActive ? item.activeIcon : item.icon,
        color: isActive ? color : Colors.grey[600],
        size: 28,
      ),
      splashRadius: 24,
    );
  }
}

/// Kullanım örnekleri:
///
/// ```dart
/// // Standart Bottom Nav Bar
/// Scaffold(
///   bottomNavigationBar: CustomBottomNavBar(
///     currentIndex: _currentIndex,
///     onTap: (index) => setState(() => _currentIndex = index),
///   ),
/// )
///
/// // Floating Bottom Nav Bar
/// Scaffold(
///   extendBody: true,
///   bottomNavigationBar: FloatingBottomNavBar(
///     currentIndex: _currentIndex,
///     onTap: (index) => setState(() => _currentIndex = index),
///     items: navItems,
///   ),
/// )
///
/// // Flexible Bottom Nav Bar
/// Scaffold(
///   bottomNavigationBar: FlexibleBottomNavBar(
///     currentIndex: _currentIndex,
///     onTap: (index) => setState(() => _currentIndex = index),
///     items: navItems,
///     showLabels: false, // Sadece ikonlar
///   ),
/// )
/// ```
