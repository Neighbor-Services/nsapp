import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/widgets/portfolio_widget.dart';
import 'package:nsapp/features/profile/presentation/widgets/reviews_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/widget/loading_widget.dart';
import '../../../shared/presentation/widget/solid_container_widget.dart';
import '../../../seeker/presentation/widgets/rating_review_form_widget.dart';

class AboutPage extends StatefulWidget {
  final Profile? profile;
  final String? userId;
  const AboutPage({super.key, this.profile, this.userId});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  Future<Profile?>? _profileFuture;
  bool _showFab = false;
  String _viewingUserId = "";

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller.addListener(() {
      setState(() {
        _showFab = controller.index == 1;
      });
    });
    
    if (widget.profile != null) {
      _viewingUserId = widget.profile!.user?.id ?? "";
      _profileFuture = Future.value(widget.profile);
    } else if (widget.userId != null) {
      _viewingUserId = widget.userId!;
      _loadProfile();
    } else {
      // Fallback
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is PortfolioUserState) {
        _viewingUserId = profileState.userId;
      }
      _loadProfile();
    }
  }

  void _loadProfile() {
    if (_viewingUserId.isNotEmpty) {
      setState(() {
        _profileFuture = Helpers.getSeekerProfile(_viewingUserId);
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settingsState) {
          final isProvider = settingsState.isProvider;
          final profileState = context.read<ProfileBloc>().state;
          final myProfile = profileState is SuccessGetProfileState ? profileState.profile : null;

          return SafeArea(
            child: Scaffold(
              backgroundColor: context.appColors.surfaceBackground,
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
            
                  return RefreshIndicator(
                    onRefresh: () async {
                      _loadProfile();
                      context.read<ProfileBloc>().add(GetProfileStreamEvent());
                      context.read<ProfileBloc>().add(GetProfileEvent());
                    },
                    child: NestedScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                       
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isProvider) {
                                      context.pop();
                                    } else {
                                      context.pop();
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.appColors.glassBorder,
                                      ),
                                    ),
                                    child: FaIcon(
                                      FontAwesomeIcons.chevronLeft,
                                      color: context.appColors.primaryTextColor,
                                      size: 16.r,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 40 * (1 - value)),
                                      child: Opacity(opacity: value, child: child),
                                    );
                                  },
                                  child: SolidContainer(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(20.r),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 180.h,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: context.appColors.primaryColor
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.images,
                                            size: 60.r,
                                            color: context.appColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                      Transform.translate(
                                        offset: Offset(0, -40.h),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(3.r),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    context.appColors.primaryColor,
                                                    Colors.purpleAccent,
                                                  ],
                                                ),
                                              ),
                                              child: CircleAvatar(
                                                radius: 40.r,
                                                backgroundImage: (profile
                                                                .profilePictureUrl !=
                                                            null &&
                                                        profile.profilePictureUrl!
                                                            .isNotEmpty)
                                                    ? CachedNetworkImageProvider(
                                                      profile.profilePictureUrl!,
                                                    )
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              (profile.firstName ?? "User")
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: context
                                                    .appColors.primaryTextColor,
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              getServiceName(profile.service ?? "")
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                color: context
                                                    .appColors.secondaryTextColor,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Text(
                                              "Payment Mode : On Site",
                                              style: TextStyle(
                                                color: context.appColors.successColor,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: 8.h),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                RatingBarIndicator(
                                                  rating: double.tryParse(
                                                        profile.rating ?? "0",
                                                      ) ??
                                                      0.0,
                                                  itemBuilder: (context, index) =>
                                                      const FaIcon(
                                                        FontAwesomeIcons.star,
                                                        color: Colors.amber,
                                                      ),
                                                  itemCount: 5,
                                                  itemSize: 14.r,
                                                ),
                                                SizedBox(width: 8.w),
                                                Text(
                                                  "${profile.rating ?? "0.0"} (${profile.totalReviews ?? 0} reviews)",
                                                  style: TextStyle(
                                                    color: context
                                                        .appColors.secondaryTextColor,
                                                    fontSize: 12.sp,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                SizedBox(height: 12.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionBtn(
                                        label: "CHAT",
                                        icon: FontAwesomeIcons.comment,
                                        color: context.appColors.primaryColor,
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
                                            context.push('/chat');
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    (!isProvider) ? Expanded(
                                      child: _buildActionBtn(
                                        label: "REQUEST SERVICE",
                                        icon: FontAwesomeIcons.fileLines,
                                        color: Colors.transparent,
                                        isBorder: true,
                                        onTap: () {
                                          if (profile.user != null) {
                                            if (isProvider) {
                                              customAlert(
                                                context,
                                                AlertType.error,
                                                "Switch to Seeker mode to request service",
                                              );
                                              return;
                                            }
                                            context.push('/new-request', extra: {
                                              'targetProviderId': profile.user!.id,
                                              'initialServiceId': profile.catalogServiceId,
                                              'initialServiceName': profile.catalogServiceName,
                                            });
                                          }
                                        },
                                      ),
                                    ): const SizedBox.shrink(),
                                  ],
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              controller: controller,
                              isScrollable: true,
                              tabAlignment: TabAlignment.start,
                              labelColor: context.appColors.primaryTextColor,
                              unselectedLabelColor:
                                  context.appColors.secondaryTextColor,
                              indicatorColor: context.appColors.primaryColor,
                              indicatorWeight: 4.r,
                              indicatorSize: TabBarIndicatorSize.label,
                              dividerColor: Colors.transparent,
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                                letterSpacing: 0.5,
                              ),
                              tabs: const [
                                Tab(text: "PORTFOLIO"),
                                Tab(text: "REVIEWS"),
                              ],
                            ),
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      controller: controller,
                      children: [
                        PortfolioWidget(userId: _viewingUserId),
                        ReviewsWidget(userId: _viewingUserId)
                      ],
                    ),
                  ),
                  );
                },
              ),
              floatingActionButton:
                  _showFab &&
                      (_viewingUserId != myProfile?.user?.id)
                  ? Container(
                      margin: EdgeInsets.only(bottom: 100.h),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierColor: Colors.black.withAlpha(180),
                            builder: (context) => RatingReviewFormWidget(profile: widget.profile),
                          );
                        },
                        label: Text(
                          "WRITE A REVIEW",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: context.appColors.primaryColor,
                            letterSpacing: 1.0,
                          ),
                        ),
                        icon: FaIcon(
                          FontAwesomeIcons.penToSquare,
                          color: context.appColors.primaryColor,
                        ),
                        backgroundColor: context.appColors.primaryColor.withAlpha(40),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: context.appColors.glassBorder,
                            width: 1.5,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      );
  }

  Widget _buildActionBtn({
    required String label,
    required FaIconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isBorder = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15.r),
          border: isBorder
              ? Border.all(color: context.appColors.primaryColor)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              color: isBorder ? context.appColors.primaryColor : Colors.white,
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isBorder ? context.appColors.primaryColor : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 9.sp,
                letterSpacing: 1.0,
              ),
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
      color: context.appColors.appBarBackground,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}


