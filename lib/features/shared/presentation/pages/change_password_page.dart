import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/core.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  TextEditingController emailTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;

    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is SuccessResetPasswordAuthenticationState) {
            customAlert(
              context,
              AlertType.success,
              "Password change email is sent to ${emailTextController.text.trim()}",
            );
          }
          if (state is FailureResetPasswordAuthenticationState) {
            customAlert(
              context,
              AlertType.error,
              "Unable to send email to ${emailTextController.text.trim()}",
            );
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingAuthenticationState),
            child: GradientBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: context.appColors.cardBackground,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: context.appColors.glassBorder,
                                ),
                              ),
                              child: Icon(
                                FontAwesomeIcons.chevronLeft,
                                color: textColor,
                                size: 18.r,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Text(
                            "CHANGE PASSWORD",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),
                            Image.asset(
                              resetPasswordLogo,
                              width: 200.w,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 32.h),

                            SolidContainer(
                              padding: EdgeInsets.all(24.r),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "RESET PASSWORD",
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      "Please enter the email you registered your Neighbor Service account with to change your password",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: secondaryTextColor,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 32.h),
                                    SolidTextField(
                                      controller: emailTextController,
                                      hintText: "Enter your email",
                                      label: "Email Address",
                                      prefixIcon: FontAwesomeIcons.envelope,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return "Email field is required";
                                        } else if (!val.isEmail) {
                                          return "Email is invalid";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 32.h),
                                    SolidButton(
                                      label: "CHANGE PASSWORD",
                                      allCaps: true,
                                      onPressed: () {
                                        if (emailTextController.text.trim() !=
                                            SuccessGetProfileState
                                                .profile
                                                .user!
                                                .email) {
                                          customAlert(
                                            context,
                                            AlertType.error,
                                            "Please use email you registered the account with",
                                          );
                                          return;
                                        }
                                        if (formKey.currentState!.validate()) {
                                          // Note: The original code had this commented out,
                                          // but I'm keeping the structure ready for when it's needed.
                                          /*
                                          context.read<AuthenticationBloc>().add(
                                            ResetPasswordAuthenticationEvent(
                                              password: emailTextController.text.trim(),
                                            ),
                                          );
                                          */
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


