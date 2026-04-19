import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

class AppointmentInputFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final VoidCallback? onPressed;
  final bool readOnly;
  final bool allCapsLabel;
  const AppointmentInputFieldWidget({
    super.key,
    required this.label,
    this.controller,
    this.onPressed,
    this.readOnly = true,
    this.allCapsLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final labelColor = context.appColors.secondaryTextColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.appColors.glassBorder,
          width: 1.r,
        ),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly, // Typically true for date pickers
        onTap: onPressed,
        style: TextStyle(color: textColor, fontSize: 13.sp),
        decoration: InputDecoration(
          labelText: allCapsLabel ? label.toUpperCase() : label,
          labelStyle: TextStyle(
            color: labelColor,
            fontSize: 12.sp,
            fontWeight: allCapsLabel ? FontWeight.bold : FontWeight.normal,
            letterSpacing: allCapsLabel ? 0.5 : null,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          isDense: true,
        ),
      ),
    );
  }
}


