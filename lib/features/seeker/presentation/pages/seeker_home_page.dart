import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_provider_search_page.dart';
import 'package:nsapp/features/seeker/presentation/widgets/popular_provider_widget.dart';
import 'package:nsapp/features/seeker/presentation/widgets/filter_drawer.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/seeker/presentation/pages/ai_search_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/providers_by_service_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_all_services_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/core/models/request_data.dart';

import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

class SeekerHomePage extends StatefulWidget {
  const SeekerHomePage({super.key});

  @override
  State<SeekerHomePage> createState() => _SeekerHomePageState();
}

class _SeekerHomePageState extends State<SeekerHomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetServicesEvent());
    context.read<SeekerBloc>().add(GetMyRequestEvent());

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
      endDrawer: const FilterDrawer(),
      body: GradientBackground(
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
                    // AI-Powered Hero Section
                    _buildHero(context, isLargeScreen),
                    const SizedBox(height: 32),

                    // Active Request Section
                    _buildActiveRequestSection(context),
                    const SizedBox(height: 32),

                    // Popular Providers Section
                    _buildSectionHeader(context, "Top Rated Professionals"),
                    const SizedBox(height: 16),
                    const SizedBox(height: 200, child: PopularProviderWidget()),
                    const SizedBox(height: 32),

                    // Available Services Section
                    _buildSectionHeader(
                      context,
                      "Explore Categories",
                      onViewAll: () {
                        context.read<SeekerBloc>().add(
                          NavigateSeekerEvent(
                            page: 1,
                            widget: const SeekerAllServicesPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildServicesGrid(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHeaderAction(IconData icon, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: 44,
  //       width: 44,
  //       decoration: BoxDecoration(
  //         color: Colors.white.withAlpha(20),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: Colors.white.withAlpha(30)),
  //       ),
  //       child: Icon(icon, color: Colors.white, size: 20),
  //     ),
  //   );
  // }

  Widget _buildHero(BuildContext context, bool isLargeScreen) {
    return SolidContainer(
      padding: const EdgeInsets.all(28),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF8E44AD), // Deep purple
          Color(0xFF3498DB), // Bright blue
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.yellow,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                "SMART SEARCH",
                style: TextStyle(
                  color: Colors.white.withAlpha(200),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Find the Best Help\nin Seconds",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeroSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildHeroSearchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        context.read<SeekerBloc>().add(
          NavigateSeekerEvent(
            page: 1,
            widget: const SeekerProviderSearchPage(),
          ),
        );
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Search services...",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ),
            const VerticalDivider(width: 20, indent: 15, endIndent: 15),
            GestureDetector(
              onTap: () {
                context.read<SeekerBloc>().add(
                  NavigateSeekerEvent(page: 1, widget: const AISearchPage()),
                );
              },
              child: const Icon(Icons.auto_awesome, color: Colors.purple),
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
            context.read<SeekerBloc>().add(
              NavigateSeekerEvent(
                page: 1,
                widget: ProvidersByServicePage(
                  serviceId: service.id ?? '',
                  serviceName: service.name ?? 'Service',
                ),
              ),
            );
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

  Widget _buildActiveRequestSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return BlocBuilder<SeekerBloc, SeekerState>(
      builder: (context, state) {
        return FutureBuilder<List<RequestData>>(
          future: SuccessGetMyRequestState.myRequests,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            // Find the most recent request that is not COMPLETED
            RequestData? activeRequest;
            try {
              activeRequest = snapshot.data!.firstWhere(
                (r) => r.request?.status != 'DONE' && r.request?.done != true,
              );
            } catch (e) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(context, "Active Project"),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    context.read<SeekerBloc>().add(
                      SeekerRequestDetailEvent(request: activeRequest!),
                    );
                    context.read<SeekerBloc>().add(
                      NavigateSeekerEvent(
                        page: 1,
                        widget: const SeekerRequestDetailsPage(),
                      ),
                    );
                  },
                  child: SolidContainer(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(40),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.pending_actions_rounded,
                            color: Colors.blue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeRequest.request?.title ?? "Project",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Status: ${activeRequest.request?.status ?? 'Processing'}",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textColor.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: textColor),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
