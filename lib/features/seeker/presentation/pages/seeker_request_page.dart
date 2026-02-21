import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_update_request_page.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../../core/helpers/helpers.dart';
import '../widgets/rating_review_form_widget.dart';

class SeekerRequestPage extends StatefulWidget {
  const SeekerRequestPage({super.key});

  @override
  State<SeekerRequestPage> createState() => _SeekerRequestPageState();
}

class _SeekerRequestPageState extends State<SeekerRequestPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late TextEditingController amountController;
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    context.read<SeekerBloc>().add(GetMyRequestEvent());
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
    amountController = TextEditingController();
    formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: BlocConsumer<SeekerBloc, SeekerState>(
        listener: (context, state) {
          if (state is SuccessMarkAsDoneState) {
            context.read<SeekerBloc>().add(GetMyRequestEvent());
            showDialog(
              context: context,
              builder: (context) {
                return RatingReviewFormWidget();
              },
            );
          }
          if (state is SuccessDeleteRequestState) {
            context.read<SeekerBloc>().add(GetMyRequestEvent());
            customAlert(context, AlertType.success, "Request Deleted");
          }
          if (state is FailureDeleteRequestState) {
            customAlert(context, AlertType.error, "Request Delete Failed");
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingSeekerState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "My Requests",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Manage your service requests",
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white.withAlpha(150)
                                    : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Expanded(child: _buildRequestList(context, isDark)),
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

  Widget _buildRequestList(BuildContext context, bool isDark) {
    return FutureBuilder<List<RequestData>>(
      future: SuccessGetMyRequestState.myRequests,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E2E3E) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : Colors.black.withAlpha(10),
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 60,
                      color: isDark
                          ? Colors.white.withAlpha(150)
                          : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No requests found",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withAlpha(200)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create a new request to get started",
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withAlpha(150)
                            : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
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
        } else {
          return const Center(child: LoadingWidget());
        }
      },
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    RequestData requestData,
    int index,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        context.read<SeekerBloc>().add(
          SeekerRequestDetailEvent(request: requestData),
        );

        context.read<SeekerBloc>().add(
          NavigateSeekerEvent(
            page: 1,
            widget: const SeekerRequestDetailsPage(),
          ),
        );
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
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2E2E3E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(30)
                  : Colors.black.withAlpha(10),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(30)
                    : Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      color: Colors.black26,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: (requestData.request?.withImage ?? false)
                          ? Image.network(
                              requestData.request?.imageUrl ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                    ),
                                  ),
                            )
                          : Image.asset(logo2Assets, fit: BoxFit.cover),
                    ),
                  ),
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(150),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (requestData.request?.status == 'DONE' ||
                                requestData.request?.done == true)
                            ? Colors.green
                            : (requestData.request?.status == 'IN_PROGRESS')
                            ? Colors.blue
                            : (requestData.request?.status == 'CANCELLED')
                            ? Colors.red
                            : (requestData.request?.approved ?? false)
                            ? Colors.blue
                            : appOrangeColor1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (requestData.request?.status ??
                            ((requestData.request?.done ?? false)
                                ? "DONE"
                                : "OPEN")),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : Colors.white, // Keep white on orange badge
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
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
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (val) async {
                          if (val == 'view') {
                            context.read<SeekerBloc>().add(
                              SeekerRequestDetailEvent(request: requestData),
                            );
                            context.read<SeekerBloc>().add(
                              NavigateSeekerEvent(
                                page: 1,
                                widget: const SeekerRequestDetailsPage(),
                              ),
                            );
                          } else if (val == 'edit') {
                            context.read<SeekerBloc>().add(
                              SeekerRequestDetailEvent(request: requestData),
                            );
                            context.read<SeekerBloc>().add(
                              NavigateSeekerEvent(
                                page: 1,
                                widget: const SeekerUpdateRequestPage(),
                              ),
                            );
                          } else if (val == 'delete') {
                            context.read<SeekerBloc>().add(
                              DeleteRequestEvent(
                                request: requestData.request?.id ?? "",
                              ),
                            );
                          } else if (val == 'done') {
                            if (!(requestData.request?.approved ?? false) ||
                                requestData.approvedUser == null) {
                              customAlert(
                                context,
                                AlertType.warning,
                                "Request not approved or no provider assigned",
                              );
                            } else {
                              final providerUserId =
                                  requestData.request?.approvedUser;
                              context.read<SeekerBloc>().add(
                                SetProviderToReviewEvent(
                                  provider: requestData.approvedUser!,
                                  providerUserId: providerUserId,
                                ),
                              );
                              context.read<SeekerBloc>().add(
                                MarkAsDoneEvent(request: requestData.request!),
                              );
                            }
                          } else if (val == 'pay') {
                            if (!(requestData.request?.approved ?? false)) {
                              customAlert(
                                context,
                                AlertType.warning,
                                "No provider approved for this request",
                              );
                              return;
                            }
                            if (requestData.request?.appointmentId == null) {
                              customAlert(
                                context,
                                AlertType.warning,
                                "No appointment created yet.",
                              );
                              return;
                            }
                            if (requestData.request?.isFunded == true) {
                              customAlert(
                                context,
                                AlertType.warning,
                                "Already funded.",
                              );
                              return;
                            }

                            showDialog(
                              context: context,
                              builder: (context) {
                                if (requestData.request?.price != null) {
                                  amountController.text = requestData
                                      .request!
                                      .price!
                                      .toString();
                                }
                                return Material(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      width: size(context).width * 0.85,
                                      constraints: const BoxConstraints(
                                        maxWidth: 400,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: isDark
                                            ? const Color(0xFF1E1E2E)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.black.withAlpha(10),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Form(
                                            key: formKey,
                                            child: Column(
                                              children: [
                                                CustomTextWidget(
                                                  text: "Fund Project",
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                const SizedBox(height: 12),
                                                CustomTextWidget(
                                                  text:
                                                      "Funds will be held in escrow.",
                                                  fontSize: 13,
                                                  color: Colors.white70,
                                                  textAlign: TextAlign.center,
                                                ),
                                                const SizedBox(height: 24),
                                                SolidTextField(
                                                  controller: amountController,
                                                  hintText: "Amount (\$)",
                                                  label: "Amount (\$)",
                                                  validator: (val) {
                                                    if (val!.isEmpty) {
                                                      return "Required";
                                                    }
                                                    if (!val.isNum) {
                                                      return "Invalid";
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text("Cancel"),
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      Navigator.pop(context);
                                                      await PaymentService.fundAppointment(
                                                        appointmentId:
                                                            requestData
                                                                .request!
                                                                .appointmentId!,
                                                        amount: amountController
                                                            .text,
                                                        context: context,
                                                      );
                                                      context
                                                          .read<SeekerBloc>()
                                                          .add(
                                                            GetMyRequestEvent(),
                                                          );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        appOrangeColor1,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text("Fund Now"),
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
                        },
                        itemBuilder: (context) => [
                          _buildPopupMenuItem(
                            'view',
                            'View details',
                            Icons.visibility,
                            isDark,
                          ),
                          _buildPopupMenuItem(
                            'edit',
                            'Edit',
                            Icons.edit,
                            isDark,
                          ),
                          _buildPopupMenuItem(
                            'delete',
                            'Delete',
                            Icons.delete,
                            isDark,
                          ),
                          _buildPopupMenuItem(
                            'done',
                            'Mark as Done',
                            Icons.check_circle,
                            isDark,
                          ),
                          _buildPopupMenuItem(
                            'pay',
                            'Pay Provider',
                            Icons.payment_outlined,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requestData.request?.service?.name?.toUpperCase() ??
                              "",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.white, // Keep white on image overlay
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat("EEEE yyyy-MMM-dd").format(
                            DateTime.parse(
                              requestData.request!.createdAt.toString(),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requestData.request!.title!,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? Colors.white.withAlpha(220)
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.people_outline_rounded,
                          "${requestData.request?.proposalsCount ?? 0} Proposals",
                          isDark,
                        ),
                      ],
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

  PopupMenuItem _buildPopupMenuItem(
    String value,
    String text,
    IconData icon,
    bool isDark,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(20)
              : Colors.black.withAlpha(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isDark ? Colors.white70 : Colors.black54),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white.withAlpha(200) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
