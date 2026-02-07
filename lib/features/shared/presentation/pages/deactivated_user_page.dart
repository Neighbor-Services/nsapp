import 'package:flutter/material.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

class DeactivatedUserPage extends StatefulWidget {
  const DeactivatedUserPage({super.key});

  @override
  State<DeactivatedUserPage> createState() => _DeactivatedUserPageState();
}

class _DeactivatedUserPageState extends State<DeactivatedUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            width: size(context).width,
            height: size(context).height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Hi, ${SuccessGetProfileState.profile.firstName}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Center(
                  child: SolidContainer(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.block,
                            color: Colors.redAccent,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Account Deactivated",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Your account has been deactivated by the administrator.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Placeholder for reason if available in future
                // CustomTextWidget(text: "Reason: ..."),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
