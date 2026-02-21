import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_more_requests_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_search_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_targeted_requests_page.dart';
import 'package:nsapp/features/provider/presentation/widgets/provider_recent_request_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/subscribe_dialog_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/wallet/presentation/pages/wallet_page.dart';
import 'package:nsapp/features/provider/presentation/pages/requests_by_service_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_all_services_page.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import '../bloc/provider_bloc.dart';

import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

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
                  constraints: const BoxConstraints(maxWidth: 800),
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

                        // Service Categories Section
                        _buildSectionHeader(
                          context,
                          "Your Services",
                          onViewAll: () {
                            context.read<ProviderBloc>().add(
                              NavigateProviderEvent(
                                page: 1,
                                widget: const ProviderAllServicesPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildServicesGrid(context),
                        const SizedBox(height: 32),

                        _buildSectionHeader(context, "Explore More"),
                        const SizedBox(height: 16),
                        _buildDirectRequestsCard(context),
                        const SizedBox(height: 16),
                        _buildExploreCard(context),
                        const SizedBox(height: 16),
                        if (SuccessGetProfileState.profile.preferredPaymentMode !=
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
                      padding: const EdgeInsets.all(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
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
                                      "Total Balance",
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${wallet?.currency ?? 'USD'} ${wallet?.balance?.toStringAsFixed(2) ?? '0.00'}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(60),
                                      ),
                                    ),
                                    child: const Row(
                                      children: [
                                        Text(
                                          "Wallet",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 10,
                                          color: Colors.white,
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
                                Colors.orange,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(30)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(40),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 11,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.white.withAlpha(20) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(10);
    final hintColor = isDark ? Colors.white.withAlpha(150) : Colors.grey[400];
    final iconColor = isDark ? Colors.white.withAlpha(180) : Colors.grey[600];

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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: iconColor),
            const SizedBox(width: 16),
            Text(
              "Find your next project...",
              style: TextStyle(color: hintColor, fontSize: 16),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appOrangeColor1.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: appOrangeColor1,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              "View All",
              style: TextStyle(
                color: textColor.withAlpha(180),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = SuccessGetServicesState.services;
    final displayServices = services.take(2).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final icons = [
      Icons.build_rounded,
      Icons.cleaning_services_rounded,
      Icons.electrical_services_rounded,
      Icons.plumbing_rounded,
      Icons.local_shipping_rounded,
      Icons.home_repair_service_rounded,
    ];

    final cardColor = isDark ? Colors.white.withAlpha(15) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.black.withAlpha(10);
    final shadowColor = isDark
        ? Colors.transparent
        : Colors.black.withAlpha(10);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final iconBgColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.blue.withAlpha(10);
    final iconColor = isDark ? Colors.white : Colors.blue;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: displayServices.length,
      itemBuilder: (context, index) {
        final service = displayServices[index];
        final icon = icons[index % icons.length];

        return GestureDetector(
          onTap: () {
            if (ValidUserSubscriptionState.isValid) {
              context.read<ProviderBloc>().add(
                NavigateProviderEvent(
                  page: 1,
                  widget: RequestsByServicePage(
                    serviceId: service.id ?? '',
                    serviceName: service.name ?? 'Service',
                  ),
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
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  bottom: -15,
                  child: Icon(
                    icon,
                    size: 90,
                    color: isDark
                        ? Colors.white.withAlpha(10)
                        : Colors.black.withAlpha(5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 24),
                      ),
                      Text(
                        service.name ?? "Service",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDirectRequestsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.white.withAlpha(15) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.black.withAlpha(10);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final shadowColor = isDark
        ? Colors.transparent
        : Colors.black.withAlpha(10);

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.handshake_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Direct Requests",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.white.withAlpha(15) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.black.withAlpha(10);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final shadowColor = isDark
        ? Colors.transparent
        : Colors.black.withAlpha(10);

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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [appBlueCardColor, Color(0xFF4299E1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.location_searching_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nearby Opportunities",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? Colors.white.withAlpha(15) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.black.withAlpha(10);
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final shadowColor = isDark
        ? Colors.transparent
        : Colors.black.withAlpha(10);

    return GestureDetector(
      onTap: () {
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(page: 1, widget: const WalletPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Color(0xFFFFA500)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Financial Wallet",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
