import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/about_page.dart';

class PopularProviderWidget extends StatefulWidget {
  const PopularProviderWidget({super.key});

  @override
  State<PopularProviderWidget> createState() => _PopularProviderWidgetState();
}

class _PopularProviderWidgetState extends State<PopularProviderWidget> {
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
      builder: (context, state) {
        return Container(
          height: 200,
          width: size(context).width,
          decoration: const BoxDecoration(),
          child: FutureBuilder<List<Profile>>(
            future: SuccessPopularProvidersState.providers,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Profile profile = snapshot.data![index];

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
                            NavigateSeekerEvent(
                              page: 1,
                              widget: const AboutPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(
                            right: 20,
                            bottom: 10,
                            top: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                (profile.profilePictureUrl != "" &&
                                        profile.profilePictureUrl != "picture")
                                    ? Image.network(
                                        profile.profilePictureUrl ?? "",
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, _, _) =>
                                            Image.asset(
                                              logo2Assets,
                                              fit: BoxFit.cover,
                                            ),
                                      )
                                    : Image.asset(
                                        logo2Assets,
                                        fit: BoxFit.cover,
                                      ),

                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: _buildFloatingRating(
                                    profile.rating ?? "0.0",
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: _buildFavoriteAction(profile),
                                ),

                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withAlpha(200),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                profile.firstName ?? "User",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  letterSpacing: -0.5,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (profile.isIdentityVerified ==
                                                true)
                                              const Icon(
                                                Icons.verified_rounded,
                                                color: Colors.blue,
                                                size: 16,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          getServiceName(profile.service!),
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(180),
                                            fontSize: 12,
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
                      );
                    },
                  );
                } else {
                  return const EmptyWidget(
                    message: "No popular providers available",
                    height: 180,
                  );
                }
              } else {
                return const LoadingWidget();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildFloatingRating(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E3E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.yellow, size: 14),
          const SizedBox(width: 4),
          Text(
            double.parse(rating).toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteAction(Profile profile) {
    final bool isFavorite = Helpers.isMyFavorite(profile.user!.id!);
    return GestureDetector(
      onTap: () {
        if (isFavorite) {
          String id = "";
          for (var favorite in SuccessGetMyFavoritesNoFutureState.profiles) {
            if (favorite.favoriteUser!.user!.id == profile.user!.id!) {
              id = favorite.id!;
              break;
            }
          }
          context.read<SeekerBloc>().add(RemoveFromFavoriteEvent(userId: id));
        } else {
          context.read<SeekerBloc>().add(
            AddToFavoriteEvent(userId: profile.user!.id!),
          );
        }
      },
      child: Container(
        height: 32,
        width: 32,
        decoration: const BoxDecoration(
          color: Color(0xFF2E2E3E),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          color: isFavorite ? Colors.red : Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
