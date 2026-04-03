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
                  constraints: BoxConstraints(maxWidth: 800),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 32 : 20,
                        vertical: 20,
                      ),
                      children: [
                        const SizedBox(height: 24),

                        // Performance Dashboard (Replaced Search Hero)
                        _buildDashboard(context, isLargeScreen),
                        const SizedBox(height: 32),

                        // Search Bar (Minimalist)
                        _buildSearchBar(context),
                        const SizedBox(height: 32),

                        // Recent Requests Section
                        _buildSectionHeader(context, "Recent Requests"),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: const ProviderRecentRequestWidget(),
                        ),
                        const SizedBox(height: 32),

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
                        const SizedBox(height: 16),
                        _buildDirectRequestsCard(context),
                        const SizedBox(height: 16),
                        _buildExploreCard(context),
                        const SizedBox(height: 16),
                        if (SuccessGetProfileState
                                .profile
                                .preferredPaymentMode !=
                            'ON_SITE') ...[
                          _buildWalletCard(context),
                          const SizedBox(height: 32),
                        ],

                        const SizedBox(height: 40),
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
                      padding: EdgeInsets.all(24),
                      backgroundColor: context.appColors.primaryColor,
                      borderRadius: BorderRadius.circular(28),
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${wallet?.currency ?? 'USD'} ${wallet?.balance?.toStringAsFixed(2) ?? '0.00'}",
                                      style: TextStyle(
                                        color:
                                            context.appColors.primaryTextColor,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
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
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.appColors.cardBackground,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: context.appColors.glassBorder,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "WALLET",
                                          style: TextStyle(
                                            color:
                                                context.appColors.primaryColor,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 10,
                                          color: context.appColors.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          Row(
                            children: [
                              _buildDashboardStat(
                                "Active Bids",
                                bidsCount.toString(),
                                Icons.gavel_rounded,
                                context.appColors.warningColor,
                              ),
                              const SizedBox(width: 16),
                              _buildDashboardStat(
                                "Avg Rating",
                                profile.averageRating?.toStringAsFixed(1) ??
                                    "0.0",
                                Icons.star_rounded,
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.glassBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: context.appColors.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.appColors.hintTextColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
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
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: iconColor),
            const SizedBox(width: 16),
            Text(
              "FIND YOUR NEXT PROJECT...",
              style: TextStyle(
                color: hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.appColors.secondaryColor.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: context.appColors.secondaryColor,
                size: 20,
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
            fontSize: 18,
            fontWeight: FontWeight.w900,
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
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildServicesGrid(BuildContext context) {
  //   final services = SuccessGetServicesState.services;
  //   final displayServices = services.take(2).toList();

  //   final icons = [
  //     Icons.build_rounded,
  //     Icons.cleaning_services_rounded,
  //     Icons.electrical_services_rounded,
  //     Icons.plumbing_rounded,
  //     Icons.local_shipping_rounded,
  //     Icons.home_repair_service_rounded,
  //   ];

  //   final cardColor = context.appColors.cardBackground;
  //   final borderColor = context.appColors.glassBorder;
  //   final textColor = context.appColors.primaryTextColor;

  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 16,
  //       mainAxisSpacing: 16,
  //       childAspectRatio: 1.3,
  //     ),
  //     itemCount: displayServices.length,
  //     itemBuilder: (context, index) {
  //       final service = displayServices[index];
  //       final icon = icons[index % icons.length];

  //       return GestureDetector(
  //         onTap: () {
  //           if (ValidUserSubscriptionState.isValid) {
  //             context.read<ProviderBloc>().add(
  //               NavigateProviderEvent(
  //                 page: 1,
  //                 widget: RequestsByServicePage(
  //                   serviceId: service.id ?? '',
  //                   serviceName: service.name ?? 'Service',
  //                 ),
  //               ),
  //             );
  //           } else {
  //             showDialog(
  //               context: context,
  //               builder: (context) => const SubscribeDialogWidget(),
  //             );
  //           }
  //         },
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: cardColor,
  //             borderRadius: BorderRadius.circular(24),
  //             border: Border.all(
  //               color: borderColor,
  //               width: 1.5,
  //             ),
  //           ),
  //           child: Stack(
  //             children: [

  //               Padding(
  //                 padding: EdgeInsets.all(20),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Container(
  //                       padding: EdgeInsets.all(10),
  //                       decoration: BoxDecoration(
  //                         color: context.appColors.primaryColor.withAlpha(40),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Icon(icon, color: context.appColors.primaryColor, size: 24),
  //                     ),
  //                     Text(
  //                       (service.name ?? "SERVICE").toUpperCase(),
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.w900,
  //                         color: textColor,
  //                         height: 1.2,
  //                         letterSpacing: 0.8,
  //                       ),
  //                       maxLines: 2,
  //                       overflow: TextOverflow.ellipsis,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.handshake_rounded,
                color: context.appColors.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DIRECT REQUESTS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Job requests sent specifically to you",
                    style: TextStyle(
                      fontSize: 13,
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
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.location_searching_rounded,
                color: context.appColors.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NEARBY OPPORTUNITIES",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Discover jobs in your location",
                    style: TextStyle(
                      fontSize: 13,
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
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: context.appColors.primaryColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "FINANCIAL WALLET",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Track earnings & payouts",
                    style: TextStyle(
                      fontSize: 13,
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
