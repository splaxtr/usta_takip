import 'package:flutter/material.dart';

/// Standart Empty State Widget
///
/// Kullanım:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.folder_open,
///   title: 'Henüz Proje Yok',
///   description: 'İlk projenizi oluşturarak başlayın',
///   actionButtonText: 'Yeni Proje',
///   onActionPressed: () => _createProject(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;
  final double iconSize;
  final Color? iconColor;
  final Widget? customButton;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionButtonText,
    this.onActionPressed,
    this.iconSize = 80,
    this.iconColor,
    this.customButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? theme.primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: color.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (customButton != null) ...[
              const SizedBox(height: 32),
              customButton!,
            ] else if (actionButtonText != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add),
                label: Text(actionButtonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact Empty State (Daha küçük görünüm)
///
/// Kullanım:
/// ```dart
/// CompactEmptyState(
///   icon: Icons.inbox,
///   message: 'Gösterilecek öğe yok',
/// )
/// ```
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? submessage;
  final Color? iconColor;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.submessage,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = iconColor ?? Colors.grey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: color.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            if (submessage != null) ...[
              const SizedBox(height: 8),
              Text(
                submessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Illustration Empty State (Görsel ile)
///
/// Kullanım:
/// ```dart
/// IllustrationEmptyState(
///   illustration: 'assets/images/empty_projects.svg',
///   title: 'Henüz Proje Yok',
///   description: 'İlk projenizi oluşturun',
///   actionText: 'Başla',
///   onAction: () {},
/// )
/// ```
class IllustrationEmptyState extends StatelessWidget {
  final String illustration;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onAction;
  final double illustrationHeight;

  const IllustrationEmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.description,
    this.actionText,
    this.onAction,
    this.illustrationHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              illustration,
              height: illustrationHeight,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Search Empty State (Arama sonucu bulunamadı)
///
/// Kullanım:
/// ```dart
/// SearchEmptyState(
///   searchQuery: 'React',
///   onClearSearch: () => _clearSearch(),
/// )
/// ```
class SearchEmptyState extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;
  final String? customMessage;

  const SearchEmptyState({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sonuç Bulunamadı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              customMessage ?? '"$searchQuery" için sonuç bulunamadı',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onClearSearch != null) ...[
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: onClearSearch,
                icon: const Icon(Icons.close),
                label: const Text('Aramayı Temizle'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error Empty State (Hata durumu)
///
/// Kullanım:
/// ```dart
/// ErrorEmptyState(
///   title: 'Bir Hata Oluştu',
///   description: 'Veriler yüklenirken bir sorun oluştu',
///   onRetry: () => _loadData(),
/// )
/// ```
class ErrorEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorEmptyState({
    super.key,
    this.title = 'Bir Hata Oluştu',
    this.description = 'Veriler yüklenirken bir sorun oluştu',
    this.onRetry,
    this.retryButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading Empty State (Yükleniyor durumu)
///
/// Kullanım:
/// ```dart
/// LoadingEmptyState(
///   message: 'Veriler yükleniyor...',
/// )
/// ```
class LoadingEmptyState extends StatelessWidget {
  final String message;
  final Color? loaderColor;

  const LoadingEmptyState({
    super.key,
    this.message = 'Yükleniyor...',
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = loaderColor ?? theme.primaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// No Connection Empty State (İnternet bağlantısı yok)
///
/// Kullanım:
/// ```dart
/// NoConnectionEmptyState(
///   onRetry: () => _checkConnection(),
/// )
/// ```
class NoConnectionEmptyState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoConnectionEmptyState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off,
                size: 80,
                color: Colors.orange.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bağlantı Yok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'İnternet bağlantınızı kontrol edin ve tekrar deneyin',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Yenile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom Empty State Builder
///
/// Kullanım:
/// ```dart
/// CustomEmptyStateBuilder(
///   child: Column(
///     children: [
///       Icon(Icons.star, size: 80),
///       Text('Özel durum'),
///     ],
///   ),
/// )
/// ```
class CustomEmptyStateBuilder extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const CustomEmptyStateBuilder({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(32.0),
        child: child,
      ),
    );
  }
}

/// Kullanım örnekleri:
///
/// ```dart
/// // Standart empty state
/// EmptyStateWidget(
///   icon: Icons.folder_open,
///   title: 'Henüz Proje Yok',
///   description: 'İlk projenizi oluşturarak başlayın',
///   actionButtonText: 'Yeni Proje',
///   onActionPressed: () => _createProject(),
/// )
///
/// // Compact (küçük)
/// CompactEmptyState(
///   icon: Icons.inbox,
///   message: 'Gösterilecek öğe yok',
/// )
///
/// // Görsel ile
/// IllustrationEmptyState(
///   illustration: 'assets/images/empty.svg',
///   title: 'Başlayın',
///   description: 'Hemen ilk projenizi oluşturun',
/// )
///
/// // Arama sonucu
/// SearchEmptyState(
///   searchQuery: query,
///   onClearSearch: () => _clear(),
/// )
///
/// // Hata durumu
/// ErrorEmptyState(
///   title: 'Hata Oluştu',
///   description: 'Bir sorun oluştu',
///   onRetry: () => _retry(),
/// )
///
/// // Yükleniyor
/// LoadingEmptyState(
///   message: 'Projeler yükleniyor...',
/// )
///
/// // Bağlantı yok
/// NoConnectionEmptyState(
///   onRetry: () => _checkConnection(),
/// )
/// ```
