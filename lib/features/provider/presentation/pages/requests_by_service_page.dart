import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/core/core.dart';

class RequestsByServicePage extends StatefulWidget {
  final String serviceId;
  final String serviceName;

  const RequestsByServicePage({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<RequestsByServicePage> createState() => _RequestsByServicePageState();
}

class _RequestsByServicePageState extends State<RequestsByServicePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);

    // Use the existing search logic with service filter
    context.read<ProviderBloc>().add(
      SearchRequestEvent(
        query: widget.serviceName,
        catalogServiceId: widget.serviceId,
      ),
    );

    // Listen for state changes
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;
    final backBtnIconColor = context.appColors.primaryTextColor;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20.r),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          ProviderBackPressedEvent(),
                        );
                      },
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
                          color: backBtnIconColor,
                          size: 20.r,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "AVAILABLE REQUESTS",
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                              color: secondaryTextColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Requests List
              Expanded(
                child: BlocBuilder<ProviderBloc, ProviderState>(
                  builder: (context, state) {
                    if (state is LoadingProviderState || _isLoading) {
                      return const Center(child: LoadingWidget());
                    }

                    if (state is SuccessSearchRequestState) {
                      return FutureBuilder<List<RequestData>>(
                        future: SuccessSearchRequestState.requests,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: LoadingWidget());
                          }

                          final requestsData = snapshot.data ?? [];

                          if (requestsData.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.magnifyingGlass,
                                    size: 80.r,
                                    color: secondaryTextColor.withAlpha(60),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    "No requests found",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    "Try searching for a different service",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: secondaryTextColor.withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: requestsData.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 16.h),
                            itemBuilder: (context, index) {
                              final requestData = requestsData[index];
                              return _buildRequestCard(context, requestData);
                            },
                          );
                        },
                      );
                    }

                    return Center(
                      child: Text(
                        "Start searching for requests",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: secondaryTextColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RequestData requestData) {
    final request = requestData.request;
    if (request == null) return const SizedBox.shrink();

    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;
    final locationIconColor = context.appColors.glassBorder;

    return GestureDetector(
      onTap: () {
        // Set request detail state before navigation
        context.read<ProviderBloc>().add(
          RequestDetailEvent(request: requestData),
        );
        context.read<ProviderBloc>().add(
          ReloadProfileEvent(request: request.id!),
        );
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(
            page: 1,
            widget: const ProviderRequestDetailPage(),
          ),
        );
      },
      child: SolidContainer(
        padding: EdgeInsets.all(16.r),
        borderColor: context.appColors.glassBorder,
        borderWidth: 1.5.r,
        // backgroundColor handled by SolidContainer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title?.toUpperCase() ?? "UNTITLED REQUEST",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(request.status),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              request.description ?? "No description",
              style: TextStyle(color: secondaryTextColor, fontSize: 13.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                FaIcon(FontAwesomeIcons.locationDot, color: locationIconColor, size: 16.r),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    request.address ?? "N/A",
                    style: TextStyle(color: locationIconColor, fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (request.distance != null) ...[
                  SizedBox(width: 12.w),
                  FaIcon(FontAwesomeIcons.locationArrow, color: context.appColors.secondaryColor, size: 16.r),
                  SizedBox(width: 4.w),
                  Text(
                    "${request.distance!.toStringAsFixed(1)} km",
                    style: TextStyle(
                      color: context.appColors.secondaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            if (request.proposalsCount != null &&
                request.proposalsCount! > 0) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.users,
                    color: context.appColors.infoColor.withAlpha(200),
                    size: 16.r,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "${request.proposalsCount} proposal${request.proposalsCount! > 1 ? 's' : ''}",
                    style: TextStyle(
                      color: context.appColors.infoColor.withAlpha(200),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    switch (status?.toUpperCase()) {
      case 'OPEN':
        color = context.appColors.successColor;
        break;
      case 'IN_PROGRESS':
        color = context.appColors.infoColor;
        break;
      case 'COMPLETED':
        color = Colors.grey;
        break;
      default:
        color = context.appColors.successColor;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withAlpha(100),
          width: 1.5.r,
        ),
      ),
      child: Text(
        status?.toUpperCase() ?? "OPEN",
        style: TextStyle(
          fontSize: 8.sp,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

