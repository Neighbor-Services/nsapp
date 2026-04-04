import 'package:flutter/material.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/core/core.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final double height;
  const EmptyWidget({super.key, required this.message, required this.height});

  @override
  Widget build(BuildContext context) {
    bool isSmall = height < 250;

    final backgroundColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.secondaryTextColor;
    final iconOpacity = 0.8;

    return Container(
      width: size(context).width,
      height: height.h,
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
        vertical: isSmall ? 8.h : 16.h,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(isSmall ? 16.r : 32.r),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: borderColor, width: 1.r),
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
                    width: isSmall ? 80.r : 120.r,
                    height: isSmall ? 80.r : 120.r,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 24.h),
                CustomTextWidget(
                  text: message,
                  textAlign: TextAlign.center,
                  fontSize: (isSmall ? 14 : 16).sp,
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
