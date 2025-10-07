import 'package:flutter/material.dart';

/// Standart Custom Button
///
/// Kullanım:
/// ```dart
/// CustomButton(
///   text: 'Kaydet',
///   onPressed: () => print('Tıklandı'),
///   icon: Icons.save,
/// )
/// ```
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final IconData? icon;
  final bool enabled;
  final EdgeInsets? padding;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.icon,
    this.enabled = true,
    this.padding,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = backgroundColor ?? theme.primaryColor;
    final onPrimaryColor = textColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: enabled && !isLoading ? onPressed : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: padding,
              ),
              child: _buildButtonContent(primaryColor),
            )
          : ElevatedButton(
              onPressed: enabled && !isLoading ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: onPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                elevation: 2,
                disabledBackgroundColor: primaryColor.withOpacity(0.5),
                padding: padding,
              ),
              child: _buildButtonContent(onPrimaryColor),
            ),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

/// Icon Button (Sadece ikon)
///
/// Kullanım:
/// ```dart
/// IconCustomButton(
///   icon: Icons.add,
///   onPressed: () => print('Eklendi'),
///   tooltip: 'Yeni Ekle',
/// )
/// ```
class IconCustomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  final bool enabled;

  const IconCustomButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.primaryColor;
    final fgColor = iconColor ?? Colors.white;

    final button = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: enabled ? bgColor : bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Icon(icon, color: fgColor, size: 24),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Text Button (Sadece metin, arka plan yok)
///
/// Kullanım:
/// ```dart
/// TextCustomButton(
///   text: 'İptal',
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class TextCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final bool enabled;
  final IconData? icon;

  const TextCustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.enabled = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = textColor ?? theme.primaryColor;

    return TextButton(
      onPressed: enabled ? onPressed : null,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
    );
  }
}

/// Gradient Button (Renkli geçişli buton)
///
/// Kullanım:
/// ```dart
/// GradientButton(
///   text: 'Başlat',
///   onPressed: () => print('Başlatıldı'),
///   gradient: LinearGradient(
///     colors: [Colors.blue, Colors.purple],
///   ),
/// )
/// ```
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;
  final bool enabled;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.gradient,
    this.isLoading = false,
    this.width,
    this.height = 50,
    this.icon,
    this.enabled = true,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled ? gradient : null,
          color: enabled ? null : Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ElevatedButton(
          onPressed: enabled && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }
}

/// Social Media Button (Sosyal medya login butonları)
///
/// Kullanım:
/// ```dart
/// SocialButton(
///   type: SocialButtonType.google,
///   onPressed: () => print('Google ile giriş'),
/// )
/// ```
enum SocialButtonType { google, apple, facebook, github }

class SocialButton extends StatelessWidget {
  final SocialButtonType type;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const SocialButton({
    super.key,
    required this.type,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(),
                  const SizedBox(width: 12),
                  Text(
                    _getText(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case SocialButtonType.google:
        return const Icon(Icons.g_mobiledata, size: 28, color: Colors.red);
      case SocialButtonType.apple:
        return const Icon(Icons.apple, size: 24, color: Colors.black);
      case SocialButtonType.facebook:
        return const Icon(Icons.facebook, size: 24, color: Colors.blue);
      case SocialButtonType.github:
        return const Icon(Icons.code, size: 24, color: Colors.black);
    }
  }

  String _getText() {
    switch (type) {
      case SocialButtonType.google:
        return 'Google ile Devam Et';
      case SocialButtonType.apple:
        return 'Apple ile Devam Et';
      case SocialButtonType.facebook:
        return 'Facebook ile Devam Et';
      case SocialButtonType.github:
        return 'GitHub ile Devam Et';
    }
  }
}

/// Floating Action Button Özelleştirilmiş
///
/// Kullanım:
/// ```dart
/// CustomFAB(
///   icon: Icons.add,
///   onPressed: () => print('Yeni eklendi'),
///   tooltip: 'Yeni Ekle',
/// )
/// ```
class CustomFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool isExtended;
  final String? label;
  final bool isLoading;

  const CustomFAB({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.isExtended = false,
    this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.primaryColor;
    final fgColor = iconColor ?? Colors.white;

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: isLoading ? null : onPressed,
        backgroundColor: bgColor,
        tooltip: tooltip,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(icon, color: fgColor),
        label: Text(
          label!,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: bgColor,
      tooltip: tooltip,
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(icon, color: fgColor),
    );
  }
}

/// Button Size presets
class ButtonSize {
  static const double small = 40;
  static const double medium = 50;
  static const double large = 56;
}

/// Kullanım örnekleri:
///
/// ```dart
/// // Standart buton
/// CustomButton(
///   text: 'Kaydet',
///   onPressed: () {},
///   icon: Icons.save,
/// )
///
/// // Outlined buton
/// CustomButton(
///   text: 'İptal',
///   onPressed: () {},
///   isOutlined: true,
/// )
///
/// // Loading buton
/// CustomButton(
///   text: 'Yükleniyor',
///   onPressed: () {},
///   isLoading: true,
/// )
///
/// // Icon buton
/// IconCustomButton(
///   icon: Icons.add,
///   onPressed: () {},
///   tooltip: 'Yeni Ekle',
/// )
///
/// // Text buton
/// TextCustomButton(
///   text: 'İptal',
///   onPressed: () {},
/// )
///
/// // Gradient buton
/// GradientButton(
///   text: 'Başlat',
///   onPressed: () {},
///   gradient: LinearGradient(
///     colors: [Colors.blue, Colors.purple],
///   ),
/// )
///
/// // Social buton
/// SocialButton(
///   type: SocialButtonType.google,
///   onPressed: () {},
/// )
///
/// // FAB
/// CustomFAB(
///   icon: Icons.add,
///   onPressed: () {},
///   isExtended: true,
///   label: 'Yeni Ekle',
/// )
/// ```
