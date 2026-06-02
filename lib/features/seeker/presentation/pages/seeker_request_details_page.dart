import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';

import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';

import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import '../../../shared/presentation/widget/custom_text_widget.dart';
import '../../../shared/presentation/widget/loading_view.dart';
import '../bloc/seeker_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/core/core.dart';

class SeekerRequestDetailsPage extends StatefulWidget {
  final String? requestId;
  final RequestData? requestData;
  const SeekerRequestDetailsPage({super.key, this.requestData, this.requestId});

  @override
  State<SeekerRequestDetailsPage> createState() =>
      _SeekerRequestDetailsPageState();
}

class _SeekerRequestDetailsPageState extends State<SeekerRequestDetailsPage> {
  late TextEditingController amountController;
  late GlobalKey<FormState> formKey;
  RequestData? _cachedRequestData;
  RequestAccept? _pendingApproval;

  @override
  void initState() {
    super.initState();
    _cachedRequestData = widget.requestData;
    final requestId = widget.requestData?.request?.id ?? widget.requestId ?? "";
    context.read<SeekerBloc>().add(ReloadRequestEvent(request: requestId));
    context.read<SeekerBloc>().add(
      GetAcceptedUsersSeekerEvent(request: requestId),
    );
    amountController = TextEditingController();
    formKey = GlobalKey<FormState>();
  }

