import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: context.appColors.surfaceBackground),
      child: child,
    );
  }
}
