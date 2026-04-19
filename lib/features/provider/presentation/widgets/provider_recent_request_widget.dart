import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

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
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;
    final cardColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final tagBgColor = context.appColors.glassBorder;

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
                        margin: EdgeInsets.only(
                          right: 20,
                          bottom: 10,
                          top: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: cardColor),
                              // Removed decorative circle for solid aesthetic
                              const SizedBox.shrink(),
                              Padding(
                                padding: EdgeInsets.all(20),
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
                                          backgroundColor: context.appColors.glassBorder,
                                          child: Icon(
                                            FontAwesomeIcons.user,
                                            color: context.appColors.primaryTextColor,
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
                                                  letterSpacing: 0.5,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Icon(
                                                    FontAwesomeIcons.locationDot,
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
                                                            context.appColors.hintTextColor,
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.appColors.glassBorder,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: context.appColors.primaryTextColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'DONE':
        color = Color.fromARGB(255, 20, 117, 72);
        break;
      case 'IN_PROGRESS':
        color = Color.fromARGB(255, 10, 83, 143);
        break;
      case 'CANCELLED':
        color = context.appColors.errorColor;
        break;
      default:
        color = Color.fromARGB(255, 129, 81, 4);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}



