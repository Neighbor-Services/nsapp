import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';

class ReceiverChatTextWidget extends StatelessWidget {
  final String message;
  final DateTime dateTime;

  const ReceiverChatTextWidget({
    super.key,
    required this.message,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = context.appColors.cardBackground;
    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;
    final timestampColor = context.appColors.hintTextColor;
    final shadowColor = context.appColors.glassBorder;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12.h,
        top: 4.h,
        left: 8.w,
        right: 40.w,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                  bottomLeft: Radius.circular(6.r),
                ),
                border: Border.all(color: borderColor, width: 1.r),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: SelectableText(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4.h, left: 4.w),
              child: Text(
                DateFormat("HH:mm").format(dateTime.toLocal()),
                style: TextStyle(
                  color: timestampColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
