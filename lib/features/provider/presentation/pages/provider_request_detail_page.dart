import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/pages/chat_page.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/subscribe_dialog_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import '../../../shared/presentation/bloc/shared_bloc.dart';
import '../../../shared/presentation/widget/loading_widget.dart';

class ProviderRequestDetailPage extends StatefulWidget {
  const ProviderRequestDetailPage({super.key});

  @override
  State<ProviderRequestDetailPage> createState() =>
      _ProviderRequestDetailPageState();
}

class _ProviderRequestDetailPageState extends State<ProviderRequestDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(
      IsRequestAcceptedEvent(
        id: RequestDetailState.requestData.request?.id ?? "",
      ),
    );

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
    final request = RequestDetailState.requestData.request;
    final user = RequestDetailState.requestData.user;

    if (request == null || user == null) {
      return const Scaffold(body: Center(child: Text("Request not found")));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is SuccessRequestAcceptState) {
            customAlert(context, AlertType.success, "Request Accepted");
            setState(() {});
            context.read<ProviderBloc>().add(
              IsRequestAcceptedEvent(id: request.id ?? ""),
            );
          }
          if (state is SuccessRequestCancelState) {
            customAlert(context, AlertType.success, "Request Canceled");
            setState(() {});
            context.read<ProviderBloc>().add(
              IsRequestAcceptedEvent(id: request.id ?? ""),
            );
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingProviderState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
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
                                    context.read<ProviderBloc>().add(
                                      ProviderBackPressedEvent(),
                                    );
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
                                    fontWeight: FontWeight.w900,
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
                                    context.read<ProviderBloc>().add(
                                      NavigateProviderEvent(
                                        page: 4,
                                        widget: const ChatPage(),
                                      ),
                                    );
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
          );
        },
      ),
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
                        context.read<SharedBloc>().add(
                          SetViewImageEvent(url: request.imageUrl ?? ""),
                        );
                        Get.toNamed("/image");
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
                              child: const Center(child: LoadingWidget()),
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
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                 
                ),
              ),
            ),
            if (!hasImage)
              Center(
                child: Text(
                  "NO IMAGE PROVIDED",
                  style: TextStyle(
                    color: context.appColors.primaryTextColor,
                    letterSpacing: 2,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
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
                        fontWeight: FontWeight.w900,
                        color: context.appColors.primaryTextColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    _buildStatusBadge(
                      request.status ??
                          (request.done == true ? "DONE" : "OPEN"),
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
                          fontWeight: FontWeight.w900,
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
                  fontWeight: FontWeight.w900,
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
              fontWeight: FontWeight.w900,
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
    final isAccepted = IsRequestAcceptedState.accepted;

    return SolidButton(
      label: isAccepted ? "CANCEL INTEREST" : "ACCEPT & PROPOSE",
      allCaps: true,
      textColor: Colors.white,
      onPressed: () => isAccepted
          ? _cancelRequest(context, request)
          : _acceptRequest(context, request),
      isPrimary: !isAccepted,
      height: 60.h,
    );
  }

  void _acceptRequest(BuildContext context, dynamic request) {
    if (ValidUserSubscriptionState.isValid) {
      context.read<ProviderBloc>().add(
        RequestAcceptEvent(
          requestAccept: RequestAccept(
            serviceRequestId: request.id ?? "",
            uid: SuccessGetProfileState.profile.user?.id ?? "",
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
    context.read<ProviderBloc>().add(
      CancelRequestAcceptEvent(
        requestAccept: RequestAccept(
          serviceRequestId: request.id ?? "",
          uid: SuccessGetProfileState.profile.user?.id ?? "",
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toUpperCase()) {
      case 'DONE':
        color = context.appColors.infoColor;
        icon = FontAwesomeIcons.circleCheck;
        break;
      case 'IN_PROGRESS':
        color = context.appColors.warningColor;
        icon = FontAwesomeIcons.hourglass;
        break;
      case 'CANCELLED':
        color = context.appColors.errorColor;
        icon = FontAwesomeIcons.circleXmark;
        break;
      default:
        color = context.appColors.successColor;
        icon = FontAwesomeIcons.certificate;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withAlpha(150), width: 1.5.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: color),
          SizedBox(width: 6.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


