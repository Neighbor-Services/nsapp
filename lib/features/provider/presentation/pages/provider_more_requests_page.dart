import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/core/core.dart';

class ProviderMoreRequestsPage extends StatefulWidget {
  const ProviderMoreRequestsPage({super.key});

  @override
  State<ProviderMoreRequestsPage> createState() =>
      _ProviderMoreRequestsPageState();
}

class _ProviderMoreRequestsPageState extends State<ProviderMoreRequestsPage>
    with TickerProviderStateMixin {
  late ScrollController scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  RequestData? requestData;
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(
      GetRequestsEvent(requestData: requestData),
    );
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);

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
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        !hasReachedMax) {
      setState(() {
        isLoadingMore = true;
        currentPage++;
      });
      context.read<ProviderBloc>().add(GetRequestsEvent(page: currentPage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
     
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is SuccessGetRequestsState ||
              state is FailureGetRequestsState) {
            setState(() {
              isLoadingMore = false;
            });
            if (state is SuccessGetRequestsState) {
              SuccessGetRequestsState.requests?.then((value) {
                if (value.length < (currentPage * 10)) {
                  setState(() {
                    hasReachedMax = true;
                  });
                }
              });
            }
          }
        },
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.0.r),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.read<ProviderBloc>().add(
                            ProviderBackPressedEvent(),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: context.appColors.cardBackground,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: context.appColors.glassBorder,
                                width: 1.5.r,
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
                          "BROWSE REQUESTS",
                          style: TextStyle(
                            color: context.appColors.primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 700.w),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Requests List
                                Expanded(
                                  child: _buildRequestsList(context, isLargeScreen),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, bool isLargeScreen) {
    return FutureBuilder<List<RequestData>>(
      future: SuccessGetRequestsState.requests,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: SolidContainer(
                padding: EdgeInsets.all(40.r),
                borderColor: context.appColors.glassBorder,
                borderWidth: 1.5.r,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FontAwesomeIcons.briefcase,
                      size: 60.r,
                      color: context.appColors.glassBorder,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "No requests available",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.glassBorder,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Check back later for new projects",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.appColors.glassBorder,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          requestData = snapshot.data!.last;
          return ListView.builder(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: isLargeScreen ? 32.w : 16.w,
              vertical: 16.h,
            ),
            itemCount: snapshot.data!.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < snapshot.data!.length) {
                return _buildRequestCard(context, snapshot.data![index], index);
              } else {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Center(child: LoadingWidget()),
                );
              }
            },
          );
        } else {
          return const Center(child: LoadingWidget());
        }
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestData data, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          context.read<ProviderBloc>().add(RequestDetailEvent(request: data));
          context.read<ProviderBloc>().add(
            ReloadProfileEvent(request: data.request?.id ?? ""),
          );
          context.read<ProviderBloc>().add(
            NavigateProviderEvent(
              page: 1,
              widget: const ProviderRequestDetailPage(),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: SolidContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(20.r),
            borderColor: context.appColors.glassBorder,
            borderWidth: 1.5.r,
            child: Row(
              children: [
                // Image
                SizedBox(
                  width: 100.w,
                  height: 125.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child:
                            (data.user?.profilePictureUrl != null &&
                                data.user!.profilePictureUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: data.user!.profilePictureUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.white.withAlpha(10),
                                  child: const Center(child: LoadingWidget()),
                                ),
                                errorWidget: (context, url, error) =>
                                    Image.asset(logoAssets, fit: BoxFit.cover),
                              )
                            : Image.asset(logoAssets, fit: BoxFit.cover),
                      ),
                      // Overlay on image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            bottomLeft: Radius.circular(20.r),
                          ),
                          
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: size(context).width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  (data.user?.firstName ?? "User").toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: context.appColors.primaryTextColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: context.appColors.primaryColor.withAlpha(50),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: context.appColors.primaryColor,
                              width: 1.5.r,
                            ),
                          ),
                          child: Text(
                            data.request?.service?.name ?? "Service",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: context.appColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          data.request?.title ?? "",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.appColors.secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.calendar,
                              size: 12.r,
                              color: context.appColors.secondaryTextColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              DateFormat("MMM dd, yyyy").format(
                                data.request?.createdAt ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: context.appColors.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Arrow
                Padding(
                  padding: EdgeInsets.all(8.0.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                     
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Icon(
                          FontAwesomeIcons.chevronRight,
                          color: context.appColors.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildStatusBadge(String status) {
  //   Color color;
  //   switch (status.toUpperCase()) {
  //     case 'DONE':
  //       color = Color(0xFF4CAF50); // Green
  //       break;
  //     case 'IN_PROGRESS':
  //       color = Color(0xFF2196F3); // Blue
  //       break;
  //     case 'CANCELLED':
  //       color = Color(0xFFF44336); // Red
  //       break;
  //     default:
  //       color = Color(0xFFFF9800); // Orange
  //   }

  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: color.withAlpha(25),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: color.withAlpha(100), width: 1.5),
  //     ),
  //     child: Text(
  //       status.toUpperCase(),
  //       style: TextStyle(
  //         fontSize: 8,
  //         fontWeight: FontWeight.bold,
  //         color: color,
  //         letterSpacing: 0.5,
  //       ),
  //     ),
  //   );
  // }
}




