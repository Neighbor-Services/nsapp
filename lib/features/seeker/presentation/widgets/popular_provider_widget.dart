import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/about_page.dart';
import 'package:nsapp/core/core.dart';


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
          height: 200.h,
          width: size(context).width,
          decoration: BoxDecoration(),
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
                                // (profile.profilePictureUrl != "" &&
                                //         profile.profilePictureUrl != "picture")
                                //     ? Image.network(
                                //         profile.profilePictureUrl ?? "",
                                //         fit: BoxFit.cover,
                                //         errorBuilder: (context, _, _) =>
                                //             Image.asset(
                                //               logo2Assets,
                                //               fit: BoxFit.cover,
                                //             ),
                                //       )
                                //     : Image.asset(
                                //         logo2Assets,
                                //         fit: BoxFit.cover,
                                //       ),

                                Positioned(
                                  top: 12.h,
                                  left: 12.w,
                                  child: _buildFloatingRating(
                                    profile.rating ?? "0.0",
                                  ),
                                ),
                                Positioned(
                                  top: 12.h,
                                  right: 12.w,
                                  child: _buildFavoriteAction(profile),
                                ),

                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 100.h,
                                    decoration: BoxDecoration(
                                      color: context.appColors.cardBackground,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.r),
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
                                                style: TextStyle(
                                                  color: context.appColors.primaryTextColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp,
                                                  letterSpacing: 0.5,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (profile.isIdentityVerified ==
                                                true)
                                               Icon(
                                                FontAwesomeIcons.circleCheck,
                                                color: context.appColors.primaryColor,
                                                size: 16.r,
                                              ),
                                          ],
                                        ),
                                        SizedBox(height: 2.h),
                                        Text(
                                          getServiceName(profile.service ?? "").toUpperCase(),
                                          style: TextStyle(
                                            color: context.appColors.primaryTextColor,
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
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
                   return  EmptyWidget(
                    message: "No popular providers available",
                    height: 180.h,
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.appColors.glassBorder,
          width: 1.5.r,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.star, color: Colors.yellow, size: 14.r),
          SizedBox(width: 4.w),
          Text(
            double.parse(rating).toStringAsFixed(1),
            style: TextStyle(
              color: context.appColors.primaryTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
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
        height: 32.h,
        width: 32.w,
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? FontAwesomeIcons.heart : FontAwesomeIcons.heart,
          color: isFavorite ? context.appColors.errorColor : Colors.white,
          size: 18.r,
        ),
      ),
    );
  }
}




