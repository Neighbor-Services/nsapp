import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/dimension.dart';
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Glassmorphic Search Bar
                    SolidTextField(
                      controller: searchController,
                      hintText: "Search Request",
                      label: "SEARCH",
                      prefixIcon: Icons.search,
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
                    const SizedBox(height: 20),

                    // Request Grid
                    SizedBox(
                      height: size(context).height - 200,
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
                                    padding: const EdgeInsets.all(24),
                                    child: EmptyWidget(
                                      message: "No request matches your search",
                                      height: 200,
                                    ),
                                  ),
                                );
                              }

                              return GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
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
                                  padding: const EdgeInsets.all(20),
                                  child: EmptyWidget(
                                    message:
                                        "No request available at the moment",
                                    height: 250,
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
        final secondaryTextColor = isDark
            ? Colors.white.withAlpha(150)
            : const Color(0xFF1E1E2E).withAlpha(150);
        final iconColor = isDark
            ? Colors.white.withAlpha(180)
            : const Color(0xFF1E1E2E).withAlpha(150);

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
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Service Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withAlpha(isDark ? 80 : 20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(50)
                                : Theme.of(context).primaryColor.withAlpha(50),
                          ),
                        ),
                        child: Text(
                          requestData.request?.service?.name ?? "Service",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Theme.of(context).primaryColor,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isDark
                                    ? Colors.white.withAlpha(50)
                                    : Colors.black.withAlpha(10),
                                backgroundImage:
                                    (profile.profilePictureUrl != null &&
                                        profile.profilePictureUrl!.isNotEmpty)
                                    ? NetworkImage(profile.profilePictureUrl!)
                                    : null,
                                child:
                                    (profile.profilePictureUrl == null ||
                                        profile.profilePictureUrl!.isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        size: 14,
                                        color: iconColor,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  profile.firstName ?? "User",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 12,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                requestData.request?.distance != null
                                    ? "${requestData.request!.distance!.toStringAsFixed(1)} km"
                                    : "N/A",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton(
                    icon: Icon(Icons.more_horiz_rounded, color: iconColor),
                    color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withAlpha(30)
                            : Colors.black.withAlpha(10),
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
                      final popupTextColor = isDark
                          ? Colors.white
                          : const Color(0xFF1E1E2E);
                      return [
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_rounded,
                                color: popupTextColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Details",
                                style: TextStyle(color: popupTextColor),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: popupTextColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Chat",
                                style: TextStyle(color: popupTextColor),
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
