import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';

class RegisterAuthPage extends StatefulWidget {
  const RegisterAuthPage({super.key});

  @override
  State<RegisterAuthPage> createState() => _RegisterAuthPageState();
}

class _RegisterAuthPageState extends State<RegisterAuthPage>
    with TickerProviderStateMixin {
  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;
  late TextEditingController confirmPasswordTextController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  GlobalKey<FormState> key = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailTextController = TextEditingController();
    passwordTextController = TextEditingController();
    confirmPasswordTextController = TextEditingController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    confirmPasswordTextController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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

          if (state is FailureRegisterAuthenticationState) {
            customAlert(context, AlertType.error, "Unable to create account");
          }
          if (state is SuccessRegisterAuthenticationState) {
            customAlert(
              context,
              AlertType.success,
              "Email verification sent to your email",
            );
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Get.toNamed("/otp");
              }
            });
          }
          if (state is SuccessGoogleRegisterAuthenticationState) {
            customAlert(context, AlertType.success, "Registration successful!");
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Get.offAllNamed("/add-profile");
              }
            });
          }
        },
        builder: (context, state) {
          final isLargeScreen = MediaQuery.of(context).size.width > 600;

          return GradientBackground(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 40 : 24,
                    vertical: isLargeScreen ? 40 : 0,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 450),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),

                            SolidContainer(
                              padding: EdgeInsets.all(28),
                              child: Form(
                                key: key,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Email Field
                                    SolidTextField(
                                      controller: emailTextController,
                                      label: "EMAIL",
                                      allCapsLabel: true,
                                      hintText: "Enter your email",
                                      prefixIcon: Icons.email_rounded,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return "Email is required";
                                        } else if (!val.isEmail) {
                                          return "Invalid email format";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    // Password Field
                                    SolidTextField(
                                      controller: passwordTextController,
                                      label: "PASSWORD",
                                      allCapsLabel: true,
                                      hintText: "Create a password",
                                      prefixIcon: Icons.lock_rounded,
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
                                    const SizedBox(height: 24),
                                    // Confirm Password Field
                                    SolidTextField(
                                      controller: confirmPasswordTextController,
                                      label: "CONFIRM PASSWORD",
                                      allCapsLabel: true,
                                      hintText: "Confirm your password",
                                      prefixIcon: Icons.lock_rounded,
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
                                    // Sign Up Button
                                    SolidButton(
                                      label: "SIGN UP",
                                      allCaps: true,
                                      isLoading: _isLoading,
                                      onPressed: () {
                                        if (key.currentState!.validate()) {
                                          context
                                              .read<AuthenticationBloc>()
                                              .add(
                                                RegisterAuthenticationEvent(
                                                  email: emailTextController
                                                      .text
                                                      .trim(),
                                                  password:
                                                      passwordTextController
                                                          .text
                                                          .trim(),
                                                ),
                                              );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    // Divider
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: context.appColors.glassBorder.withAlpha(80),
                                            thickness: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            "or",
                                            style: TextStyle(
                                              color: context.appColors.secondaryTextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: context.appColors.glassBorder.withAlpha(80),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // Google Sign Up
                                    SolidButton(
                                      label: "SIGN IN WITH GOOGLE",
                                      allCaps: true,
                                      imagePath: googleLogo,
                                      isPrimary: false,
                                      onPressed: () {
                                        context.read<AuthenticationBloc>().add(
                                          RegisterWithGoogleAuthenticationEvent(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    _buildLegalText("By signing up, you agree to our\n"),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an account? ",
                                  style: TextStyle(
                                    color: context.appColors.secondaryTextColor,
                                    fontSize: 14,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed("/login"),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      color: context.appColors.primaryTextColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Image.asset(
            logo2Assets,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          "CREATE ACCOUNT",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: context.appColors.primaryTextColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sign up to get started with Neighbor Service",
          style: TextStyle(
            fontSize: 14,
            color: context.appColors.secondaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLegalText(String prefix) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            color: context.appColors.secondaryTextColor,
            fontSize: 12,
            height: 1.5,
          ),
          children: [
            TextSpan(text: prefix),
            TextSpan(
              text: "Terms and Conditions",
              style: TextStyle(
                color: context.appColors.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed('/legal', arguments: 'TERMS'),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: TextStyle(
                color: context.appColors.primaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              recognizer: TapGestureRecognizer()..onTap = () => Get.toNamed('/legal', arguments: 'PRIVACY'),
            ),
          ],
        ),
      ),
    );
  }
}
