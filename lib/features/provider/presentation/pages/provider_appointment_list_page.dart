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
            fontSize: 18,
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
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.appColors.glassBorder,
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
                                                      color: secondaryTextColor,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    CustomTextWidget(
                                                      text:
                                                          (data.user?.firstName ?? '').trim(),
                                                      fontSize: 12,
                                                      color: secondaryTextColor,
                                                    ),
                                                    if (data.role != null) ...[
                                                      const SizedBox(width: 12),
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: context.appColors.primaryColor.withAlpha(30),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          data.role!.toUpperCase(),
                                                          style: TextStyle(
                                                            fontSize: 8,
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
                                      const SizedBox(height: 16),
                                      Divider(color: dividerColor, height: 1),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: iconBgColor,
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.calendar_today_rounded,
                                              size: 16,
                                              color: context.appColors.secondaryColor,
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
                                                  color: secondaryTextColor
                                                      .withAlpha(180),
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
    } else if (appt.isFunded == true && appt.status != 'COMPLETED') {
      text = "Funded & Active";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.primaryColor.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.appColors.primaryColor.withAlpha(100),
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
