import 'package:cached_network_image/cached_network_image.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

import '../../../shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/core/core.dart';

class ProviderRecentRequestWidget extends StatefulWidget {
  const ProviderRecentRequestWidget({super.key});

  @override
  State<ProviderRecentRequestWidget> createState() =>
      _ProviderRecentRequestWidgetState();
}

class _ProviderRecentRequestWidgetState
    extends State<ProviderRecentRequestWidget> {
  bool nearbyRequest = false;

  @override
  void initState() {
    context.read<ProviderBloc>().add(GetRecentRequestEvent());

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProviderBloc, ProviderState>(
      builder: (context, state) {
        List<RequestData> requests = (state is SuccessGetRecentRequestState) 
            ? state.myRequests 
            : context.read<ProviderBloc>().recentRequests;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: () {
            if (requests.isNotEmpty) {
              return ListView.builder(
                key: const ValueKey('requests_list'),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  var recent = requests[index];
                  RequestData requestData = recent;
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 600 + (index * 150)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          RequestDetailEvent(request: requestData),
                        );
                        context.read<ProviderBloc>().add(
                          ReloadProfileEvent(request: requestData.request!.id!),
                        );
                        context.push('/app/provider/requests/${requestData.request!.id}', extra: requestData);
                      },
                      child: Container(
                        width: 300.w,
                        margin: EdgeInsets.only(
                          right: 20.w,
                          bottom: 12.h,
                          top: 8.h,
                        ),
                        child: SolidContainer(
                          padding: EdgeInsets.zero,
                          borderRadius: BorderRadius.circular(28.r),
                          child: Stack(
                            children: [
                              // Background Image or Gradient
                              if (requestData.request?.imageUrl != null)
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: CachedNetworkImage(
                                      imageUrl: requestData.request!.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(color: Colors.black12),
                                      errorWidget: (context, url, error) => 
                                          const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              
                              // Main Content Overlay
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withAlpha(200),
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.all(20.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildTag(
                                          requestData.request?.service?.name ?? "SERVICE",
                                        ),
                                        if (requestData.request?.price != null)
                                          _buildPriceBadge(requestData.request!.price!),
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(
                                      (requestData.request?.title ?? "Untitled Job").toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(2.r),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white.withAlpha(100), width: 1.5.r),
                                          ),
                                          child: CircleAvatar(
                                            radius: 14.r,
                                            backgroundColor: Colors.white.withAlpha(40),
                                            backgroundImage: requestData.user?.profilePictureUrl != null 
                                                ? CachedNetworkImageProvider(requestData.user!.profilePictureUrl!) 
                                                : null,
                                            child: requestData.user?.profilePictureUrl == null 
                                                ? FaIcon(FontAwesomeIcons.user, size: 12.r, color: Colors.white)
                                                : null,
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                requestData.user?.firstName ?? "Neighbor",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  FaIcon(FontAwesomeIcons.locationDot, size: 10.r, color: Colors.white.withAlpha(180)),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    requestData.request?.distance != null
                                                        ? "${requestData.request!.distance!.toStringAsFixed(1)}km away"
                                                        : "Nearby",
                                                    style: TextStyle(
                                                      color: Colors.white.withAlpha(180),
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
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
                    ),
                  );
                },
              );
            } else if (state is LoadingProviderState) {
              return HorizontalSkeletonLoader(
                key: const ValueKey('loading'),
                height: 250.h, 
                itemWidth: 300.w,
              );
            } else {
              return EmptyWidget(
                key: const ValueKey('empty'),
                message: "No recent request at the moment",
                height: 250.h,
              );
            }
          }(),
        );
      },
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildPriceBadge(double price) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.appColors.primaryColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        "\$${price.toStringAsFixed(0)}",
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'DONE':
        color = appSuccessColor;
        break;
      case 'IN_PROGRESS':
        color = appInfoColor;
        break;
      case 'CANCELLED':
        color = appErrorColor;
        break;
      default:
        color = appWarningColor;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
