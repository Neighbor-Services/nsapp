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
                  constraints: BoxConstraints(maxWidth: 700),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 32 : 24,
                            vertical: 24,
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
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: iconColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "FAVORITES",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: EdgeInsets.only(left: 52),
                                child: Text(
                                  "YOUR SAVED PROFESSIONALS",
                                  style: TextStyle(
                                    fontSize: 12,
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
                                      left: isLargeScreen ? 32 : 16,
                                      right: isLargeScreen ? 32 : 16,
                                      bottom: 32,
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
                                      margin: EdgeInsets.all(24),
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: context.appColors.errorColor.withAlpha(
                                                30,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.favorite_rounded,
                                              size: 60,
                                              color: context.appColors.errorColor,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            "No favorites yet",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: textColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Save providers you like for quick access and priority booking.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
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
          margin: EdgeInsets.only(bottom: 16),
          child: SolidContainer(
            padding: EdgeInsets.all(18),
            borderColor: context.appColors.glassBorder,
            borderWidth: 1.5,
            child: Row(
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2.5),
                   
                  ),
                  child: CircleAvatar(
                    radius: 36,
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
                const SizedBox(width: 18),
        
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (favorite.favoriteUser!.firstName ?? "Provider").toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.surfaceBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          getServiceName(favorite.favoriteUser!.service!).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
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
                  icon: Icons.chat_bubble_rounded,
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
                 const SizedBox(width: 8),
                   
                    _buildActionButton(
                      icon: Icons.favorite_rounded,
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
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withAlpha(50),
            width: 1.5,
          ),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
