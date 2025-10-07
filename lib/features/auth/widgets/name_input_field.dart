import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';

/// Ad/Soyad girişi için özelleştirilmiş TextField widget'ı
///
/// Kullanım:
/// ```dart
/// NameInputField(
///   controller: _nameController,
///   label: 'Ad',
///   hint: 'Adınızı girin',
/// )
/// ```
class NameInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const NameInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingSm,
            bottom: AppSizes.paddingSm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ),

        // TextField
        TextFormField(
          controller: controller,
          enabled: enabled,
          textInputAction: textInputAction ?? TextInputAction.next,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: enabled ? AppColors.primary : AppColors.textTertiary,
                  )
                : null,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: AppSizes.paddingMd,
            ),
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontSize: AppSizes.fontMd,
            ),
          ),
          validator: validator ?? _defaultValidator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }

  /// Varsayılan validator
  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.requiredField;
    }

    if (value.trim().length < 2) {
      return '$label en az 2 karakter olmalıdır';
    }

    if (value.trim().length > 50) {
      return '$label en fazla 50 karakter olabilir';
    }

    // Sadece harf ve boşluk kontrolü
    final nameRegex = RegExp(r'^[a-zA-ZğüşıöçĞÜŞİÖÇ\s]+$');
    if (!nameRegex.hasMatch(value.trim())) {
      return '$label sadece harf içermelidir';
    }

    return null;
  }
}

/// Özelleştirilmiş TextField widget'ı (genel kullanım için)
///
/// NameInputField'a alternatif olarak kullanılabilir
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingSm,
            bottom: AppSizes.paddingSm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
        ),

        // TextField
        TextFormField(
          controller: controller,
          enabled: enabled,
          readOnly: readOnly,
          obscureText: obscureText,
          textInputAction: textInputAction ?? TextInputAction.next,
          keyboardType: keyboardType,
          maxLines: obscureText ? 1 : maxLines,
          maxLength: maxLength,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
              ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: enabled ? AppColors.primary : AppColors.textTertiary,
                  )
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: AppSizes.paddingMd,
            ),
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontSize: AppSizes.fontMd,
            ),
            counterText: maxLength != null ? null : '',
          ),
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
        ),
      ],
    );
  }
}
