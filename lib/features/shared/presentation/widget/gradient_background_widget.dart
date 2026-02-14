import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({super.key, required this.child, this.colors});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define gradient colors based on theme
    final defaultColors = isDark
        ? [
            const Color.fromARGB(255, 0, 0, 0), // Dark blue-gray
            const Color.fromARGB(255, 3, 6, 14), // Darker blue
            const Color.fromARGB(255, 0, 3, 7), // Deep blue
            const Color.fromARGB(255, 9, 9, 20), // Dark blue-gray
          ]
        : [
            const Color(0xFFF5F7FA), // Light gray-blue
            const Color(0xFFE8EAF6), // Light indigo
            const Color(0xFFDCE4F5), // Lighter blue
            const Color(0xFFF5F7FA), // Light gray-blue
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? defaultColors,
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: child,
    );
  }
}
