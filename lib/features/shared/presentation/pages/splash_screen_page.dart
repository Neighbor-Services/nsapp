import 'dart:async';
import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../bloc/shared_bloc.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffold = GlobalKey<ScaffoldState>();

  StreamSubscription? streamSubscription;
  late AnimationController _controller;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  init() async {
    final bool dark = await Helpers.getBool("darkmode");
    final bool usebiometric = await Helpers.getBool("usebiometric");
    if (dark) {
      scaffold.currentContext?.read<SharedBloc>().add(
        ToggleThemeModeEvent(themeMode: ThemeMode.dark),
      );
    } else {
      scaffold.currentContext?.read<SharedBloc>().add(
        ToggleThemeModeEvent(themeMode: ThemeMode.light),
      );
    }
    streamSubscription = InternetConnection().onStatusChange.listen((
      status,
    ) async {
      switch (status) {
        case InternetStatus.connected:
          final isAuthenticated = await Helpers.isAuthenticated();
          if (isAuthenticated) {
            Helpers.getLocation();
            if (mounted) {
              context.read<ProfileBloc>().add(GetProfileEvent());
            }

            await Future.delayed(const Duration(seconds: 4));

            if (!mounted) return;

            if (SuccessGetProfileState.profile.firstName != null) {
              context.read<SharedBloc>().add(
                SharedBlocReloadEvent(SuccessGetProfileState.profile.userType!),
              );

              if (Helpers.isProvider(SuccessGetProfileState.profile.userType)) {
                context.read<SharedBloc>().add(
                  SharedBlocReloadEvent("PROVIDER"),
                );
                context.read<SharedBloc>().add(
                  ToggleDashboardEvent(isProvider: true),
                );
              }
              if (usebiometric) {
                context.read<SharedBloc>().add(
                  UseBiometricEvent(usebiometric: true),
                );
                Get.offAllNamed('/biometric');
              } else {
                context.read<SharedBloc>().add(
                  UseBiometricEvent(usebiometric: false),
                );
                Get.offAllNamed("/home");
              }
            } else {
              Get.offAllNamed('/add-profile');
            }
            } else {
            // Not authenticated, check for biometric credentials
            final usebiometric = await Helpers.getBool("usebiometric");
            if (usebiometric) {
              const secureStorage = FlutterSecureStorage();
              final email = await secureStorage.read(key: "email");
              final password = await secureStorage.read(key: "password");

              if (email != null && password != null) {
                Get.offAllNamed('/biometric');
                return;
              }
            }

            await Future.delayed(const Duration(seconds: 3));
            if (mounted) {
              Get.offAllNamed('/login');
            }
          }
          break;
        case InternetStatus.disconnected:
          Future.delayed(const Duration(seconds: 3), () {
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0.r),
                      child: Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: context.appColors.cardBackground,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: context.appColors.glassBorder,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: context.appColors.errorColor.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.wifi_off_rounded,
                                color: context.appColors.errorColor,
                                size: 40.r,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            CustomTextWidget(
                              text: "Connection Lost",
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.primaryTextColor,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            CustomTextWidget(
                              text:
                                  "Please check your internet connection and try again.",
                              fontSize: 16.sp,
                              color: context.appColors.secondaryTextColor,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                            SizedBox(height: 32.h),
                            Container(
                              width: double.infinity,
                              height: 55.h,
                              decoration: BoxDecoration(
                                gradient: context.appColors.primaryGradient,
                                borderRadius: BorderRadius.circular(16.r),
                                
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (Platform.isAndroid) {
                                    SystemNavigator.pop();
                                  } else if (Platform.isIOS) {
                                    exit(0);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                ),
                                child: Text(
                                  "CLOSE APP",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.1,
                                  ),
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
            );
          });
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
          ),
        );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnimation =
        Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
    init();
  }

  @override
  void dispose() {
    _controller.dispose();
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffold,
      body: GradientBackground(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final textColor = context.appColors.primaryTextColor;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: context.appColors.cardBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.appColors.glassBorder,
                            width: 1.5.r,
                          ),
                         
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.r),
                          child: Image.asset(
                            logo2Assets,
                            width: 110.w,
                            height: 110.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Neighbor Service',
                            style: TextStyle(
                              fontSize: 34.sp,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          SlideTransition(
                            position: _subtitleSlideAnimation,
                            child: FadeTransition(
                              opacity: _subtitleFadeAnimation,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30.w,
                                ),
                                child: Text(
                                  'Connecting your business and\nyour side hustle to neighbors',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: context.appColors.secondaryTextColor,
                                    height: 1.6,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _subtitleFadeAnimation,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 40.w,
                          height: 40.h,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.appColors.secondaryTextColor,
                            ),
                            strokeWidth: 3.r,
                          ),
                        ),
                        SizedBox(height: 60.h),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
