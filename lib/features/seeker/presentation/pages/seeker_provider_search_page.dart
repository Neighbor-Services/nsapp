import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/notify.dart';
import '../../../../core/models/profile.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';
import '../../../messages/presentation/pages/chat_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/about_page.dart';
import '../../../shared/presentation/bloc/shared_bloc.dart';
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
        listener: (context, state) {},
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0.w,
                  vertical: 10.h,
                ),
                child: Column(
                  children: [
                    SolidTextField(
                      controller: searchController,
                      hintText: "SEARCH PROVIDERS",
                      allCapsLabel: true,
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() {
                          // Trigger rebuild for local search list
                          searchedProviders = [];
                          if (value.isNotEmpty) {
                            context.read<SeekerBloc>().add(
                              SearchEvent(isSearching: true),
                            );
                            for (var provider in providers) {
                              Profile rq = provider;
                              if (rq.firstName!.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ) ||
                                  getServiceName(rq.service!)
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  rq.address!.toLowerCase().contains(
                                    value.toLowerCase(),
                                  )) {
                                searchedProviders.add(provider);
                              }
                            }
                          } else {
                            context.read<SeekerBloc>().add(
                              SearchEvent(isSearching: false),
                            );
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: FutureBuilder<List<Profile>>(
                        future: SuccessSearchProviderState.providers,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (providers.isEmpty &&
                                snapshot.data!.isNotEmpty) {
                              providers = snapshot.data!;
                            }

                            List<Profile> displayList =
                                (SearchingState.isSearching)
                                ? searchedProviders
                                : snapshot.data!;

                            if (SearchingState.isSearching &&
                                displayList.isEmpty) {
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

                            if (displayList.isNotEmpty) {
                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                     SliverGridDelegateWithFixedCrossAxisCount(
                                       crossAxisCount: 2,
                                       crossAxisSpacing: 16.w,
                                       mainAxisSpacing: 16.h,
                                       childAspectRatio:
                                           0.75, // Adjust for card height
                                     ),
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  // Add staggered animation
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                      milliseconds: 300 + (index * 100),
                                    ),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 30 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _buildProviderCard(
                                      displayList[index],
                                      context,
                                    ),
                                  );
                                },
                              );
                            } else {
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
                          } else {
                            return const Center(child: LoadingWidget());
                          }
                        },
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

  Widget _buildProviderCard(Profile profile, BuildContext context) {
    return GestureDetector(
      onTap: () {
        PortfolioUserState.userId = profile.user!.id!;

        context.read<SeekerBloc>().add(
          SetProviderToReviewEvent(
            provider: profile,
            providerUserId: profile.user!.id!,
          ),
        );
        context.read<ProfileBloc>().add(
          AboutUserEvent(userID: profile.user!.id!),
        );
        context.read<SeekerBloc>().add(
          NavigateSeekerEvent(page: 1, widget: const AboutPage()),
        );
      },
      child: SolidContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(20),
        borderColor: context.appColors.glassBorder,
        borderWidth: 1.5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  (profile.profilePictureUrl != null &&
                      profile.profilePictureUrl!.isNotEmpty)
                  ? Image.network(
                      profile.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, _) =>
                          Image.asset(logo2Assets, fit: BoxFit.cover),
                    )
                  : Image.asset(logo2Assets, fit: BoxFit.cover),
            ),
            // Gradient Overlay
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
            // Content
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
                      fontWeight: FontWeight.w900,
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
                      getServiceName(profile.service ?? "").toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
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
                            fontWeight: FontWeight.w900,
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
            // Top Buttons (Favorite)
            Positioned(
              top: 8,
              right: 8,
              child: _buildFavoriteIcon(profile, context),
            ),
            // Rating Tag
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
                      Icons.star_rounded,
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // More Menu Overlay
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
                    Icons.more_vert,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onSelected: (val) {
                    _handleMenuSelection(val, profile, context);
                  },
                  itemBuilder: (context) {
                    final iconColor = context.appColors.secondaryTextColor;
                    final textColor = context.appColors.primaryTextColor;

                    return [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_rounded,
                              color: iconColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "DETAILS",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
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
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: iconColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "CHAT",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
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

  Widget _buildFavoriteIcon(Profile profile, BuildContext context) {
    bool isFav = Helpers.isMyFavorite(profile.user!.id!);
    return GestureDetector(
      onTap: () {
        if (isFav) {
          _removeFromFavorites(profile, context);
        } else {
          _addToFavorites(profile, context);
        }
      },
      child: SolidContainer(
        padding: EdgeInsets.all(6),
        borderRadius: BorderRadius.circular(50), // Circle
        backgroundColor: Colors.black.withAlpha(50),
        child: Icon(
          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
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
  ) {
    if (val == 1) {
      PortfolioUserState.userId = profile.user!.id!;

      context.read<SeekerBloc>().add(
        SetProviderToReviewEvent(
          provider: profile,
          providerUserId: profile.user!.id!,
        ),
      );
      context.read<ProfileBloc>().add(
        AboutUserEvent(userID: profile.user!.id!),
      );
      context.read<SeekerBloc>().add(
        NavigateSeekerEvent(page: 1, widget: const AboutPage()),
      );
    } else if (val == 2) {
      context.read<MessageBloc>().add(
        SetMessageReceiverEvent(profile: profile),
      );
      context.read<SeekerBloc>().add(
        NavigateSeekerEvent(page: 4, widget: const ChatPage()),
      );
    }
  }

  void _addToFavorites(Profile profile, BuildContext context) {
    context.read<SeekerBloc>().add(
      AddToFavoriteEvent(userId: profile.user!.id!),
    );
    _sendNotification(
      profile,
      "Favorite added",
      "added you as favorite",
      context,
    );
  }

  void _removeFromFavorites(Profile profile, BuildContext context) {
    String id = "";
    // Note: Safely accessing the state list; assuming it's popluated.
    try {
      for (var favorite in SuccessGetMyFavoritesNoFutureState.profiles) {
        if (favorite.favoriteUser!.user!.id == profile.user!.id!) {
          id = favorite.id!;
          break;
        }
      }
    } catch (e) {
      // Fallback or ignore if state is not ready
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
    String myName = SuccessGetProfileState.profile.firstName ?? "User";
    context.read<SharedBloc>().add(
      SendNotificationEvent(
        notify: Notify(
          userId: profile.id!,
          title: title,
          body: "$myName $bodySuffix",
        ),
      ),
    );
  }
}
