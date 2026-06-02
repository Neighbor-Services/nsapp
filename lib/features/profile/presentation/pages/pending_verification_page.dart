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
    final colors = context.appColors;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Account Verification",
          style: TextStyle(
            color: colors.primaryTextColor,
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.arrowRightFromBracket,
              color: colors.primaryTextColor.withAlpha(200),
            ),
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
                const SnackBar(
                  content: Text("Your background check is still processing. Please check back later."),
                  behavior: SnackBarBehavior.floating,
                ),
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
                backgroundColor: colors.errorColor.withAlpha(200),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: GradientBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.h),
                  // Animated Shield/Icon section
                  _buildAnimatedIconSection(colors),
                  SizedBox(height: 32.h),

                  // Header title & Description
                  Text(
                    "Verification Required",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: colors.primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "To ensure community safety, all service providers must complete a secure background check before accepting requests.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: colors.secondaryTextColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  // Visual Stepper/Timeline
                  _buildTimelineStepper(colors),
                  SizedBox(height: 32.h),

                  // Information Details Card
                  _buildDetailsCard(colors),
                  SizedBox(height: 32.h),

                  // Buttons Section
                  _buildActionButtons(colors),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIconSection(AppColorsExtension colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Decorative glowing circles background
        Container(
          width: 140.r,
          height: 140.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryColor.withAlpha(20),
            boxShadow: [
              BoxShadow(
                color: colors.primaryColor.withAlpha(30),
                blurRadius: 40.r,
                spreadRadius: 10.r,
              ),
            ],
          ),
        ),
        Container(
          width: 110.r,
          height: 110.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryColor.withAlpha(40),
          ),
        ),
        // Shield Icon
        Container(
          padding: EdgeInsets.all(22.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.cardBackground,
            border: Border.all(
              color: colors.glassBorder,
              width: 2.r,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 15.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.shieldHalved,
              size: 48.r,
              color: colors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineStepper(AppColorsExtension colors) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: colors.cardBackground.withAlpha(60),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: colors.glassBorder, width: 1.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepNode(
            title: "Register",
            icon: FontAwesomeIcons.check,
            isCompleted: true,
            isActive: false,
            colors: colors,
          ),
          _buildStepConnector(isCompleted: true, colors: colors),
          _buildStepNode(
            title: "Verify",
            icon: FontAwesomeIcons.magnifyingGlass,
            isCompleted: false,
            isActive: true,
            colors: colors,
          ),
          _buildStepConnector(isCompleted: false, colors: colors),
          _buildStepNode(
            title: "Go Active",
            icon: FontAwesomeIcons.rocket,
            isCompleted: false,
            isActive: false,
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode({
    required String title,
    required FaIconData icon,
    required bool isCompleted,
    required bool isActive,
    required AppColorsExtension colors,
  }) {
    Color nodeColor;
    Color iconColor;
    double size = 36.r;

    if (isCompleted) {
      nodeColor = colors.successColor;
      iconColor = Colors.white;
    } else if (isActive) {
      nodeColor = colors.primaryColor;
      iconColor = Colors.white;
    } else {
      nodeColor = colors.secondaryTextColor.withAlpha(40);
      iconColor = colors.secondaryTextColor.withAlpha(150);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: nodeColor,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: colors.primaryColor.withAlpha(80),
                      blurRadius: 10.r,
                      spreadRadius: 2.r,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 16.r,
              color: iconColor,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.w400,
            color: isActive || isCompleted ? colors.primaryTextColor : colors.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isCompleted, required AppColorsExtension colors}) {
    return Expanded(
      child: Container(
        height: 3.h,
        margin: EdgeInsets.only(left: 8.w, right: 8.w, bottom: 20.h),
        decoration: BoxDecoration(
          color: isCompleted ? colors.successColor : colors.secondaryTextColor.withAlpha(40),
          borderRadius: BorderRadius.circular(1.5.r),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(AppColorsExtension colors) {
    return SolidContainer(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.circleInfo, color: colors.primaryColor, size: 20.r),
              SizedBox(width: 12.w),
              Text(
                "How it works",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          _buildInfoRow(
            icon: FontAwesomeIcons.shieldHalved,
            title: "Secure Screening",
            description: "Screening is performed by Checkr, a secure FCRA-compliant platform trusted by leading on-demand networks.",
            colors: colors,
          ),
          Divider(color: colors.glassBorder, height: 24.h),
          _buildInfoRow(
            icon: FontAwesomeIcons.clock,
            title: "Processing Time",
            description: "Background checks typically clear in 2-5 business days. We will notify you the moment your check clears.",
            colors: colors,
          ),
          Divider(color: colors.glassBorder, height: 24.h),
          _buildInfoRow(
            icon: FontAwesomeIcons.userCheck,
            title: "Instant Activation",
            description: "Once verified, your profile becomes publicly visible to nearby seekers so you can begin earning.",
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required FaIconData icon,
    required String title,
    required String description,
    required AppColorsExtension colors,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2.h),
          child: FaIcon(icon, color: colors.secondaryTextColor.withAlpha(200), size: 16.r),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryTextColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colors.secondaryTextColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AppColorsExtension colors) {
    return Column(
      children: [
        SolidButton(
          label: "Start Background Check",
          icon: FontAwesomeIcons.upRightFromSquare,
          isLoading: _isLoading,
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
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
            } catch (e) {
              debugPrint("Background check initialization failed: $e");
              if (context.mounted) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to initiate background check: $e"),
                    backgroundColor: colors.errorColor.withAlpha(200),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        ),
        SizedBox(height: 16.h),
        SolidButton(
          label: "Check Status",
          isPrimary: false,
          isLoading: _isLoading,
          onPressed: () {
            context.read<ProfileBloc>().add(GetProfileEvent());
          },
        ),
      ],
    );
  }
}
