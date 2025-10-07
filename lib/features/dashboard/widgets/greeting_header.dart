import 'package:flutter/material.dart';

/// Standart Greeting Header
///
/// Kullanım:
/// ```dart
/// GreetingHeader(
///   userName: 'Ahmet Yılmaz',
///   subtitle: 'Bugün 5 aktif projeniz var',
/// )
/// ```
class GreetingHeader extends StatelessWidget {
  final String userName;
  final String? subtitle;
  final String? avatarUrl;
  final VoidCallback? onNotificationTap;
  final int notificationCount;
  final bool showDate;

  const GreetingHeader({
    super.key,
    required this.userName,
    this.subtitle,
    this.avatarUrl,
    this.onNotificationTap,
    this.notificationCount = 0,
    this.showDate = true,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın';
    } else if (hour < 18) {
      return 'İyi günler';
    } else {
      return 'İyi akşamlar';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    final days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (avatarUrl != null)
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(avatarUrl!),
            )
          else
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.primaryColor.withOpacity(0.2),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()}, $userName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ] else if (showDate) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onNotificationTap != null)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: onNotificationTap,
                  iconSize: 28,
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Compact Greeting Header (Daha küçük)
///
/// Kullanım:
/// ```dart
/// CompactGreetingHeader(
///   userName: 'Ahmet',
/// )
/// ```
class CompactGreetingHeader extends StatelessWidget {
  final String userName;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;

  const CompactGreetingHeader({
    super.key,
    required this.userName,
    this.onAvatarTap,
    this.avatarUrl,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${_getGreeting()}, $userName 👋',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAvatarTap,
            child: avatarUrl != null
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl!),
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.primaryColor.withOpacity(0.2),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Extended Greeting Header (Detaylı bilgi ile)
///
/// Kullanım:
/// ```dart
/// ExtendedGreetingHeader(
///   userName: 'Ahmet Yılmaz',
///   role: 'Proje Müdürü',
///   stats: [
///     HeaderStat(label: 'Aktif Proje', value: '5'),
///     HeaderStat(label: 'Ekip', value: '12'),
///   ],
/// )
/// ```
class ExtendedGreetingHeader extends StatelessWidget {
  final String userName;
  final String? role;
  final String? avatarUrl;
  final List<HeaderStat> stats;
  final VoidCallback? onNotificationTap;
  final int notificationCount;

  const ExtendedGreetingHeader({
    super.key,
    required this.userName,
    this.role,
    this.avatarUrl,
    this.stats = const [],
    this.onNotificationTap,
    this.notificationCount = 0,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                avatarUrl != null
                    ? CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(avatarUrl!),
                      )
                    : CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()},',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (role != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          role!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onNotificationTap != null)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: onNotificationTap,
                        iconSize: 28,
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              notificationCount > 9
                                  ? '9+'
                                  : '$notificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            if (stats.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: stats
                    .map((stat) => Expanded(
                          child: _buildStatItem(stat),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(HeaderStat stat) {
    return Column(
      children: [
        Text(
          stat.value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Minimal Greeting Header
///
/// Kullanım:
/// ```dart
/// MinimalGreetingHeader(
///   userName: 'Ahmet',
/// )
/// ```
class MinimalGreetingHeader extends StatelessWidget {
  final String userName;

  const MinimalGreetingHeader({
    super.key,
    required this.userName,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(
        '${_getGreeting()}, $userName 👋',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Header Stat Model (İstatistik bilgisi için)
class HeaderStat {
  final String label;
  final String value;
  final IconData? icon;

  const HeaderStat({
    required this.label,
    required this.value,
    this.icon,
  });
}

/// Kullanım örnekleri:
///
/// ```dart
/// // Standart header
/// GreetingHeader(
///   userName: 'Ahmet Yılmaz',
///   subtitle: 'Bugün 5 aktif projeniz var',
///   avatarUrl: 'https://example.com/avatar.jpg',
///   onNotificationTap: () => _showNotifications(),
///   notificationCount: 3,
/// )
///
/// // Compact header
/// CompactGreetingHeader(
///   userName: 'Ahmet',
///   onAvatarTap: () => _goToProfile(),
/// )
///
/// // Extended header
/// ExtendedGreetingHeader(
///   userName: 'Ahmet Yılmaz',
///   role: 'Proje Müdürü',
///   stats: [
///     HeaderStat(label: 'Aktif Proje', value: '5'),
///     HeaderStat(label: 'Ekip Üyesi', value: '12'),
///     HeaderStat(label: 'Tamamlanan', value: '23'),
///   ],
///   onNotificationTap: () => _showNotifications(),
///   notificationCount: 3,
/// )
///
/// // Minimal header
/// MinimalGreetingHeader(
///   userName: 'Ahmet',
/// )
/// ```
