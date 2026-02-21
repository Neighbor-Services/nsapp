import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:get/get.dart';

import '../../../profile/presentation/bloc/profile_bloc.dart';

class LoginAuthPage extends StatefulWidget {
  const LoginAuthPage({super.key});

  @override
  State<LoginAuthPage> createState() => _LoginAuthPageState();
}

class _LoginAuthPageState extends State<LoginAuthPage>
    with TickerProviderStateMixin {
  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  GlobalKey<FormState> key = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    emailTextController = TextEditingController();
    passwordTextController = TextEditingController();

    // Fade animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // Slide animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
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
    _fadeController.dispose();
    _slideController.dispose();
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
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
          } else {
            setState(() => _isLoading = false);
          }

          if (state is SuccessLoginAuthenticationState) {
            context.read<ProfileBloc>().add(GetProfileEvent());
            Future.delayed(const Duration(seconds: 2), () {
              if (SuccessGetProfileState.profile.firstName != null) {
                if (Helpers.isProvider(
                  SuccessGetProfileState.profile.userType,
                )) {
                  context.read<SharedBloc>().add(
                    ToggleDashboardEvent(isProvider: true),
                  );
                } else {
                  context.read<SharedBloc>().add(
                    ToggleDashboardEvent(isProvider: false),
                  );
                }
                Get.offAllNamed("/home");
              } else {
                Get.offAllNamed("/add-profile");
              }
            });
          }

          if (state is FailureLoginAuthenticationState) {
            setState(() {
              _errorMessage = state.message;
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
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo/Branding
                            _buildHeader(),
                            const SizedBox(height: 40),

                            // Glass Form Container
                            SolidContainer(
                              padding: const EdgeInsets.all(28),
                              child: Form(
                                key: key,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Welcome Text
                                    Text(
                                      "Welcome Back",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Sign in to continue to Neighbor Service",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // Email Field
                                    SolidTextField(
                                      controller: emailTextController,
                                      label: "Email",
                                      hintText: "Enter your email",
                                      prefixIcon: Icons.email_outlined,
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
                                    const SizedBox(height: 20),

                                    // Password Field
                                    SolidTextField(
                                      controller: passwordTextController,
                                      label: "Password",
                                      hintText: "Enter your password",
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

                                    // Error Message
                                    if (_errorMessage != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent.withAlpha(40),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.redAccent.withAlpha(
                                              100,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline_rounded,
                                              color: Colors.redAccent,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _errorMessage!,
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    // Forgot Password
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () =>
                                            Get.toNamed("/reset-password"),
                                        child: Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                            color: secondaryTextColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Login Button
                                    SolidButton(
                                      label: "LOGIN",
                                      isLoading: _isLoading,
                                      onPressed: () {
                                        if (key.currentState!.validate()) {
                                          context
                                              .read<AuthenticationBloc>()
                                              .add(
                                                LoginAuthenticationEvent(
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
                                          child: Container(
                                            height: 1,
                                            color: isDark
                                                ? Colors.white.withAlpha(50)
                                                : Colors.black.withAlpha(20),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            "OR",
                                            style: TextStyle(
                                              color: secondaryTextColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: isDark
                                                ? Colors.white.withAlpha(50)
                                                : Colors.black.withAlpha(20),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Google Sign In
                                    SolidButton(
                                      label: "Sign in with Google",
                                      imagePath: googleLogo,
                                      isPrimary: false,
                                      onPressed: () {
                                        context.read<AuthenticationBloc>().add(
                                          LoginWithGoogleAuthenticationEvent(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sign Up Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed("/register"),
                                  child: Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return Column(
      children: [
        // App Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.white.withAlpha(50), Colors.white.withAlpha(20)]
                  : [Colors.black.withAlpha(10), Colors.black.withAlpha(5)],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(40)
                  : Colors.black.withAlpha(20),
              width: 2,
            ),
          ),
          child: Icon(Icons.home_work_rounded, size: 40, color: textColor),
        ),
        const SizedBox(height: 16),
        Text(
          "Neighbor Service",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
