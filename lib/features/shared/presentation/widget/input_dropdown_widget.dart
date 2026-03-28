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
    return Container(
      decoration: BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(text: label),
          const SizedBox(height: 10),
          DropdownButtonFormField(
            items: items,
            onChanged: onChange,
            initialValue: value,
            dropdownColor: context.appColors.cardBackground,
            style: TextStyle(
              color: context.appColors.primaryTextColor,
              fontSize: 16,
            ),
            iconEnabledColor: context.appColors.secondaryTextColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: context.appColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: context.appColors.glassBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: context.appColors.glassBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: context.appColors.secondaryColor,
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
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
