// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

class SolidButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final IconData? icon;
  final String? imagePath;
  final bool isPrimary;
  final List<Color>? gradientColors;
  final bool allCaps;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;

  const SolidButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.icon,
    this.imagePath,
    this.isPrimary = true,
    this.gradientColors,
    this.allCaps = true,
    this.color,
    this.textColor,
    this.borderColor,
  });

  @override
  State<SolidButton> createState() => _SolidButtonState();
}

class _SolidButtonState extends State<SolidButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {

    // Theme-aware colors
    final Color backgroundColor = (widget.isPrimary
            ? widget.color ?? context.appColors.primaryColor
            : context.appColors.primaryColor);

    final Color textColor = widget.textColor ??
        (widget.isPrimary
            ? Colors.white
            : context.appColors.primaryTextColor);

    final Color borderColor = widget.borderColor ?? context.appColors.glassBorder;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _handleTapDown : null,
        onTapUp: widget.onPressed != null ? _handleTapUp : null,
        onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          width: widget.width?.w ?? double.infinity,
          height: widget.height.h,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: borderColor, width: 1.2.r),
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5.r,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: textColor, size: 20.r),
                        SizedBox(width: 10.w),
                      ] else if (widget.imagePath != null) ...[
                        Image.asset(widget.imagePath!, width: 20.r, height: 20.r),
                        SizedBox(width: 10.w),
                      ],
                      Text(
                        widget.allCaps ? widget.label.toUpperCase() : widget.label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
