import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/request_accept.dart';
import '../../../../core/models/request_acceptance.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';
import '../../../messages/presentation/pages/chat_page.dart';
import 'package:nsapp/core/core.dart';

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
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.secondaryTextColor;
    final cardColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;

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
                  constraints: BoxConstraints(maxWidth: 800.w),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ACCEPTED REQUESTS",
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "MANAGE YOUR ACTIVE PROJECTS AND PROGRESS",
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w900,
                                  color: secondaryTextColor,
                                  letterSpacing: 0.8,
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(48.r),
                                        decoration: BoxDecoration(
                                          color: cardColor,
                                          borderRadius: BorderRadius.circular(
                                            32.r,
                                          ),
                                          border: Border.all(
                                            color: borderColor,
                                            width: 1.5.r,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(24.r),
                                              decoration: BoxDecoration(
                                                color: context.appColors.cardBackground,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                FontAwesomeIcons.clockRotateLeft,
                                                size: 64.r,
                                                color: context.appColors.glassBorder,
                                              ),
                                            ),
                                            SizedBox(height: 32.h),
                                            Text(
                                              "No accepted requests",
                                              style: TextStyle(
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.w900,
                                                color: textColor,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                            Text(
                                              "You haven't accepted any service requests yet.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                color: context.appColors.glassBorder,
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
                                    horizontal: isLargeScreen ? 32.w : 16.w,
                                    vertical: 8.h,
                                  ),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return _buildRequestCard(
                                      context,
                                      snapshot.data![index],
                                      index,
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
 
  ) {
    final textColor = context.appColors.primaryTextColor;
    final cardColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;

    final request = requestAcceptance.acceptance!.request;
    if (request == null) return const SizedBox.shrink();

    final user = requestAcceptance.user;
    if (user == null) return const SizedBox.shrink();

    final isApproved = request.approved ?? false;
    final isAssignedToMe =
        request.approvedUser == SuccessGetProfileState.profile.user?.id;
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
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: borderColor,
            width: 1.5.r,
          ),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                  child: (request.withImage ?? false)
                      ? Image.network(
                          request.imageUrl ?? "",
                          width: double.infinity,
                          height: 140.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: double.infinity,
                                height: 140.h,
                                color: context.appColors.primaryColor.withAlpha(50),
                                child: Icon(
                                  FontAwesomeIcons.image,
                                  color: context.appColors.primaryColor,
                                ),
                              ),
                        )
                      : Container(
                          width: double.infinity,
                          height: 140.h,
                          color: context.appColors.primaryColor.withAlpha(50),
                          child: Icon(
                            FontAwesomeIcons.fileLines,
                            color: context.appColors.primaryColor,
                            size: 40.r,
                          ),
                        ),
                ),
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.primaryColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(isApproved, isAssignedToMe, status),
                          size: 14.r,
                          color: context.appColors.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _getStatusText(isApproved, isAssignedToMe, status).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      cardColor: context.appColors.cardBackground,
                      iconTheme: IconThemeData(
                        color: context.appColors.primaryTextColor,
                      ),
                    ),
                    child: PopupMenuButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: context.appColors.cardBackground,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          FontAwesomeIcons.ellipsis,
                          color: context.appColors.primaryTextColor,
                          size: 20.r,
                        ),
                      ),
                      onSelected: (val) =>
                          _handleMenuAction(context, val, requestAcceptance),
                      itemBuilder: (context) => _buildMenuItems(),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26.r,
                    backgroundColor: context.appColors.glassBorder,
                    backgroundImage:
                        (user.profilePictureUrl != null &&
                            user.profilePictureUrl!.isNotEmpty)
                        ? NetworkImage(user.profilePictureUrl!)
                        : const AssetImage(logoAssets) as ImageProvider,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.title ?? "Project",
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          user.firstName ?? "Client",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: context.appColors.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    FontAwesomeIcons.chevronRight,
                    color: context.appColors.secondaryTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  IconData _getStatusIcon(bool isApproved, bool isAssignedToMe, String status) {
    // If assigned to me and in progress or done
    if (isAssignedToMe && isApproved) {
      if (status == 'DONE') return FontAwesomeIcons.circleCheck;
      if (status == 'IN_PROGRESS') return FontAwesomeIcons.clock;
      return FontAwesomeIcons.circleCheck;
    }
    // If approved but not assigned to me
    if (isApproved) return FontAwesomeIcons.ellipsis;
    // Waiting for approval
    return FontAwesomeIcons.hourglass;
  }

  String _getStatusText(bool isApproved, bool isAssignedToMe, String status) {
    // If assigned to me and in progress or done
    if (isAssignedToMe && isApproved) {
      if (status == 'DONE') return "COMPLETED";
      if (status == 'IN_PROGRESS') return "IN PROGRESS";
      return "ACTIVE TASK";
    }
    // If approved but not assigned to me
    if (isApproved) return "ASSIGNED TO OTHER";
    // Waiting for approval
    return "WAITING RESPONSE";
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.appColors.primaryBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          "CANCEL INTEREST?",
          style: TextStyle(
            color: context.appColors.primaryTextColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        content: Text(
          "Are you sure you want to withdraw your interest from this request?",
          style: TextStyle(color: context.appColors.secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Keep It",
              style: TextStyle(color: context.appColors.secondaryTextColor),
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
              backgroundColor: context.appColors.errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: const Text(
              "WITHDRAW",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<int>> _buildMenuItems() {
    return [
      _buildMenuItem(
        1,
        FontAwesomeIcons.eye,
        "View Details",
        context.appColors.primaryTextColor
       
      ),
      _buildMenuItem(
        2,
        FontAwesomeIcons.comment,
        "Chat",
        context.appColors.primaryTextColor
       
      ),
      _buildMenuItem(
        3,
        FontAwesomeIcons.calendar,
        "Schedule",
        context.appColors.primaryTextColor
      ),
      _buildMenuItem(
        4,
        FontAwesomeIcons.circleXmark,
        "Cancel",
        context.appColors.primaryTextColor
      ),
      _buildMenuItem(
        5,
        FontAwesomeIcons.directions,
        "Directions",
        context.appColors.primaryTextColor
      ),
    ];
  }

  PopupMenuItem<int> _buildMenuItem(
    int value,
    IconData icon,
    String text,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.r),
          SizedBox(width: 12.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: context.appColors.primaryTextColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


