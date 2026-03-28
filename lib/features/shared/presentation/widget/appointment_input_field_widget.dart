import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

class AppointmentInputFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final VoidCallback? onPressed;
  final bool readOnly;
  final bool allCapsLabel;
  const AppointmentInputFieldWidget({
    super.key,
    required this.label,
    this.controller,
    this.onPressed,
    this.readOnly = true,
    this.allCapsLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final labelColor = context.appColors.secondaryTextColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.glassBorder,
        ),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly, // Typically true for date pickers
        onTap: onPressed,
        style: TextStyle(color: textColor, fontSize: 13),
        decoration: InputDecoration(
          labelText: allCapsLabel ? label.toUpperCase() : label,
          labelStyle: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: allCapsLabel ? FontWeight.w900 : FontWeight.normal,
            letterSpacing: allCapsLabel ? 0.5 : null,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
