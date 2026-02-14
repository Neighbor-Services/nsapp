import 'package:flutter/material.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final double height;
  const EmptyWidget({super.key, required this.message, required this.height});

  @override
  Widget build(BuildContext context) {
    bool isSmall = height < 250;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark
        ? const Color(0xFF2E2E3E)
        : const Color(0xFFF8F9FA);
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final textColor = isDark
        ? Colors.white.withAlpha(200)
        : const Color(0xFF1E1E2E).withAlpha(180);
    final iconOpacity = isDark ? 0.8 : 0.6;

    return Container(
      width: size(context).width,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: isSmall ? 8 : 16),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(isSmall ? 16 : 32),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Opacity(
                  opacity: iconOpacity,
                  child: Image.asset(
                    emptyLogo,
                    width: isSmall ? 80 : 120,
                    height: isSmall ? 80 : 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextWidget(
                  text: message,
                  textAlign: TextAlign.center,
                  fontSize: isSmall ? 14 : 16,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
