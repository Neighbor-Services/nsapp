import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(180)
        : Colors.black54;

    // Calculate dynamic width for OTP fields
    final double screenWidth = MediaQuery.of(context).size.width;
    final double availableWidth = screenWidth - 48 - 56;
    final double fieldWidth =
        (availableWidth / 4) - 12; // 4 fields, more spacing

    return Scaffold(
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is LoadingAuthenticationState) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is SuccessVerifyEmailState) {
            customAlert(context, AlertType.success, "Verification successful!");
            Future.delayed(const Duration(seconds: 3), () {
              Get.toNamed("/forgot-password");
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
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 450),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        isDark
                                            ? Colors.white.withAlpha(50)
                                            : Colors.black.withAlpha(10),
                                        isDark
                                            ? Colors.white.withAlpha(20)
                                            : Colors.black.withAlpha(10),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withAlpha(40)
                                          : Colors.black.withAlpha(30),
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.verified_user_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Glass Container
                                SolidContainer(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Verify Email",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Enter the verification code we sent to your email to reset your password",
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
                                        fieldWidth: fieldWidth > 60
                                            ? 60
                                            : fieldWidth,
                                        fieldHeight: fieldWidth > 70
                                            ? 70
                                            : fieldWidth + 10,
                                        showFieldAsBox: true,
                                        borderWidth: 1.5,
                                        borderRadius: BorderRadius.circular(12),
                                        fillColor: isDark
                                            ? Colors.white.withAlpha(20)
                                            : Colors.black.withAlpha(10),
                                        filled: true,
                                        borderColor: isDark
                                            ? Colors.white.withAlpha(40)
                                            : Colors.black.withAlpha(30),
                                        focusedBorderColor: appOrangeColor1,
                                        enabledBorderColor: Colors.white
                                            .withAlpha(20),
                                        cursorColor: Colors.white,
                                        textStyle: TextStyle(
                                          fontSize: fieldWidth > 40 ? 24 : 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        margin: const EdgeInsets.only(
                                          right: 12.0,
                                        ),
                                        onSubmit: (code) {
                                          verificationCode = code;
                                        },
                                        onCodeChanged: (code) {
                                          verificationCode = code;
                                        },
                                      ),
                                      const SizedBox(height: 40),

                                      SolidButton(
                                        label: "VERIFY",
                                        isLoading: _isLoading,
                                        onPressed: () {
                                          if (verificationCode.isNotEmpty &&
                                              verificationCode.length == 4) {
                                            context
                                                .read<AuthenticationBloc>()
                                                .add(
                                                  VerifiEmailEvent(
                                                    otp: verificationCode,
                                                  ),
                                                );
                                          } else {
                                            customAlert(
                                              context,
                                              AlertType.error,
                                              "Please enter the verification code",
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
