import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/core.dart';
// import 'package:nsapp/features/provider/presentation/pages/requests_by_service_page.dart';
// import 'package:nsapp/features/provider/presentation/pages/provider_all_services_page.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_more_requests_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_search_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_targeted_requests_page.dart';
import 'package:nsapp/features/provider/presentation/widgets/provider_recent_request_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(SearchRequestEvent());
    context.read<ProviderBloc>().add(GetAcceptedRequestEvent());
    context.read<SharedBloc>().add(GetServicesEvent());
    context.read<SharedBloc>().add(GetMyWalletEvent());

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
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {},
        builder: (context, state) {
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
                        SizedBox(height: 24.h),

                        // Performance Dashboard (Replaced Search Hero)
                        _buildDashboard(context, isLargeScreen),
                        SizedBox(height: 32.h),

                        // Search Bar (Minimalist)
                        _buildSearchBar(context),
                        SizedBox(height: 32.h),

                        // Recent Requests Section
                        _buildSectionHeader(context, "Recent Requests"),
                        SizedBox(height: 16.h),
                        SizedBox(
                          height: 250.h,
                          child: const ProviderRecentRequestWidget(),
                        ),
                        SizedBox(height: 32.h),

                        // // Service Categories Section
                        // _buildSectionHeader(
                        //   context,
                        //   "Your Services",
                        //   onViewAll: () {
                        //     context.read<ProviderBloc>().add(
                        //       NavigateProviderEvent(
                        //         page: 1,
                        //         widget: const ProviderAllServicesPage(),
                        //       ),
                        //     );
                        //   },
                        // ),
                        // const SizedBox(height: 16),
                        // _buildServicesGrid(context),
                        // const SizedBox(height: 32),
                        _buildSectionHeader(context, "Explore More"),
                        SizedBox(height: 16.h),
                        _buildDirectRequestsCard(context),
                        SizedBox(height: 16.h),
                        _buildExploreCard(context),
                        SizedBox(height: 16.h),
                        if (SuccessGetProfileState
                                .profile
                                .preferredPaymentMode !=
                            'ON_SITE') ...[
                          _buildWalletCard(context),
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
    );
  }

  Widget _buildDashboard(BuildContext context, bool isLargeScreen) {
    return BlocBuilder<SharedBloc, SharedState>(
      builder: (context, sharedState) {
        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<ProviderBloc, ProviderState>(
              builder: (context, providerState) {
                final wallet = SuccessGetMyWalletState.wallet;
                final profile = SuccessGetProfileState.profile;

                return FutureBuilder<List<RequestAcceptance>>(
                  future: SuccessGetAcceptRequestState.accepts,
                  builder: (context, snapshot) {
                    final bidsCount = snapshot.hasData
                        ? snapshot.data!.length
                        : 0;

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
                                        color:
                                            context.appColors.primaryTextColor,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "${wallet?.currency ?? 'USD'} ${wallet?.balance?.toStringAsFixed(2) ?? '0.00'}",
                                      style: TextStyle(
                                        color:
                                            context.appColors.primaryTextColor,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.read<ProviderBloc>().add(
                                      NavigateProviderEvent(
                                        page: 1,
                                        widget: const WalletPage(),
                                      ),
                                    );
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
                                            color:
                                                context.appColors.primaryColor,
                                            fontWeight: FontWeight.bold,
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
                                profile.averageRating?.toStringAsFixed(1) ??
                                    "0.0",
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
      },
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.appColors.hintTextColor,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
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
        if (ValidUserSubscriptionState.isValid) {
          context.read<ProviderBloc>().add(
            NavigateProviderEvent(
              page: 1,
              widget: const ProviderSearchRequestPage(),
            ),
          );
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
                fontWeight: FontWeight.bold,
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
            fontWeight: FontWeight.bold,
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
                fontWeight: FontWeight.bold,
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
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(
            page: 1,
            widget: const ProviderTargetedRequestsPage(),
          ),
        );
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
                      fontWeight: FontWeight.bold,
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
        if (ValidUserSubscriptionState.isValid) {
          context.read<ProviderBloc>().add(
            NavigateProviderEvent(
              page: 1,
              widget: const ProviderMoreRequestsPage(),
            ),
          );
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
                      fontWeight: FontWeight.bold,
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
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(page: 1, widget: const WalletPage()),
        );
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
                      fontWeight: FontWeight.bold,
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



