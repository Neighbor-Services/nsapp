import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  bool _isChecking = false;

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
    });

    final hasInternet = await InternetConnection().hasInternetAccess;
    
    setState(() {
      _isChecking = false;
    });

    if (hasInternet) {
      Get.offAllNamed('/'); // Restart via the registered splash route
    } else {
      // Show brief snackbar that it's still offline
      Get.snackbar(
        "Still Offline",
        "Please check your network settings.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: context.appColors.errorColor.withAlpha(200),
        colorText: Colors.white,
        margin: EdgeInsets.all(16.r),
        borderRadius: 12.r,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.0.r),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(32.r),
                    decoration: BoxDecoration(
                      color: context.appColors.errorColor.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.wifi,
                      color: context.appColors.errorColor,
                      size: 64.r,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  CustomTextWidget(
                    text: "Connection Lost",
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.primaryTextColor,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextWidget(
                    text: "It looks like you're not connected to the internet. Please check your network connection and try again.",
                    fontSize: 16.sp,
                    color: context.appColors.secondaryTextColor,
                    textAlign: TextAlign.center,
                    maxLines: 4,
                  ),
                  SizedBox(height: 48.h),
                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: _isChecking ? null : _checkConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _isChecking
                          ? SizedBox(
                              width: 24.r,
                              height: 24.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              "RETRY CONNECTION",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }
                    },
                    child: Text(
                      "CLOSE APP",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.appColors.hintTextColor,
                        fontWeight: FontWeight.w500,
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
  }
}
