import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

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
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        // App Bar
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 16 : 8,
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
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: textColor,
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
                                      colors: isDark
                                          ? [
                                              Colors.white.withAlpha(50),
                                              Colors.white.withAlpha(20),
                                            ]
                                          : [
                                              Colors.black.withAlpha(10),
                                              Colors.black.withAlpha(5),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withAlpha(40)
                                          : Colors.black.withAlpha(20),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.lock_reset_rounded,
                                    size: 50,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Glass Container
                                SolidContainer(
                                  padding: const EdgeInsets.all(28),
                                  child: Form(
                                    key: formKey,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Reset Password",
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          "Enter your email and we'll send you a verification code to reset your password",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: secondaryTextColor,
                                            height: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 32),

                                        SolidTextField(
                                          controller: emailTextController,
                                          label: "Email Address",
                                          hintText: "Enter your email",
                                          prefixIcon: Icons.email_outlined,
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
                                        const SizedBox(height: 32),

                                        SolidButton(
                                          label: "SEND VERIFICATION CODE",
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
                                const SizedBox(height: 24),

                                // Back to login
                                GestureDetector(
                                  onTap: () => Get.toNamed("/login"),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_rounded,
                                        size: 18,
                                        color: secondaryTextColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Back to Login",
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
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
              ),
            ),
          );
        },
      ),
    );
  }
}
