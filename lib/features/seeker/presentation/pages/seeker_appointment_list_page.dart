import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/services/dialog_utils.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/appointment_detail_bottom_sheet.dart';
import 'package:nsapp/core/core.dart';

class SeekerAppointmentListPage extends StatefulWidget {
  const SeekerAppointmentListPage({super.key});

  @override
  State<SeekerAppointmentListPage> createState() =>
      _SeekerAppointmentListPageState();
}

class _SeekerAppointmentListPageState extends State<SeekerAppointmentListPage> {
  @override
  void initState() {
    super.initState();
    context.read<SeekerBloc>().add(GetAppointmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;
    final buttonColor = context.appColors.glassBorder;
    final dividerColor = context.appColors.glassBorder;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "MY APPOINTMENTS",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            context.read<SeekerBloc>().add(SeekerBackPressedEvent());
          },
          child: Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 16,
            ),
          ),
        ),
      ),
      body: BlocListener<SeekerBloc, SeekerState>(
        listener: (context, state) {
          if (state is SuccessCancelAppointmentState ||
              state is SuccessUpdateAppointmentState ||
              state is SuccessCompleteAppointmentState) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<SeekerBloc>().add(GetAppointmentsEvent());
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
        child: BlocBuilder<SeekerBloc, SeekerState>(
          builder: (context, state) {
            return LoadingView(
              isLoading: state is LoadingSeekerState,
              child: GradientBackground(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: FutureBuilder<List<AppointmentData>>(
                      future: SuccessGetAppointmentsState.appointments,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: LoadingWidget());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: EmptyWidget(
                              message: "No appointments found",
                              height: 200,
                            ),
                          );
                        }

                        final appointments = snapshot.data!;
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemCount: appointments.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
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
                                  padding: EdgeInsets.all(20),
                                  borderColor: context.appColors.glassBorder,
                                  borderWidth: 1.5,
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
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: textColor,
                                                  letterSpacing: 0.5,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .person_outline_rounded,
                                                      size: 14,
                                                      color: context.appColors.hintTextColor,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    CustomTextWidget(
                                                      text:
                                                          (data.user?.firstName ?? '')
                                                              .trim(),
                                                      fontSize: 12,
                                                      color: context.appColors.hintTextColor,
                                                    ),
                                                    if (data.role != null) ...[
                                                      const SizedBox(width: 12),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: context.appColors.secondaryColor.withAlpha(30),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          data.role!.toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 8,
                                                            fontWeight: FontWeight.w900,
                                                            color: context.appColors.secondaryColor,
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
                                      const SizedBox(height: 16),
                                      Divider(color: dividerColor, height: 1),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: context.appColors.primaryColor.withAlpha(40),
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.calendar_today_rounded,
                                              size: 16,
                                              color: context.appColors.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "SCHEDULED FOR",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: context.appColors.hintTextColor,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              CustomTextWidget(
                                                text: appt.effectiveDate != null
                                                    ? DateFormat(
                                                        "MMM dd, yyyy • h:mm a",
                                                      ).format(
                                                        appt.effectiveDate!
                                                            .toLocal(),
                                                      )
                                                    : "Date TBD",
                                                fontSize: 14,
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
    } else if (appt.isFunded == false) {
      text = "Action Needed";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.primaryColor.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.primaryColor,
          width: 1.5,
        ),
      ),
      child: CustomTextWidget(
        text: text.toUpperCase(),
        color: context.appColors.primaryColor,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
  }
}
