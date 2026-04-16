import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

import '../../../messages/presentation/bloc/message_bloc.dart';
import '../../../messages/presentation/pages/chat_page.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/pages/about_page.dart';
import 'package:nsapp/core/core.dart';

class SeekerFavoritePage extends StatefulWidget {
  const SeekerFavoritePage({super.key});

  @override
  State<SeekerFavoritePage> createState() => _SeekerFavoritePageState();
}

class _SeekerFavoritePageState extends State<SeekerFavoritePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.secondaryTextColor;
    final iconColor = context.appColors.primaryTextColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<SeekerBloc, SeekerState>(
        listener: (context, state) {
          if (state is SuccessRemoveFromFavoriteState) {
            context.read<SeekerBloc>().add(GetMyFavoritesEvent());
          }
          if (state is FailureRemoveFromFavoriteState) {
            customAlert(
              context,
              AlertType.error,
              "Failed to remove from favorites",
            );
          }
        },
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 700.w),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 32.w : 24.w,
                            vertical: 24.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.read<SeekerBloc>().add(
                                      SeekerBackPressedEvent(),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                          width: 1.5.r,
                                        ),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.chevronLeft,
                                        color: iconColor,
                                        size: 20.r,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Text(
                                    "FAVORITES",
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.only(left: 52.w),
                                child: Text(
                                  "YOUR SAVED PROFESSIONALS",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w900,
                                    color: textColor.withAlpha(150),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Favorites List
                        Expanded(
                          child: FutureBuilder<List<Favorite>>(
                            future: SuccessGetMyFavoritesState.profiles,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.isNotEmpty) {
                                  return ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(
                                      left: isLargeScreen ? 32.w : 16.w,
                                      right: isLargeScreen ? 32.w : 16.w,
                                      bottom: 32.h,
                                    ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return _buildFavoriteCard(
                                        context,
                                        snapshot.data![index],
                                        index,
                                      );
                                    },
                                  );
                                } else {
                                  return Center(
                                    child: SolidContainer(
                                      // Use SolidContainer for consistency
                                      margin: EdgeInsets.all(24.r),
                                      padding: EdgeInsets.all(20.r),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(20.r),
                                            decoration: BoxDecoration(
                                              color: context.appColors.errorColor.withAlpha(
                                                30,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              FontAwesomeIcons.heart,
                                              size: 60.r,
                                              color: context.appColors.errorColor,
                                            ),
                                          ),
                                          SizedBox(height: 24.h),
                                          Text(
                                            "No favorites yet",
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w900,
                                              color: textColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(height: 12.h),
                                          Text(
                                            "Save providers you like for quick access and priority booking.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: secondaryTextColor,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
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
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    Favorite favorite,
    int index,
  ) {
    if (favorite.favoriteUser == null) {
      return const SizedBox.shrink();
    }

    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: (){
          context.read<ProfileBloc>().add(
            AboutUserEvent(
              userID: favorite.favoriteUser!.user!.id!,
            ),
          );
          context.read<SeekerBloc>().add(
            NavigateSeekerEvent(
              page: 1,
              widget: const AboutPage(),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: SolidContainer(
            padding: EdgeInsets.all(18.r),
            borderColor: context.appColors.glassBorder,
            borderWidth: 1.5.r,
            child: Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2.5.r),
                   
                  ),
                  child: CircleAvatar(
                    radius: 36.r,
                    backgroundColor: Colors.white12,
                    backgroundImage:
                        (favorite.favoriteUser!.profilePictureUrl != null &&
                            favorite
                                .favoriteUser!
                                .profilePictureUrl!
                                .isNotEmpty &&
                            favorite.favoriteUser!.profilePictureUrl!.startsWith(
                              "http",
                            ))
                        ? NetworkImage(favorite.favoriteUser!.profilePictureUrl!)
                        : const AssetImage(logoAssets) as ImageProvider,
                  ),
                ),
                SizedBox(width: 18.w),
        
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (favorite.favoriteUser!.firstName ?? "Provider").toUpperCase(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.surfaceBackground,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          getServiceName(favorite.favoriteUser!.service ?? favorite.favoriteUser!.catalogServiceName ?? "").toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.hintTextColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     _buildActionButton(
                  icon: FontAwesomeIcons.comment,
                  color: context.appColors.primaryColor,
                  onTap: () {
                    context.read<MessageBloc>().add(
                      SetMessageReceiverEvent(
                        profile: favorite.favoriteUser!,
                      ),
                    );
                    context.read<SeekerBloc>().add(
                      NavigateSeekerEvent(page: 4, widget: const ChatPage()),
                    );
                  },
                ),
                 SizedBox(width: 8.w),
                   
                    _buildActionButton(
                      icon: FontAwesomeIcons.heart,
                      color: context.appColors.errorColor,
                      onTap: () {
                        context.read<SeekerBloc>().add(
                          RemoveFromFavoriteEvent(userId: favorite.id!),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: color.withAlpha(50),
            width: 1.5.r,
          ),
        ),
        child: Icon(icon, color: color, size: 18.r),
      ),
    );
  }
}

