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
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return Material(
                  color: Colors.transparent,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E2E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withAlpha(20),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wifi_off_rounded,
                                color: Colors.redAccent,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomTextWidget(
                              text: "Connection Lost",
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            CustomTextWidget(
                              text:
                                  "Please check your internet connection and try again.",
                              fontSize: 16,
                              color: isDark
                                  ? Colors.white.withAlpha(180)
                                  : Colors.black54,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [appOrangeColor1, appOrangeColor2],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: appOrangeColor1.withAlpha(100),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
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
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  "CLOSE APP",
                                  style: TextStyle(
                                    fontSize: 16,
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
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
              final subtitleColor = isDark
                  ? Colors.white.withAlpha(220)
                  : Colors.black87;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Opacity(
                      opacity: _logoFadeAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(20)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(40)
                                : Colors.black.withAlpha(10),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            logo2Assets,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Text(
                            'Neighbor Service',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: 1.2,
                              shadows: isDark
                                  ? [
                                      const Shadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SlideTransition(
                            position: _subtitleSlideAnimation,
                            child: FadeTransition(
                              opacity: _subtitleFadeAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                child: Text(
                                  'Connecting your business and\nyour side hustle to neighbors',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: subtitleColor,
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
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white70 : appOrangeColor1,
                            ),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 60),
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
