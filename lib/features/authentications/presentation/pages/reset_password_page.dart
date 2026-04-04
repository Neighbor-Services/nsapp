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

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  TextEditingController emailTextController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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
    emailTextController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is LoadingAuthenticationState) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is SuccessSendEmailVerificationState) {
            customAlert(
              context,
              AlertType.success,
              "Verification code sent to ${emailTextController.text.trim()}",
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Get.toNamed("/forgot-password");
              }
            });
          }
          if (state is FailureSendEmailVerificationState) {
            customAlert(
              context,
              AlertType.error,
              "Unable to send email. Please try again.",
            );
          }
        },
        builder: (context, state) {
          final isLargeScreen = MediaQuery.of(context).size.width > 600;

          return GradientBackground(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500.w),
                    child: Column(
                      children: [
                        // App Bar
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 16.w : 8.w,
                            vertical: 16.h,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: context.appColors.cardBackground,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: context.appColors.glassBorder,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: context.appColors.primaryTextColor,
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
                                SizedBox(height: 40.h),

                                // Glass Container
                                SolidContainer(
                                  padding: EdgeInsets.all(28.r),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        Text(
                                          "RESET PASSWORD",
                                          style: TextStyle(
                                            fontSize: 28.sp,
                                            fontWeight: FontWeight.w900,
                                            color: context.appColors.primaryTextColor,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          "Enter your email and we'll send you a verification code to reset your password",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: context.appColors.secondaryTextColor,
                                            height: 1.5,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        SizedBox(height: 32.h),

                                        SolidTextField(
                                          controller: emailTextController,
                                          label: "EMAIL",
                                          allCapsLabel: true,
                                          hintText: "Enter your email",
                                          prefixIcon: Icons.email_rounded,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Email is required";
                                            } else if (!val.isEmail) {
                                              return "Invalid email format";
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 32.h),

                                        SolidButton(
                                          label: "SEND VERIFICATION CODE",
                                          allCaps: true,
                                          isLoading: _isLoading,
                                          onPressed: () {
                                            if (formKey.currentState!
                                                .validate()) {
                                              context
                                                  .read<AuthenticationBloc>()
                                                  .add(
                                                    RequestPasswordResetEvent(
                                                      email: emailTextController
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
                                SizedBox(height: 32.h),

                                // Back to login
                                GestureDetector(
                                  onTap: () => Get.toNamed("/login"),
                                  child: Text(
                                    "Back to Login",
                                    style: TextStyle(
                                      color: context.appColors.secondaryTextColor,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
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
              ),
            ),
          );
        },
      ),
    );
  }
}
