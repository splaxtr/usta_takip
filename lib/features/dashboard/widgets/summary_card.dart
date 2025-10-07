import 'package:flutter/material.dart';

/// Standart Summary Card
///
/// Kullanım:
/// ```dart
/// SummaryCard(
///   title: 'Toplam Proje',
///   value: '24',
///   icon: Icons.work,
///   color: Colors.blue,
///   trend: '+12%',
///   trendUp: true,
/// )
/// ```
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final String? trend;
  final bool trendUp;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.trend,
    this.trendUp = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: trendUp
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendUp ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 14,
                            color: trendUp ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trend!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: trendUp ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact Summary Card (Daha küçük)
///
/// Kullanım:
/// ```dart
/// CompactSummaryCard(
///   title: 'Aktif',
///   value: '12',
///   icon: Icons.check_circle,
///   color: Colors.green,
/// )
/// ```
class CompactSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const CompactSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gradient Summary Card (Renkli geçişli)
///
/// Kullanım:
/// ```dart
/// GradientSummaryCard(
///   title: 'Toplam Gelir',
///   value: '₺450.000',
///   icon: Icons.payments,
///   gradient: LinearGradient(
///     colors: [Colors.purple, Colors.blue],
///   ),
/// )
/// ```
class GradientSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String? subtitle;
  final VoidCallback? onTap;

  const GradientSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress Summary Card (İlerleme göstergeli)
///
/// Kullanım:
/// ```dart
/// ProgressSummaryCard(
///   title: 'Proje İlerlemesi',
///   value: '75%',
///   progress: 0.75,
///   icon: Icons.trending_up,
///   color: Colors.orange,
/// )
/// ```
class ProgressSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final double progress;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const ProgressSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.progress,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: 24,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: cardColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List Summary Card (Liste görünümlü)
///
/// Kullanım:
/// ```dart
/// ListSummaryCard(
///   title: 'Bu Ay',
///   items: [
///     SummaryItem(label: 'Yeni Proje', value: '5'),
///     SummaryItem(label: 'Tamamlanan', value: '8'),
///     SummaryItem(label: 'İptal', value: '1'),
///   ],
/// )
/// ```
class ListSummaryCard extends StatelessWidget {
  final String title;
  final List<SummaryItem> items;
  final IconData? icon;
  final VoidCallback? onTap;

  const ListSummaryCard({
    super.key,
    required this.title,
    required this.items,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                size: 16,
                                color: item.color ?? Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: item.color,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon Summary Card (Büyük ikonlu)
///
/// Kullanım:
/// ```dart
/// IconSummaryCard(
///   icon: Icons.construction,
///   title: 'İnşaatlar',
///   value: '8',
///   subtitle: 'Aktif inşaat',
///   color: Colors.orange,
/// )
/// ```
class IconSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;
  final VoidCallback? onTap;

  const IconSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.primaryColor;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: cardColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Summary Item Model (Liste için)
class SummaryItem {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const SummaryItem({
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });
}

/// Kullanım örnekleri:
///
/// ```dart
/// // Standart summary card
/// SummaryCard(
///   title: 'Toplam Proje',
///   value: '24',
///   icon: Icons.work,
///   color: Colors.blue,
///   trend: '+12%',
///   trendUp: true,
///   subtitle: 'Bu ay 3 yeni',
/// )
///
/// // Compact card
/// CompactSummaryCard(
///   title: 'Aktif Projeler',
///   value: '12',
///   icon: Icons.check_circle,
///   color: Colors.green,
/// )
///
/// // Gradient card
/// GradientSummaryCard(
///   title: 'Toplam Gelir',
///   value: '₺450.000',
///   icon: Icons.payments,
///   gradient: LinearGradient(
///     colors: [Colors.purple, Colors.blue],
///   ),
///   subtitle: 'Bu ay +25%',
/// )
///
/// // Progress card
/// ProgressSummaryCard(
///   title: 'Genel İlerleme',
///   value: '75%',
///   progress: 0.75,
///   icon: Icons.trending_up,
///   color: Colors.orange,
/// )
///
/// // List card
/// ListSummaryCard(
///   title: 'Bu Ay',
///   items: [
///     SummaryItem(label: 'Yeni', value: '5', color: Colors.green),
///     SummaryItem(label: 'Devam Eden', value: '8', color: Colors.blue),
///     SummaryItem(label: 'Tamamlanan', value: '12', color: Colors.orange),
///   ],
/// )
///
/// // Icon card
/// IconSummaryCard(
///   icon: Icons.people,
///   title: 'Çalışanlar',
///   value: '48',
///   subtitle: '12 yeni bu ay',
///   color: Colors.teal,
/// )
/// ```
