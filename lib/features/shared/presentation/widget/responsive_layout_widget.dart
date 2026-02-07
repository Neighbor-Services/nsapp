import 'package:flutter/material.dart';

/// A responsive wrapper that constrains content width on larger screens
/// while allowing full width on mobile devices.
class ResponsiveAuthLayout extends StatelessWidget {
  final Widget child;
  final double maxContentWidth;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;

  const ResponsiveAuthLayout({
    super.key,
    required this.child,
    this.maxContentWidth = 450,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isLargeScreen ? maxContentWidth : double.infinity,
            ),
            padding:
                padding ??
                (isLargeScreen
                    ? const EdgeInsets.symmetric(horizontal: 24, vertical: 40)
                    : const EdgeInsets.symmetric(horizontal: 24)),
            child: child,
          ),
        );
      },
    );
  }
}

/// Breakpoint utilities for responsive design
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= mobile;
  }
}

/// Responsive sizing utilities
class ResponsiveSize {
  static double getFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (Breakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (Breakpoints.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  static double getSpacing(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (Breakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (Breakpoints.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  static EdgeInsets getPadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (Breakpoints.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (Breakpoints.isTablet(context)) {
      return tablet ?? mobile;
    }
    return mobile;
  }
}
