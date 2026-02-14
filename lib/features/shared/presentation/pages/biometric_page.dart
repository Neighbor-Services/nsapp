import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

class BiometricPage extends StatefulWidget {
  const BiometricPage({super.key});

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  final LocalAuthentication localAuthentication = LocalAuthentication();
  bool _isAuthenticating = false;

  auth() async {
    setState(() => _isAuthenticating = true);
    try {
      final bool hasBiometric = await localAuthentication.canCheckBiometrics;
      final isAuthenticated = await localAuthentication.authenticate(
        localizedReason: "Unlock Neighbor Service",
        biometricOnly: hasBiometric,
      );

      if (isAuthenticated) {
        Get.offAllNamed("/home");
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contentColor = isDark ? Colors.white : Colors.black87;
    final secondaryColor = isDark
        ? Colors.white.withAlpha(180)
        : Colors.black54;
    final glassColor = isDark ? Colors.white.withAlpha(20) : Colors.black12;
    final glassBorderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black26;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: glassColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: glassBorderColor),
                  ),
                  child: Icon(Icons.fingerprint, color: contentColor, size: 80),
                ),
                const SizedBox(height: 30),
                Text(
                  "Neighbor Service Locked",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Authenticate to continue",
                  style: TextStyle(fontSize: 16, color: secondaryColor),
                ),
                const SizedBox(height: 50),
                if (!_isAuthenticating)
                  TextButton.icon(
                    onPressed: auth,
                    icon: Icon(Icons.lock_open, color: contentColor),
                    label: Text(
                      "Unlock",
                      style: TextStyle(color: contentColor, fontSize: 16),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      backgroundColor: glassColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
  }
}
