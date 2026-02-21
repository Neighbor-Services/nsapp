import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/request_accept.dart';
import '../../../../core/models/request_acceptance.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';
import '../../../messages/presentation/pages/chat_page.dart';

class ProviderAcceptedRequestPage extends StatefulWidget {
  const ProviderAcceptedRequestPage({super.key});

  @override
  State<ProviderAcceptedRequestPage> createState() =>
      _ProviderAcceptedRequestPageState();
}

class _ProviderAcceptedRequestPageState
    extends State<ProviderAcceptedRequestPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(GetAcceptedRequestEvent());

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(200)
        : const Color(0xFF64748B);
    final cardColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is SuccessRequestCancelState) {
            context.read<ProviderBloc>().add(GetAcceptedRequestEvent());
            customAlert(context, AlertType.success, "Request Cancelled");
          }
          if (state is FailureRequestCancelState) {
            customAlert(context, AlertType.error, "Request Cancelled Failed");
          }
        },
        builder: (context, state) {
          return GradientBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Accepted Requests",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Manage your active projects and progress",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder<List<RequestAcceptance>>(
                            future: SuccessGetAcceptRequestState.accepts,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(48),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                          border: Border.all(
                                            color: borderColor,
                                          ),
                                          boxShadow: isDark
                                              ? null
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(5),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.white10
                                                    : Colors.black.withAlpha(5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.work_history_rounded,
                                                size: 64,
                                                color: isDark
                                                    ? Colors.white.withAlpha(
                                                        160,
                                                      )
                                                    : Colors.black38,
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            Text(
                                              "No accepted requests",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              "You haven't accepted any service requests yet.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: isDark
                                                    ? Colors.white.withAlpha(
                                                        140,
                                                      )
                                                    : Colors.black54,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isLargeScreen ? 32 : 16,
                                    vertical: 8,
                                  ),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return _buildRequestCard(
                                      context,
                                      snapshot.data![index],
                                      index,
                                      isDark,
                                    );
                                  },
                                );
                              }
                              return const Center(child: LoadingWidget());
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

  Widget _buildRequestCard(
    BuildContext context,
    RequestAcceptance requestAcceptance,
    int index,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(160)
        : const Color(0xFF64748B);
    final cardColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);

    final request = requestAcceptance.acceptance?.request;
    if (request == null) return const SizedBox.shrink();

    final user = requestAcceptance.user;
    if (user == null) return const SizedBox.shrink();

    final isApproved = request.approved ?? false;
    final isAssignedToMe =
        request.approvedUser == requestAcceptance.provider?.id;
    final status = request.status ?? 'OPEN';

    return GestureDetector(
      onTap: () {
        context.read<ProviderBloc>().add(
          RequestDetailEvent(
            request: RequestData(
              request: requestAcceptance.acceptance!.request,
              user: requestAcceptance.user,
            ),
          ),
        );
        context.read<ProviderBloc>().add(
          ReloadProfileEvent(request: request.id ?? ""),
        );
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(
            page: 3,
            widget: const ProviderRequestDetailPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(40)
                  : Colors.black.withAlpha(5),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: (request.withImage ?? false)
                      ? Image.network(
                          request.imageUrl ?? "",
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: double.infinity,
                                height: 140,
                                color: isDark
                                    ? Colors.white12
                                    : Colors.black.withAlpha(20),
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black26,
                                ),
                              ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 140,
                          color: appDeepBlueColor1.withAlpha(50),
                          child: const Icon(
                            Icons.assignment_rounded,
                            color: Colors.white24,
                            size: 40,
                          ),
                        ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        isApproved,
                        isAssignedToMe,
                        status,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(isApproved, isAssignedToMe, status),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getStatusText(isApproved, isAssignedToMe, status),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: isDark
                          ? const Color(0xFF1E1E2E)
                          : Colors.white,
                      iconTheme: IconThemeData(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    child: PopupMenuButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black54
                              : Colors.white.withAlpha(200),
                          borderRadius: BorderRadius.circular(10),
                          border: isDark
                              ? null
                              : Border.all(color: Colors.black.withAlpha(20)),
                        ),
                        child: Icon(
                          Icons.more_horiz_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 20,
                        ),
                      ),
                      onSelected: (val) =>
                          _handleMenuAction(context, val, requestAcceptance),
                      itemBuilder: (context) => _buildMenuItems(isDark),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.black.withAlpha(10),
                    backgroundImage:
                        (user.profilePictureUrl != null &&
                            user.profilePictureUrl!.isNotEmpty)
                        ? NetworkImage(user.profilePictureUrl!)
                        : const AssetImage(logoAssets) as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title ?? "Project",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.firstName ?? "Client",
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(bool isApproved, bool isAssignedToMe, String status) {
    // If assigned to me and in progress or done
    if (isAssignedToMe && isApproved) {
      if (status == 'DONE') return Colors.blue;
      if (status == 'IN_PROGRESS') return Colors.green;
      return Colors.green; // Approved and assigned
    }
    // If approved but not assigned to me
    if (isApproved) return Colors.orange;
    // Waiting for approval
    return Colors.grey;
  }

  IconData _getStatusIcon(bool isApproved, bool isAssignedToMe, String status) {
    // If assigned to me and in progress or done
    if (isAssignedToMe && isApproved) {
      if (status == 'DONE') return Icons.check_circle_rounded;
      if (status == 'IN_PROGRESS') return Icons.pending_actions_rounded;
      return Icons.verified_rounded;
    }
    // If approved but not assigned to me
    if (isApproved) return Icons.pending_rounded;
    // Waiting for approval
    return Icons.hourglass_empty_rounded;
  }

  String _getStatusText(bool isApproved, bool isAssignedToMe, String status) {
    // If assigned to me and in progress or done
    if (isAssignedToMe && isApproved) {
      if (status == 'DONE') return "Completed";
      if (status == 'IN_PROGRESS') return "In Progress";
      return "Active Task";
    }
    // If approved but not assigned to me
    if (isApproved) return "Assigned to Other";
    // Waiting for approval
    return "Waiting Response";
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    int action,
    RequestAcceptance ra,
  ) async {
    switch (action) {
      case 1:
        context.read<ProviderBloc>().add(
          RequestDetailEvent(
            request: RequestData(
              request: ra.acceptance!.request,
              user: ra.user,
            ),
          ),
        );
        context.read<ProviderBloc>().add(
          ReloadProfileEvent(request: ra.acceptance?.request?.id ?? ""),
        );
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(
            page: 3,
            widget: const ProviderRequestDetailPage(),
          ),
        );
        break;
      case 2:
        if (ra.user == null) break;
        context.read<MessageBloc>().add(
          SetMessageReceiverEvent(profile: ra.user!),
        );
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(page: 4, widget: const ChatPage()),
        );
        break;
      case 3:
        context.read<MessageBloc>().add(
          CalenderAppointmentEvent(setAppointment: true),
        );
        if (ra.user == null) break;
        context.read<MessageBloc>().add(
          SetMessageReceiverEvent(profile: ra.user!),
        );
        context.read<ProviderBloc>().add(
          NavigateProviderEvent(page: 4, widget: const ChatPage()),
        );
        break;
      case 4:
        if (ra.acceptance?.request?.id == null) break;
        _showCancelConfirmation(context, ra);
        break;
      case 5:
        if (ra.acceptance?.request == null) break;
        await Helpers.getLocation();
        context.read<ProviderBloc>().add(
          RequestDirectionEvent(request: ra.acceptance!.request!),
        );
        Get.toNamed("/map-direction");
        break;
    }
  }

  void _showCancelConfirmation(BuildContext context, RequestAcceptance ra) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Cancel Interest?",
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E1E2E),
          ),
        ),
        content: Text(
          "Are you sure you want to withdraw your interest from this request?",
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Keep It",
              style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProviderBloc>().add(
                CancelRequestAcceptEvent(
                  requestAccept: RequestAccept(
                    serviceRequestId: ra.acceptance!.request!.id!,
                    proposalId: ra.acceptance!.id,
                    uid: ra.user!.user!.id!,
                  ),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Withdraw",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<int>> _buildMenuItems(bool isDark) {
    return [
      _buildMenuItem(
        1,
        Icons.visibility_rounded,
        "View Details",
        Colors.blueAccent,
        isDark,
      ),
      _buildMenuItem(
        2,
        Icons.chat_bubble_rounded,
        "Chat",
        Colors.greenAccent,
        isDark,
      ),
      _buildMenuItem(
        3,
        Icons.calendar_month_rounded,
        "Schedule",
        Colors.purpleAccent,
        isDark,
      ),
      _buildMenuItem(
        4,
        Icons.cancel_rounded,
        "Cancel",
        Colors.redAccent,
        isDark,
      ),
      _buildMenuItem(
        5,
        Icons.directions_rounded,
        "Directions",
        Colors.orangeAccent,
        isDark,
      ),
    ];
  }

  PopupMenuItem<int> _buildMenuItem(
    int value,
    IconData icon,
    String text,
    Color color,
    bool isDark,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E1E2E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
