import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/request_acceptance.dart';
import '../../../messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/core/core.dart';

class ProviderActiveTasksPage extends StatefulWidget {
  const ProviderActiveTasksPage({super.key});

  @override
  State<ProviderActiveTasksPage> createState() =>
      _ProviderActiveTasksPageState();
}

class _ProviderActiveTasksPageState
    extends State<ProviderActiveTasksPage>
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
        builder: (context, providerState) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final myId = (profileState is SuccessGetProfileState)
                  ? profileState.profile.user?.id
                  : null;

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
                                vertical: 10.h,
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => context.pop(),
                                    child: Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                          width: 1.5.r,
                                        ),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.chevronLeft,
                                        color: context.appColors.primaryTextColor,
                                        size: 18.r,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ACTIVE TASKS",
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "TASKS YOU HAVE BEEN APPROVED FOR",
                                        style: TextStyle(
                                          fontSize: 9.sp,
                                          fontWeight: FontWeight.w500,
                                          color: secondaryTextColor,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  context.read<ProviderBloc>().add(GetAcceptedRequestEvent());
                                  context.read<ProfileBloc>().add(GetProfileStreamEvent());
                                  context.read<ProfileBloc>().add(GetProfileEvent());
                                  await Future.delayed(const Duration(seconds: 1));
                                },
                                child: Builder(
                                  builder: (context) {
                                    final accepts = context.read<ProviderBloc>().myAcceptedRequests;

                                    final activeTasks = accepts.where((r) {
                                      final request = r.acceptance?.request;
                                      return request?.approved == true &&
                                             request?.approvedUser == myId;
                                    }).toList();

                                    if (providerState is LoadingProviderState && activeTasks.isEmpty) {
                                      return const LoadingWidget();
                                    }

                                    if (activeTasks.isEmpty) {
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
                                                    FontAwesomeIcons.briefcase,
                                                    size: 64.r,
                                                    color: context.appColors.glassBorder,
                                                  ),
                                                ),
                                                SizedBox(height: 32.h),
                                                Text(
                                                  "No active tasks",
                                                  style: TextStyle(
                                                    fontSize: 22.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: textColor,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                SizedBox(height: 12.h),
                                                Text(
                                                  "You have no tasks approved for you yet.",
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
                                      physics: const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isLargeScreen ? 32.w : 16.w,
                                        vertical: 8.h,
                                      ),
                                      itemCount: activeTasks.length,
                                      itemBuilder: (context, index) {
                                        return _buildRequestCard(
                                          context,
                                          activeTasks[index],
                                          index,
                                          myId,
                                        );
                                      },
                                  );
                                  },
                                ),
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
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    RequestAcceptance requestAcceptance,
    int index,
    String? myId,
  ) {
    final textColor = context.appColors.primaryTextColor;
    final cardColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;

    final request = requestAcceptance.acceptance!.request;
    if (request == null) return const SizedBox.shrink();

    final user = requestAcceptance.user;
    if (user == null) return const SizedBox.shrink();

    final isApproved = request.approved ?? false;
    final isAssignedToMe = request.approvedUser == myId;
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
        context.push('/app/provider/requests/${request.id}', extra: RequestData(
          request: requestAcceptance.acceptance!.request,
          user: requestAcceptance.user,
        ));
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (index * 100)),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(opacity: value, child: child),
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
                            fontWeight: FontWeight.w500,
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
                        : const AssetImage(person) as ImageProvider,
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
                            fontWeight: FontWeight.w500,
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
    ),
    );
  }


  IconData _getStatusIcon(bool isApproved, bool isAssignedToMe, String status) {
    if (isAssignedToMe && isApproved) {
      if (status == 'DONE') return FontAwesomeIcons.circleCheck;
      if (status == 'IN_PROGRESS') return FontAwesomeIcons.clock;
      return FontAwesomeIcons.circleCheck;
    }
    if (isApproved) return FontAwesomeIcons.ellipsis;
    return FontAwesomeIcons.hourglass;
  }

  String _getStatusText(bool isApproved, bool isAssignedToMe, String status) {
    if (isAssignedToMe && isApproved) {
      if (status == 'DONE') return "COMPLETED";
      if (status == 'IN_PROGRESS') return "IN PROGRESS";
      return "ACTIVE TASK";
    }
    if (isApproved) return "ASSIGNED TO OTHER";
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
        context.push('/app/provider/requests/${ra.acceptance!.request!.id}', extra: RequestData(
          request: ra.acceptance!.request,
          user: ra.user,
        ));
        break;
      case 2:
        if (ra.user == null) break;
        context.read<MessageBloc>().add(
          SetMessageReceiverEvent(profile: ra.user!),
        );
        context.push('/chat');
        break;
      case 3:
        context.read<MessageBloc>().add(
          CalenderAppointmentEvent(setAppointment: true),
        );
        if (ra.user == null) break;
        context.read<MessageBloc>().add(
          SetMessageReceiverEvent(profile: ra.user!),
        );
        context.push('/chat');
        break;
      case 5:
        if (ra.acceptance?.request == null) break;
        await Helpers.getLocation();
        context.read<ProviderBloc>().add(
          RequestDirectionEvent(request: ra.acceptance!.request!),
        );
        context.push("/map-direction");
        break;
    }
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
        5,
        FontAwesomeIcons.diamondTurnRight,
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
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


