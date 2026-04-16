import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/services/background_notification_service.dart';
import 'package:nsapp/core/services/device_token_service.dart';

class BiometricPage extends StatefulWidget {
  const BiometricPage({super.key});

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  final LocalAuthentication localAuthentication = LocalAuthentication();
  bool _isAuthenticating = false;

  auth() async {
    if (!mounted) return;
    setState(() => _isAuthenticating = true);
    try {
      final bool hasBiometric = await localAuthentication.canCheckBiometrics;
      final isAuthenticated = await localAuthentication.authenticate(
        localizedReason: "Unlock Neighbor Service",
        biometricOnly: hasBiometric,
      );

      if (isAuthenticated) {
        if (await Helpers.isAuthenticated()) {
          Get.offAllNamed("/home");
        } else {
          const secureStorage = FlutterSecureStorage();
          final email = await secureStorage.read(key: "email");
          final password = await secureStorage.read(key: "password");

          if (email != null && password != null) {
            context.read<AuthenticationBloc>().add(
                  LoginAuthenticationEvent(email: email, password: password),
                );
          } else {
            Get.offAllNamed("/login");
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // Small delay to allow UI to build before showing auth dialog
    Future.delayed(const Duration(milliseconds: 500), auth);
  }

  @override
  Widget build(BuildContext context) {
    final contentColor = context.appColors.primaryTextColor;
    final secondaryColor =
        context.appColors.secondaryTextColor;
    final glassColor = context.appColors.glassBorder;
    final glassBorderColor =
        context.appColors.glassBorder;

    return Scaffold(
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is SuccessLoginAuthenticationState) {
            BackgroundNotificationService.connectForeground();
            DeviceTokenService.tryRegisterStoredToken();
            context.read<ProfileBloc>().add(GetProfileEvent());
            Future.delayed(const Duration(seconds: 2), () {
              if (!mounted) return;
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
          } else if (state is FailureLoginAuthenticationState) {
            Get.snackbar(
              "Login Failed",
              "Biometric login failed. Please sign in with your password.",
              snackPosition: SnackPosition.BOTTOM,
            );
            Get.offAllNamed("/login");
          }
        },
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return LoadingView(
              isLoading: state is LoadingAuthenticationState,
              child: GradientBackground(
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(30.r),
                          decoration: BoxDecoration(
                            color: context.appColors.cardBackground,
                            shape: BoxShape.circle,
                            border: Border.all(color: glassBorderColor),
                          ),
                          child: FaIcon(FontAwesomeIcons.fingerprint,
                              color: contentColor, size: 80.r),
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "NEIGHBOR SERVICE LOCKED",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: contentColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          "Authenticate to continue",
                          style: TextStyle(fontSize: 16.sp, color: secondaryColor),
                        ),
                        SizedBox(height: 50.h),
                        if (!_isAuthenticating)
                          TextButton.icon(
                            onPressed: auth,
                            icon: FaIcon(FontAwesomeIcons.lockOpen, color: contentColor),
                            label: Text(
                              "UNLOCK",
                              style: TextStyle(
                                color: contentColor, 
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30.w,
                                vertical: 15.h,
                              ),
                              backgroundColor: glassColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                                side: BorderSide(color: glassBorderColor),
                              ),
                            ),
                          ),
                      ],
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
}

