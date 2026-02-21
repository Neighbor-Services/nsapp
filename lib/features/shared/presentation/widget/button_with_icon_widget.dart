import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class ButtonWithIconWidget extends StatelessWidget {
  final Color? color;
  final String? label;
  final VoidCallback? onPressed;
  final String? logo;

  const ButtonWithIconWidget({
    super.key,
    this.color,
    this.label,
    this.onPressed,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size(context).width,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(logo!, width: 20),
              SizedBox(width: 10),
              CustomTextWidget(text: label!, color: appBlueCardColor),
            ],
          ),
        ),
      ),
    );
  }
}
