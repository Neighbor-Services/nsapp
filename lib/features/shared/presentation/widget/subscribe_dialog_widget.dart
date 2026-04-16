import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/core.dart';
import '../../../provider/presentation/bloc/provider_bloc.dart';
import '../pages/subscription_page.dart';

class SubscribeDialogWidget extends StatelessWidget {
  const SubscribeDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: size(context).width * 0.85,
          constraints: BoxConstraints(maxWidth: 400.w),
          padding: EdgeInsets.all(24.r),
          decoration: BoxDecoration(
            color: Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: Colors.white12, width: 1.r),
           
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: context.appColors.warningColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child:  Icon(
                  FontAwesomeIcons.star,
                  size: 40.r,
                  color: context.appColors.warningColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Premium Feature",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                "You must subscribe to use this feature.",
                style: TextStyle(fontSize: 16.sp, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: NavigatorProviderState.page,
                            widget: const SubscriptionPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.warningColor,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Subscribe",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

