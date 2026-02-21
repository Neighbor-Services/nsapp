import 'package:flutter/material.dart';
import 'solid_container_widget.dart';

class AppointmentInputFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final VoidCallback? onPressed;
  final bool readOnly;
  const AppointmentInputFieldWidget({
    super.key,
    required this.label,
    this.controller,
    this.onPressed,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final labelColor = isDark
        ? Colors.white70
        : const Color(0xFF1E1E2E).withAlpha(150);

    return SolidContainer(
      child: TextFormField(
        controller: controller,
        readOnly: readOnly, // Typically true for date pickers
        onTap: onPressed,
        style: TextStyle(color: textColor, fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
