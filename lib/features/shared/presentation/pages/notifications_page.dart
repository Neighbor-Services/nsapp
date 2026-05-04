import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/notification.dart' as not;
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_accepted_request_page.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_page.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/pages/chat_page.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' as provider_bloc show GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' as seeker_bloc show GetAppointmentsEvent;
import '../bloc/shared_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/models/profile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetMyNotificationsEvent());
    
    // Get initial profile
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is SuccessGetProfileState) {
      _currentProfile = profileState.profile;
    }

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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is SuccessGetProfileState) {
                setState(() => _currentProfile = state.profile);
              }
            },
          ),
        ],
        child: BlocConsumer<SharedBloc, SharedState>(
          listener: (context, state) {},
          builder: (context, state) {
            final isProvider = state.isProvider;

            return GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 32.w : 20.w,
                              vertical: 24.h,
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isProvider) {
                                      context.read<ProviderBloc>().add(
                                        ProviderBackPressedEvent(),
                                      );
                                    } else {
                                      context.read<SeekerBloc>().add(
                                        SeekerBackPressedEvent(),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(12.r),
                                    decoration: BoxDecoration(
                                      color: context.appColors.cardBackground,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: context.appColors.glassBorder,
                                      ),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.chevronLeft,
                                      color: context.appColors.primaryTextColor,
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
                                    color: context.appColors.primaryTextColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: _buildNotificationsList(state, isLargeScreen),
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
      ),
    );
  }

  Widget _buildNotificationsList(SharedState state, bool isLargeScreen) {
    if (state is SuccessGetMyNotificationsState) {
      final notifications = state.notifications;
      if (notifications.isNotEmpty) {
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: isLargeScreen ? 32.w : 16.w,
            right: isLargeScreen ? 32.w : 16.w,
            bottom: 24.h,
          ),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationCard(
              context,
              notifications[index],
              index,
            );
          },
        );
      } else {
        return _buildEmptyState();
      }
    } else if (state is SharedLoadingState) {
       return const ListSkeletonLoader();
    } else {
       return _buildEmptyState();
    }
  }

  Widget _buildEmptyState() {
     return Center(
      child: Container(
      padding: EdgeInsets.all(40.r),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: context.appColors.glassBorder,
        ),
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
              child: Icon(
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
    final notification = notificationData.notification!;
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
        onTap: () => _showNotificationDetails(context, notificationData),
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
                    child: Icon(
                      _getNotificationIcon(notification.notificationType),
                      color: _getNotificationColor(
                        notification.notificationType,
                      ),
                      size: 26.r,
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
                            Icon(
                              FontAwesomeIcons.clock,
                              size: 12.r,
                              color: context.appColors.hintTextColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDate(notification.createdAt!),
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

  IconData _getNotificationIcon(String? notificationType) {
    switch (notificationType?.toLowerCase()) {
      case "message":
        return FontAwesomeIcons.comment;
      case "proposal":
      case "request":
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

  void _showNotificationDetails(
    BuildContext context,
    not.NotificationData notificationData,
  ) {
    context.read<SharedBloc>().add(
      SetNotificationSeenEvent(
        notificationID: notificationData.notification!.id!,
      ),
    );
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(
            color: context.appColors.glassBorder,
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
                color: context.appColors.glassBorder,
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
              child: Icon(
                _getNotificationIcon(
                  notificationData.notification!.notificationType,
                ),
                color: _getNotificationColor(
                  notificationData.notification!.notificationType,
                ),
                size: 38.r,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              (notificationData.notification!.title ?? "NOTIFICATION").toUpperCase(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: context.appColors.primaryTextColor,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              notificationData.notification!.message ?? "",
              style: TextStyle(
                fontSize: 16.sp,
                color: context.appColors.hintTextColor,
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
                  onPressed: () =>
                      _navigateToDetails(context, notificationData),
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
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.appColors.glassBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                  child: Text(
                    "DISMISS",
                    style: TextStyle(
                      color: context.appColors.primaryTextColor,
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
      isScrollControlled: true,
    );
  }

  Future<void> _navigateToDetails(
    BuildContext context,
    not.NotificationData notificationData,
  ) async {
    final notification = notificationData.notification;
    final data = notification?.data;
    final type = notification?.notificationType?.toLowerCase();
    final sharedState = context.read<SharedBloc>().state;
    final isProvider = sharedState.isProvider;

    Get.back(); // Close bottom sheet

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ListSkeletonLoader(),
    );

    switch (type) {
      case "message":
        if (notificationData.from != null) {
          context.read<MessageBloc>().add(
            SetMessageReceiverEvent(profile: notificationData.from!),
          );
          await context.read<MessageBloc>().stream.firstWhere(
                (state) => state is MessageReceiverState,
              ).timeout(const Duration(seconds: 5), onTimeout: () => MessageReceiverState(profile: Profile()));
        }
        
        Navigator.pop(context); // Remove loading

        if (isProvider) {
          context.read<ProviderBloc>().add(
            NavigateProviderEvent(page: 4, widget: const ChatPage()),
          );
        } else {
          context.read<SeekerBloc>().add(
            NavigateSeekerEvent(page: 4, widget: const ChatPage()),
          );
        }
        break;

      case "proposal":
      case "request":
      case "direct_request":
        final requestId = data?['request_id']?.toString();
        if (isProvider) {
          if (requestId != null && requestId.isNotEmpty) {
            context.read<ProviderBloc>().add(
              GetRequestDetailEvent(id: requestId),
            );

            final state = await context.read<ProviderBloc>().stream.firstWhere(
              (state) => state is SuccessGetRequestDetailState || state is FailureGetRecentRequestState,
            ).timeout(const Duration(seconds: 10), onTimeout: () => FailureGetRecentRequestState());

            Navigator.pop(context); // Remove loading

            if (state is SuccessGetRequestDetailState) {
              context.read<ProviderBloc>().add(
                NavigateProviderEvent(
                  page: 1,
                  widget: const ProviderRequestDetailPage(),
                ),
              );
            } else {
              customAlert(context, AlertType.error, "Failed to load request details");
            }
          } else {
             Navigator.pop(context);
             context.read<ProviderBloc>().add(
              NavigateProviderEvent(
                page: 3,
                widget: const ProviderAcceptedRequestPage(),
              ),
            );
          }
        } else {
          if (requestId != null && requestId.isNotEmpty) {
            context.read<ProviderBloc>().add(
              GetRequestDetailEvent(id: requestId),
            );

            final state = await context.read<ProviderBloc>().stream.firstWhere(
              (state) => state is SuccessGetRequestDetailState || state is FailureGetRecentRequestState,
            ).timeout(const Duration(seconds: 10), onTimeout: () => FailureGetRecentRequestState());

            Navigator.pop(context); // Remove loading

            if (state is SuccessGetRequestDetailState) {
              final requestData = state.request; 
              requestData.user = notificationData.from;
              
              if (requestData.request?.userId != _currentProfile?.user?.id) {
                customAlert(context, AlertType.error, "You can't view this request");
                return;
              }
              
              context.read<SeekerBloc>().add(
                SeekerRequestDetailEvent(request: requestData),
              );
              context.read<SeekerBloc>().add(
                NavigateSeekerEvent(
                  page: 1,
                  widget: const SeekerRequestDetailsPage(),
                ),
              );
            } else {
              customAlert(context, AlertType.error, "Failed to load request details");
            }
          } else {
            Navigator.pop(context);
            context.read<SeekerBloc>().add(
              NavigateSeekerEvent(
                page: 4,
                widget: const SeekerRequestPage(),
              ),
            );
          }
        }
        break;

      case "appointment":
        Navigator.pop(context);
        if (isProvider) {
          context.read<ProviderBloc>().add(provider_bloc.GetAppointmentsEvent());
          context.read<ProviderBloc>().add(
            NavigateProviderEvent(
              page: 2,
              widget: const ProviderAcceptedRequestPage(),
            ),
          );
        } else {
          context.read<SeekerBloc>().add(seeker_bloc.GetAppointmentsEvent());
          context.read<SeekerBloc>().add(
            NavigateSeekerEvent(
              page: 3,
              widget: const SeekerRequestPage(),
            ),
          );
        }
        break;

      default:
        Navigator.pop(context);
        break;
    }
  }
}


