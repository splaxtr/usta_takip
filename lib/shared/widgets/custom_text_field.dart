import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standart Custom TextField
///
/// Kullanım:
/// ```dart
/// CustomTextField(
///   label: 'E-posta',
///   hint: 'ornek@email.com',
///   controller: emailController,
///   prefixIcon: Icons.email,
/// )
/// ```
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final String? helperText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool showLabel;
  final bool filled;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.errorText,
    this.helperText,
    this.focusNode,
    this.textInputAction,
    this.showLabel = true,
    this.filled = true,
    this.fillColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          decoration: InputDecoration(
            labelText: widget.showLabel ? null : widget.label,
            hintText: widget.hint,
            helperText: widget.helperText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: theme.primaryColor)
                : null,
            suffixIcon: _buildSuffixIcon(),
            errorText: widget.errorText,
            filled: widget.filled,
            fillColor: widget.fillColor ??
                (widget.enabled ? theme.cardColor : Colors.grey[100]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey[600],
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon, color: Colors.grey[600]),
        onPressed: widget.onSuffixIconPressed,
      );
    }

    return null;
  }
}

/// Search TextField (Arama için özelleştirilmiş)
///
/// Kullanım:
/// ```dart
/// SearchTextField(
///   hint: 'Ara...',
///   onChanged: (value) => print(value),
///   onClear: () => print('Temizlendi'),
/// )
/// ```
class SearchTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const SearchTextField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChange);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _clearText() {
    _controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        hintText: widget.hint ?? 'Ara...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: _clearText,
              )
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}

/// Multiline TextField (Çok satırlı metin girişi)
///
/// Kullanım:
/// ```dart
/// MultilineTextField(
///   label: 'Açıklama',
///   hint: 'Detaylı açıklama girin...',
///   minLines: 3,
///   maxLines: 6,
/// )
/// ```
class MultilineTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final bool showLabel;

  const MultilineTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            labelText: showLabel ? null : label,
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}

/// Dropdown TextField (Seçim için)
///
/// Kullanım:
/// ```dart
/// DropdownTextField<String>(
///   label: 'Kategori',
///   value: selectedCategory,
///   items: categories,
///   onChanged: (value) => setState(() => selectedCategory = value),
///   itemBuilder: (item) => Text(item),
/// )
/// ```
class DropdownTextField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final void Function(T?)? onChanged;
  final Widget Function(T) itemBuilder;
  final String? hint;
  final bool showLabel;

  const DropdownTextField({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.onChanged,
    required this.itemBuilder,
    this.hint,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          value: value,
          hint: hint != null ? Text(hint!) : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item,
                    child: itemBuilder(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Date Picker TextField
///
/// Kullanım:
/// ```dart
/// DatePickerTextField(
///   label: 'Başlangıç Tarihi',
///   selectedDate: startDate,
///   onDateSelected: (date) => setState(() => startDate = date),
/// )
/// ```
class DatePickerTextField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hint;
  final bool showLabel;

  const DatePickerTextField({
    super.key,
    required this.label,
    this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.hint,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
        ],
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: firstDate ?? DateTime(2000),
              lastDate: lastDate ?? DateTime(2100),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                      : hint ?? 'Tarih seçin',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDate != null
                        ? theme.textTheme.bodyLarge?.color
                        : Colors.grey[400],
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Pin Code TextField (OTP girişi için)
///
/// Kullanım:
/// ```dart
/// PinCodeTextField(
///   length: 6,
///   onCompleted: (pin) => print('Pin: $pin'),
/// )
/// ```
class PinCodeTextField extends StatefulWidget {
  final int length;
  final void Function(String) onCompleted;
  final void Function(String)? onChanged;

  const PinCodeTextField({
    super.key,
    this.length = 4,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<PinCodeTextField> createState() => _PinCodeTextFieldState();
}

class _PinCodeTextFieldState extends State<PinCodeTextField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final pin = _controllers.map((c) => c.text).join();
    if (widget.onChanged != null) {
      widget.onChanged!(pin);
    }

    if (pin.length == widget.length) {
      widget.onCompleted(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => SizedBox(
          width: 50,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            onChanged: (value) => _onChanged(value, index),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kullanım örnekleri koleksiyonu için dokümantasyon:
///
/// ```dart
/// // Standart text field
/// CustomTextField(
///   label: 'E-posta',
///   hint: 'ornek@email.com',
///   prefixIcon: Icons.email,
///   keyboardType: TextInputType.emailAddress,
/// )
///
/// // Şifre field
/// CustomTextField(
///   label: 'Şifre',
///   obscureText: true,
///   prefixIcon: Icons.lock,
/// )
///
/// // Arama field
/// SearchTextField(
///   hint: 'Proje ara...',
///   onChanged: (value) => _filterProjects(value),
/// )
///
/// // Multiline
/// MultilineTextField(
///   label: 'Açıklama',
///   minLines: 3,
///   maxLines: 6,
/// )
///
/// // Dropdown
/// DropdownTextField<String>(
///   label: 'Kategori',
///   items: ['Yapı', 'Yol', 'Köprü'],
///   itemBuilder: (item) => Text(item),
/// )
///
/// // Date picker
/// DatePickerTextField(
///   label: 'Tarih',
///   onDateSelected: (date) => print(date),
/// )
///
/// // Pin code
/// PinCodeTextField(
///   length: 6,
///   onCompleted: (pin) => _verifyOTP(pin),
/// )
/// ```
