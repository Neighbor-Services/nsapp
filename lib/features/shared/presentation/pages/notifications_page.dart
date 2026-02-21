import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/notification.dart' as not;
import 'package:nsapp/features/provider/presentation/pages/provider_accepted_request_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_page.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import '../../../messages/presentation/bloc/message_bloc.dart';
import '../../../messages/presentation/pages/chat_page.dart';
import '../../../provider/presentation/bloc/provider_bloc.dart';
import '../../../seeker/presentation/bloc/seeker_bloc.dart';
import '../bloc/shared_bloc.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) {},
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 32 : 20,
                            vertical: 24,
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
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withAlpha(25)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withAlpha(40)
                                          : Colors.black.withAlpha(10),
                                      width: 1,
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(10),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                "Notifications",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: -0.5,
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
                                      left: isLargeScreen ? 32 : 16,
                                      right: isLargeScreen ? 32 : 16,
                                      bottom: 24,
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
                                      padding: const EdgeInsets.all(40),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? const Color(0xFF1E1E2E)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white.withAlpha(30)
                                              : Colors.black.withAlpha(10),
                                        ),
                                        boxShadow: isDark
                                            ? null
                                            : [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    5,
                                                  ),
                                                  blurRadius: 20,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withAlpha(10)
                                                  : Colors.black.withAlpha(5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.notifications_off_rounded,
                                              size: 50,
                                              color: isDark
                                                  ? Colors.white.withAlpha(150)
                                                  : Colors.black.withAlpha(100),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            "No notifications yet",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white.withAlpha(220)
                                                  : Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "You'll see your notifications here\nas soon as they arrive.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDark
                                                  ? Colors.white.withAlpha(140)
                                                  : Colors.black54,
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
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => _showNotificationDetails(context, notificationData),
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isUnread
                    ? (isDark ? const Color(0xFF2E2E3E) : Colors.white)
                    : (isDark
                          ? const Color(0xFF1E1E2E)
                          : Colors.white.withAlpha(200)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isUnread
                      ? (isDark
                            ? Colors.white.withAlpha(60)
                            : Colors.blue.withAlpha(60))
                      : (isDark
                            ? Colors.white.withAlpha(25)
                            : Colors.black.withAlpha(10)),
                  width: isUnread ? 1.2 : 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withAlpha(20)
                        : Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  if (isUnread)
                    BoxShadow(
                      color: Colors.blue.withAlpha(isDark ? 20 : 10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(
                        notification.notificationType,
                      ).withAlpha(40),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.notificationType),
                      color: _getNotificationColor(
                        notification.notificationType,
                      ),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title ?? "",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isUnread
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(left: 8),
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notification.message ?? "",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? Colors.white.withAlpha(160)
                                : Colors.black.withAlpha(140),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              size: 12,
                              color: isDark
                                  ? Colors.white.withAlpha(100)
                                  : Colors.black.withAlpha(80),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(notification.createdAt!),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.white.withAlpha(120)
                                    : Colors.black.withAlpha(100),
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
        return const Color(0xFF4FACFE);
      case "proposal":
      case "request":
        return const Color(0xFFF093FB);
      case "appointment":
        return const Color(0xFF43E97B);
      case "system":
        return const Color(0xFFFAD961);
      default:
        return Colors.white70;
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F0F1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(40)
                    : Colors.black.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getNotificationColor(
                  notificationData.notification!.notificationType,
                ).withAlpha(40),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getNotificationIcon(
                  notificationData.notification!.notificationType,
                ),
                color: _getNotificationColor(
                  notificationData.notification!.notificationType,
                ),
                size: 38,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              notificationData.notification!.title ?? "Notification",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              notificationData.notification!.message ?? "",
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? Colors.white.withAlpha(180)
                    : Colors.black.withAlpha(160),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (notificationData.notification!.notificationType
                    ?.toLowerCase() !=
                "system") ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
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
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "View Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withAlpha(40)
                          : Colors.black.withAlpha(20),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    "Dismiss",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  void _navigateToDetails(
    BuildContext context,
    not.NotificationData notificationData,
  ) {
    Get.back();
    switch (notificationData.notification!.notificationType?.toLowerCase()) {
      case "message":
        context.read<MessageBloc>().add(
          SetMessageReceiverEvent(profile: notificationData.from!),
        );
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
        if (DashboardState.isProvider) {
          if (notificationData.notification!.notificationType?.toLowerCase() ==
                  "proposal" &&
              notificationData.from != null) {
            context.read<MessageBloc>().add(
              SetMessageReceiverEvent(profile: notificationData.from!),
            );
            context.read<MessageBloc>().add(
              CalenderAppointmentEvent(setAppointment: true),
            );
            context.read<ProviderBloc>().add(
              NavigateProviderEvent(page: 4, widget: const ChatPage()),
            );
          } else {
            context.read<ProviderBloc>().add(
              NavigateProviderEvent(
                page: 3,
                widget: const ProviderAcceptedRequestPage(),
              ),
            );
          }
        } else {
          context.read<SeekerBloc>().add(
            NavigateSeekerEvent(page: 4, widget: const SeekerRequestPage()),
          );
        }
        break;
      default:
        break;
    }
  }
}
