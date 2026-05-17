import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nsapp/features/authentications/presentation/bloc/authentication_bloc.dart';
import 'package:nsapp/core/services/payment_service.dart';

class PendingVerificationPage extends StatefulWidget {
  const PendingVerificationPage({super.key});

  @override
  State<PendingVerificationPage> createState() => _PendingVerificationPageState();
}

class _PendingVerificationPageState extends State<PendingVerificationPage> {
  bool _isLoading = false;

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open the background check form. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Verification"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowRightFromBracket),
            onPressed: () {
              context.read<AuthenticationBloc>().add(LogoutAuthenticationEvent());
              context.go("/login");
            },
            tooltip: "Logout",
          )
        ],
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is LoadingProfileState) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is SuccessGetProfileState) {
            if (state.profile.isIdentityVerified == true) {
              context.go("/home");
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Your background check is still processing. Please check back later.")),
              );
            }
          }

          if (state is SuccessInitiateBackgroundCheckState) {
            _launchUrl(state.url);
          }

          if (state is FailureInitiateBackgroundCheckState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.appColors.errorColor.withAlpha(200),
              ),
            );
          }
        },
        child: GradientBackground(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SolidContainer(
                  padding: EdgeInsets.all(32.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.shieldHalved,
                        size: 80.r,
                        color: context.appColors.primaryColor,
                      ),
                      SizedBox(height: 32.h),
                      Text(
                        "Verification Required",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primaryTextColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "To ensure the safety of our community, all providers must complete a background check through our partner Checkr before accepting requests.",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: context.appColors.secondaryTextColor,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.h),
                      SolidButton(
                        label: "START BACKGROUND CHECK",
                        icon: FontAwesomeIcons.upRightFromSquare,
                        isLoading: _isLoading,
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          
                          // 1. Fetch config from backend
                          final paymentMode = await PaymentService.getBackgroundCheckConfig();
                          
                          if (paymentMode == 'NATIVE_CHECKR') {
                            // Option 1: Native Checkr (Candidate-Paid)
                            if (context.mounted) {
                              context.read<ProfileBloc>().add(InitiateBackgroundCheckEvent(paymentIntentId: ""));
                            }
                          } else {
                            // Option 2: In-App Stripe Checkout
                            if (context.mounted) {
                              final paymentIntentId = await PaymentService.fundBackgroundCheck(context: context);
                              if (paymentIntentId != null && paymentIntentId.isNotEmpty) {
                                if (context.mounted) {
                                  context.read<ProfileBloc>().add(InitiateBackgroundCheckEvent(paymentIntentId: paymentIntentId));
                                }
                              } else {
                                if (context.mounted) {
                                   setState(() => _isLoading = false);
                                }
                              }
                            }
                          }
                        },
                      ),
                      SizedBox(height: 16.h),
                      SolidButton(
                        label: "I'VE COMPLETED IT (CHECK STATUS)",
                        isPrimary: false,
                        isLoading: _isLoading,
                        onPressed: () {
                          context.read<ProfileBloc>().add(GetProfileEvent());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


