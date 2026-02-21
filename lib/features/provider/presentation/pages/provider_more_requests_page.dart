import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () =>
              context.read<ProviderBloc>().add(ProviderBackPressedEvent()),
        ),
        title: Text(
          "Browse Requests",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Requests List
                        Expanded(
                          child: _buildRequestsList(
                            context,
                            isLargeScreen,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    bool isLargeScreen,
    bool isDark,
  ) {
    return FutureBuilder<List<RequestData>>(
      future: SuccessGetRequestsState.requests,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: SolidContainer(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.work_off_rounded,
                      size: 60,
                      color: isDark
                          ? Colors.white.withAlpha(150)
                          : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No requests available",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withAlpha(200)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Check back later for new projects",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withAlpha(150)
                            : Colors.black54,
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
              horizontal: isLargeScreen ? 32 : 16,
              vertical: 16,
            ),
            itemCount: snapshot.data!.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < snapshot.data!.length) {
                return _buildRequestCard(
                  context,
                  snapshot.data![index],
                  index,
                  isDark,
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
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

  Widget _buildRequestCard(
    BuildContext context,
    RequestData data,
    int index,
    bool isDark,
  ) {
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
          padding: const EdgeInsets.only(bottom: 16),
          child: SolidContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                // Image
                SizedBox(
                  width: 100,
                  height: 125,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
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
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                data.user?.firstName ?? "User",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(data.request?.status ?? "OPEN"),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(15)
                                : Colors.black.withAlpha(5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withAlpha(20)
                                  : Colors.black.withAlpha(10),
                            ),
                          ),
                          child: Text(
                            data.request?.service?.name ?? "Service",
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.white.withAlpha(200)
                                  : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.request?.title ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withAlpha(180)
                                : Colors.black45,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: isDark
                                  ? Colors.white.withAlpha(100)
                                  : Colors.black26,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat("MMM dd, yyyy").format(
                                data.request?.createdAt ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withAlpha(100)
                                    : Colors.black38,
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
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? Colors.white.withAlpha(100)
                        : Colors.black12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'DONE':
        color = const Color(0xFF4CAF50); // Green
        break;
      case 'IN_PROGRESS':
        color = const Color(0xFF2196F3); // Blue
        break;
      case 'CANCELLED':
        color = const Color(0xFFF44336); // Red
        break;
      default:
        color = const Color(0xFFFF9800); // Orange
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
