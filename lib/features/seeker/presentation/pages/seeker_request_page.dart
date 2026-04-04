import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_update_request_page.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
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
                    constraints: BoxConstraints(maxWidth: 800.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 24.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MY REQUESTS",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w900,
                                color: context.appColors.primaryTextColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "MANAGE YOUR SERVICE REQUESTS",
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                color: context.appColors.secondaryTextColor,
                                letterSpacing: 1.0,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Expanded(child: _buildRequestList(context)),
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

  Widget _buildRequestList(BuildContext context) {
    return FutureBuilder<List<RequestData>>(
      future: SuccessGetMyRequestState.myRequests,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: SolidContainer(
                padding: EdgeInsets.all(40.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 60.r,
                      color: context.appColors.glassBorder,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "NO REQUESTS FOUND",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: context.appColors.glassBorder,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Create a new request to get started",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.appColors.glassBorder,
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
                index
               
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
        child: SolidContainer(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.only(bottom: 16.h),
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 140.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                      color: Colors.black26,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
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
                    height: 140.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                      
                    ),
                  ),
                  Positioned(
                    top: 10.r,
                    left: 10.r,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (requestData.request?.status == 'DONE' ||
                                requestData.request?.done == true)
                            ? context.appColors.successColor
                            : (requestData.request?.status == 'IN_PROGRESS')
                            ? context.appColors.infoColor
                            : (requestData.request?.status == 'CANCELLED')
                            ? context.appColors.errorColor
                            : (requestData.request?.approved ?? false)
                            ? context.appColors.infoColor
                            : context.appColors.secondaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        (requestData.request?.status ??
                            ((requestData.request?.done ?? false)
                                ? "DONE"
                                : "OPEN")),
                        style: TextStyle(
                          color: context.appColors.primaryTextColor, // Keep white on orange badge
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5.r,
                    right: 5.r,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        cardColor: context.appColors.cardBackground,
                        iconTheme: IconThemeData(
                          color: context.appColors.primaryTextColor,
                        ),
                      ),
                      child: PopupMenuButton(
                        icon:  Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: context.appColors.cardBackground,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: context.appColors.glassBorder,
                              width: 1.5.r,
                            ),
                          ),
                          child: Icon(Icons.more_horiz, color: context.appColors.primaryTextColor)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                          side: BorderSide(
                            color: context.appColors.glassBorder,
                            width: 1.5.r,
                          ),
                        ),
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
                                      padding: EdgeInsets.all(24.r),
                                      width: size(context).width * 0.85,
                                      constraints: BoxConstraints(
                                        maxWidth: 400.w,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24.r),
                                        color: context.appColors.cardBackground,
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                          width: 1.5.r,
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
                                                  text: "FUND PROJECT",
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.2,
                                                ),
                                                SizedBox(height: 12.h),
                                                CustomTextWidget(
                                                  text:
                                                      "Funds will be held in escrow.",
                                                  fontSize: 13.sp,
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
                                              SizedBox(width: 16.w),
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
                                                        context.appColors.secondaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.r,
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
                            'VIEW DETAILS',
                            Icons.visibility
                            
                          ),
                          _buildPopupMenuItem(
                            'edit',
                            'EDIT',
                            Icons.edit
                           
                          ),
                          _buildPopupMenuItem(
                            'delete',
                            'DELETE',
                            Icons.delete
                            
                          ),
                          _buildPopupMenuItem(
                            'done',
                            'MARK AS DONE',
                            Icons.check_circle
                            
                          ),
                          _buildPopupMenuItem(
                            'pay',
                            'PAY PROVIDER',
                            Icons.payment_outlined
                           
                          ),
                        ],
                      ),
                    ),
                  ),
                 
                ],
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requestData.request?.service?.name?.toUpperCase() ??
                              "",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.primaryTextColor, // Keep white on image overlay
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat("EEEE, MMM dd, yyyy").format(
                            DateTime.parse(
                              requestData.request!.createdAt.toString(),
                            ),
                          ).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: context.appColors.hintTextColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      requestData.request!.title!,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: context.appColors.primaryTextColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildInfoChip(
                          Icons.people_outline_rounded,
                          "${requestData.request?.proposalsCount ?? 0} Proposals",
                         
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
  
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: context.appColors.primaryTextColor),
          SizedBox(width: 12.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: context.appColors.primaryTextColor,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.appColors.primaryColor.withAlpha(40),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.appColors.primaryColor.withAlpha(40),
          width: 1.5.r,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: context.appColors.primaryColor),
          SizedBox(width: 6.w),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: context.appColors.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
