import 'package:flutter/material.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';


class DeactivatedUserPage extends StatefulWidget {
  const DeactivatedUserPage({super.key});

  @override
  State<DeactivatedUserPage> createState() => _DeactivatedUserPageState();
}

class _DeactivatedUserPageState extends State<DeactivatedUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(20.r),
            width: size(context).width,
            height: size(context).height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Text(
                  "HI, ${SuccessGetProfileState.profile.firstName?.toUpperCase() ?? ''}",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Center(
                  child: SolidContainer(
                    padding: EdgeInsets.all(30.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: context.appColors.errorColor.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.block,
                            color: context.appColors.errorColor,
                            size: 80.r,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "ACCOUNT DEACTIVATED",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.primaryTextColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "YOUR ACCOUNT HAS BEEN DEACTIVATED BY THE ADMINISTRATOR.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.secondaryTextColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
