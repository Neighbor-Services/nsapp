import 'dart:io';
import 'package:nsapp/core/initialize/init.dart' as init;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_verification_page.dart';
import 'package:nsapp/features/provider/presentation/pages/add_service_package_page.dart';
import 'package:nsapp/features/profile/presentation/widgets/portfolio_gallery.dart';
import 'package:nsapp/features/shared/presentation/widget/performance_badge_widget.dart';

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
    context.read<ProfileBloc>().add(GetProfileStreamEvent());

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
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {},
          ),
          BlocListener<ProviderBloc, ProviderState>(
            listener: (context, state) {
              if (state is SuccessAddPortfolioItemState) {
                Get.back(); // Close loading dialog if any
                context.read<ProfileBloc>().add(GetProfileStreamEvent());
                Get.snackbar(
                  "Success",
                  "Portfolio item added! AI analysis started.",
                  backgroundColor: Colors.green.withAlpha(100),
                  colorText: Colors.white,
                );
              } else if (state is FailureAddPortfolioItemState) {
                Get.back();
                Get.snackbar(
                  "Error",
                  "Failed to upload image. Please try again.",
                  backgroundColor: Colors.red.withAlpha(100),
                  colorText: Colors.white,
                );
              } else if (state is LoadingProviderState) {
                Get.dialog(
                  const Center(child: LoadingWidget()),
                  barrierDismissible: false,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is! SuccessGetProfileStreamState &&
                SuccessGetProfileState.profile.id == null) {
              return const Center(child: LoadingWidget());
            }

            return FutureBuilder<Profile>(
              future: SuccessGetProfileStreamState.profile,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  Profile profile = snapshot.data!;
                  final isProvider = Helpers.isProvider(profile.userType);

                  return GradientBackground(
                    child: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.symmetric(
                                horizontal: isLargeScreen ? 32 : 20,
                                vertical: 24,
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
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withAlpha(25)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white.withAlpha(40)
                                                : Colors.black.withAlpha(10),
                                          ),
                                          boxShadow:
                                              Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(10),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Get.toNamed("/edit-profile"),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withAlpha(25)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color:
                                                Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white.withAlpha(40)
                                                : Colors.black.withAlpha(10),
                                          ),
                                          boxShadow:
                                              Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(10),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Icon(
                                          Icons.edit_rounded,
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black87,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Profile Header
                                _buildProfileHeader(profile, isProvider),
                                const SizedBox(height: 32),

                                // Info Section
                                _buildInfoSection(profile),
                                const SizedBox(height: 24),

                                // Portfolio Section
                                PortfolioGallery(
                                  profile: profile,
                                  isProvider: isProvider,
                                  onAddImage: () =>
                                      _pickAndUploadPortfolioImage(context),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Center(child: LoadingWidget());
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Profile profile, bool isProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white.withAlpha(140) : Colors.black54;

    return Column(
      children: [
        // Avatar
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(100)
                  : Colors.black.withAlpha(20),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isProvider ? appDeepBlueColor1 : appOrangeColor1)
                    .withAlpha(60),
                blurRadius: 40,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(40)
                    : Colors.black.withAlpha(10),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.grey.shade200,
              backgroundImage:
                  (profile.profilePictureUrl != null &&
                      profile.profilePictureUrl!.isNotEmpty &&
                      !profile.profilePictureUrl!.startsWith("file:///"))
                  ? NetworkImage(profile.profilePictureUrl!)
                  : const AssetImage(logoAssets) as ImageProvider,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              profile.firstName ?? "User",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            if (profile.isIdentityVerified == true) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified_rounded,
                color: Colors.blueAccent,
                size: 26,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          profile.user?.email ?? "No email provided",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: subTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: (isProvider ? appDeepBlueColor1 : appOrangeColor1).withAlpha(
              40,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isProvider ? appDeepBlueColor1 : appOrangeColor1)
                  .withAlpha(60),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isProvider
                    ? Icons.business_center_rounded
                    : Icons.person_rounded,
                size: 14,
                color: isProvider
                    ? Colors.lightBlueAccent
                    : Colors.orangeAccent,
              ),
              const SizedBox(width: 8),
              Text(
                profile.userType?.toUpperCase() ?? "USER",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isProvider
                      ? Colors.lightBlueAccent
                      : Colors.orangeAccent,
                ),
              ),
            ],
          ),
        ),
        if (profile.performanceBadges != null &&
            profile.performanceBadges!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: profile.performanceBadges!
                .map(
                  (badge) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? Colors.white.withAlpha(15) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.black.withAlpha(10);
    final shadow = isDark
        ? null
        : [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor),
        boxShadow: shadow,
      ),
      child: Column(
        children: [
          _buildInfoRow(
            "Email",
            profile.user?.email ?? "Not set",
            Icons.email_rounded,
          ),
          _buildGlassDivider(),
          _buildInfoRow(
            "Country",
            profile.country ?? "Not set",
            Icons.public_rounded,
          ),
          _buildGlassDivider(),
          _buildInfoRow(
            "Phone",
            "(${profile.countryCode ?? ""}) ${profile.phone ?? ""}",
            Icons.phone_rounded,
          ),
          _buildGlassDivider(),
          _buildInfoRow(
            "Address",
            profile.address ?? "Not set",
            Icons.location_on_rounded,
          ),
          _buildGlassDivider(),
          _buildInfoRow(
            "Gender",
            profile.gender ?? "Not set",
            Icons.person_rounded,
          ),
          _buildGlassDivider(),
          _buildInfoRow("State", profile.state ?? "Not set", Icons.map_rounded),
          _buildGlassDivider(),
          _buildInfoRow(
            "Service",
            getServiceName(profile.service ?? ""),
            Icons.work_rounded,
          ),
          _buildGlassDivider(),
          _buildInfoRow(
            "Date of Birth",
            profile.dateOfBirth != null
                ? DateFormat("dd/MM/yyyy").format(profile.dateOfBirth!)
                : "Not set",
            Icons.cake_rounded,
          ),
          _buildGlassDivider(),
          _buildInfoRow(
            "Zipcode",
            profile.zipCode ?? "Not set",
            Icons.pin_drop_rounded,
          ),
          if (Helpers.isProvider(profile.userType)) ...[
            _buildGlassDivider(),
            _buildInfoRow(
              "Payment Preference",
              profile.preferredPaymentMode ?? "BOTH",
              Icons.payments_rounded,
            ),
            _buildGlassDivider(),
            InkWell(
              onTap: () {
                // Navigate to Add Service Package Page
                Get.to(() => const AddServicePackagePage());
              },
              child: _buildInfoRow(
                "Service Packages",
                "Add New Package",
                Icons.inventory_2_rounded,
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
                  Icons.verified_user_rounded,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark
        ? Colors.white.withAlpha(15)
        : Colors.black.withAlpha(5);
    final iconColor = isDark ? Colors.white.withAlpha(180) : Colors.black54;
    final labelColor = isDark ? Colors.white.withAlpha(120) : Colors.black54;
    final valueColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : "Not set",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(10),
    );
  }

  Future<void> _pickAndUploadPortfolioImage(BuildContext context) async {
    await MediaUtils.selectImageFromGallery();
    if (init.image != null) {
      // Show description dialog (optional, but good for UX)
      final descController = TextEditingController();
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor = isDark ? Colors.white : Colors.black87;
      final hintColor = isDark
          ? Colors.white.withAlpha(100)
          : Colors.black.withAlpha(100);
      final fillColor = isDark
          ? Colors.white.withAlpha(10)
          : Colors.black.withAlpha(5);
      final borderColor = isDark
          ? Colors.white.withAlpha(30)
          : Colors.black.withAlpha(10);
      final cancelColor = isDark
          ? Colors.white.withAlpha(160)
          : Colors.black.withAlpha(160);

      Get.dialog(
        Center(
          child: Dialog(
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(
                color: isDark
                    ? Colors.white.withAlpha(40)
                    : Colors.black.withAlpha(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Add Portfolio Item",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(init.image!.path),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Enter a brief description (optional)",
                      hintStyle: TextStyle(color: hintColor),
                      filled: true,
                      fillColor: fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: cancelColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: appDeepBlueColor1.withAlpha(60),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<ProviderBloc>().add(
                                AddPortfolioItemEvent(
                                  image: File(init.image!.path),
                                  description: descController.text.isEmpty
                                      ? null
                                      : descController.text,
                                ),
                              );
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appDeepBlueColor1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Upload",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
