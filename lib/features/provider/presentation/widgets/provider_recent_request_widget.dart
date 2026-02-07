import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import '../../../shared/presentation/widget/empty_widget.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withOpacity(0.7)
        : const Color(0xFF1E1E2E).withOpacity(0.7);
    final cardColor = isDark ? const Color(0xFF2D2D44) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.1);
    final decorativeCircleColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.05);
    final tagBgColor = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.black.withOpacity(0.05);

    return BlocBuilder<ProviderBloc, ProviderState>(
      builder: (context, state) {
        return FutureBuilder<List<RequestData>>(
          future: SuccessGetRecentRequestState.myRequests,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var recent = snapshot.data![index];
                    RequestData requestData = recent;
                    return GestureDetector(
                      onTap: () {
                        context.read<ProviderBloc>().add(
                          RequestDetailEvent(request: requestData),
                        );
                        context.read<ProviderBloc>().add(
                          ReloadProfileEvent(request: requestData.request!.id!),
                        );
                        context.read<ProviderBloc>().add(
                          NavigateProviderEvent(
                            page: 1,
                            widget: ProviderRequestDetailPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 260,
                        margin: const EdgeInsets.only(
                          right: 20,
                          bottom: 10,
                          top: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: cardColor),
                              Positioned(
                                top: -20,
                                right: -20,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: decorativeCircleColor,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildTag(
                                          requestData.request?.service?.name ??
                                              "Service",
                                          tagBgColor,
                                          textColor,
                                        ),
                                        _buildStatusBadge(
                                          requestData.request?.status ?? "OPEN",
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isDark
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.05),
                                          child: Icon(
                                            Icons.person,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black54,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                requestData.user?.firstName ??
                                                    "User",
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on_rounded,
                                                    size: 12,
                                                    color: secondaryTextColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      requestData
                                                                  .request
                                                                  ?.distance !=
                                                              null
                                                          ? "${requestData.request!.distance!.toStringAsFixed(1)}km away"
                                                          : "Distance N/A",
                                                      style: TextStyle(
                                                        color:
                                                            secondaryTextColor,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                    );
                  },
                );
              } else {
                return const EmptyWidget(
                  message: "No recent request at the moment",
                  height: 250,
                );
              }
            } else if (snapshot.hasError) {
              return const SizedBox();
            } else {
              return const LoadingWidget();
            }
          },
        );
      },
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'DONE':
        color = const Color.fromARGB(255, 20, 117, 72);
        break;
      case 'IN_PROGRESS':
        color = const Color.fromARGB(255, 10, 83, 143);
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = const Color.fromARGB(255, 129, 81, 4);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
