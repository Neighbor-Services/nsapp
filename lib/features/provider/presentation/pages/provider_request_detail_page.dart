import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/subscribe_dialog_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';

class ProviderRequestDetailPage extends StatefulWidget {
  final String? requestId;
  final RequestData? requestData;
  const ProviderRequestDetailPage({super.key, this.requestId, this.requestData});

  @override
  State<ProviderRequestDetailPage> createState() =>
      _ProviderRequestDetailPageState();
}

class _ProviderRequestDetailPageState extends State<ProviderRequestDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isAccepted = false;
  bool _isSubscriptionValid = false;
  @override
  void initState() {
    super.initState();
    
    final profileState = context.read<ProfileBloc>().state;
    String? uid;
    if (profileState is SuccessGetProfileState) {
      uid = profileState.profile.user?.id;
    }

    final selectedRequest = widget.requestData ?? context.read<ProviderBloc>().selectedRequest;
    final requestId = selectedRequest?.request?.id ?? widget.requestId;

    if (requestId != null) {
      context.read<ProviderBloc>().add(
        IsRequestAcceptedEvent(
          id: requestId,
          uid: uid,
        ),
      );
    }

    context.read<SubscriptionBloc>().add(CheckUserSubscriptionEvent());

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
      backgroundColor: Colors.transparent,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProviderBloc, ProviderState>(
            listener: (context, state) {
              if (state is SuccessRequestAcceptState) {
                customAlert(context, AlertType.success, "Request Accepted");
                _refreshStatus(state.requestAccept.serviceRequestId);
              } else if (state is SuccessRequestCancelState) {
                customAlert(context, AlertType.success, "Request Canceled");
                _refreshStatus(state.requestAccept.serviceRequestId);
              } else if (state is IsRequestAcceptedState) {
                setState(() => _isAccepted = state.accepted);
              }
            },
          ),
          BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is ValidUserSubscriptionState) {
                setState(() => _isSubscriptionValid = state.isValid);
              }
            },
          ),
        ],
        child: BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, state) {
            final requestData = widget.requestData ?? context.read<ProviderBloc>().selectedRequest;

            if (requestData == null) {
              if (state is LoadingProviderState) {
                return const Scaffold(body: ProfileSkeletonLoader());
              }
              return const Scaffold(body: Center(child: Text("Request not found")));
            }

            final request = requestData.request;
            final user = requestData.user;

            if (request == null || user == null) {
              return const Scaffold(body: Center(child: Text("Request data incomplete")));
            }

            return LoadingView(
              isLoading: (state is LoadingProviderState),
              child: GradientBackground(
                child: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 700.w),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            final requestId = requestData.request?.id;
                            if (requestId != null) {
                              context.read<ProviderBloc>().add(GetRequestDetailEvent(id: requestId));
                            }
                            context.read<ProfileBloc>().add(GetProfileStreamEvent());
                            context.read<ProfileBloc>().add(GetProfileEvent());
                            await Future.delayed(const Duration(seconds: 1));
                          },
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 32.w : 16.w,
                            vertical: 20.h,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context.pop();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(14.r),
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                          width: 1.5.r,
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
                                    "REQUEST DETAILS",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: context.appColors.primaryTextColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      context.read<MessageBloc>().add(
                                        SetMessageReceiverEvent(profile: user),
                                      );
                                      context.push('/chat');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color: context.appColors.primaryColor,
                                        borderRadius: BorderRadius.circular(14.r),
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.comment,
                                        color: Colors.white,
                                        size: 20.r,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 28.h),

                              // Image Card
                              _buildImageCard(request, isDark),
                              SizedBox(height: 24.h),

                              // User Info Card
                              _buildUserInfoCard(user, request, isDark),
                              SizedBox(height: 20.h),

                              // Request Details Card
                              _buildRequestDetailsCard(request, isDark),
                              SizedBox(height: 32.h),

                              // Action Button
                              _buildActionButton(context, request, isDark),
                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                        ),
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

  void _refreshStatus(String requestId) {
    final profileState = context.read<ProfileBloc>().state;
    String? uid;
    if (profileState is SuccessGetProfileState) {
      uid = profileState.profile.user?.id;
    }
    context.read<ProviderBloc>().add(
      IsRequestAcceptedEvent(id: requestId, uid: uid),
    );
  }


  Widget _buildImageCard(dynamic request, bool isDark) {
    bool hasImage = request.withImage ?? false;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        
        border: Border.all(
          color: context.appColors.glassBorder,
          width: 1.5.r,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Stack(
          children: [
            SizedBox(
              height: 280.h,
              width: double.infinity,
              child: hasImage
                  ? GestureDetector(
                      onTap: () {
                        context.read<CommonBloc>().add(
                          SetViewImageEvent(url: request.imageUrl ?? ""),
                        );
                        context.push("/image");
                      },
                      child: Hero(
                        tag: 'request_image_${request.id}',
                        child: Image.network(
                          request.imageUrl ?? "",
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.white.withAlpha(10),
                              child: const SkeletonWidget(width: double.infinity, height: 280, borderRadius: 28),
                            );
                          },
                          errorBuilder: (context, _, __) => Container(
                            color: Colors.white.withAlpha(10),
                            child: Center(
                              child: Icon(
                                FontAwesomeIcons.image,
                                color: Colors.white24,
                                size: 50.r,
                               ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Image.asset(logoAssets, fit: BoxFit.cover),
            ),
            if (!hasImage)
              Center(
                child: Text(
                  "NO IMAGE PROVIDED",
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    letterSpacing: 2,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic user, dynamic request, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: context.appColors.glassBorder,
          width: 1.5.r,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(40), width: 2.r),
            ),
            child: CircleAvatar(
              radius: 30.r,
              backgroundColor: context.appColors.glassBorder,
              backgroundImage:
                  (user.profilePictureUrl != null &&
                      user.profilePictureUrl != "")
                  ? NetworkImage(user.profilePictureUrl!)
                  : const AssetImage(logo2Assets) as ImageProvider,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (user.firstName ?? "User").toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: context.appColors.primaryTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.primaryColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: context.appColors.primaryColor.withAlpha(50),
                        ),
                      ),
                      child: Text(
                        (request.service?.name ?? "Service").toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      DateFormat(
                        "MMM dd, yyyy",
                      ).format(request.createdAt ?? DateTime.now()),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.appColors.secondaryTextColor,
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
  }

  Widget _buildRequestDetailsCard(dynamic request, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: context.appColors.glassBorder,
          width: 1.5.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Icon(
                FontAwesomeIcons.circleInfo,
                color: context.appColors.primaryColor,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                "REQUEST SUMMARY",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: context.appColors.secondaryTextColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Text(
            (request.title ?? "Service Request").toUpperCase(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: context.appColors.primaryTextColor,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            request.description ?? "",
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.6,
              color: context.appColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    dynamic request,
    bool isDark,
  ) {
    final isApproved = request.approved ?? false;

    if (isApproved) {
      final profileState = context.read<ProfileBloc>().state;
      String? myId;
      if (profileState is SuccessGetProfileState) {
        myId = profileState.profile.user?.id;
      }

      final isAssignedToMe = request.approvedUser == myId;
      return SolidButton(
        label: isAssignedToMe ? "TASK ACTIVE" : "ASSIGNED TO ANOTHER",
        allCaps: true,
        textColor: Colors.white,
        onPressed: () {},
        color: context.appColors.hintTextColor,
        height: 60.h,
      );
    }

    return SolidButton(
      label: _isAccepted ? "CANCEL INTEREST" : "ACCEPT & PROPOSE",
      allCaps: true,
      textColor: Colors.white,
      onPressed: () => _isAccepted
          ? _cancelRequest(context, request)
          : _acceptRequest(context, request),
      isPrimary: !_isAccepted,
      height: 60.h,
    );
  }

  void _acceptRequest(BuildContext context, dynamic request) {
    if (_isSubscriptionValid) {
      final profileState = context.read<ProfileBloc>().state;
      String? myId;
      if (profileState is SuccessGetProfileState) {
        myId = profileState.profile.user?.id;
      }

      context.read<ProviderBloc>().add(
        RequestAcceptEvent(
          requestAccept: RequestAccept(
            serviceRequestId: request.id ?? "",
            uid: myId ?? "",
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => const SubscribeDialogWidget(),
      );
    }
  }

  void _cancelRequest(BuildContext context, dynamic request) {
    final profileState = context.read<ProfileBloc>().state;
    String? myId;
    if (profileState is SuccessGetProfileState) {
      myId = profileState.profile.user?.id;
    }

    context.read<ProviderBloc>().add(
      CancelRequestAcceptEvent(
        requestAccept: RequestAccept(
          serviceRequestId: request.id ?? "",
          uid: myId ?? "",
        ),
      ),
    );
  }

  // Widget _buildStatusBadge(String status) {
  //   Color color;
  //   IconData icon;
  //   switch (status.toUpperCase()) {
  //     case 'DONE':
  //       color = context.appColors.infoColor;
  //       icon = FontAwesomeIcons.circleCheck;
  //       break;
  //     case 'IN_PROGRESS':
  //       color = context.appColors.warningColor;
  //       icon = FontAwesomeIcons.hourglass;
  //       break;
  //     case 'CANCELLED':
  //       color = context.appColors.errorColor;
  //       icon = FontAwesomeIcons.circleXmark;
  //       break;
  //     default:
  //       color = context.appColors.successColor;
  //       icon = FontAwesomeIcons.certificate;
  //   }

  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
  //     decoration: BoxDecoration(
  //       color: context.appColors.cardBackground,
  //       borderRadius: BorderRadius.circular(10.r),
  //       border: Border.all(color: color.withAlpha(150), width: 1.5.r),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(icon, size: 14.r, color: color),
  //         SizedBox(width: 6.w),
  //         Text(
  //           status.toUpperCase(),
  //           style: TextStyle(
  //             fontSize: 10.sp,
  //             fontWeight: FontWeight.w500,
  //             color: color,
  //             letterSpacing: 0.5,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}