  void _showSuccessCelebration(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: FadeInUp(
          child: SolidContainer(
            padding: EdgeInsets.all(32.r),
            width: MediaQuery.of(context).size.width * 0.85,
            borderRadius: BorderRadius.circular(32.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.circleCheck,
                    color: Colors.greenAccent,
                    size: 64.r,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "TASK COMPLETED!",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.primaryTextColor,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "Amazing work! You've just made your neighborhood a better place.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.appColors.secondaryTextColor,
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),
                SolidButton(
                  label: "REVIEW NEIGHBOR",
                  onPressed: () {
                    context.pop();
                    // Navigate to review flow
                  },
                  isPrimary: true,
                  height: 56.h,
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.push('/seeker-requests');
                  },
                  child: Text(
                    "NOT NOW",
                    style: TextStyle(
                      color: context.appColors.hintTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReschedulePromptDialog(BuildContext context, Request request) {
    DateTime? tempSelectedDate;
    final textColor = context.appColors.primaryTextColor;
    final hintColor = context.appColors.hintTextColor;
    final borderColor = context.appColors.glassBorder;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Center(
              child: FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: Material(
                  color: Colors.transparent,
                  child: SolidContainer(
                    padding: EdgeInsets.all(24.r),
                    width: MediaQuery.of(context).size.width * 0.85,
                    borderRadius: BorderRadius.circular(28.r),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: context.appColors.warningColor.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.clock,
                            color: context.appColors.warningColor,
                            size: 36.r,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "Schedule Time Due",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          "The scheduled time for this request has passed. Please select a new date and time before you accept the provider.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor.withAlpha(160),
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        GestureDetector(
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(const Duration(minutes: 5)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: context.appColors.primaryColor,
                                      onPrimary: Colors.white,
                                      surface: context.appColors.cardBackground,
                                      onSurface: textColor,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (date != null) {
                              if (!context.mounted) return;
                              TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: context.appColors.primaryColor,
                                        onPrimary: Colors.white,
                                        surface: context.appColors.cardBackground,
                                        onSurface: textColor,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setDialogState(() {
                                  tempSelectedDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: context.appColors.cardBackground,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: tempSelectedDate != null
                                    ? context.appColors.primaryColor
                                    : borderColor,
                                width: 1.5.r,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.calendarDay,
                                  color: tempSelectedDate != null
                                      ? context.appColors.primaryColor
                                      : hintColor,
                                  size: 18.r,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    tempSelectedDate != null
                                        ? DateFormat("EEEE, MMM dd, yyyy | h:mm a").format(tempSelectedDate!)
                                        : "Select New Date & Time",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: tempSelectedDate != null
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: tempSelectedDate != null
                                          ? textColor
                                          : hintColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  _pendingApproval = null;
                                  Navigator.of(dialogContext).pop();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r),
                                    side: BorderSide(color: borderColor),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: textColor.withAlpha(200),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: SolidButton(
                                label: "",
                                icon: FontAwesomeIcons.check,
                                onPressed: tempSelectedDate == null
                                    ? null
                                    : () {
                                        final updatedRequest = Request(
                                          id: request.id,
                                          title: request.title,
                                          description: request.description,
                                          userId: request.userId,
                                          service: request.service,
                                          serviceID: request.serviceID,
                                          approved: request.approved,
                                          address: request.address,
                                          longitude: request.longitude,
                                          latitude: request.latitude,
                                          withImage: request.withImage,
                                          done: request.done,
                                          imageUrl: request.imageUrl,
                                          approvedUser: request.approvedUser,
                                          createdAt: request.createdAt,
                                          updatedAt: request.updatedAt,
                                          version: request.version,
                                          distance: request.distance,
                                          status: request.status,
                                          proposalsCount: request.proposalsCount,
                                          appointmentId: request.appointmentId,
                                          isFunded: request.isFunded,
                                          price: request.price,
                                          targetProviderId: request.targetProviderId,
                                          paymentMode: request.paymentMode,
                                          scheduledTime: tempSelectedDate,
                                        );
                                        Navigator.of(dialogContext).pop();
                                        context.read<SeekerBloc>().add(
                                              UpdateRequestEvent(request: updatedRequest),
                                            );
                                      },
                                height: 50.h,
                                color: context.appColors.primaryColor,
                                textColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    String userType = "seeker";
    if (profileState is SuccessGetProfileState) {
      userType = profileState.profile.userType ?? "seeker";
    } else if (profileState is SuccessGetProfileStreamState) {
      userType = profileState.profile.userType ?? "seeker";
    }
    final isProvider = Helpers.isProvider(userType);
    
    final textColor = context.appColors.primaryTextColor;
    final buttonColor = context.appColors.glassBorder;
    final borderColor = context.appColors.glassBorder;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: BlocConsumer<SeekerBloc, SeekerState>(
            buildWhen: (previous, current) =>
                current is SuccessReloadRequestState ||
                current is LoadingSeekerState ||
                current is FailureReloadRequestState ||
                current is SeekerRequestDetailState ||
                current is SuccessMarkAsDoneState ||
                current is SuccessApprovedProviderState ||
                current is SuccessCancelApprovedProviderState ||
                current is SuccessUpdateRequestState ||
                current is FailureUpdateRequestState,
            listener: (context, state) {
              if (state is SuccessDeleteRequestState) {
                context.push('/seeker-requests');
                customAlert(
                  context,
                  AlertType.success,
                  "Request Deleted Successfully",
                );
              }
              if (state is FailureDeleteRequestState) {
                customAlert(context, AlertType.error, "Request Delete Failed");
              }
              if (state is SuccessApprovedProviderState) {
                context.read<SeekerBloc>().add(
                  GetAcceptedUsersSeekerEvent(
                    request: widget.requestData?.request?.id ?? widget.requestId ?? "",
                  ),
                );
                customAlert(
                  context,
                  AlertType.success,
                  "Provider Acceptance Approved",
                );
              }
              if (state is FailureApprovedProviderState) {
                context.read<SeekerBloc>().add(
                  GetAcceptedUsersSeekerEvent(
                    request: widget.requestData?.request?.id ?? widget.requestId ?? "",
                  ),
                );
                customAlert(context, AlertType.error, "Unable to Approve");
              }
              if (state is SuccessCancelApprovedProviderState) {
                context.read<SeekerBloc>().add(
                  GetAcceptedUsersSeekerEvent(
                    request: widget.requestData?.request?.id ?? widget.requestId ?? "",
                  ),
                );
                customAlert(
                  context,
                  AlertType.success,
                  "Provider Approval Canceled",
                );
              }
              if (state is FailureCancelApprovedProviderState) {
                context.read<SeekerBloc>().add(
                  GetAcceptedUsersSeekerEvent(
                    request: widget.requestData?.request?.id ?? widget.requestId ?? "",
                  ),
                );
                customAlert(context, AlertType.error, "Unable to Cancel Approval");
              }
              if (state is SuccessMarkAsDoneState) {
                HapticFeedback.heavyImpact();
                _showSuccessCelebration(context);
                // Refresh profile to update XP/Level
                context.read<ProfileBloc>().add(GetProfileEvent());
              }
              if (state is FailureMarkAsDoneState) {
                customAlert(context, AlertType.error, state.message ?? "Failed to mark as done");
              }
              if (state is SuccessUpdateRequestState) {
                final requestId = widget.requestData?.request?.id ?? widget.requestId ?? "";
                if (requestId.isNotEmpty) {
                  context.read<SeekerBloc>().add(ReloadRequestEvent(request: requestId));
                }
                if (_pendingApproval != null) {
                  final pending = _pendingApproval!;
                  _pendingApproval = null;
                  context.read<SeekerBloc>().add(
                    ApprovedRequestEvent(requestAccept: pending),
                  );
                } else {
                  customAlert(
                    context,
                    AlertType.success,
                    "Service Rescheduled Successfully",
                  );
                }
              }
              if (state is FailureUpdateRequestState) {
                _pendingApproval = null;
                customAlert(
                  context,
                  AlertType.error,
                  state.message ?? "Rescheduling Failed",
                );
              }
            },
            builder: (context, state) {
              if (state is SuccessReloadRequestState) {
                _cachedRequestData = state.request;
              } else if (state is SeekerRequestDetailState) {
                _cachedRequestData = state.request;
              }

              final requestData = _cachedRequestData;

              if (requestData != null) {
                return LoadingView(
                  isLoading: state is LoadingSeekerState,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 800.w),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          final requestId = widget.requestData?.request?.id ?? widget.requestId ?? "";
                          context.read<SeekerBloc>().add(ReloadRequestEvent(request: requestId));
                          context.read<SeekerBloc>().add(GetAcceptedUsersSeekerEvent(request: requestId));
                          context.read<ProfileBloc>().add(GetProfileStreamEvent());
                          context.read<ProfileBloc>().add(GetProfileEvent());
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        child: ListView(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 20.h,
                        ),
                        children: [
                          // Modified Header
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (Navigator.of(context).canPop()) {
                                    context.pop();
                                  } else {
                                    if (isProvider) {
                                      context.read<ProviderBloc>().add(
                                          ChangeProviderTabEvent(
                                              tabIndex: 1));
                                    } else {
                                      context.read<SeekerBloc>().add(
                                          ChangeSeekerTabEvent(
                                              tabIndex: 1));
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: buttonColor,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.5.r,
                                    ),
                                  ),
                                  child: FaIcon(
                                    FontAwesomeIcons.chevronLeft,
                                    color: textColor,
                                    size: 18.r,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Text(
                                "REQUEST DETAILS",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Spacer(),
                              _buildActionMenu(requestData, context),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          // Request Info Card
                          SolidContainer(
                            padding: EdgeInsets.all(24.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12.r),
                                      decoration: BoxDecoration(
                                        color:
                                            context.appColors.primaryColor
                                                .withAlpha(40),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.fileLines,
                                        color: context.appColors.primaryColor,
                                        size: 24.r,
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (requestData
                                                    .request
                                                    ?.service
                                                    ?.name ??
                                                "Service Request").toUpperCase(),
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          Text(
                                            requestData
                                                        .request
                                                        ?.createdAt !=
                                                    null
                                                ? DateFormat(
                                                    "EEEE, MMM d, yyyy",
                                                  ).format(
                                                    requestData
                                                        .request!
                                                        .createdAt!,
                                                  )
                                                : "",
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w400,
                                              color: context.appColors.hintTextColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Divider(
                                  color: borderColor.withAlpha(50),
                                  height: 1,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  (requestData.request?.title ?? "").toUpperCase(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  requestData.request?.description ??
                                      requestData.request?.title ??
                                      "",
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Divider(
                                  color: borderColor.withAlpha(50),
                                  height: 1,
                                ),
                                const SizedBox(height: 20),
                                // Row(
                                //   children: [
                                //     FaIcon(
                                //       FontAwesomeIcons.moneyBillWave,
                                //       color: context.appColors.primaryColor,
                                //       size: 18.r,
                                //     ),
                                //     SizedBox(width: 12.w),
                                //     Text(
                                //       "PAYMENT MODE:",
                                //       style: TextStyle(
                                //         color: context.appColors.hintTextColor,
                                //         fontSize: 12.sp,
                                //         fontWeight: FontWeight.w500,
                                //         letterSpacing: 0.5,
                                //       ),
                                //     ),
                                //     const Spacer(),
                                //     Text(
                                //       requestData.request?.paymentMode == 'ON_SITE' ? "ON-SITE" : "IN-APP",
                                //       style: TextStyle(
                                //         color: context.appColors.primaryColor,
                                //         fontSize: 13.sp,
                                //         fontWeight: FontWeight.w600,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          if (requestData.request?.withImage ?? false)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<CommonBloc>().add(
                                      SetViewImageEvent(
                                        url:
                                            requestData
                                                .request!
                                                .imageUrl ??
                                            "",
                                      ),
                                    );
                                    context.push("/image");
                                  },
                                  child: Hero(
                                    tag:
                                        'request_image_${requestData.request!.id}',
                                    child: Image.network(
                                      requestData.request?.imageUrl ??
                                          "",
                                      height: 350.h,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              height: 350.h,
                                              color: buttonColor,
                                                child: const Center(
                                                  child: SkeletonWidget(width: double.infinity, height: 350, borderRadius: 24),
                                              ),
                                            );
                                          },
                                      errorBuilder: (context, _, __) =>
                                          Container(
                                            height: 350,
                                            color: buttonColor,
                                            child: const Icon(
                                              Icons
                                                  .image_not_supported_rounded,
                                              color: Colors.white24,
                                              size: 50,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 32),

                          Text(
                            "INTERESTED PROVIDERS",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 16),

                          BlocBuilder<SeekerBloc, SeekerState>(
                            buildWhen: (previous, current) =>
                                current is SuccessAcceptedUsersState ||
                                current is FailureAcceptedUserstState ||
                                current is SuccessApprovedProviderState ||
                                current is SuccessCancelApprovedProviderState,
                            builder: (context, state) {
                              List<RequestAcceptance> acceptedProviders = [];
                              if (state is SuccessAcceptedUsersState) {
                                acceptedProviders = state.users;
                              }

                              // Check if any provider is approved
                              bool anyApproved = acceptedProviders.any((ap) {
                                var req = ap.acceptance?.request;
                                var usr = ap.provider?.user;
                                return (ap.acceptance?.isApproved == true) ||
                                    (req?.approvedUser != null &&
                                        req?.approvedUser == usr?.id);
                              });

                              // If any is approved, only show the approved one(s)
                              if (anyApproved) {
                                acceptedProviders = acceptedProviders.where((ap) {
                                  var req = ap.acceptance?.request;
                                  var usr = ap.provider?.user;
                                  return (ap.acceptance?.isApproved == true) ||
                                      (req?.approvedUser != null &&
                                          req?.approvedUser == usr?.id);
                                }).toList();
                              }

                              if (acceptedProviders.isNotEmpty) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  primary: false,
                                  physics:
                                      const NeverScrollableScrollPhysics(),
                                  itemCount: acceptedProviders.length,
                                  separatorBuilder: (context, index) =>
                                      SizedBox(height: 16.h),
                                  itemBuilder: (context, index) {
                                    return _buildAcceptedUserItem(
                                      acceptedProviders[index],
                                      context,
                                      index,
                                      state
                                    );
                                  },
                                );
                              } else if (state is LoadingSeekerState) {
                                return const ListSkeletonLoader();
                              } else {
                                return SolidContainer(
                                  padding: EdgeInsets.all(40.r),
                                  child: EmptyWidget(
                                    message:
                                        "No acceptance for your request yet!",
                                    height: 150.h,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                );
              } else if (state is LoadingSeekerState) {
                return const ProfileSkeletonLoader();
              } else if (state is FailureReloadRequestState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: context.appColors.errorColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.circleExclamation,
                          color: context.appColors.errorColor,
                          size: 60.r,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        state.message ?? "Error loading request",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SolidButton(
                        label: "Retry",
                        onPressed: () {
                          final currentState = context.read<SeekerBloc>().state;
                          String? rId;
                          if (currentState is SeekerRequestDetailState) {
                            rId = currentState.request.request?.id;
                          } else if (currentState is SuccessReloadRequestState) {
                            rId = currentState.request.request?.id;
                          }
                          
                          if (rId != null) {
                            context.read<SeekerBloc>().add(
                              ReloadRequestEvent(request: rId),
                            );
                          }
                        },
                        isPrimary: true,
                        height: 50.h,
                        width: 120.w,
                      ),
                    ],
                  ),
                );
              }

              return const ProfileSkeletonLoader();
            },
          ),
        ),
      ),
    );
  }

  // Widget _getStatusBadge(Request request) {
  //   Color color = context.appColors.warningColor;
  //   String text = "Pending";

  //   if (request.done == true || request.status == 'DONE') {
  //     color = context.appColors.warningColor;
  //     text = "Completed";
  //   } else if (request.status == 'IN_PROGRESS') {
  //     color = context.appColors.warningColor;
  //     text = "Active";
  //   } else if (request.approved == true) {
  //     if (request.isFunded == true) {
  //       color = context.appColors.warningColor;
  //       text = "Active";
  //     } else {
  //       color = context.appColors.warningColor;
  //       text = "Approved, Pending Funding";
  //     }
  //   }

  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //     decoration: BoxDecoration(
  //       color: context.appColors.warningColor.withAlpha(40),
  //       borderRadius: BorderRadius.circular(10),
  //       border: Border.all(color: color.withAlpha(150), width: 1.5),
  //     ),
  //     child: Text(
  //       text,
  //       style: TextStyle(
  //         color: color,
  //         fontSize: 11,
  //         fontWeight: FontWeight.w500,
  //         letterSpacing: 1.0,
  //       ),
  //     ),
  //   );
  // }

  void _showDeleteConfirmation(BuildContext context, String requestId) {
    final textColor = context.appColors.primaryTextColor;

    showDialog(
      context: context,
      builder: (context) => Center(
        child: SolidContainer(
          padding: EdgeInsets.all(24.r),
          width: MediaQuery.of(context).size.width * 0.8,
          borderRadius: BorderRadius.circular(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: context.appColors.errorColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child:  FaIcon(
                  FontAwesomeIcons.trashCan,
                  color: context.appColors.errorColor,
                  size: 32.r,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Delete Request?",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "This action cannot be undone. Are you sure you want to delete this service request?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withAlpha(160),
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: textColor.withAlpha(180)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SolidButton(
                      label: "Delete",
                      onPressed: () {
                        context.read<SeekerBloc>().add(
                          DeleteRequestEvent(request: requestId),
                        );
                        context.pop();
                      },
                      isPrimary: true,
                      height: 50.h,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(RequestData requestData, BuildContext context) {
    final cardColor = context.appColors.cardBackground;
    final iconColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;
    final menuIconBg = context.appColors.hintTextColor;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: cardColor,
        iconTheme: IconThemeData(color: iconColor),
        popupMenuTheme: PopupMenuThemeData(
          color: cardColor,
          textStyle: TextStyle(color: iconColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
      child: PopupMenuButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: menuIconBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: FaIcon(FontAwesomeIcons.ellipsis, color: iconColor, size: 20.r),
        ),
        onSelected: (val) {
          switch (val) {
            case 1:
              context.read<SeekerBloc>().add(
                SeekerRequestDetailEvent(request: requestData),
              );
              context.push('/seeker-requests'); // Placeholder for update request page if no route exists
              // Ideally: context.push('/edit-request');
              break;
            case 2:
              final requestId = requestData.request?.id;
              if (requestId != null) {
                _showDeleteConfirmation(context, requestId);
              }
              break;
            case 3:
              if (!(requestData.request?.approved ?? false) ||
                  requestData.request?.approvedUser == null) {
                customAlert(
                  context,
                  AlertType.warning,
                  "Request not approved or no provider assigned",
                );
              } else {
                // Use the user ID from request.approvedUser (which is already extracted)
                final providerUserId = requestData.request?.approvedUser;
                if (providerUserId != null &&
                    requestData.approvedUser != null) {
                  context.read<SeekerBloc>().add(
                    SetProviderToReviewEvent(
                      provider: requestData.approvedUser!,
                      providerUserId: providerUserId,
                    ),
                  );
                  context.read<SeekerBloc>().add(
                    MarkAsDoneEvent(request: requestData.request!),
                  );
                } else {
                  customAlert(
                    context,
                    AlertType.warning,
                    "Provider details not found.",
                  );
                }
              }
              break;
            case 4:
              _showFundingDialog(context, requestData);
              break;
          }
        },
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.penToSquare, color: appBlueCardColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "EDIT",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.trashCan, color: context.appColors.errorColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "DELETE",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.circleCheck, color: context.appColors.successColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "MARK AS DONE",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (requestData.request?.paymentMode != 'ON_SITE')
            PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.vault, color: context.appColors.secondaryColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "FUND PROJECT",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget _buildAcceptedUserItem(
    RequestAcceptance acceptedProvider,
    BuildContext context,
    int index,
    SeekerState state
  ) {
    final provider = acceptedProvider.provider;
    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;
    final avatarBg = context.appColors.glassBorder;

    return SolidContainer(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2.r),
            ),
            child: CircleAvatar(
              radius: 28.r,
              backgroundColor: avatarBg,
              backgroundImage:
                  (provider?.profilePictureUrl != null &&
                      provider!.profilePictureUrl!.isNotEmpty &&
                      provider.profilePictureUrl!.startsWith("http"))
                  ? NetworkImage(provider.profilePictureUrl!)
                  : const AssetImage(person) as ImageProvider,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (provider?.firstName ?? "Unknown").toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                     FaIcon(
                      FontAwesomeIcons.star,
                      color: context.appColors.warningColor,
                      size: 16.r,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      "4.8", // Hardcoded for design
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: textColor.withAlpha(140),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildApprovalButton(acceptedProvider, context, state),
              SizedBox(width: 4.w),
              _buildAcceptedUserMenu(acceptedProvider, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalButton(
    RequestAcceptance acceptedProvider,
    BuildContext context,
    SeekerState state
  ) {
    var request = acceptedProvider.acceptance?.request;
    var provider = acceptedProvider.provider;
    var user = provider?.user;

    bool isApproved =
        (acceptedProvider.acceptance?.isApproved ?? false) ||
        (request?.approvedUser != null && request?.approvedUser == user?.id);

    if (isApproved) {
      return IconButton(
        onPressed: () {
          final requestId = widget.requestData?.request?.id ?? widget.requestId ?? "";
          if (requestId.isNotEmpty) {
            context.read<SeekerBloc>().add(
              CancelApprovedRequestEvent(request: requestId),
            );
          }
        },
        icon: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: context.appColors.primaryColor.withAlpha(40),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: FaIcon(
            FontAwesomeIcons.circleXmark,
            color: context.appColors.errorColor,
          ),
        ),
        tooltip: "Cancel Approval",
      );
    } else {
      bool hasApprovedUser =
          request?.approvedUser != null && request!.approvedUser!.isNotEmpty;
      if (hasApprovedUser) {
        return const SizedBox.shrink();
      }
      return IconButton(
        onPressed: () {
          final requestId = widget.requestData?.request?.id ?? widget.requestId ?? "";
          final proposalId = acceptedProvider.acceptance?.id;
          final userId = user?.id ?? provider?.id ?? "unknown";

          if (requestId.isEmpty) {
            customAlert(
              context,
              AlertType.error,
              "Unable to approve: Request ID is missing.",
            );
            return;
          }

          if (proposalId == null) {
            customAlert(
              context,
              AlertType.error,
              "Unable to approve: Proposal ID is missing.",
            );
            return;
          }

          final requestObj = _cachedRequestData?.request;
          if (requestObj != null) {
            final scheduledTime = requestObj.scheduledTime;
            final now = DateTime.now();
            
            if (scheduledTime != null && scheduledTime.isBefore(now)) {
              // Store pending approval parameters
              _pendingApproval = RequestAccept(
                serviceRequestId: requestId,
                proposalId: proposalId,
                uid: userId,
              );
              // Show prompt dialog to reschedule before proceeding
              _showReschedulePromptDialog(context, requestObj);
              return;
            }
          }

          context.read<SeekerBloc>().add(
            ApprovedRequestEvent(
              requestAccept: RequestAccept(
                serviceRequestId: requestId,
                proposalId: proposalId,
                uid: userId,
              ),
            ),
          );
        },
        icon: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: context.appColors.primaryColor.withAlpha(40),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: FaIcon(
            FontAwesomeIcons.circleCheck,
            color: context.appColors.primaryColor,
          ),
        ),
        tooltip: "Approve Provider",
      );
    }
  }

  Widget _buildAcceptedUserMenu(
    RequestAcceptance acceptedProvider,
    BuildContext context,
  ) {
    final cardColor = context.appColors.primaryBackground;
    final iconColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: cardColor,
        iconTheme: IconThemeData(color: iconColor),
        popupMenuTheme: PopupMenuThemeData(
          color: cardColor,
          textStyle: TextStyle(color: iconColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: borderColor),
          ),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(1.r),
        decoration: BoxDecoration(
          color: context.appColors.primaryColor.withAlpha(40),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: PopupMenuButton(
          icon: FaIcon(FontAwesomeIcons.ellipsisVertical, color: iconColor.withAlpha(160)),
          onSelected: (val) {
            final provider = acceptedProvider.provider;
            final userId = provider?.user?.id;
        
            if (val == 1) {
              if (userId != null) {
                context.push('/portfolio-view', extra: provider);
              }
            } else if (val == 2) {
              if (provider != null) {
                context.read<MessageBloc>().add(
                  SetMessageReceiverEvent(profile: provider),
                );
                context.push('/chat');
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                   FaIcon(
                    FontAwesomeIcons.eye,
                    color: context.appColors.infoColor,
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "ABOUT",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                   FaIcon(
                    FontAwesomeIcons.comment,
                    color: context.appColors.successColor,
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "CHAT",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFundingDialog(BuildContext context, RequestData requestData) {
    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;

    if (!(requestData.request?.approved ?? false)) {
      customAlert(
        context,
        AlertType.warning,
        "No service provider have been approved for this request",
      );
      return;
    }

    if (requestData.request?.appointmentId == null) {
      customAlert(
        context,
        AlertType.warning,
        "No appointment has been created yet for this approved provider.",
      );
      return;
    }

    if (requestData.request?.isFunded == true) {
      customAlert(
        context,
        AlertType.warning,
        "This project has already been funded.",
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        if (requestData.request?.price != null) {
          amountController.text = requestData.request!.price!.toString();
        }

        return Material(
          color: Colors.transparent,
          child: Center(
            child: SolidContainer(
              padding: EdgeInsets.all(24.r),
              width: MediaQuery.of(context).size.width * 0.85,
              borderRadius: BorderRadius.circular(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomTextWidget(
                          text: "FUND PROJECT & SECURE PROVIDER",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                        SizedBox(height: 12.h),
                        CustomTextWidget(
                          text:
                              "Funds will be held in escrow until you mark the job as completed.",
                          fontSize: 13.sp,
                          color: textColor.withAlpha(180),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        SolidTextField(
                          controller: amountController,
                          hintText: "Amount (\$)",
                          label: "Amount (\$)",
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Amount is required";
                            } else if (double.tryParse(val) == null) {
                              return "Amount entered is invalid";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => context.pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: textColor.withAlpha(200),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: SolidButton(
                          label: "Fund Now",
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              if (amountController.text.isNotEmpty) {
                                context.pop();
                                await PaymentService.fundAppointment(
                                  appointmentId:
                                      requestData.request!.appointmentId!,
                                  amount: amountController.text,
                                  context: context,
                                );
                                // Refresh
                                if (context.mounted) {
                                  final rId = requestData.request?.id;
                                  if (rId != null) {
                                    context.read<SeekerBloc>().add(
                                      ReloadRequestEvent(request: rId),
                                    );
                                  }
                                }
                              }
                            }
                          },
                          height: 50.h,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}








