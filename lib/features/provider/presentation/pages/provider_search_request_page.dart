import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import '../../../messages/presentation/bloc/message_bloc.dart';
import '../../../messages/presentation/pages/chat_page.dart';
import '../bloc/provider_bloc.dart';
import 'package:nsapp/core/core.dart';

class ProviderSearchRequestPage extends StatefulWidget {
  const ProviderSearchRequestPage({super.key});

  @override
  State<ProviderSearchRequestPage> createState() =>
      _ProviderSearchRequestPageState();
}

class _ProviderSearchRequestPageState extends State<ProviderSearchRequestPage> {
  List<RequestData> requests = [];
  List<RequestData> searchedRequests = [];
  TextEditingController searchController = TextEditingController();

  RequestData search = RequestData();

  @override
  void initState() {
    context.read<ProviderBloc>().add(SearchRequestEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {},
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.0.r),
                child: Column(
                  children: [
                    // Glassmorphic Search Bar
                    SolidTextField(
                      controller: searchController,
                      hintText: "SEARCH REQUEST",
                      label: "SEARCH",
                      allCapsLabel: true,
                      prefixIcon: FontAwesomeIcons.magnifyingGlass,
                      onChanged: (value) {
                        setState(() {
                          searchedRequests = [];
                          if (value.isNotEmpty) {
                            context.read<ProviderBloc>().add(
                              SearchEvent(isSearching: true),
                            );
                            for (var req in requests) {
                              RequestData rd = req;
                              if (rd.request!.title!.toLowerCase().contains(
                                    value.toLowerCase(),
                                  ) ||
                                  rd.request!.service!.name!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  rd.request!.description!
                                      .toLowerCase()
                                      .contains(value.toLowerCase())) {
                                searchedRequests.add(req);
                              }
                            }
                          } else {
                            context.read<ProviderBloc>().add(
                              SearchEvent(isSearching: false),
                            );
                          }
                        });
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Request Grid
                    SizedBox(
                      height: size(context).height - 200.h,
                      child: FutureBuilder<List<RequestData>>(
                        future: SuccessSearchRequestState.requests,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.isNotEmpty) {
                              if (requests.isEmpty) requests = snapshot.data!;

                              final displayList = SearchingState.isSearching
                                  ? searchedRequests
                                  : snapshot.data!;

                              if (displayList.isEmpty &&
                                  SearchingState.isSearching) {
                                return Center(
                                  child: SolidContainer(
                                    padding: EdgeInsets.all(24.r),
                                    child: EmptyWidget(
                                      message: "No request matches your search",
                                      height: 200.h,
                                    ),
                                  ),
                                );
                              }

                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16.w,
                                      mainAxisSpacing: 16.h,
                                      childAspectRatio: 0.75,
                                    ),
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  RequestData requestD = displayList[index];
                                  if (SearchingState.isSearching) {
                                    search = searchedRequests[index];
                                  }

                                  // Staggered Animation
                                  return TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(
                                      milliseconds: 400 + (index * 100),
                                    ),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 50 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _buildRequestCard(requestD),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: SolidContainer(
                                  padding: EdgeInsets.all(20.r),
                                  child: EmptyWidget(
                                    message:
                                        "No request available at the moment",
                                    height: 250.h,
                                  ),
                                ),
                              );
                            }
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                "Error loading requests",
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          } else {
                            return const Center(child: LoadingWidget());
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(RequestData requestData) {
    return FutureBuilder<Profile?>(
      future: Helpers.getSeekerProfile(requestData.request!.userId!),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data ?? Profile();
        final textColor = context.appColors.primaryTextColor;
        final secondaryTextColor = context.appColors.secondaryTextColor;
        final iconColor = context.appColors.glassBorder;

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
                widget: const ProviderRequestDetailPage(),
              ),
            );
          },
          child: SolidContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(20.r),
            borderColor: context.appColors.glassBorder,
            borderWidth: 1.5.r,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Content
                Padding(
                  padding: EdgeInsets.all(16.0.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Service Tag
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.primaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: context.appColors.primaryColor.withAlpha(50),
                          ),
                        ),
                        child: Text(
                          (requestData.request?.service?.name ?? "Service")
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.primaryColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requestData.request?.title ?? "",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12.r,
                                backgroundColor: context.appColors.glassBorder,
                                backgroundImage:
                                    (profile.profilePictureUrl != null &&
                                        profile.profilePictureUrl!.isNotEmpty)
                                    ? NetworkImage(profile.profilePictureUrl!)
                                    : null,
                                child:
                                    (profile.profilePictureUrl == null ||
                                        profile.profilePictureUrl!.isEmpty)
                                    ? Icon(
                                        FontAwesomeIcons.user,
                                        size: 14.r,
                                        color: iconColor,
                                      )
                                    : null,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (profile.firstName ?? "User")
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.locationDot,
                                          size: 12.r,
                                          color: secondaryTextColor,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          requestData.request?.distance != null
                                              ? "${requestData.request!.distance!.toStringAsFixed(1)} km"
                                              : "N/A",
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: PopupMenuButton(
                    icon: FaIcon(FontAwesomeIcons.ellipsis, color: context.appColors.primaryTextColor),
                    color: context.appColors.primaryBackground,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                      side: BorderSide(
                        color: context.appColors.glassBorder,
                        width: 1.5.r,
                      ),
                    ),
                    onSelected: (val) {
                      switch (val) {
                        case 1:
                          context.read<ProviderBloc>().add(
                            RequestDetailEvent(request: requestData),
                          );
                          context.read<ProviderBloc>().add(
                            ReloadProfileEvent(
                              request: requestData.request!.id!,
                            ),
                          );
                          context.read<ProviderBloc>().add(
                            NavigateProviderEvent(
                              page: 1,
                              widget: const ProviderRequestDetailPage(),
                            ),
                          );
                          break;
                        case 2:
                          context.read<MessageBloc>().add(
                            SetMessageReceiverEvent(profile: profile),
                          );
                          context.read<ProviderBloc>().add(
                            NavigateProviderEvent(
                              page: 4,
                              widget: const ChatPage(),
                            ),
                          );
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final popupTextColor = context.appColors.primaryTextColor;
                      return [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.eye,
                                color: popupTextColor,
                                size: 20.r,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                "DETAILS",
                                style: TextStyle(
                                  color: popupTextColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.comment,
                                color: popupTextColor,
                                size: 20.r,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                "CHAT",
                                style: TextStyle(
                                  color: popupTextColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12.sp,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


