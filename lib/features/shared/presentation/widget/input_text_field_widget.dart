import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';
import 'custom_text_widget.dart';

class InputTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? label;
  final bool isMultiLine;
  final String? Function(String?)? validator;

  const InputTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.isMultiLine = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size(context).width,
      decoration: const BoxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(text: label!),
          SizedBox(height: 10),
          TextFormField(
            minLines: isMultiLine ? 5 : 1,
            maxLines: isMultiLine ? 7 : 1,
            validator: validator,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: keyboardType,
            obscureText: obscureText,
          ),
        ],
      ),
    );
  }
}
