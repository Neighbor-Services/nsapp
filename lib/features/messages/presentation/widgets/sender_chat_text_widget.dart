import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';

class SenderChatTextWidget extends StatelessWidget {
  final String message;
  final DateTime dateTime;
  final VoidCallback onLongPressed;
  const SenderChatTextWidget({
    super.key,
    required this.message,
    required this.dateTime,
    required this.onLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    final timestampColor = context.appColors.hintTextColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12.h,
        top: 4.h,
        right: 8.w,
        left: 40.w,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: onLongPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
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
                  color: context.appColors.primaryColor.withAlpha(10),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                    bottomLeft: Radius.circular(24.r),
                    bottomRight: Radius.circular(6.r),
                  ),
                  border: Border.all(
                    color: context.appColors.primaryColor,
                    width: 1.r,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primaryColor.withAlpha(40),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: SelectableText(
                  message,
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontSize: 15.sp,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 4.w),
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
      ),
    );
  }
}
