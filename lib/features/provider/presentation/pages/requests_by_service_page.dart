import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);
    final backBtnColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final backBtnIconColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          ProviderBackPressedEvent(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backBtnColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(40)
                                : Colors.black.withAlpha(20),
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
                            widget.serviceName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Available Requests",
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
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
                            padding: const EdgeInsets.symmetric(
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);
    final locationIconColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(120);

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
        padding: const EdgeInsets.all(16),
        // backgroundColor handled by SolidContainer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.title ?? "Untitled Request",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
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
                  const Icon(Icons.near_me, color: appOrangeColor1, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "${request.distance!.toStringAsFixed(1)} km",
                    style: const TextStyle(
                      color: appOrangeColor1,
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
                    color: Colors.blue.withAlpha(200),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${request.proposalsCount} proposal${request.proposalsCount! > 1 ? 's' : ''}",
                    style: TextStyle(
                      color: Colors.blue.withAlpha(200),
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
        color = Colors.green;
        break;
      case 'IN_PROGRESS':
        color = Colors.blue;
        break;
      case 'COMPLETED':
        color = Colors.grey;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        status?.toUpperCase() ?? "OPEN",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
