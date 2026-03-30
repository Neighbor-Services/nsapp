import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:get/get.dart';

import '../../../profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/services/background_notification_service.dart';
import 'package:nsapp/core/services/device_token_service.dart';

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
        Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero).animate(
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
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is SuccessGetProfileState) {
                if (SuccessGetProfileState.profile.phone != null &&
                    SuccessGetProfileState.profile.phone!.isNotEmpty) {
                  if (Helpers.isProvider(SuccessGetProfileState.profile.userType)) {
                    context.read<SharedBloc>().add(ToggleDashboardEvent(isProvider: true));
                  } else {
                    context.read<SharedBloc>().add(ToggleDashboardEvent(isProvider: false));
                  }
                  Get.offAllNamed("/home");
                } else {
                  Get.offAllNamed("/add-profile");
                }
              }
              if (state is FailureGetProfileState) {
                Get.offAllNamed("/add-profile");
              }
            },
          ),
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is LoadingAuthenticationState) {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
              } else {
                setState(() => _isLoading = false);
              }

              if (state is SuccessLoginAuthenticationState ||
                  state is SuccessGoogleRegisterAuthenticationState) {
                // Start foreground WebSocket (works on both Android & iOS)
                BackgroundNotificationService.connectForeground();
                // Register device token for native push (iOS)
                DeviceTokenService.tryRegisterStoredToken();
                context.read<ProfileBloc>().add(GetProfileEvent());
              }

              if (state is FailureLoginAuthenticationState) {
                setState(() {
                  _errorMessage = state.message;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
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
                              // Logo/Branding
                              _buildHeader(),
                              const SizedBox(height: 40),

                              // Glass Form Container
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
                                        hintText: "Enter your password",
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
                                      // Forgot Password
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () =>
                                              Get.toNamed("/reset-password"),
                                          child: Text(
                                            "Forgot Password?",
                                            style: TextStyle(
                                              color: context.appColors.secondaryTextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Error Message
                                      if (_errorMessage != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appColors.errorColor.withAlpha(25),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: context.appColors.errorColor.withAlpha(60),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline_rounded,
                                                color: context.appColors.errorColor,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _errorMessage!,
                                                  style: TextStyle(
                                                    color: context.appColors.errorColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 28),
                                      // Login Button
                                      SolidButton(
                                        label: "LOGIN",
                                        allCaps: true,
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
                                      // Google Sign In
                                      SolidButton(
                                        label: "SIGN IN WITH GOOGLE",
                                        allCaps: true,
                                        imagePath: googleLogo,
                                        textColor: Colors.white,
                                        isPrimary: false,
                                        onPressed: () {
                                          context.read<AuthenticationBloc>().add(
                                            LoginWithGoogleAuthenticationEvent(),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      _buildLegalText("By logging in, you agree to our\n"),
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
                                      color: context.appColors.secondaryTextColor,
                                      fontSize: 14,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.toNamed("/register"),
                                    child: Text(
                                      "Sign Up",
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
            color: Colors.transparent,
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
          "WELCOME BACK",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: context.appColors.primaryTextColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sign in to continue to Neighbor Service",
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
