import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/core/core.dart';

class ConnectAccountSetupWidget extends StatelessWidget {
  const ConnectAccountSetupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final subtitleColor = context.appColors.secondaryTextColor;
    final infoBgColor = context.appColors.glassBorder;
    final infoBorderColor = context.appColors.glassBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Payment Setup",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          "To receive payments safely, you need to connect your payout account.",
          style: TextStyle(fontSize: 16.sp, color: subtitleColor),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: infoBgColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: infoBorderColor, width: 1.r),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: context.appColors.infoColor, size: 24.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "You'll be redirected to a secure page to complete setup.",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.appColors.glassBorder,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30.h),
        SolidButton(
          label: "CONTINUE TO SETUP",
          onPressed: () {
            context.read<SharedBloc>().add(CreateConnectAccountEvent());
          },
        ),
      ],
    );
  }
}
