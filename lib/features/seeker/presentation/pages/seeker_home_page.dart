import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/profile/presentation/pages/about_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_provider_search_page.dart';
import 'package:nsapp/features/seeker/presentation/widgets/popular_provider_widget.dart';
import 'package:nsapp/features/seeker/presentation/widgets/filter_drawer.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import 'package:nsapp/features/shared/presentation/bloc/location/location_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/seeker/presentation/pages/ai_search_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/providers_by_service_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_all_services_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/core/core.dart';

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
    context.read<CommonBloc>().add(GetServicesEvent());
    context.read<SeekerBloc>().add(GetMyRequestEvent());
    context.read<SeekerBloc>().add(GetPopularProvidersEvent());
    context.read<SeekerBloc>().add(GetMyFavoritesEvent());

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
      endDrawer: const FilterDrawer(),
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800.w),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<CommonBloc>().add(GetServicesEvent());
                    context.read<SeekerBloc>().add(GetMyRequestEvent());
                    context.read<ProfileBloc>().add(GetProfileStreamEvent());
                    context.read<ProfileBloc>().add(GetProfileEvent());
                    context.read<SeekerBloc>().add(GetPopularProvidersEvent());
                    context.read<SeekerBloc>().add(GetMyFavoritesEvent());
                    await Future.delayed(const Duration(seconds: 1));
                  },
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 32.w : 20.w,
                      vertical: 20.h,
                    ),
                    children: [
                      // Dynamic Greeting & Location
                      _buildHeader(context),
                      SizedBox(height: 16.h),
                      
                      // Gamification Dashboard
                      BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (previous, current) => 
                          current is SuccessGetProfileState || 
                          current is SuccessGetProfileStreamState,
                        builder: (context, state) {
                          Profile? profile;
                          if (state is SuccessGetProfileState) {
                            profile = state.profile;
                          }
                          return _buildAnimatedSection(0.2.toInt(), _buildGamificationBar(context, profile));
                        },
                      ),
                      SizedBox(height: 24.h),

                      // AI-Powered Hero Section
                      _buildAnimatedSection(0, _buildHero(context, isLargeScreen)),
                      _buildAnimatedSection(0.5.toInt(), _buildLiveStatusTicker(context)),
                      SizedBox(height: 24.h),

                      // Active Request Section
                      _buildAnimatedSection(1, _buildActiveRequestSection(context)),
                      SizedBox(height: 32.h),

                      // My Favorites Section
                      _buildAnimatedSection(2, _buildFavoritesSection(context)),
                      SizedBox(height: 32.h),

                      // Popular Providers Section
                      _buildAnimatedSection(3, Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(context, "Top Rated Professionals"),
                          SizedBox(height: 16.h),
                          SizedBox(height: 200.h, child: PopularProviderWidget()),
                        ],
                      )),
                      SizedBox(height: 32.h),

                      // Available Services Section
                      _buildAnimatedSection(4, Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            context,
                            "Explore Categories",
                            onViewAll: () {
                              Get.to(() => const SeekerAllServicesPage());
                            },
                          ),
                          SizedBox(height: 16.h),
                          BlocBuilder<CommonBloc, CommonState>(
                            builder: (context, state) {
                              return _buildServicesGrid(context, state);
                            },
                          ),
                        ],
                      )),
                      SizedBox(height: 40.h),
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
      padding: EdgeInsets.all(28.r),
      backgroundColor: context.appColors.primaryColor,
      gradient: context.appColors.primaryGradient,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.wandMagicSparkles,
                color: context.appColors.primaryColor,
                size: 22.r,
              ),
              SizedBox(width: 8.w),
              Text(
                "SMART SEARCH",
                style: TextStyle(
                  color: context.appColors.primaryTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
           Text(
            "FIND THE BEST HELP IN SECONDS",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: context.appColors.primaryTextColor,
              height: 1.2,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 24.h),
          _buildHeroSearchBar(context),
        ],
      ),
    );
  }

  Widget _buildHeroSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const SeekerProviderSearchPage());
      },
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5.r,
          ),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.magnifyingGlass, color: context.appColors.hintTextColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                "SEARCH SERVICES...",
                style: TextStyle(
                  color: context.appColors.hintTextColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            VerticalDivider(width: 20.w, indent: 15, endIndent: 15),
            GestureDetector(
              onTap: () {
                Get.to(() => const AISearchPage());
              },
              child:  FaIcon(FontAwesomeIcons.wandMagicSparkles, color: context.appColors.primaryColor),
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

  Widget _buildServicesGrid(BuildContext context, CommonState state) {
    List<Service> services = [];
    if (state is SuccessGetServicesState) {
      services = state.services;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: () {
        if (state is CommonLoading && services.isEmpty) {
          return const LoadingWidget(
            key: ValueKey('loading'),
          );
        }

        final displayServices = services.take(6).toList();

        final icons = [
          FontAwesomeIcons.wrench,
          FontAwesomeIcons.broom,
          FontAwesomeIcons.plug,
          FontAwesomeIcons.wrench,
          FontAwesomeIcons.truck,
          FontAwesomeIcons.toolbox,
        ];

        final cardColor = context.appColors.cardBackground;
        final borderColor = context.appColors.glassBorder;
        final textColor = context.appColors.primaryTextColor;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 1.3,
      ),
      itemCount: displayServices.length,
      itemBuilder: (context, index) {
        final service = displayServices[index];
        final icon = icons[index % icons.length];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 500 + (index * 100)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: GestureDetector(
            onTap: () {
              Get.to(
                () => ProvidersByServicePage(
                  serviceId: service.id ?? '',
                  serviceName: service.name ?? 'Service',
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: borderColor,
                  width: 1.5.r,
                ),
              ),
              child: Stack(
                children: [
                  
                  Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: context.appColors.primaryColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(icon, color: context.appColors.primaryColor, size: 24.r),
                        ),
                        Text(
                          (service.name ?? "SERVICE").toUpperCase(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                            height: 1.2,
                            letterSpacing: 0.8,
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
          ),
        );
      },
    );
      }(),
    );
  }

  Widget _buildActiveRequestSection(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;

    return BlocBuilder<SeekerBloc, SeekerState>(
      builder: (context, state) {
        List<RequestData> requests = [];
        if (state is SuccessGetMyRequestState) {
          requests = state.myRequests;
        }

        if (requests.isEmpty) {
          return const SizedBox.shrink();
        }

        // Find the most recent request that is not COMPLETED
        RequestData? activeRequest;
        try {
          activeRequest = requests.firstWhere(
            (r) => r.request?.status != 'DONE' && r.request?.done != true,
          );
        } catch (e) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, "Active Project"),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () {
                context.read<SeekerBloc>().add(
                  SeekerRequestDetailEvent(request: activeRequest!),
                );
                Get.to(() => SeekerRequestDetailsPage(requestData: activeRequest!));
              },
              child: SolidContainer(
                padding: EdgeInsets.all(20.r),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: context.appColors.primaryColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        FontAwesomeIcons.clock,
                        color: context.appColors.primaryColor,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (activeRequest.request?.title ?? "PROJECT")
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            "STATUS: ${activeRequest.request?.status ?? 'PROCESSING'}"
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: textColor.withAlpha(150),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FaIcon(FontAwesomeIcons.chevronRight, color: textColor),
                  ],
                ),
              ),
            ),
          ],
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

  Widget _buildLiveStatusTicker(BuildContext context) {
    return BlocBuilder<SeekerBloc, SeekerState>(
      buildWhen: (previous, current) => current is SuccessPopularProvidersState,
      builder: (context, state) {
        final providersCount = context.read<SeekerBloc>().popularProviders.length;
        final liveCount = providersCount > 0 ? (providersCount * 3) + 7 : 12;

        return Padding(
          padding: EdgeInsets.only(top: 12.h),
          child: Row(
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withAlpha(100),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "LIVE: $liveCount Professionals online in your area",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.secondaryTextColor,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
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
                value: "SEEKER",
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
                        color: context.appColors.secondaryTextColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      "${(profile.xp ?? 0) % 1000} / 1000 XP",
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: LinearProgressIndicator(
                    value: ((profile.xp ?? 0) % 1000) / 1000,
                    backgroundColor: context.appColors.cardBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(context.appColors.primaryColor),
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
            color: context.appColors.secondaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFavoritesSection(BuildContext context) {
    return BlocBuilder<SeekerBloc, SeekerState>(
      buildWhen: (previous, current) =>
          current is SuccessGetMyFavoritesState ||
          current is LoadingSeekerState ||
          current is InitialSeekerState,
      builder: (context, state) {
        final favorites = context.read<SeekerBloc>().myFavorites;
        
        if (favorites.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              "My Favorites",
              onViewAll: () {
                 context.read<SeekerBloc>().add(ChangeSeekerTabEvent(tabIndex: 5));
              },
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final favorite = favorites[index];
                  final profile = favorite.favoriteUser;
                  
                  return GestureDetector(
                    onTap: () {
                      final String? providerId = profile?.user?.id;
                      if (providerId != null) {
                        Get.to(() => AboutPage(profile: profile));
                      }
                    },
                    child: Container(
                      width: 80.w,
                      margin: EdgeInsets.only(right: 16.w),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.appColors.secondaryColor.withAlpha(100),
                                width: 1.5.r,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30.r,
                              backgroundImage: (profile?.profilePictureUrl != null &&
                                      profile!.profilePictureUrl!.isNotEmpty)
                                  ? NetworkImage(profile.profilePictureUrl!)
                                  : const AssetImage(logo2Assets) as ImageProvider,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            profile?.firstName ?? "User",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.primaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}







