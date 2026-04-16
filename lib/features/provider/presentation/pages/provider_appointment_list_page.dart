import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/widget/appointment_detail_bottom_sheet.dart';

class ProviderAppointmentListPage extends StatefulWidget {
  const ProviderAppointmentListPage({super.key});

  @override
  State<ProviderAppointmentListPage> createState() =>
      _ProviderAppointmentListPageState();
}

class _ProviderAppointmentListPageState
    extends State<ProviderAppointmentListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(GetAppointmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.secondaryTextColor;
    final dividerColor = context.appColors.glassBorder;
    final iconBgColor = context.appColors.glassBorder;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "MY APPOINTMENTS",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 18.sp,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            context.read<ProviderBloc>().add(ProviderBackPressedEvent());
          },
          child: Container(
            margin: EdgeInsets.all(10.r),
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
              color: textColor,
              size: 16.r,
            ),
          ),
        ),
      ),
      body: BlocListener<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is SuccessCancelAppointmentState ||
              state is SuccessUpdateAppointmentState ||
              state is SuccessCompleteAppointmentState) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<ProviderBloc>().add(GetAppointmentsEvent());
              }
            });
            final message = state is SuccessCancelAppointmentState
                ? "Appointment canceled"
                : state is SuccessUpdateAppointmentState
                ? "Appointment updated"
                : "Job completed";
            customAlert(context, AlertType.success, message);
          }
        },
        child: BlocBuilder<ProviderBloc, ProviderState>(
          builder: (context, state) {
            return LoadingView(
              isLoading: state is LoadingProviderState,
              child: GradientBackground(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: FutureBuilder<List<AppointmentData>>(
                      future: SuccessGetAppointmentsState.appointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: LoadingWidget());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: EmptyWidget(
                              message: "No appointments found",
                              height: 200.h,
                            ),
                          );
                        }

                        final appointments = snapshot.data!;
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: appointments.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            final data = appointments[index];
                            final appt = data.appointment;
                            if (appt == null) return const SizedBox.shrink();

                            return Container(
                              margin: EdgeInsets.only(bottom: 0),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Get.bottomSheet(
                                    AppointmentDetailBottomSheet(data: data),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                                child: SolidContainer(
                                  padding: EdgeInsets.all(20.r),
                                  borderColor: context.appColors.glassBorder,
                                  borderWidth: 1.5.r,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomTextWidget(
                                                  text: (appt.title ?? "No Title").toUpperCase(),
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w900,
                                                  color: textColor,
                                                  letterSpacing: 0.5,
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .person_outline_rounded,
                                                      size: 14.r,
                                                      color: secondaryTextColor,
                                                    ),
                                                    SizedBox(width: 6.w),
                                                    CustomTextWidget(
                                                      text:
                                                          (data.user?.firstName ?? '').trim(),
                                                      fontSize: 12.sp,
                                                      color: secondaryTextColor,
                                                    ),
                                                    if (data.role != null) ...[
                                                      SizedBox(width: 12.w),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                                        decoration: BoxDecoration(
                                                          color: context.appColors.primaryColor.withAlpha(30),
                                                          borderRadius: BorderRadius.circular(6.r),
                                                        ),
                                                        child: Text(
                                                          data.role!.toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 8.sp,
                                                            fontWeight: FontWeight.w900,
                                                            color: context.appColors.primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildStatusBadge(appt, context),
                                        ],
                                      ),
                                      SizedBox(height: 16.h),
                                      Divider(color: dividerColor, height: 1.h),
                                      SizedBox(height: 16.h),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8.r),
                                            decoration: BoxDecoration(
                                              color: iconBgColor,
                                              borderRadius: BorderRadius.circular(
                                                10.r,
                                              ),
                                            ),
                                            child: Icon(
                                              FontAwesomeIcons.calendar,
                                              size: 16.r,
                                              color: context.appColors.secondaryColor,
                                            ),
                                          ),
                                          SizedBox(width: 12.w),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "SCHEDULED FOR",
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  color: secondaryTextColor
                                                      .withAlpha(180),
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              SizedBox(height: 2.h),
                                              CustomTextWidget(
                                                text: appt.effectiveDate != null
                                                    ? DateFormat(
                                                        "MMM dd, yyyy â€¢ h:mm a",
                                                      ).format(
                                                        appt.effectiveDate!
                                                            .toLocal(),
                                                      )
                                                    : "Date TBD",
                                                fontSize: 14.sp,
                                                color: textColor.withAlpha(220),
                                              ),
                                            ],
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
                      },
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

  Widget _buildStatusBadge(Appointment appt, BuildContext context) {
    String text = appt.status ?? "Scheduled";

    if (appt.status == 'COMPLETED') {
      text = "Completed";
    } else if (appt.status == 'CANCELLED') {
      text = "Cancelled";
    } else if (appt.isFunded == true && appt.status != 'COMPLETED') {
      text = "Funded & Active";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.appColors.primaryColor.withAlpha(40),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: context.appColors.primaryColor.withAlpha(100),
          width: 1.5.r,
        ),
      ),
      child: CustomTextWidget(
        text: text.toUpperCase(),
        color: context.appColors.primaryColor,
        fontSize: 10.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }
}


