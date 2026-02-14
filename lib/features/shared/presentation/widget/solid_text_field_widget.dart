import 'package:flutter/material.dart';
import 'package:nsapp/core/constants/app_colors.dart';

class SolidTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? label;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool isMultiLine;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const SolidTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isMultiLine = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.focusNode,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<SolidTextField> createState() => _SolidTextFieldState();
}

class _SolidTextFieldState extends State<SolidTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final labelColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final backgroundColor = isDark
        ? const Color(0xFF2E2E3E)
        : const Color(0xFFF5F5F5);
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(20);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final hintColor = isDark
        ? Colors.white.withAlpha(80)
        : Colors.black.withAlpha(100);
    final iconColor = isDark
        ? Colors.white.withAlpha(120)
        : Colors.black.withAlpha(120);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              color: labelColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused ? appOrangeColor1 : borderColor,
              width: _isFocused ? 1.5 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: appOrangeColor1.withAlpha(20),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: _obscureText,
            validator: widget.validator,
            onChanged: widget.onChanged,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            minLines: widget.isMultiLine ? 4 : 1,
            maxLines: widget.isMultiLine ? 6 : 1,
            style: TextStyle(color: textColor, fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: hintColor, fontSize: 14),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused ? appOrangeColor1 : iconColor,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: iconColor,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              errorStyle: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
