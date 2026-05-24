import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';

import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

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
    await Helpers.getBool("usebiometric");
    if (dark) {
      scaffold.currentContext?.read<SettingsBloc>().add(
        ToggleThemeModeEvent(themeMode: ThemeMode.dark),
      );
    } else {
      scaffold.currentContext?.read<SettingsBloc>().add(
        ToggleThemeModeEvent(themeMode: ThemeMode.light),
      );
    }
    // Retry up to 3 times before concluding there's no internet.
    // A single check can fail on many networks (ISP ICMP blocks, slow
    // network init on startup, corporate firewalls, etc.).
    bool hasInternet = false;
    for (int attempt = 0; attempt < 3; attempt++) {
      hasInternet = await InternetConnection().hasInternetAccess;
      if (hasInternet) break;
      if (attempt < 2) await Future.delayed(const Duration(milliseconds: 800));
    }
    if (!hasInternet) {
      context.go('/no-internet');
      return;
    }

    final isAuthenticated = await Helpers.isAuthenticated();
    if (isAuthenticated) {
      Helpers.getLocation();
      if (mounted) {
        context.read<ProfileBloc>().add(GetProfileEvent());
      }
      // Routing logic moved to BlocListener in build method
    } else {
      // Not authenticated, check for biometric credentials
      final usebiometric = await Helpers.getBool("usebiometric");
      if (usebiometric) {
        final email = await Helpers.getString("email");
        final password = await Helpers.getString("password");

        if (email.isNotEmpty && password.isNotEmpty) {
          context.go('/biometric');
          return;
        }
      }

      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        context.go('/login');
      }
    }
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

    _textSlideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero)
        .animate(
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
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) async {
        if (state is SuccessGetProfileState) {
          final profile = state.profile;
          if (profile.firstName != null &&
              profile.userType != null &&
              profile.phone != null) {
            bool isProvider = Helpers.isProvider(profile.userType);
            if (isProvider) {
              context.read<SettingsBloc>().add(
                ToggleDashboardEvent(isProvider: true),
              );
            }

            final usebiometric = await Helpers.getBool("usebiometric");
            if (isProvider && profile.isIdentityVerified != true) {
              context.go('/home');
              //  context.go("/pending-verification");
            } else if (usebiometric) {
              context.read<SettingsBloc>().add(
                UseBiometricEvent(useBiometric: true),
              );
              context.go('/biometric');
            } else {
              context.read<SettingsBloc>().add(
                UseBiometricEvent(useBiometric: false),
              );
              context.go("/home");
            }
          } else {
            context.go('/add-profile');
          }
        } else if (state is FailureGetProfileState) {
          context.go('/add-profile');
        }
      },
      child: Scaffold(
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
                                fontWeight: FontWeight.w500,
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
                                      color:
                                          context.appColors.secondaryTextColor,
                                      height: 1.6,
                                      fontWeight: FontWeight.w400,
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
      ),
    );
  }
}
