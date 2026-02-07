import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

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
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(180)
        : Colors.black54;

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
              Get.offAndToNamed("/login");
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withAlpha(20)
                                    : Colors.black.withAlpha(10),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withAlpha(30)
                                      : Colors.black.withAlpha(20),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

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
                                Icons.key_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Glass Container
                            SolidContainer(
                              padding: const EdgeInsets.all(28),
                              child: Form(
                                key: key,
                                child: Column(
                                  children: [
                                    const Text(
                                      "Create New Password",
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Create a strong password to secure your account",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: secondaryTextColor,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    SolidTextField(
                                      controller: otpTextController,
                                      label: "Verification Code",
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
                                    const SizedBox(height: 20),

                                    SolidTextField(
                                      controller: passwordTextController,
                                      label: "New Password",
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
                                    const SizedBox(height: 20),

                                    SolidTextField(
                                      controller: confirmPasswordTextController,
                                      label: "Confirm Password",
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
                                    const SizedBox(height: 32),

                                    SolidButton(
                                      label: "RESET PASSWORD",
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
                            const SizedBox(height: 40),
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
