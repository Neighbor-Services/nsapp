import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:nsapp/core/core.dart';
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
import '../../../shared/presentation/widget/solid_container_widget.dart';
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
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is PortfolioUserState) {
          setState(() {
            _loadProfile();
          });
        }
      },
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

            return NestedScrollView(
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
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.appColors.glassBorder,
                                ),
                              ),
                              child: Icon(
                                FontAwesomeIcons.chevronLeft,
                                color: context.appColors.primaryTextColor,
                                size: 16.r,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          SolidContainer(
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
                                  child: Icon(
                                    FontAwesomeIcons.images,
                                    size: 60.r,
                                    color: context.appColors.primaryColor,
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
                                              ? NetworkImage(
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
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        getServiceName(profile.service ?? "")
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: context
                                              .appColors.secondaryTextColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        "Payment Mode : On Site",
                                        style: TextStyle(
                                          color: context.appColors.successColor,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
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
                                                const Icon(
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
                                      final chatPage = const ChatPage();
                                      if (DashboardState.isProvider) {
                                        context.read<ProviderBloc>().add(
                                          NavigateProviderEvent(
                                            page: 4,
                                            widget: chatPage,
                                          ),
                                        );
                                      } else {
                                        context.read<SeekerBloc>().add(
                                          NavigateSeekerEvent(
                                            page: 4,
                                            widget: chatPage,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              (!DashboardState.isProvider) ? Expanded(
                                child: _buildActionBtn(
                                  label: "REQUEST SERVICE",
                                  icon: FontAwesomeIcons.fileLines,
                                  color: Colors.transparent,
                                  isBorder: true,
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
                                            targetProviderId: profile.user!.id,
                                            initialServiceId:
                                                profile.catalogServiceId,
                                            initialServiceName:
                                                profile.catalogServiceName,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ): SizedBox.shrink(),
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
                          fontWeight: FontWeight.w900,
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
                margin: EdgeInsets.only(bottom: 100.h),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    Get.dialog(
                      const RatingReviewFormWidget(),
                      barrierColor: Colors.black.withAlpha(180),
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
                  icon: Icon(
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
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
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
            Icon(
              icon,
              color: isBorder ? context.appColors.primaryColor : Colors.white,
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isBorder ? context.appColors.primaryColor : Colors.white,
                fontWeight: FontWeight.w900,
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


