import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class ButtonWithoutIconWidget extends StatelessWidget {
  final Color? color;
  final String? label;
  final VoidCallback? onPressed;

  const ButtonWithoutIconWidget({
    super.key,
    this.color,
    this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size(context).width,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: CustomTextWidget(
            text: label!,
            fontSize: 16,
            color: appWhiteColor,
          ),
        ),
      ),
    );
  }
}
