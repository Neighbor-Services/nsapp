import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/widgets/portfolio_widget.dart';
import 'package:nsapp/features/profile/presentation/widgets/reviews_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:get/get.dart';
import '../../../messages/presentation/pages/chat_page.dart';
import '../../../shared/presentation/widget/loading_widget.dart';
import '../../../seeker/presentation/widgets/rating_review_form_widget.dart';
import '../../../seeker/presentation/pages/seeker_new_request_page.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  Future<Profile?>? _profileFuture;
  bool _showFab = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {
        _showFab = controller.index == 1;
      });
    });
    _loadProfile();
  }

  void _loadProfile() {
    if (PortfolioUserState.userId.isNotEmpty) {
      _profileFuture = Helpers.getSeekerProfile(PortfolioUserState.userId);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is PortfolioUserState) {
          setState(() {
            _loadProfile();
          });
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? appDeepBlueColor2
            : Theme.of(context).scaffoldBackgroundColor,
        body: FutureBuilder<Profile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingWidget());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Provider not found"));
            }

            final profile = snapshot.data!;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 380,
                    floating: false,
                    pinned: true,
                    backgroundColor: isDark ? appDeepBlueColor2 : Colors.white,
                    leading: GestureDetector(
                      onTap: () {
                        if (DashboardState.isProvider) {
                          context.read<ProviderBloc>().add(
                            ProviderBackPressedEvent(),
                          );
                        } else {
                          context.read<SeekerBloc>().add(
                            SeekerBackPressedEvent(),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withValues(alpha: 30)
                              : Colors.white.withValues(alpha: 60),
                          borderRadius: BorderRadius.circular(12),
                          border: isDark
                              ? null
                              : Border.all(color: Colors.black.withAlpha(20)),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 18,
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background Image
                          if (profile.profilePictureUrl != null &&
                              profile.profilePictureUrl!.isNotEmpty)
                            Image.network(
                              profile.profilePictureUrl!,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(color: appDeepBlueColor1),

                          // Solid Overlay for readability (replacing blur)
                          Container(
                            color: Colors.black.withAlpha(isDark ? 80 : 40),
                          ),

                          // Gradient Overlay for readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: isDark
                                    ? [
                                        Colors.transparent,
                                        const Color.fromARGB(
                                          255,
                                          14,
                                          32,
                                          59,
                                        ).withAlpha(80),
                                        const Color.fromARGB(188, 18, 33, 56),
                                      ]
                                    : [
                                        Colors.white.withAlpha(10),
                                        Colors.white.withAlpha(200),
                                        Colors.white,
                                      ],
                              ),
                            ),
                          ),

                          // Profile Content
                          Positioned(
                            bottom: 70, // Leave space for TabBar
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Avatar
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 10, 24, 49),
                                        Colors.purpleAccent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromARGB(
                                          255,
                                          10,
                                          24,
                                          49,
                                        ).withValues(alpha: 30),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey[900],
                                    backgroundImage:
                                        (profile.profilePictureUrl != null &&
                                            profile
                                                .profilePictureUrl!
                                                .isNotEmpty)
                                        ? NetworkImage(
                                            profile.profilePictureUrl!,
                                          )
                                        : null,
                                    child:
                                        (profile.profilePictureUrl == null ||
                                            profile.profilePictureUrl!.isEmpty)
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Name & Badge
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      profile.firstName ?? "User",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (profile.isIdentityVerified == true) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.verified,
                                        color: Colors.blueAccent,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Service Title
                                Text(
                                  getServiceName(
                                    profile.service ?? "",
                                  ).toUpperCase(),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white.withAlpha(100)
                                        : Colors.black.withAlpha(100),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),

                                // Payment Mode
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withAlpha(10)
                                        : Colors.black.withAlpha(5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withAlpha(15)
                                          : Colors.black.withAlpha(10),
                                    ),
                                  ),
                                  child: Text(
                                    "PAYMENT MODE: ${profile.preferredPaymentMode}",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withAlpha(200)
                                          : Colors.black87,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Rating
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RatingBarIndicator(
                                      rating:
                                          double.tryParse(
                                            profile.rating ?? "0",
                                          ) ??
                                          0.0,
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                      itemCount: 5,
                                      itemSize: 16,
                                      direction: Axis.horizontal,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${double.tryParse(profile.rating ?? "0")?.toStringAsFixed(1)} (${profile.totalReviews ?? 0} reviews)",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Action Buttons
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Chat Button
                                      _buildActionButton(
                                        icon: Icons.chat_bubble_outline_rounded,
                                        label: "Chat",
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF2196F3),
                                            Color(0xFF1976D2),
                                          ],
                                        ),
                                        onTap: () {
                                          if (profile.user != null) {
                                            context.read<MessageBloc>().add(
                                              SetMessageReceiverEvent(
                                                profile: profile,
                                              ),
                                            );
                                            context.read<MessageBloc>().add(
                                              SetSeenMessageEvent(
                                                reciever: profile.user!.id!,
                                              ),
                                            );
                                            if (DashboardState.isProvider) {
                                              context.read<ProviderBloc>().add(
                                                NavigateProviderEvent(
                                                  page: 4,
                                                  widget: const ChatPage(),
                                                ),
                                              );
                                            } else {
                                              context.read<SeekerBloc>().add(
                                                NavigateSeekerEvent(
                                                  page: 4,
                                                  widget: const ChatPage(),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 8),

                                      // Request Service Button - More prominent
                                      Expanded(
                                        flex: 2,
                                        child: _buildActionButton(
                                          icon: Icons.handshake_rounded,
                                          label: "Request Service",
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF6C63FF),
                                              Color(0xFF5A52D5),
                                            ],
                                          ),
                                          onTap: () {
                                            if (profile.user != null) {
                                              if (DashboardState.isProvider) {
                                                customAlert(
                                                  context,
                                                  AlertType.error,
                                                  "Switch to Seeker mode to request service",
                                                );
                                                return;
                                              }
                                              context.read<SeekerBloc>().add(
                                                NavigateSeekerEvent(
                                                  page: 4,
                                                  widget: SeekerNewRequestPage(
                                                    targetProviderId:
                                                        profile.user!.id,
                                                    initialServiceId:
                                                        profile.catalogServiceId,
                                                    initialServiceName: profile
                                                        .catalogServiceName,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: controller,
                        labelColor: isDark ? Colors.white : Colors.black87,
                        unselectedLabelColor: isDark
                            ? Colors.white.withValues(alpha: 50)
                            : Colors.black45,
                        indicatorColor: Colors.blueAccent,
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: "Portfolio"),
                          Tab(text: "Reviews"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: controller,
                children: [PortfolioWidget(), ReviewsWidget()],
              ),
            );
          },
        ),
        floatingActionButton:
            _showFab &&
                (PortfolioUserState.userId !=
                    SuccessGetProfileState.profile.user?.id)
            ? Container(
                margin: EdgeInsets.only(bottom: 100),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Get.dialog(
                      const RatingReviewFormWidget(),
                      barrierColor: Colors.black.withAlpha(180),
                    );
                  },
                  label: const Text(
                    "Write a Review",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(
                    Icons.rate_review_rounded,
                    color: Colors.white,
                  ),
                  backgroundColor: appOrangeColor1,
                  elevation: 4,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    Color textColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (gradient as LinearGradient).colors.first.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: (Theme.of(context).brightness == Brightness.dark)
          ? appDeepBlueColor2
          : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
