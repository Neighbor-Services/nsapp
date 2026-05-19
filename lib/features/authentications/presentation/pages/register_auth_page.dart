import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:go_router/go_router.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/core/services/device_token_service.dart';

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
  bool _acceptTerms = false;

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
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
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
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is SuccessGetProfileState) {
                final profile = state.profile;
                if (profile.phone != null && profile.phone!.isNotEmpty) {
                  bool isProvider = Helpers.isProvider(profile.userType);
                  context.read<SettingsBloc>().add(
                    ToggleDashboardEvent(isProvider: isProvider),
                  );

                  if (isProvider && profile.isIdentityVerified != true) {
                    context.go("/home");
                    // context.go("/pending-verification");
                  } else {
                    context.go("/home");
                  }
                } else {
                  context.go("/add-profile");
                }
              }
              if (state is FailureGetProfileState) {
                context.go("/add-profile");
              }
            },
          ),
          BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is LoadingAuthenticationState) {
                setState(() => _isLoading = true);
              } else if (state is FailureRegisterAuthenticationState ||
                  state is FailureLoginAuthenticationState) {
                setState(() => _isLoading = false);
                String message = "Unable to complete authentication";
                if (state is FailureLoginAuthenticationState) {
                  message = state.message;
                }
                customAlert(context, AlertType.error, message);
              } else if (state is SuccessRegisterAuthenticationState) {
                setState(() => _isLoading = false);
                customAlert(
                  context,
                  AlertType.success,
                  "Email verification sent to your email",
                );
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    context.push("/otp");
                  }
                });
              } else if (state is SuccessGoogleRegisterAuthenticationState ||
                  state is SuccessLoginAuthenticationState) {
                // Keep _isLoading = true while we fetch the profile
                customAlert(
                  context,
                  AlertType.success,
                  "Authentication successful!",
                );
                DeviceTokenService.tryRegisterStoredToken();
                context.read<ProfileBloc>().add(GetProfileEvent());
              } else {
                setState(() => _isLoading = false);
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
                      horizontal: isLargeScreen ? 40.w : 24.w,
                      vertical: isLargeScreen ? 40.h : 0,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 450.w),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: _buildHeader(),
                              ),
                              SizedBox(height: 32.h),

                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 50 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: SolidContainer(
                                  padding: EdgeInsets.all(28.r),
                                  child: Form(
                                    key: key,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Email Field
                                        SolidTextField(
                                          controller: emailTextController,
                                          label: "EMAIL",
                                          allCapsLabel: true,
                                          hintText: "Enter your email",
                                          prefixIcon: FontAwesomeIcons.envelope,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          validator: (val) => ValidationUtil.validateEmail(val),
                                        ),
                                        SizedBox(height: 24.h),
                                        // Password Field
                                        SolidTextField(
                                          controller: passwordTextController,
                                          label: "PASSWORD",
                                          allCapsLabel: true,
                                          hintText: "Create a password",
                                          prefixIcon: FontAwesomeIcons.lock,
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
                                        SizedBox(height: 24.h),
                                        // Confirm Password Field
                                        SolidTextField(
                                          controller:
                                              confirmPasswordTextController,
                                          label: "CONFIRM PASSWORD",
                                          allCapsLabel: true,
                                          hintText: "Confirm your password",
                                          prefixIcon: FontAwesomeIcons.lock,
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
                                        SizedBox(height: 16.h),
                                        _buildTermsCheckbox(),
                                        SizedBox(height: 32.h),
                                        // Sign Up Button
                                        SolidButton(
                                          label: "SIGN UP",
                                          allCaps: true,
                                          isLoading: _isLoading,
                                          onPressed: () {
                                            if (!_acceptTerms) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text("Required: Please accept our terms and conditions to proceed"),
                                                  backgroundColor: context.appColors.errorColor.withAlpha(200),
                                                ),
                                              );
                                              return;
                                            }
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
                                        SizedBox(height: 24.h),
                                        // Divider
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Divider(
                                                color: context
                                                    .appColors
                                                    .glassBorder
                                                    .withAlpha(80),
                                                thickness: 1.r,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                              ),
                                              child: Text(
                                                "or",
                                                style: TextStyle(
                                                  color: context
                                                      .appColors
                                                      .secondaryTextColor,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: context
                                                    .appColors
                                                    .glassBorder
                                                    .withAlpha(80),
                                                thickness: 1.r,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 24.h),
                                        // Google Sign Up
                                        SolidButton(
                                          label: "SIGN IN WITH GOOGLE",
                                          allCaps: true,
                                          imagePath: googleLogo,
                                          textColor: Colors.white,
                                          isPrimary: false,
                                          onPressed: () {
                                            if (!_acceptTerms) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text("Required: Please accept our terms and conditions to proceed"),
                                                  backgroundColor: context.appColors.errorColor.withAlpha(200),
                                                ),
                                              );
                                              return;
                                            }
                                            context.read<AuthenticationBloc>().add(
                                              RegisterWithGoogleAuthenticationEvent(),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 16.h),
                                        // Apple Sign In
                                        SolidButton(
                                          label: "SIGN IN WITH APPLE",
                                          allCaps: true,
                                          icon: FontAwesomeIcons.apple,
                                          textColor: Colors.white,
                                          isPrimary: false,
                                          onPressed: () {
                                            if (!_acceptTerms) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text("Required: Please accept our terms and conditions to proceed"),
                                                  backgroundColor: context.appColors.errorColor.withAlpha(200),
                                                ),
                                              );
                                              return;
                                            }
                                            context.read<AuthenticationBloc>().add(
                                              LoginWithAppleAuthenticationEvent(),
                                            );
                                          },
                                        ),
                                        SizedBox(height: 24.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(
                                      color:
                                          context.appColors.secondaryTextColor,
                                      fontSize: 14.sp,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push("/login"),
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        color:
                                            context.appColors.primaryTextColor,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40.h),
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
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Image.asset(logo2Assets, height: 60.h, fit: BoxFit.contain),
        ),
        SizedBox(height: 32.h),
        Text(
          "CREATE ACCOUNT",
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w500,
            color: context.appColors.primaryTextColor,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "Sign up to get started with Neighbor Service",
          style: TextStyle(
            fontSize: 14.sp,
            color: context.appColors.secondaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Theme(
          data: ThemeData(
            unselectedWidgetColor: context.appColors.secondaryTextColor,
          ),
          child: Checkbox(
            value: _acceptTerms,
            activeColor: context.appColors.primaryColor,
            onChanged: (val) {
              setState(() {
                _acceptTerms = val ?? false;
              });
            },
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: context.appColors.secondaryTextColor,
                fontSize: 12.sp,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: "I accept the "),
                TextSpan(
                  text: "Terms and Conditions",
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.push('/legal', extra: 'TERMS'),
                ),
                const TextSpan(text: " and "),
                TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.push('/legal', extra: 'PRIVACY'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
