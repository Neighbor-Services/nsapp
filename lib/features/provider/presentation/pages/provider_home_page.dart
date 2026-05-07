import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_more_requests_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_search_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_targeted_requests_page.dart';
import 'package:nsapp/features/provider/presentation/widgets/provider_recent_request_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/location/location_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/subscribe_dialog_widget.dart';
import 'package:nsapp/features/wallet/presentation/pages/wallet_page.dart';

import '../bloc/provider_bloc.dart';

class ProviderHomePage extends StatefulWidget {
  const ProviderHomePage({super.key});

  @override
  State<ProviderHomePage> createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isSubscriptionValid = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(SearchRequestEvent());
    context.read<ProviderBloc>().add(GetAcceptedRequestEvent());
    context.read<CommonBloc>().add(GetServicesEvent());
    context.read<WalletBloc>().add(GetMyWalletEvent());
    context.read<SubscriptionBloc>().add(CheckUserSubscriptionEvent());

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

  Widget _buildAnimatedSection(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 150)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is ValidUserSubscriptionState) {
                setState(() => _isSubscriptionValid = state.isValid);
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (previous, current) =>
              current is SuccessGetProfileState ||
              current is SuccessGetProfileStreamState ||
              current is LoadingProfileState ||
              current is InitialProfileState,
          builder: (context, profileState) {
            Profile? profile;
            if (profileState is SuccessGetProfileState) {
              profile = profileState.profile;
            } else if (profileState is SuccessGetProfileStreamState) {
              profile = profileState.profile;
            }

            return GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 800.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 32.w : 20.w,
                          vertical: 20.h,
                        ),
                        children: [
                          _buildAnimatedSection(0, _buildHeader(context)),
                          SizedBox(height: 16.h),
                          _buildAnimatedSection(1, _buildGamificationBar(context, profile)),
                          SizedBox(height: 24.h),

                          // Performance Dashboard
                          _buildAnimatedSection(2, _buildDashboard(context, isLargeScreen)),
                          SizedBox(height: 32.h),

                          // Search Bar
                          _buildAnimatedSection(1, _buildSearchBar(context)),
                          SizedBox(height: 32.h),

                          // Recent Requests Section
                          _buildAnimatedSection(2, Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(context, "Recent Requests"),
                              SizedBox(height: 16.h),
                              SizedBox(
                                height: 250.h,
                                child: const ProviderRecentRequestWidget(),
                              ),
                            ],
                          )),
                          SizedBox(height: 32.h),

                          _buildAnimatedSection(3, Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(context, "Explore More"),
                              SizedBox(height: 16.h),
                              _buildDirectRequestsCard(context),
                            ],
                          )),
                          SizedBox(height: 16.h),
                          _buildAnimatedSection(4, _buildExploreCard(context)),
                          SizedBox(height: 16.h),
                          if (profile?.preferredPaymentMode != 'ON_SITE') ...[
                            _buildAnimatedSection(5, _buildWalletCard(context)),
                            SizedBox(height: 32.h),
                          ],

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, bool isLargeScreen) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<ProviderBloc, ProviderState>(
              builder: (context, providerState) {
                final wallet = (walletState is SuccessGetMyWalletState)
                    ? walletState.wallet
                    : null;
                
                Profile? profile;
                if (profileState is SuccessGetProfileState) {
                  profile = profileState.profile;
                } else if (profileState is SuccessGetProfileStreamState) {
                  profile = profileState.profile;
                }

                if (profile == null) return const SizedBox.shrink();

                List<RequestAcceptance> accepts = [];
                if (providerState is SuccessGetAcceptRequestState) {
                  accepts = providerState.accepts;
                }
                final bidsCount = accepts.length;

                return SolidContainer(
                  padding: EdgeInsets.all(24.r),
                  backgroundColor: context.appColors.primaryColor,
                  borderRadius: BorderRadius.circular(28.r),
                  gradient: context.appColors.primaryGradient,
                  child: Column(
                    children: [
                      if (profile.preferredPaymentMode != 'ON_SITE') ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TOTAL BALANCE",
                                  style: TextStyle(
                                    color: context.appColors.primaryTextColor,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "${wallet?.currency ?? 'USD'} ${wallet?.balance?.toStringAsFixed(2) ?? '0.00'}",
                                  style: TextStyle(
                                    color: context.appColors.primaryTextColor,
                                    fontSize: 32.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(() => const WalletPage());
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.cardBackground,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: context.appColors.glassBorder,
                                    width: 1.5.r,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "WALLET",
                                      style: TextStyle(
                                        color: context.appColors.primaryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.sp,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(
                                      FontAwesomeIcons.chevronRight,
                                      size: 10.r,
                                      color: context.appColors.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                      ],
                      // Removed duplicate _buildGamificationBar
                      Row(
                        children: [
                          _buildDashboardStat(
                            "Active Bids",
                            bidsCount.toString(),
                            FontAwesomeIcons.gavel,
                            context.appColors.warningColor,
                          ),
                          SizedBox(width: 16.w),
                          _buildDashboardStat(
                            "Avg Rating",
                            profile.averageRating?.toStringAsFixed(1) ?? "0.0",
                            FontAwesomeIcons.star,
                            Colors.yellow,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    String greeting = "Good Day";
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 17) {
      greeting = "Good Afternoon";
    } else {
      greeting = "Good Evening";
    }

    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (previous, current) => 
        current is SuccessGetProfileState || 
        current is SuccessGetProfileStreamState,
      builder: (context, state) {
        String name = "Neighbor";
        if (state is SuccessGetProfileState) {
          name = state.profile.firstName ?? "Neighbor";
        } else if (state is SuccessGetProfileStreamState) {
          name = state.profile.firstName ?? "Neighbor";
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$greeting, $name! 👋",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.primaryTextColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _buildLocationHeader(context),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                Get.toNamed("/notifications");
              },
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.appColors.glassBorder),
                ),
                child: Stack(
                  children: [
                    FaIcon(FontAwesomeIcons.bell, size: 20.r, color: context.appColors.primaryTextColor),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8.r,
                        height: 8.r,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final address = (state.location.city.isNotEmpty)
            ? "${state.location.city}, ${state.location.state}"
            : "Locating...";
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Get.toNamed("/map-location");
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.locationDot,
                color: context.appColors.primaryColor,
                size: 12.r,
              ),
              SizedBox(width: 6.w),
              Text(
                address.toUpperCase(),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.secondaryTextColor,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 4.w),
              Icon(
                FontAwesomeIcons.chevronDown,
                size: 10.r,
                color: context.appColors.secondaryTextColor,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGamificationBar(BuildContext context, Profile? profile) {
    final streak = profile?.streakCount ?? 0;
    final score = profile?.neighborScore ?? 500;
    final level = profile?.level ?? 1;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: context.appColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGamificationItem(
                icon: FontAwesomeIcons.fire,
                iconColor: Colors.orangeAccent,
                label: "$streak DAY STREAK",
                value: "STREAK",
              ),
              Container(height: 30.h, width: 1, color: context.appColors.glassBorder),
              _buildGamificationItem(
                icon: FontAwesomeIcons.shieldHeart,
                iconColor: Colors.blueAccent,
                label: "NEIGHBOR SCORE",
                value: "$score",
              ),
              Container(height: 30.h, width: 1, color: context.appColors.glassBorder),
              _buildGamificationItem(
                icon: FontAwesomeIcons.bolt,
                iconColor: Colors.yellowAccent,
                label: "LVL $level",
                value: "PROVIDER",
              ),
            ],
          ),
        ),
        if (profile != null) ...[
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "PROGRESS TO NEXT LEVEL",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.primaryTextColor.withAlpha(180),
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      "${(profile.xp ?? 0) % 1000} / 1000 XP",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.primaryTextColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: ((profile.xp ?? 0) % 1000) / 1000,
                    backgroundColor: Colors.white.withAlpha(40),
                    valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primaryTextColor),
                    minHeight: 4.h,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGamificationItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        FaIcon(icon, color: iconColor, size: 20.r),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: context.appColors.primaryTextColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            fontWeight: FontWeight.w600,
            color: context.appColors.primaryTextColor.withAlpha(150),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardStat(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.appColors.glassBorder, width: 1.5.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: context.appColors.primaryColor,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.appColors.hintTextColor,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final bgColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final hintColor = context.appColors.hintTextColor;
    final iconColor = context.appColors.hintTextColor;

    return GestureDetector(
      onTap: () {
        if (_isSubscriptionValid) {
          Get.to(() => const ProviderSearchRequestPage());
        } else {
          showDialog(
            context: context,
            builder: (context) => const SubscribeDialogWidget(),
          );
        }
      },
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 1.5.r),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.magnifyingGlass, color: iconColor),
            SizedBox(width: 16.w),
            Text(
              "FIND YOUR NEXT PROJECT...",
              style: TextStyle(
                color: hintColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: context.appColors.secondaryColor.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                FontAwesomeIcons.arrowRight,
                color: context.appColors.secondaryColor,
                size: 20.r,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onViewAll,
  }) {
    final textColor = context.appColors.primaryTextColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              "VIEW ALL",
              style: TextStyle(
                color: textColor.withAlpha(180),
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
                letterSpacing: 1.0,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDirectRequestsCard(BuildContext context) {
    final cardColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;

    return GestureDetector(
      onTap: () {
        Get.to(() => const ProviderTargetedRequestsPage());
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor, width: 1.5.r),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                FontAwesomeIcons.handshake,
                color: context.appColors.primaryColor,
                size: 26.r,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DIRECT REQUESTS",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Job requests sent specifically to you",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: textColor.withAlpha(150),
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

  Widget _buildExploreCard(BuildContext context) {
    final cardColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;

    return GestureDetector(
      onTap: () {
        if (_isSubscriptionValid) {
          Get.to(() => const ProviderMoreRequestsPage());
        } else {
          showDialog(
            context: context,
            builder: (context) => const SubscribeDialogWidget(),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor, width: 1.5.r),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                FontAwesomeIcons.locationCrosshairs,
                color: context.appColors.primaryColor,
                size: 26.r,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NEARBY OPPORTUNITIES",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Discover jobs in your location",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: textColor.withAlpha(150),
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

  Widget _buildWalletCard(BuildContext context) {
    final cardColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;

    return GestureDetector(
      onTap: () {
        Get.to(() => const WalletPage());
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: borderColor, width: 1.5.r),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                FontAwesomeIcons.wallet,
                color: context.appColors.primaryColor,
                size: 26.r,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FINANCIAL WALLET",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Track earnings & payouts",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: textColor.withAlpha(150),
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
}


