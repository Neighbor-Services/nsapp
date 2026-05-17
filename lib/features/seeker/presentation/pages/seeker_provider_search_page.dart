import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/notify.dart';
import '../../../../core/models/profile.dart';
import '../../../../core/models/favorite.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';


import '../../../shared/presentation/widget/empty_widget.dart';
import '../../../shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/core/core.dart';

class SeekerProviderSearchPage extends StatefulWidget {
  const SeekerProviderSearchPage({super.key});

  @override
  State<SeekerProviderSearchPage> createState() =>
      _SeekerProviderSearchPageState();
}

class _SeekerProviderSearchPageState extends State<SeekerProviderSearchPage> {
  List<Profile> providers = [];
  List<Profile> searchedProviders = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    context.read<SeekerBloc>().add(SearchProviderEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocConsumer<SeekerBloc, SeekerState>(
        listener: (context, state) {
          if (state is SuccessSearchProviderState) {
            // Cache providers locally for client-side search filtering
            if (state.providers.isNotEmpty) {
              setState(() => providers = state.providers);
            }
          }
          if (state is SuccessGetMyFavoritesState) {
            setState(() {}); // Refresh to update favorite icons
          }
          if (state is FailureAddToFavoriteState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add favorite: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is FailureRemoveFromFavoriteState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to remove favorite: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Extract favorites list reactively for favorite checks
          final favorites = state is SuccessGetMyFavoritesState
              ? state.profiles
              : <Favorite>[];

          // Resolve the canonical provider list from state first, fallback to cached
          final List<Profile> stateProviders = state is SuccessSearchProviderState
              ? state.providers
              : providers;

          return GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0.w,
                  vertical: 10.h,
                ),
                child: Column(
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: context.appColors.cardBackground,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: context.appColors.glassBorder,
                              ),
                            ),
                            child: Icon(
                              FontAwesomeIcons.chevronLeft,
                              color: context.appColors.primaryTextColor,
                              size: 18.r,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          "SEARCH PROVIDERS",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.primaryTextColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SolidTextField(
                      controller: searchController,
                      hintText: "SEARCH PROVIDERS",
                      allCapsLabel: true,
                      prefixIcon: FontAwesomeIcons.magnifyingGlass,
                      onChanged: (value) {
                        setState(() {
                          searchedProviders = [];
                          isSearching = value.isNotEmpty;
                          if (value.isNotEmpty) {
                            for (var provider in providers) {
                              Profile rq = provider;
                              if ((rq.firstName?.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ) ??
                                      false) ||
                                  (rq.service != null &&
                                      rq.service!
                                          .toLowerCase()
                                          .contains(value.toLowerCase())) ||
                                  (rq.address?.toLowerCase().contains(
                                        value.toLowerCase(),
                                      ) ??
                                      false)) {
                                searchedProviders.add(provider);
                              }
                            }
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<SeekerBloc>().add(SearchProviderEvent());
                          context.read<ProfileBloc>().add(GetProfileStreamEvent());
                          context.read<ProfileBloc>().add(GetProfileEvent());
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: Builder(
                          builder: (context) {
                            // Show loader only when actively fetching and nothing cached yet
                          if (state is LoadingSeekerState && stateProviders.isEmpty) {
                            return const LoadingWidget();
                          }

                          final List<Profile> displayList =
                              isSearching ? searchedProviders : stateProviders;

                          if (isSearching && displayList.isEmpty) {
                            return Center(
                              child: SolidContainer(
                                padding: EdgeInsets.all(24),
                                child: EmptyWidget(
                                  message: "No provider matches your search",
                                  height: 200,
                                ),
                              ),
                            );
                          }

                          if (displayList.isEmpty) {
                            return Center(
                              child: SolidContainer(
                                padding: EdgeInsets.all(24),
                                child: EmptyWidget(
                                  message: "No providers found",
                                  height: 200,
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(milliseconds: 300 + (index * 100)),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 30 * (1 - value)),
                                    child: Opacity(opacity: value, child: child),
                                  );
                                },
                                child: _buildProviderCard(
                                  displayList[index],
                                  context,
                                  favorites,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProviderCard(
    Profile profile,
    BuildContext context,
    List<Favorite> favorites,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<SeekerBloc>().add(
          SetProviderToReviewEvent(
            provider: profile,
            providerUserId: profile.user!.id!,
          ),
        );
      context.push('/portfolio-view', extra: profile);
      },
      child: SolidContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        borderColor: context.appColors.glassBorder,
        borderWidth: 1.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  (profile.profilePictureUrl != null &&
                      profile.profilePictureUrl!.isNotEmpty)
                  ? Image.network(
                      profile.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) =>
                          Image.asset(logo2Assets, fit: BoxFit.cover),
                    )
                  : Image.asset(logo2Assets, fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(50),
                    Colors.black.withAlpha(220),
                  ],
                  stops: const [0.3, 0.6, 1.0],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (profile.firstName ?? "Unknown").toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      (profile.service ?? "").toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        FontAwesomeIcons.locationDot,
                        size: 12,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          (profile.address ?? "No Address").toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withAlpha(200),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildFavoriteIcon(profile, context, favorites),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: SolidContainer(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                borderRadius: BorderRadius.circular(12),
                backgroundColor: Colors.black.withAlpha(100),
                borderColor: Colors.white.withAlpha(40),
                borderWidth: 1.5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      FontAwesomeIcons.star,
                      color: Color(0xFFFFD700),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      double.tryParse(
                        profile.rating ?? "0.0",
                      )?.toStringAsFixed(1) ??
                      "0.0",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 4,
              child: Theme(
                data: Theme.of(context).copyWith(
                  cardColor: context.appColors.cardBackground,
                  iconTheme: IconThemeData(
                    color: context.appColors.primaryBackground,
                  ),
                  popupMenuTheme: PopupMenuThemeData(
                    color: context.appColors.cardBackground,
                    textStyle: TextStyle(
                      color: context.appColors.primaryBackground,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: context.appColors.glassBorder,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                child: PopupMenuButton(
                  icon: const Icon(
                    FontAwesomeIcons.ellipsisVertical,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onSelected: (val) {
                    _handleMenuSelection(val, profile, context, favorites);
                  },
                  itemBuilder: (context) {
                    final iconColor = context.appColors.secondaryTextColor;
                    final textColor = context.appColors.primaryTextColor;

                    return [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.eye, color: iconColor),
                            const SizedBox(width: 10),
                            Text(
                              "DETAILS",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.comment, color: iconColor),
                            const SizedBox(width: 10),
                            Text(
                              "CHAT",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteIcon(
    Profile profile,
    BuildContext context,
    List<Favorite> favorites,
  ) {
    final bool isFav = Helpers.isMyFavorite(profile.user!.id!, favorites);
    return GestureDetector(
      onTap: () {
        if (isFav) {
          _removeFromFavorites(profile, context, favorites);
        } else {
          _addToFavorites(profile, context);
        }
      },
      child: SolidContainer(
        padding: EdgeInsets.all(6),
        borderRadius: BorderRadius.circular(50),
        backgroundColor: Colors.black.withAlpha(50),
        child: Icon(
          isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
          color: isFav ? context.appColors.errorColor : Colors.white,
          size: 18,
        ),
      ),
    );
  }

  void _handleMenuSelection(
    dynamic val,
    Profile profile,
    BuildContext context,
    List<Favorite> favorites,
  ) {
    if (val == 1) {
      context.read<SeekerBloc>().add(
        SetProviderToReviewEvent(
          provider: profile,
          providerUserId: profile.user!.id!,
        ),
      );
      context.push('/portfolio-view', extra: profile);
    } else if (val == 2) {
      context.read<MessageBloc>().add(
        SetMessageReceiverEvent(profile: profile),
      );
      context.push('/chat');
    }
  }

  void _addToFavorites(Profile profile, BuildContext context) {
    context.read<SeekerBloc>().add(
      AddToFavoriteEvent(userId: profile.user!.id!),
    );
    _sendNotification(profile, "Favorite added", "added you as favorite", context);
  }

  void _removeFromFavorites(
    Profile profile,
    BuildContext context,
    List<Favorite> favorites,
  ) {
    String id = "";
    for (var favorite in favorites) {
      if (favorite.favoriteUser?.user?.id == profile.user?.id) {
        id = favorite.id ?? "";
        break;
      }
    }

    if (id.isNotEmpty) {
      context.read<SeekerBloc>().add(RemoveFromFavoriteEvent(userId: id));
      _sendNotification(
        profile,
        "Favorite removed",
        "removed you from favorites",
        context,
      );
    }
  }

  void _sendNotification(
    Profile profile,
    String title,
    String bodySuffix,
    BuildContext context,
  ) {
    // Get current user's name from ProfileBloc reactively
    final profileState = context.read<ProfileBloc>().state;
    final String myName = profileState is SuccessGetProfileState
        ? (profileState.profile.firstName ?? "User")
        : "User";

    context.read<NotificationBloc>().add(
      SendNotificationEvent(
        notificationModel: Notify(
          userId: profile.user!.id!,
          title: title,
          body: "$myName $bodySuffix",
        ),
      ),
    );
  }
}


