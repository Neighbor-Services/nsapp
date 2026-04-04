import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

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
  final bool allCapsLabel;

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
    this.allCapsLabel = true,
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

    // Theme-aware colors
    final labelColor = context.appColors.primaryTextColor;
    final backgroundColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final hintColor = context.appColors.hintTextColor;
    final iconColor = context.appColors.hintTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.allCapsLabel ? widget.label!.toUpperCase() : widget.label!,
            style: TextStyle(
              color: labelColor,
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
        ],
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _isFocused ? context.appColors.secondaryColor : borderColor,
              width: _isFocused ? 1.5.r : 1.r,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: context.appColors.secondaryColor.withAlpha(20),
                      blurRadius: 10.r,
                      spreadRadius: 1.r,
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
            style: TextStyle(color: textColor, fontSize: 15.sp),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: hintColor, fontSize: 14.sp),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused ? context.appColors.secondaryColor : iconColor,
                      size: 20.r,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: iconColor,
                        size: 20.r,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 18.h,
              ),
              errorStyle:  TextStyle(
                color: context.appColors.errorColor,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
