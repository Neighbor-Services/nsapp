import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {
  String verificationCode = "";
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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.secondaryTextColor;

    // Calculate dynamic width for OTP fields to prevent overflow
    // Screen width - horizontal padding (24*2) - container padding (28*2) - spacing
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - 48 - 56;
    final double fieldWidth =
        (availableWidth / 4) - 10; // 4 fields, more spacing

    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is LoadingAuthenticationState) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is SuccessVerifyOtpState) {
            customAlert(context, AlertType.success, "Verification successful!");
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Get.offAndToNamed("login");
              }
            });
          }
          if (state is FailureVerifyOtpState) {
            customAlert(
              context,
              AlertType.error,
              "Invalid code. Please try again.",
            );
          }
        },
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 450),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.appColors.primaryColor.withAlpha(20),
                                    border: Border.all(
                                      color: context.appColors.glassBorder,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.mark_email_read_rounded,
                                    size: 50,
                                    color: context.appColors.primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Glass Container
                                SolidContainer(
                                  padding: EdgeInsets.all(28),
                                  child: Column(
                                    children: [
                                      Text(
                                        "VERIFY EMAIL",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: textColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Enter the verification code we sent to your email",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: secondaryTextColor,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      // OTP Field with Dynamic Width
                                      OtpTextField(
                                        numberOfFields: 4,
                                        fieldWidth: fieldWidth > 50
                                            ? 50
                                            : fieldWidth, // Max cap 50
                                        fieldHeight: 70,
                                        showFieldAsBox: true,
                                        borderWidth: 1.5,
                                        borderRadius: BorderRadius.circular(12),
                                        fillColor: context.appColors.cardBackground,
                                        filled: true,
                                        borderColor: context.appColors.glassBorder,
                                        focusedBorderColor: context.appColors.cardBackground,
                                        enabledBorderColor: context.appColors.glassBorder,
                                        cursorColor: textColor,
                                        textStyle: TextStyle(
                                          fontSize: fieldWidth > 40 ? 24 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                        margin: EdgeInsets.only(
                                          right: 10.0,
                                        ),
                                        onSubmit: (code) {
                                          verificationCode = code;
                                        },
                                        onCodeChanged: (code) {
                                          verificationCode = code;
                                        },
                                      ),
                                      const SizedBox(height: 32),

                                      // Resend Button
                                      GestureDetector(
                                        onTap: () async {
                                          final email = await Helpers.getString(
                                            "email",
                                          );
                                          context
                                              .read<AuthenticationBloc>()
                                              .add(
                                                SendEmailVerificationEvent(
                                                  email: email,
                                                ),
                                              );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appColors.cardBackground,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: context.appColors.glassBorder,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.refresh_rounded,
                                                size: 18,
                                                color: secondaryTextColor,
                                              ),
                                              const SizedBox(width: 8),
                                               Text(
                                                "RESEND CODE",
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      SolidButton(
                                        label: "VERIFY",
                                        isLoading: _isLoading,
                                        onPressed: () {
                                          if (verificationCode.isNotEmpty &&
                                              verificationCode.length == 4) {
                                            context
                                                .read<AuthenticationBloc>()
                                                .add(
                                                  VerifyEmailOtpEvent(
                                                    verificationCode,
                                                  ),
                                                );
                                          } else {
                                            customAlert(
                                              context,
                                              AlertType.error,
                                              "Please enter the complete verification code",
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
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
