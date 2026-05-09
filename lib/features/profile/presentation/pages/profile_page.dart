import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_verification_page.dart';
import 'package:nsapp/features/provider/presentation/pages/add_service_package_page.dart';
import 'package:nsapp/features/profile/presentation/pages/audit_log_page.dart';
import 'package:nsapp/features/shared/presentation/widget/performance_badge_widget.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fetchProfile();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  void _fetchProfile() {
    context.read<ProfileBloc>().add(GetProfileStreamEvent());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProviderBloc, ProviderState>(
            listener: (context, state) {
              if (state is SuccessAddPortfolioItemState) {
                Get.back(); // Close loading dialog
                _fetchProfile();
                Get.snackbar(
                  "Success",
                  "Portfolio item added! AI analysis started.",
                  backgroundColor: context.appColors.successColor.withAlpha(100),
                  colorText: Colors.white,
                );
              } else if (state is FailureAddPortfolioItemState) {
                Get.back();
                Get.snackbar(
                  "Error",
                  state.message ?? "Failed to upload image. Please try again.",
                  backgroundColor: context.appColors.errorColor.withAlpha(100),
                  colorText: Colors.white,
                );
              } else if (state is LoadingProviderState) {
                Get.dialog(
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: context.appColors.cardBackground,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: const CircularProgressIndicator(),
                    ),
                  ),
                  barrierDismissible: false,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (previous, current) =>
              current is SuccessGetProfileStreamState ||
              current is FailureGetProfileStreamState ||
              current is LoadingProfileState ||
              current is InitialProfileState,
          builder: (context, state) {
            if (state is LoadingProfileState) {
              return const ProfileSkeletonLoader();
            }

            if (state is FailureGetProfileStreamState) {
              return _buildErrorUI(state.message);
            }

            if (state is SuccessGetProfileStreamState) {
              Profile profile = state.profile;
              final isProvider = Helpers.isProvider(profile.userType);

              return GradientBackground(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600.w),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            context.read<ProfileBloc>().add(GetProfileStreamEvent());
                            context.read<ProfileBloc>().add(GetProfileEvent());
                          },
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 32.w : 20.w,
                              vertical: 24.h,
                            ),
                            children: [
                              // Back & Edit Buttons
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                          width: 1.5.r,
                                        ),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.chevronLeft,
                                        color: context.appColors.primaryTextColor,
                                        size: 20.r,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Get.toNamed("/edit-profile"),
                                    child: Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                          width: 1.5.r,
                                        ),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.penToSquare,
                                        color: context.appColors.primaryTextColor,
                                        size: 20.r,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 32.h),
    
                              // Profile Header
                              _buildProfileHeader(profile, isProvider),
                              SizedBox(height: 32.h),
    
                              // Info Section
                              _buildInfoSection(profile),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return const ProfileSkeletonLoader();
          },
        ),
      ),
    );
  }

  Widget _buildErrorUI(String message) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.circleExclamation,
                size: 60.r,
                color: context.appColors.errorColor,
              ),
              SizedBox(height: 24.h),
              CustomTextWidget(
                text: "OPS! SOMETHING WENT WRONG",
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appColors.secondaryTextColor,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                onPressed: () {
                  _fetchProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text("RETRY"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Profile profile, bool isProvider) {
    final textColor = context.appColors.primaryTextColor;
    final subTextColor = context.appColors.secondaryTextColor;

    return Column(
      children: [
        // Avatar
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: context.appColors.glassBorder,
              width: 1.5.r,
            ),
            boxShadow: [
              BoxShadow(
                color: (isProvider ? context.appColors.primaryColor : context.appColors.secondaryColor)
                    .withAlpha(60),
                blurRadius: 40.r,
                spreadRadius: -10.r,
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.all(2.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: context.appColors.glassBorder,
                width: 1.r,
              ),
            ),
            child: CircleAvatar(
              radius: 60.r,
              backgroundColor: context.appColors.glassBorder,
              backgroundImage:
                  (profile.profilePictureUrl != null &&
                      profile.profilePictureUrl!.isNotEmpty &&
                      !profile.profilePictureUrl!.startsWith("file:///"))
                  ? NetworkImage(profile.profilePictureUrl!)
                  : const AssetImage(logoAssets) as ImageProvider,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.firstName ?? "USER",
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w500,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            if (profile.isIdentityVerified == true) ...[
              SizedBox(width: 8.w),
               Icon(
                FontAwesomeIcons.circleCheck,
                color: context.appColors.infoColor,
                size: 26.r,
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        Text(
          profile.user?.email ?? "No email provided",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: subTextColor,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: (isProvider ? context.appColors.primaryColor : context.appColors.secondaryColor).withAlpha(
              40,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: (isProvider ? context.appColors.primaryColor : context.appColors.secondaryColor)
                  .withAlpha(60),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isProvider
                    ? FontAwesomeIcons.briefcase
                    : FontAwesomeIcons.user,
                size: 14.r,
                color: isProvider
                    ? context.appColors.primaryColor
                    : context.appColors.warningColor,
              ),
              SizedBox(width: 8.w),
              Text(
                profile.userType?.toUpperCase() ?? "USER",
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: isProvider
                      ? context.appColors.primaryColor
                      : context.appColors.warningColor,
                ),
              ),
            ],
          ),
        ),
        if (profile.performanceBadges != null &&
            profile.performanceBadges!.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: profile.performanceBadges!
                .map(
                   (badge) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: PerformanceBadgeWidget(badge: badge),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoSection(Profile profile) {
    final containerColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: borderColor,
          width: 1.5.r,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            "Email",
            profile.user?.email ?? "Not set",
            FontAwesomeIcons.envelope,
          ),
          _buildInfoRow(
            "Country",
            profile.country ?? "Not set",
            FontAwesomeIcons.globe,
          ),
          _buildInfoRow(
            "Phone",
            profile.phone ?? "Not set",
            FontAwesomeIcons.phone,
          ),
          
          _buildInfoRow(
            "Address",
            profile.address ?? "Not set",
            FontAwesomeIcons.locationDot,
          ),
          _buildInfoRow(
            "Gender",
            profile.gender ?? "Not set",
            FontAwesomeIcons.user,
          ),
          _buildInfoRow("State", profile.state ?? "Not set", FontAwesomeIcons.map),
          _buildInfoRow(
            "Service",
            getServiceName(profile.service ?? ""),
            FontAwesomeIcons.briefcase,
          ),
          _buildInfoRow(
            "Date of Birth",
            profile.dateOfBirth != null
                ? DateFormat("dd/MM/yyyy").format(profile.dateOfBirth!)
                : "Not set",
            FontAwesomeIcons.cakeCandles,
          ),
          _buildInfoRow(
            "Zipcode",
            profile.zipCode ?? "Not set",
            FontAwesomeIcons.mapPin,
          ),
          
          // Audit Logs Link
          InkWell(
            onTap: () => Get.to(() => const AuditLogPage()),
            child: _buildInfoRow(
              "Activity History",
              "View your recent logs",
              FontAwesomeIcons.clockRotateLeft,
            ),
          ),

          if (Helpers.isProvider(profile.userType)) ...[
            _buildGlassDivider(),
            _buildInfoRow(
              "Payment Preference",
              profile.preferredPaymentMode ?? "BOTH",
              FontAwesomeIcons.creditCard,
            ),
            InkWell(
              onTap: () {
                Get.to(() => const AddServicePackagePage());
              },
              child: _buildInfoRow(
                "Service Packages",
                "Add New Package",
                FontAwesomeIcons.boxOpen,
              ),
            ),
            if (Helpers.isProvider(profile.userType) &&
                profile.isIdentityVerified == false) ...[
              _buildGlassDivider(),
              InkWell(
                onTap: () => Get.to(() => const ProviderVerificationPage()),
                child: _buildInfoRow(
                  "Verification",
                  "Verify Identity",
                  FontAwesomeIcons.userShield,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final labelColor = context.appColors.secondaryTextColor;
    final valueColor = context.appColors.primaryTextColor;
 
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: context.appColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 50.r,
              height: 50.r,
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: context.appColors.glassBorder),
              ),
              child: Icon(icon, color: context.appColors.primaryColor, size: 25.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value.isNotEmpty ? value : "Not set",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: valueColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassDivider() {
    return Divider(
      height: 1,
      color: context.appColors.glassBorder,
    );
  }
}



