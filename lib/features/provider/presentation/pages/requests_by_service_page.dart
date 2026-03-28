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
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          ProviderBackPressedEvent(),
                        );
                      },
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
                          color: backBtnIconColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "AVAILABLE REQUESTS",
                            style: TextStyle(
                              fontSize: 10,
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
                                    Icons.search_off_rounded,
                                    size: 80,
                                    color: secondaryTextColor.withAlpha(60),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No requests found",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Try searching for a different service",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondaryTextColor.withAlpha(100),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            physics: const BouncingScrollPhysics(),
                            itemCount: requestsData.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
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
                          fontSize: 16,
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
        padding: EdgeInsets.all(16),
        borderColor: context.appColors.glassBorder,
        borderWidth: 1.5,
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
                      fontSize: 14,
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
            const SizedBox(height: 8),
            Text(
              request.description ?? "No description",
              style: TextStyle(color: secondaryTextColor, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: locationIconColor, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    request.address ?? "N/A",
                    style: TextStyle(color: locationIconColor, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (request.distance != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.near_me, color: context.appColors.secondaryColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${request.distance!.toStringAsFixed(1)} km",
                    style: TextStyle(
                      color: context.appColors.secondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            if (request.proposalsCount != null &&
                request.proposalsCount! > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    color: context.appColors.infoColor.withAlpha(200),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${request.proposalsCount} proposal${request.proposalsCount! > 1 ? 's' : ''}",
                    style: TextStyle(
                      color: context.appColors.infoColor.withAlpha(200),
                      fontSize: 12,
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withAlpha(100),
          width: 1.5,
        ),
      ),
      child: Text(
        status?.toUpperCase() ?? "OPEN",
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
