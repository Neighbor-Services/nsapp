import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import 'package:nsapp/core/core.dart';
import 'custom_text_widget.dart';

class ContactInputFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? initailCode;
  final Function(CountryCode?)? onChange;
  final String? label;
  final String? Function(String?)? validator;
  const ContactInputFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.initailCode,
    this.onChange,
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
            validator: validator,
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: CountryCodePicker(
                initialSelection: initailCode,
                onChanged: onChange,
                dialogBackgroundColor: Theme.of(context).cardColor,
                flagDecoration: BoxDecoration(),
              ),
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
