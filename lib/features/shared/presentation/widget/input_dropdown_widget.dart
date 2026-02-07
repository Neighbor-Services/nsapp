import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';
import 'custom_text_widget.dart';

class InputDropdownWidget extends StatelessWidget {
  final List<DropdownMenuItem<String>> items;
  final Function(String?)? onChange;
  final String label;
  final String? value;
  const InputDropdownWidget({
    super.key,
    required this.items,
    required this.onChange,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(text: label),
          const SizedBox(height: 10),
          DropdownButtonFormField(
            items: items,
            onChanged: onChange,
            initialValue: value,
            dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            iconEnabledColor: isDark ? Colors.white70 : Colors.black54,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? Colors.white.withAlpha(10) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : Colors.black.withAlpha(10),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : Colors.black.withAlpha(10),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: appOrangeColor1,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
