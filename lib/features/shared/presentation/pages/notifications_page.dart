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
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/pages/chat_page.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart' as provider_bloc show GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' hide GetAppointmentsEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' as seeker_bloc show GetAppointmentsEvent;
import '../bloc/shared_bloc.dart';
import 'package:nsapp/core/core.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetMyNotificationsEvent());

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
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) {},
        builder: (context, state) {
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
                                  if (DashboardState.isProvider) {
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
                                    Icons.arrow_back_ios_new_rounded,
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
                                  fontWeight: FontWeight.w900,
                                  color: context.appColors.primaryTextColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: FutureBuilder<List<not.NotificationData>>(
                            future:
                                SuccessGetMyNotificationsState.notifications,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.isNotEmpty) {
                                  return ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.only(
                                      left: isLargeScreen ? 32.w : 16.w,
                                      right: isLargeScreen ? 32.w : 16.w,
                                      bottom: 24.h,
                                    ),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      return _buildNotificationCard(
                                        context,
                                        snapshot.data![index],
                                        index,
                                      );
                                    },
                                  );
                                } else {
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
                                              Icons.notifications_off_rounded,
                                              size: 50.r,
                                              color: context.appColors.glassBorder,
                                            ),
                                          ),
                                          SizedBox(height: 24.h),
                                          Text(
                                            "NO NOTIFICATIONS YET",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w900,
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
              ),
            ),
          );
        },
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
                color: isUnread
                    ? context.appColors.cardBackground
                    : context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isUnread
                      ? context.appColors.glassBorder
                      : context.appColors.glassBorder,
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
                                  fontWeight: FontWeight.w900,
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
                              Icons.access_time_filled_rounded,
                              size: 12.r,
                              color: context.appColors.hintTextColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDate(notification.createdAt!),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
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
        return Icons.chat_bubble_rounded;
      case "proposal":
      case "request":
        return Icons.assignment_rounded;
      case "appointment":
        return Icons.calendar_month_rounded;
      case "system":
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getNotificationColor(String? notificationType) {
    switch (notificationType?.toLowerCase()) {
      case "message":
        return context.appColors.primaryColor;
      case "proposal":
      case "request":
        return context.appColors.primaryColor;
      case "appointment":
        return context.appColors.primaryColor;
      case "system":
        return context.appColors.primaryColor;
      default:
        return context.appColors.primaryColor;
    }
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
                fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w900,
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
                      fontWeight: FontWeight.w900,
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

    // Show loading for types that require data fetching
    bool showLoading = false;
    if (type == "message" ||
        type == "proposal" ||
        type == "request" ||
        type == "direct_request") {
      showLoading = true;
    }

    Get.back(); // Close bottom sheet

    if (showLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: LoadingWidget()),
      );
    }

    switch (type) {
      case "message":
        // Navigate to the specific chat with the sender
        if (notificationData.from != null) {
          context.read<MessageBloc>().add(
            SetMessageReceiverEvent(profile: notificationData.from!),
          );
          // Wait for state update
          await context.read<MessageBloc>().stream.firstWhere(
                (state) => state is MessageReceiverState,
              ).timeout(const Duration(seconds: 5), onTimeout: () => MessageReceiverState());
        }
        
        if (showLoading) Navigator.pop(context);

        if (DashboardState.isProvider) {
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
        if (DashboardState.isProvider) {
          if (requestId != null && requestId.isNotEmpty) {
            // Fetch the specific request, then navigate to it
            context.read<ProviderBloc>().add(
              GetRequestDetailEvent(id: requestId),
            );

            // Wait for data
            final state = await context.read<ProviderBloc>().stream.firstWhere(
              (state) => state is SuccessGetRequestDetailState || state is FailureGetRecentRequestState,
            ).timeout(const Duration(seconds: 10), onTimeout: () => FailureGetRecentRequestState());

            if (showLoading) Navigator.pop(context);

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
          } else if (type == "proposal" && notificationData.from != null) {
            // For proposals, go to chat for appointment scheduling
            context.read<MessageBloc>().add(
              SetMessageReceiverEvent(profile: notificationData.from!),
            );
            context.read<MessageBloc>().add(
              CalenderAppointmentEvent(setAppointment: true),
            );
            
            if (showLoading) Navigator.pop(context);

            context.read<ProviderBloc>().add(
              NavigateProviderEvent(page: 4, widget: const ChatPage()),
            );
          } else {
            if (showLoading) Navigator.pop(context);

            context.read<ProviderBloc>().add(
              NavigateProviderEvent(
                page: 3,
                widget: const ProviderAcceptedRequestPage(),
              ),
            );
          }
        } else {
          // Seeker: navigate to specific request details if we have the ID
          if (requestId != null && requestId.isNotEmpty) {
            context.read<ProviderBloc>().add(
              GetRequestDetailEvent(id: requestId),
            );

            // Wait for data
            final state = await context.read<ProviderBloc>().stream.firstWhere(
              (state) => state is SuccessGetRequestDetailState || state is FailureGetRecentRequestState,
            ).timeout(const Duration(seconds: 10), onTimeout: () => FailureGetRecentRequestState());

            if (showLoading) Navigator.pop(context);

            if (state is SuccessGetRequestDetailState) {
              final requestData = SuccessGetRequestDetailState.request;
              requestData.user = notificationData.from;
              
              if (requestData.request?.userId != SuccessGetProfileState.profile.user?.id) {
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
            if (showLoading) Navigator.pop(context);

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
        final appointmentId = data?['appointment_id']?.toString();
        if (appointmentId != null && appointmentId.isNotEmpty) {
          // Navigate to the appointments tab and refresh
          if (DashboardState.isProvider) {
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
        }
        break;

      default:
        break;
    }
  }
}
