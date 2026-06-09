import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/notification.dart' as not;
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart'
    hide GetAppointmentsEvent;
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart'
    as provider_bloc
    show GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart'
    hide GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart'
    as seeker_bloc
    show GetAppointmentsEvent;
import 'package:nsapp/features/shared/presentation/bloc/notification/notification_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/models/profile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Profile? _currentProfile;

  final PagingController<int, not.NotificationData> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();

    // Check if we have cached notifications in the Bloc state to show instantly
    final cachedState = context.read<NotificationBloc>().state;
    if (cachedState is SuccessGetMyNotificationsState &&
        cachedState.notifications.isNotEmpty) {
      _pagingController.value = PagingState(
        nextPageKey: cachedState.hasReachedMax
            ? null
            : cachedState.currentPage + 1,
        error: null,
        itemList: cachedState.notifications,
      );
      // Trigger a silent background refresh to sync with backend
      context.read<NotificationBloc>().add(GetMyNotificationsEvent(page: 1));
    }

    _pagingController.addPageRequestListener((pageKey) {
      if (pageKey == 1) {
        context.read<NotificationBloc>().add(GetMyNotificationsEvent(page: 1));
      } else {
        context.read<NotificationBloc>().add(
          LoadMoreNotificationsEvent(page: pageKey),
        );
      }
    });

    // Get initial profile
    _currentProfile = context.read<ProfileBloc>().state.profile;

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
    _pagingController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              setState(() => _currentProfile = state.profile);
            },
          ),
          BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is SuccessGetMyNotificationsState) {
                final isLastPage = state.hasReachedMax;
                if (state.currentPage == 1) {
                  // Direct update for the first page to avoid full screen skeleton reload and resolve duplicates
                  _pagingController.value = PagingState(
                    nextPageKey: isLastPage ? null : 2,
                    error: null,
                    itemList: state.notifications,
                  );
                } else {
                  if (isLastPage) {
                    _pagingController.appendLastPage(
                      state.notifications
                          .skip(_pagingController.itemList?.length ?? 0)
                          .toList(),
                    );
                  } else {
                    final nextPageKey = state.currentPage + 1;
                    final newItems = state.notifications
                        .skip(_pagingController.itemList?.length ?? 0)
                        .toList();
                    _pagingController.appendPage(newItems, nextPageKey);
                  }
                }
              } else if (state is NotificationFailure) {
                _pagingController.error = state.message;
              }
            },
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                return GradientBackground(
                  child: SafeArea(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 700.w),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _pagingController.refresh();
                              context.read<ProfileBloc>().add(
                                GetProfileStreamEvent(),
                              );
                              context.read<ProfileBloc>().add(
                                GetProfileEvent(),
                              );
                            },
                            child: CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isLargeScreen ? 32.w : 20.w,
                                      vertical: 24.h,
                                    ),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (Navigator.of(
                                              context,
                                            ).canPop()) {
                                              context.pop();
                                            } else {
                                              if (settingsState.isProvider) {
                                                context
                                                    .read<ProviderBloc>()
                                                    .add(
                                                      ChangeProviderTabEvent(
                                                        tabIndex: 1,
                                                      ),
                                                    );
                                              } else {
                                                context.read<SeekerBloc>().add(
                                                  ChangeSeekerTabEvent(
                                                    tabIndex: 1,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12.r),
                                            decoration: BoxDecoration(
                                              color: context
                                                  .appColors
                                                  .cardBackground,
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                color: context
                                                    .appColors
                                                    .glassBorder,
                                              ),
                                            ),
                                            child: FaIcon(
                                              FontAwesomeIcons.chevronLeft,
                                              color: context
                                                  .appColors
                                                  .primaryTextColor,
                                              size: 20.r,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Text(
                                          "NOTIFICATIONS",
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: context
                                                .appColors
                                                .primaryTextColor,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.only(
                                    left: isLargeScreen ? 32.w : 16.w,
                                    right: isLargeScreen ? 32.w : 16.w,
                                    bottom: 24.h,
                                  ),
                                  sliver: PagedSliverList<int, not.NotificationData>(
                                    pagingController: _pagingController,
                                    builderDelegate:
                                        PagedChildBuilderDelegate<
                                          not.NotificationData
                                        >(
                                          itemBuilder: (context, item, index) =>
                                              _buildNotificationCard(
                                                context,
                                                item,
                                                index,
                                              ),
                                          firstPageProgressIndicatorBuilder:
                                              (_) => const ListSkeletonLoader(),
                                          newPageProgressIndicatorBuilder:
                                              (_) => const Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              ),
                                          noItemsFoundIndicatorBuilder: (_) =>
                                              _buildEmptyState(),
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: context.appColors.glassBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: context.appColors.glassBorder,
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.bellSlash,
                size: 50.r,
                color: context.appColors.glassBorder,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "NO NOTIFICATIONS YET",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: context.appColors.glassBorder,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "You'll see your notifications here\nas soon as they arrive.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: context.appColors.glassBorder,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    not.NotificationData notificationData,
    int index,
  ) {
    final notification = notificationData.notification;
    if (notification == null) return const SizedBox.shrink();

    final isUnread = !(notification.isRead ?? false);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30.h * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showNotificationDetails(notificationData),
        child: Builder(
          builder: (context) {
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: context.appColors.glassBorder,
                  width: isUnread ? 1.2.r : 0.8.r,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52.w,
                    height: 52.h,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.notificationType,
                      ).withAlpha(40),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Center(
                      child: FaIcon(
                        _getNotificationFaIcon(notification.notificationType),
                        color: _getNotificationColor(
                          notification.notificationType,
                        ),
                        size: 26.r,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                (notification.title ?? "").toUpperCase(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: context.appColors.primaryTextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 10.r,
                                height: 10.h,
                                margin: EdgeInsets.only(left: 8.w),
                                decoration: BoxDecoration(
                                  color: context.appColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          notification.message ?? "",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.appColors.hintTextColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.clock,
                              size: 12.r,
                              color: context.appColors.hintTextColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDate(
                                notification.createdAt ?? DateTime.now(),
                              ),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: context.appColors.hintTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  FaIconData _getNotificationFaIcon(String? notificationType) {
    switch (notificationType?.toLowerCase()) {
      case "message":
        return FontAwesomeIcons.comment;
      case "proposal":
      case "request":
      case "direct_request":
      case "broadcast_request":
        return FontAwesomeIcons.fileLines;
      case "appointment":
        return FontAwesomeIcons.calendar;
      case "system":
        return FontAwesomeIcons.circleInfo;
      default:
        return FontAwesomeIcons.bell;
    }
  }

  Color _getNotificationColor(String? notificationType) {
    return context.appColors.primaryColor;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    if (diff.inDays < 7) return "${diff.inDays}d ago";
    return DateFormat("MMM dd, yyyy").format(date);
  }

  void _showNotificationDetails(not.NotificationData notificationData) {
    // sheet, because showModalBottomSheet can be tricky with context inheritance
    // if not using the correct context level.
    final pageContext = context;
    pageContext.read<NotificationBloc>().add(
      SetNotificationSeenEvent(
        notificationID: notificationData.notification!.id!,
      ),
    );
    showModalBottomSheet(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: pageContext.appColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(
            color: pageContext.appColors.glassBorder,
            width: 1.r,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: pageContext.appColors.glassBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notificationData.notification!.notificationType,
                ).withAlpha(40),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Center(
                child: FaIcon(
                  _getNotificationFaIcon(
                    notificationData.notification!.notificationType,
                  ),
                  color: _getNotificationColor(
                    notificationData.notification!.notificationType,
                  ),
                  size: 38.r,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              (notificationData.notification!.title ?? "NOTIFICATION")
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: pageContext.appColors.primaryTextColor,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              notificationData.notification!.message ?? "",
              style: TextStyle(
                fontSize: 16.sp,
                color: pageContext.appColors.hintTextColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (notificationData.notification!.notificationType
                    ?.toLowerCase() !=
                "system") ...[
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () => _navigateToDetails(notificationData),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getNotificationColor(
                      notificationData.notification!.notificationType,
                    ),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    "VIEW DETAILS",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: pageContext.appColors.glassBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    "DISMISS",
                    style: TextStyle(
                      color: pageContext.appColors.primaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToDetails(not.NotificationData notificationData) async {
    final notification = notificationData.notification;
    final data = notification?.data;
    final type = notification?.notificationType?.toLowerCase();

    // Capture all BLoC references from the page's own mounted context.
    final isProvider = context.read<SettingsBloc>().state.isProvider;
    final messageBloc = context.read<MessageBloc>();
    final providerBloc = context.read<ProviderBloc>();
    final seekerBloc = context.read<SeekerBloc>();

    Navigator.of(context).pop(); // Close bottom sheet

    if (!mounted) return;
    final pageContext = context;

    bool loaderDismissed = false;
    BuildContext? dialogContext;
    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        if (loaderDismissed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted && Navigator.of(ctx).canPop()) {
              Navigator.of(ctx).pop();
            }
          });
        }
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 28.h),
                decoration: BoxDecoration(
                  color: pageContext.appColors.cardBackground.withAlpha(217),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: pageContext.appColors.glassBorder,
                    width: 1.2.r,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: pageContext.appColors.primaryColor,
                      strokeWidth: 3.5.r,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      "LOADING DETAILS...",
                      style: TextStyle(
                        color: pageContext.appColors.primaryTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
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

    void dismissLoader() {
      loaderDismissed = true;
      if (dialogContext != null && Navigator.of(dialogContext!).canPop()) {
        Navigator.of(dialogContext!).pop();
      }
    }

    switch (type) {
      case "message":
        final senderId = data?['sender_id']?.toString();

        if (notificationData.from != null) {
          // Set receiver profile synchronously in the bloc, then navigate.
          // The ChatPage reads receiverProfile from the bloc in initState,
          // so we just need to ensure it's set before push.
          messageBloc.add(
            SetMessageReceiverEvent(profile: notificationData.from!),
          );

          // Give the bloc a microtask to process the event
          await Future.delayed(const Duration(milliseconds: 100));

          dismissLoader();
          if (!mounted) return;
          context.push('/chat');
        } else if (senderId != null && senderId.isNotEmpty) {
          // `from` is null but we have a sender_id — fetch the profile by ID.
          final reloadFuture = messageBloc.stream
              .firstWhere(
                (state) =>
                    state is MessageReceiverState ||
                    state is FailureGetMyMessagesState,
              )
              .timeout(
                const Duration(seconds: 8),
                onTimeout: () => FailureGetMyMessagesState(message: "Timeout"),
              );
          messageBloc.add(ReloadMessagesEvent(user: senderId));
          final reloadState = await reloadFuture;

          dismissLoader();
          if (!mounted) return;

          if (reloadState is MessageReceiverState) {
            debugPrint(
              "Navigating to chat with receiver: ${reloadState.profile.user?.id}",
            );
            context.push('/chat');
          } else {
            // Reload failed — navigate to messages tab instead
            if (isProvider) {
              providerBloc.add(ChangeProviderTabEvent(tabIndex: 4));
            } else {
              seekerBloc.add(ChangeSeekerTabEvent(tabIndex: 4));
            }
            context.pop(); // Go back to home
          }
        } else {
          // No sender info at all — go to messages tab as fallback.
          dismissLoader();
          if (!mounted) return;
          if (isProvider) {
            providerBloc.add(ChangeProviderTabEvent(tabIndex: 4));
          } else {
            seekerBloc.add(ChangeSeekerTabEvent(tabIndex: 4));
          }
          context.pop(); // Go back to home
        }
        break;

      case "proposal":
      case "request":
      case "direct_request":
      case "broadcast_request":
        final requestId = data?['request_id']?.toString();
        if (isProvider) {
          if (requestId != null && requestId.isNotEmpty) {
            // Subscribe FIRST to avoid race condition, then dispatch.
            final stateFuture = providerBloc.stream
                .firstWhere(
                  (state) =>
                      state is SuccessGetRequestDetailState ||
                      state is FailureGetRequestsState,
                )
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () => FailureGetRequestsState(message: "Timeout"),
                );
            providerBloc.add(GetRequestDetailEvent(id: requestId));
            final state = await stateFuture;

            dismissLoader();

            if (state is SuccessGetRequestDetailState) {
              if (!mounted) return;
              context.push(
                '/app/provider/requests/$requestId',
                extra: state.request,
              );
            } else {
              customAlert(
                pageContext,
                AlertType.error,
                "Failed to load request details",
              );
            }
          } else {
            dismissLoader();
            providerBloc.add(ChangeProviderTabEvent(tabIndex: 3));
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
          }
        } else {
          if (requestId != null && requestId.isNotEmpty) {
            // Subscribe FIRST to avoid race condition, then dispatch.
            final stateFuture = seekerBloc.stream
                .firstWhere(
                  (state) =>
                      state is SuccessReloadRequestState ||
                      state is FailureReloadRequestState,
                )
                .timeout(
                  const Duration(seconds: 10),
                  onTimeout: () =>
                      FailureReloadRequestState(message: "Timeout"),
                );
            seekerBloc.add(ReloadRequestEvent(request: requestId));
            final state = await stateFuture;

            dismissLoader();

            if (state is SuccessReloadRequestState) {
              final requestData = state.request;
              requestData.user = notificationData.from;

              if (requestData.request?.userId != _currentProfile?.user?.id) {
                customAlert(
                  pageContext,
                  AlertType.error,
                  "You can't view this request",
                );
                return;
              }

              seekerBloc.add(SeekerRequestDetailEvent(request: requestData));
              if (!mounted) return;
              context.push(
                '/app/requests/${requestData.request?.id}',
                extra: requestData,
              );
            } else {
              customAlert(
                pageContext,
                AlertType.error,
                "Failed to load request details",
              );
            }
          } else {
            dismissLoader();
            if (!mounted) return;
            context.push('/seeker-requests');
          }
        }
        break;

      case "appointment":
        dismissLoader();
        if (isProvider) {
          providerBloc.add(provider_bloc.GetAppointmentsEvent());
          providerBloc.add(ChangeProviderTabEvent(tabIndex: 5));
          if (Navigator.of(context).canPop()) {
            context.pop();
          }
        } else {
          seekerBloc.add(seeker_bloc.GetAppointmentsEvent());
          if (!mounted) return;
          context.push('/seeker-appointments');
        }
        break;

      default:
        dismissLoader();
        break;
    }
  }
}
