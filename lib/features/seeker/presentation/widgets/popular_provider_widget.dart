import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';

import 'package:nsapp/core/core.dart';


class PopularProviderWidget extends StatefulWidget {
  const PopularProviderWidget({super.key});

  @override
  State<PopularProviderWidget> createState() => _PopularProviderWidgetState();
}

class _PopularProviderWidgetState extends State<PopularProviderWidget> {
  List<Favorite> _favorites = [];

  @override
  void initState() {
    context.read<SeekerBloc>().add(GetPopularProvidersEvent());
    context.read<SeekerBloc>().add(GetMyFavoritesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SeekerBloc, SeekerState>(
      listener: (context, state) {
        if (state is SuccessGetMyFavoritesState) {
          setState(() => _favorites = state.profiles);
        }
        if (state is SuccessAddToFavoriteState) {
          context.read<SeekerBloc>().add(GetMyFavoritesEvent());
        }
        if (state is SuccessRemoveFromFavoriteState) {
          context.read<SeekerBloc>().add(GetMyFavoritesEvent());
        }
        if (state is FailureRemoveFromFavoriteState) {
          context.read<SeekerBloc>().add(GetMyFavoritesEvent());
        }
      },
      buildWhen: (previous, current) =>
          current is SuccessPopularProvidersState ||
          current is FailurePopularProviderState ||
          current is SuccessGetMyFavoritesState ||
          current is PopularProvidersLoadingState ||
          current is LoadingSeekerState ||
          current is InitialSeekerState,
      builder: (context, state) {
        // Resolve canonical providers list from bloc state or cache
        final List<Profile> providers = context.read<SeekerBloc>().popularProviders;
        final bool isLoading = state is PopularProvidersLoadingState;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Container(
            key: ValueKey(state.runtimeType),
            height: 200.h,
            width: size(context).width,
            decoration: const BoxDecoration(),
            child: () {
                if (isLoading && providers.isEmpty) {
                   return const HorizontalSkeletonLoader(height: 200, itemWidth: 200);
                }

                if (state is SuccessPopularProvidersState) {
                  if (state.providers.isNotEmpty) {
                    return _buildProviderList(state.providers);
                  } else {
                    return EmptyWidget(
                      message: "No popular providers available",
                      height: 180.h,
                    );
                  }
                } else if (state is FailurePopularProviderState) {
                  return EmptyWidget(
                    message: "Failed to load providers: ${state.message}",
                    height: 180.h,
                  );
                } else {
                  // Fallback to existing data if available
                  if (providers.isNotEmpty) {
                    return _buildProviderList(providers);
                  }
                  
                  // Show skeleton as ultimate fallback if still loading or initial
                  if (state is InitialSeekerState || state is LoadingSeekerState || isLoading) {
                    return const HorizontalSkeletonLoader(height: 200, itemWidth: 200);
                  }

                  return EmptyWidget(
                    message: "No popular providers found",
                    height: 180.h,
                  );
                }
              }()
          ),
        );
      },
    );
  }

  Widget _buildProviderList(List<Profile> providers) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemCount: providers.length,
      itemBuilder: (context, index) {
        Profile profile = providers[index];

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 150)),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(30 * (1 - value), 0),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: GestureDetector(
            onTap: () {
              context.read<SeekerBloc>().add(
                    SetProviderToReviewEvent(
                      provider: profile,
                      providerUserId: profile.user!.id!,
                    ),
                  );
              context.push('/portfolio-view', extra: profile);
            },
            child: Container(
              width: 200.w,
              margin: EdgeInsets.only(
                right: 20.w,
                bottom: 10.h,
                top: 4.h,
              ),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: context.appColors.glassBorder,
                  width: 1.5.r,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    (profile.profilePictureUrl != null && profile.profilePictureUrl!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: profile.profilePictureUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const HorizontalSkeletonLoader(height: 200, itemWidth: 200),
                            errorWidget: (context, url, error) => Image.asset(logo2Assets, fit: BoxFit.contain),
                          )
                        : Image.asset(
                            logo2Assets,
                            fit: BoxFit.contain,
                            color: context.appColors.primaryColor.withAlpha(20),
                          ),
                    
                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(50),
                              Colors.black.withAlpha(200),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Top Action Buttons
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: _buildFloatingRating(profile.rating ?? "0.0"),
                    ),
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: _buildFavoriteAction(profile, _favorites),
                    ),

                    // Subscription Tier Badge
                    if (profile.subscriptionTier != null && profile.subscriptionTier != 'NONE')
                      Positioned(
                        top: 45.h,
                        left: 12.w,
                        child: _buildTierBadge(profile.subscriptionTier!),
                      ),

                    // Bottom Content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                // Pulsing Online Indicator
                                if ((profile.totalReviews ?? 0) > 2)
                                  Container(
                                    margin: EdgeInsets.only(right: 6.w),
                                    width: 8.r,
                                    height: 8.r,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent.withAlpha(100),
                                          blurRadius: 4.r,
                                          spreadRadius: 2.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    (profile.firstName ?? "User").toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (profile.isIdentityVerified == true)
                                  Icon(
                                    FontAwesomeIcons.circleCheck,
                                    color: Colors.blueAccent,
                                    size: 16.r,
                                  ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              getServiceName(profile.service ?? "").toUpperCase(),
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingRating(String rating) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.white.withAlpha(30),
          width: 1.r,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.solidStar, color: Colors.orangeAccent, size: 12.r),
          SizedBox(width: 4.w),
          Text(
            double.tryParse(rating)?.toStringAsFixed(1) ?? "0.0",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(String tier) {
    Color tierColor;
    IconData icon;
    
    switch (tier.toUpperCase()) {
      case 'PLATINUM':
        tierColor = const Color(0xFFE5E4E2);
        icon = FontAwesomeIcons.crown;
        break;
      case 'GOLD':
        tierColor = const Color(0xFFFFD700);
        icon = FontAwesomeIcons.medal;
        break;
      case 'SILVER':
        tierColor = const Color(0xFFC0C0C0);
        icon = FontAwesomeIcons.award;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: tierColor.withAlpha(200),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: tierColor.withAlpha(50),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, color: Colors.black87, size: 10.r),
          SizedBox(width: 4.w),
          Text(
            tier.toUpperCase(),
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 9.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteAction(Profile profile, List<Favorite> favorites) {
    final String? userId = profile.user?.id;
    if (userId == null) return const SizedBox.shrink();

    final bool isFavorite = Helpers.isMyFavorite(userId, favorites);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isFavorite) {
          String id = "";
          for (var favorite in favorites) {
            if (favorite.favoriteUser?.user?.id == userId) {
              id = favorite.id ?? "";
              break;
            }
          }
          if (id.isNotEmpty) {
            context.read<SeekerBloc>().add(RemoveFromFavoriteEvent(userId: id));
          }
        } else {
          context.read<SeekerBloc>().add(
            AddToFavoriteEvent(userId: userId),
          );
        }
      },
      child: Container(
        height: 32.h,
        width: 32.w,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(100),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
          color: isFavorite ? Colors.redAccent : Colors.white,
          size: 16.r,
        ),
      ),
    );
  }
}







