import 'package:flutter/material.dart';

class SolidContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur; // Kept for compatibility, but not used
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;

  const SolidContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 20,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(24);

    // Theme-aware default colors
    final defaultBackgroundColor = isDark
        ? const Color(0xFF2E2E3E) // Dark mode: dark blue-gray
        : const Color(0xFFFFFFFF); // Light mode: white

    final defaultBorderColor = isDark
        ? Colors.white.withAlpha(30) // Dark mode: subtle white border
        : Colors.black.withAlpha(15); // Light mode: subtle black border

    final defaultShadowColor = isDark
        ? Colors.black.withAlpha(30) // Dark mode: black shadow
        : Colors.black.withAlpha(10); // Light mode: lighter shadow

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(
          color: borderColor ?? defaultBorderColor,
          width: borderWidth,
        ),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: defaultShadowColor,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
        gradient: gradient,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}
