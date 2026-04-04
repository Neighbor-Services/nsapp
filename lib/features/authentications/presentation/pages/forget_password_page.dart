import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage>
    with TickerProviderStateMixin {
  late TextEditingController passwordTextController;
  late TextEditingController confirmPasswordTextController;
  late TextEditingController otpTextController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  GlobalKey<FormState> key = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();
    otpTextController = TextEditingController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    otpTextController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;

    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is LoadingAuthenticationState) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is FailureResetPasswordAuthenticationState) {
            customAlert(context, AlertType.error, "An error occurred");
          }
          if (state is SuccessResetPasswordAuthenticationState) {
            customAlert(
              context,
              AlertType.success,
              "Password changed successfully!",
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Get.offAndToNamed("/login");
              }
            });
          }
        },
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // App Bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 16.h,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: context.appColors.glassBorder.withAlpha(20),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.appColors.glassBorder,
                                  width: 1.r,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: isDark ? Colors.white : Colors.black,
                                size: 18.r,
                              ),
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

                            // Icon
                            Container(
                              width: 100.r,
                              height: 100.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.appColors.primaryColor.withAlpha(20),
                                border: Border.all(
                                  color: context.appColors.primaryColor.withAlpha(50),
                                  width: 2.r,
                                ),
                              ),
                              child: Icon(
                                Icons.key_rounded,
                                size: 50.r,
                                color: context.appColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 32.h),

                            // Glass Container
                            SolidContainer(
                              padding: EdgeInsets.all(28.r),
                              child: Form(
                                key: key,
                                child: Column(
                                  children: [
                                    Text(
                                      "CREATE NEW PASSWORD",
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : Colors.black,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      "Create a strong password to secure your account",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: secondaryTextColor,
                                        height: 1.5,
                                      ),
                                    ),
                                    SizedBox(height: 32.h),

                                    SolidTextField(
                                      controller: otpTextController,
                                      label: "Verification Code",
                                      allCapsLabel: true,
                                      hintText: "Enter 4-digit OTP",
                                      prefixIcon: Icons.pin_rounded,
                                      keyboardType: TextInputType.number,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return "OTP is required";
                                        } else if (val.length != 4) {
                                          return "Enter 4 digits";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20.h),

                                    SolidTextField(
                                      controller: passwordTextController,
                                      label: "New Password",
                                      allCapsLabel: true,
                                      hintText: "Enter new password",
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: true,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return "Password is required";
                                        } else if (val.length < 6) {
                                          return "Password must be at least 6 characters";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 20.h),

                                    SolidTextField(
                                      controller: confirmPasswordTextController,
                                      label: "Confirm Password",
                                      allCapsLabel: true,
                                      hintText: "Confirm new password",
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: true,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return "Please confirm your password";
                                        } else if (val !=
                                            passwordTextController.text) {
                                          return "Passwords don't match";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 32.h),

                                    SolidButton(
                                      label: "RESET PASSWORD",
                                      allCaps: true,
                                      isLoading: _isLoading,
                                      onPressed: () {
                                        if (key.currentState!.validate()) {
                                          context.read<AuthenticationBloc>().add(
                                            ResetPasswordAuthenticationEvent(
                                              otp: otpTextController.text
                                                  .trim(),
                                              password: passwordTextController
                                                  .text
                                                  .trim(),
                                            ),
                                          );
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
