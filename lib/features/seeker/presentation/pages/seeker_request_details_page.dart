import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/pages/chat_page.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/profile/presentation/pages/about_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_update_request_page.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';

import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import '../../../shared/presentation/bloc/shared_bloc.dart';
import '../../../shared/presentation/widget/custom_text_widget.dart';
import '../../../shared/presentation/widget/loading_view.dart';
import '../bloc/seeker_bloc.dart';
import 'package:nsapp/core/core.dart';

class SeekerRequestDetailsPage extends StatefulWidget {
  const SeekerRequestDetailsPage({super.key});

  @override
  State<SeekerRequestDetailsPage> createState() =>
      _SeekerRequestDetailsPageState();
}

class _SeekerRequestDetailsPageState extends State<SeekerRequestDetailsPage> {
  late TextEditingController amountController;
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    final requestId = SeekerRequestDetailState.request.request?.id ?? "";
    context.read<SeekerBloc>().add(ReloadRequestEvent(request: requestId));
    context.read<SeekerBloc>().add(
      GetAcceptedUsersSeekerEvent(request: requestId),
    );
    amountController = TextEditingController();
    formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final buttonColor = context.appColors.glassBorder;
    final borderColor = context.appColors.glassBorder;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: BlocConsumer<SeekerBloc, SeekerState>(
            listener: (context, state) {
              if (state is SuccessDeleteRequestState) {
                context.read<SeekerBloc>().add(
                  NavigateSeekerEvent(
                    page: NavigatorSeekerState.page,
                    widget: SeekerRequestPage(),
                  ),
                );
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
                    request: SeekerRequestDetailState.request.request?.id ?? "",
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
                    request: SeekerRequestDetailState.request.request?.id ?? "",
                  ),
                );
                customAlert(context, AlertType.error, "Unable to Approve");
              }
              if (state is SuccessCancelApprovedProviderState) {
                context.read<SeekerBloc>().add(
                  GetAcceptedUsersSeekerEvent(
                    request: SeekerRequestDetailState.request.request?.id ?? "",
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
                    request: SeekerRequestDetailState.request.request?.id ?? "",
                  ),
                );
              }
            },
            builder: (context, state) {
              return LoadingView(
                isLoading: (state is LoadingSeekerState),
                child: FutureBuilder<RequestData>(
                  future: SuccessReloadRequestState.request,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
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
                              child:  Icon(
                                Icons.error_outline_rounded,
                                color: context.appColors.errorColor,
                                size: 60.r,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              "Failed to load request details",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            SolidButton(
                              label: "Retry",
                              onPressed: () {
                                context.read<SeekerBloc>().add(
                                  ReloadRequestEvent(
                                    request:
                                        SeekerRequestDetailState
                                            .request
                                            .request
                                            ?.id ??
                                        "",
                                  ),
                                );
                              },
                              isPrimary: true,
                              height: 50.h,
                              width: 120.w,
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 800.w),
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
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
                                      context.read<SeekerBloc>().add(
                                        SeekerBackPressedEvent(),
                                      );
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
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: textColor,
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
                                      color: textColor,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const Spacer(),
                                  _buildActionMenu(snapshot.data!, context),
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
                                          child: Icon(
                                            Icons.assignment_rounded,
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
                                                (snapshot
                                                        .data
                                                        ?.request
                                                        ?.service
                                                        ?.name ??
                                                    "Service Request").toUpperCase(),
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                snapshot
                                                            .data
                                                            ?.request
                                                            ?.createdAt !=
                                                        null
                                                    ? DateFormat(
                                                        "EEEE, MMM d, yyyy",
                                                      ).format(
                                                        snapshot
                                                            .data!
                                                            .request!
                                                            .createdAt!,
                                                      )
                                                    : "",
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
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
                                      (snapshot.data?.request?.title ?? "").toUpperCase(),
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      snapshot.data?.request?.description ??
                                          snapshot.data?.request?.title ??
                                          "",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              if (snapshot.data?.request?.withImage ?? false)
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
                                        context.read<SharedBloc>().add(
                                          SetViewImageEvent(
                                            url:
                                                snapshot
                                                    .data!
                                                    .request!
                                                    .imageUrl ??
                                                "",
                                          ),
                                        );
                                        Get.toNamed("/image");
                                      },
                                      child: Hero(
                                        tag:
                                            'request_image_${snapshot.data!.request!.id}',
                                        child: Image.network(
                                          snapshot.data?.request?.imageUrl ??
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
                                                    child: LoadingWidget(),
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
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 16),

                              FutureBuilder<List<RequestAcceptance>>(
                                future: SuccessAcceptedUsersState.users,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<RequestAcceptance> acceptedProviders =
                                        snapshot.data!;
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
                                          );
                                        },
                                      );
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
                                  }
                                  return const Center(child: LoadingWidget());
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: LoadingWidget());
                    }
                  },
                ),
              );
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
  //         fontWeight: FontWeight.w900,
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
                child:  Icon(
                  Icons.delete_forever_rounded,
                  color: context.appColors.errorColor,
                  size: 32.r,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "Delete Request?",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
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
                      onPressed: () => Navigator.pop(context),
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
                        Navigator.pop(context);
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
          child: Icon(Icons.more_horiz_rounded, color: iconColor, size: 20.r),
        ),
        onSelected: (val) {
          switch (val) {
            case 1:
              context.read<SeekerBloc>().add(
                SeekerRequestDetailEvent(request: requestData),
              );
              context.read<SeekerBloc>().add(
                NavigateSeekerEvent(
                  page: 3,
                  widget: const SeekerUpdateRequestPage(),
                ),
              );
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
                  Icon(Icons.edit_document, color: appBlueCardColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "EDIT",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
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
                  Icon(Icons.delete, color: context.appColors.errorColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "DELETE",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
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
                  Icon(Icons.check_circle, color: context.appColors.successColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "MARK AS DONE",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  Icon(Icons.payment, color: context.appColors.secondaryColor, size: 20.r),
                  SizedBox(width: 12.w),
                  Text(
                    "FUND PROVIDER",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
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
                  : const AssetImage(logoAssets) as ImageProvider,
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
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                     Icon(
                      Icons.star_rounded,
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
              _buildApprovalButton(acceptedProvider, context),
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
          final requestId = SeekerRequestDetailState.request.request?.id;
          if (requestId != null) {
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
          child: Icon(
            Icons.cancel_outlined,
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
          final requestId = SeekerRequestDetailState.request.request?.id;
          final proposalId = acceptedProvider.acceptance?.id;
          final userId = user?.id ?? provider?.id ?? "unknown";

          if (requestId != null && proposalId != null) {
            context.read<SeekerBloc>().add(
              ApprovedRequestEvent(
                requestAccept: RequestAccept(
                  serviceRequestId: requestId,
                  proposalId: proposalId,
                  uid: userId,
                ),
              ),
            );
          }
        },
        icon: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: context.appColors.primaryColor.withAlpha(40),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.check_circle_outline,
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
          icon: Icon(Icons.more_vert_rounded, color: iconColor.withAlpha(160)),
          onSelected: (val) {
            final provider = acceptedProvider.provider;
            final userId = provider?.user?.id;
        
            if (val == 1) {
              if (userId != null) {
                context.read<ProfileBloc>().add(AboutUserEvent(userID: userId));
                context.read<SeekerBloc>().add(
                  NavigateSeekerEvent(page: 1, widget: const AboutPage()),
                );
              }
            } else if (val == 2) {
              if (provider != null) {
                context.read<MessageBloc>().add(
                  SetMessageReceiverEvent(profile: provider),
                );
                context.read<SeekerBloc>().add(
                  NavigateSeekerEvent(page: 4, widget: const ChatPage()),
                );
              }
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                   Icon(
                    Icons.remove_red_eye_rounded,
                    color: context.appColors.infoColor,
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "ABOUT",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
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
                   Icon(
                    Icons.chat_bubble_rounded,
                    color: context.appColors.successColor,
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "CHAT",
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w900,
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
                          fontWeight: FontWeight.w900,
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
                            } else if (!val.isNum) {
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
                          onPressed: () => Navigator.pop(dialogContext),
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
                              fontWeight: FontWeight.w600,
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
                                Navigator.pop(dialogContext);
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
