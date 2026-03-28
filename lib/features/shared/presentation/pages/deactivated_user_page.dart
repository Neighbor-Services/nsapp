import 'package:flutter/material.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';


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
            padding: EdgeInsets.all(20),
            width: size(context).width,
            height: size(context).height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "HI, ${SuccessGetProfileState.profile.firstName?.toUpperCase() ?? ''}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Center(
                  child: SolidContainer(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: context.appColors.errorColor.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child:  Icon(
                            Icons.block,
                            color: context.appColors.errorColor,
                            size: 80,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "ACCOUNT DEACTIVATED",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "YOUR ACCOUNT HAS BEEN DEACTIVATED BY THE ADMINISTRATOR.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withAlpha(200),
                            letterSpacing: 0.8,
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
