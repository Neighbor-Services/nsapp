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
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';

import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/core/services/payment_service.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../shared/presentation/bloc/shared_bloc.dart';
import '../../../shared/presentation/widget/custom_text_widget.dart';
import '../../../shared/presentation/widget/loading_view.dart';
import '../bloc/seeker_bloc.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final buttonColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final borderColor = isDark
        ? Colors.white.withAlpha(40)
        : Colors.black.withAlpha(20);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(160)
        : const Color(0xFF1E1E2E).withAlpha(160);

    return Scaffold(
      extendBodyBehindAppBar: true,
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
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                color: Colors.redAccent,
                                size: 60,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Failed to load request details",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                              height: 50,
                              width: 120,
                            ),
                          ],
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
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
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: buttonColor,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: textColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    "Request Details",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  _buildActionMenu(snapshot.data!, context),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Request Info Card
                              SolidContainer(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color:
                                                (isDark
                                                        ? Colors.white
                                                        : appDeepBlueColor1)
                                                    .withAlpha(40),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.assignment_rounded,
                                            color: isDark
                                                ? Colors.white
                                                : appDeepBlueColor1,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                snapshot
                                                        .data
                                                        ?.request
                                                        ?.service
                                                        ?.name ??
                                                    "Service Request",
                                                style: TextStyle(
                                                  color: textColor,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
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
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: secondaryTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _getStatusBadge(
                                          snapshot.data!.request!,
                                          isDark,
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
                                      snapshot.data?.request?.title ?? "",
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      snapshot.data?.request?.description ??
                                          snapshot.data?.request?.title ??
                                          "",
                                      style: TextStyle(
                                        color: textColor.withAlpha(180),
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
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(50),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
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
                                          height: 350,
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
                                                  height: 350,
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
                                "Interested Providers",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  letterSpacing: -0.5,
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
                                            const SizedBox(height: 16),
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
                                        padding: const EdgeInsets.all(40),
                                        child: const EmptyWidget(
                                          message:
                                              "No acceptance for your request yet!",
                                          height: 150,
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

  Widget _getStatusBadge(Request request, bool isDark) {
    Color color = Colors.orangeAccent;
    String text = "Pending";

    if (request.done == true || request.status == 'DONE') {
      color = isDark ? Colors.blueAccent : Colors.blue;
      text = "Completed";
    } else if (request.status == 'IN_PROGRESS') {
      color = isDark ? Colors.greenAccent : Colors.green;
      text = "Active";
    } else if (request.approved == true) {
      if (request.isFunded == true) {
        color = isDark ? Colors.greenAccent : Colors.green;
        text = "Active";
      } else {
        color = isDark ? Colors.amber : Colors.orange;
        text = "Approved, Pending Funding";
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String requestId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final borderColor = isDark
        ? Colors.white.withAlpha(40)
        : Colors.black.withAlpha(20);

    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Delete Request?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "This action cannot be undone. Are you sure you want to delete this service request?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor.withAlpha(160),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
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
                      height: 50,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final borderColor = isDark
        ? Colors.white.withAlpha(40)
        : Colors.black.withAlpha(20);
    final menuIconBg = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);

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
      child: PopupMenuButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: menuIconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.more_horiz_rounded, color: iconColor, size: 20),
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
                  Icon(Icons.edit_document, color: appBlueCardColor),
                  SizedBox(width: 6),
                  CustomTextWidget(text: "Edit", color: iconColor),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 6),
                  CustomTextWidget(text: "Delete", color: iconColor),
                ],
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 6),
                  CustomTextWidget(text: "Mark as Done", color: iconColor),
                ],
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  Icon(Icons.payment, color: appOrangeColor1),
                  SizedBox(width: 6),
                  CustomTextWidget(text: "Fund Provider", color: iconColor),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final borderColor = isDark
        ? Colors.white.withAlpha(40)
        : Colors.black.withAlpha(20);
    final avatarBg = isDark
        ? Colors.white.withAlpha(10)
        : Colors.black.withAlpha(5);

    return SolidContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
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
                  provider?.firstName ?? "Unknown",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "4.8", // Hardcoded for design
                      style: TextStyle(
                        fontSize: 13,
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
              const SizedBox(width: 4),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        icon: Icon(
          Icons.cancel_rounded,
          color: isDark ? Colors.redAccent : Colors.red,
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
          final userId = user?.id;

          if (requestId != null && proposalId != null && userId != null) {
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
        icon: Icon(
          Icons.check_circle_rounded,
          color: isDark ? Colors.greenAccent : Colors.green,
        ),
        tooltip: "Approve Provider",
      );
    }
  }

  Widget _buildAcceptedUserMenu(
    RequestAcceptance acceptedProvider,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final borderColor = isDark
        ? Colors.white.withAlpha(40)
        : Colors.black.withAlpha(20);

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
                const Icon(
                  Icons.remove_red_eye_rounded,
                  color: Colors.blueAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text("About", style: TextStyle(color: iconColor)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.greenAccent,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text("Chat", style: TextStyle(color: iconColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFundingDialog(BuildContext context, RequestData requestData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final borderColor = isDark
        ? Colors.white.withAlpha(50)
        : Colors.black.withAlpha(20);

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
            child: Container(
              padding: const EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: backgroundColor,
                border: Border.all(color: borderColor),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomTextWidget(
                          text: "Fund Project & Secure Provider",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        const SizedBox(height: 12),
                        CustomTextWidget(
                          text:
                              "Funds will be held in escrow until you mark the job as completed.",
                          fontSize: 13,
                          color: textColor.withAlpha(180),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
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
                        const SizedBox(height: 20),
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
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: borderColor),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              color: textColor.withAlpha(200),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                          height: 50,
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
