import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/empty_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);
    final borderColor = isDark
        ? Colors.white.withAlpha(40)
        : Colors.black.withAlpha(20);
    final buttonColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final dividerColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.black.withAlpha(10);
    final iconBgColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(5);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "My Appointments",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
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
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 16,
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProviderBloc, ProviderState>(
        builder: (context, state) {
          return LoadingView(
            isLoading: state is LoadingProviderState,
            child: GradientBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                            margin: const EdgeInsets.only(bottom: 0),
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
                                padding: const EdgeInsets.all(20),
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
                                                text: appt.title ?? "No Title",
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
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
                                                        "${data.user?.firstName ?? ''} ${data.user?.lastName ?? ''}"
                                                            .trim(),
                                                    fontSize: 12,
                                                    color: secondaryTextColor,
                                                  ),
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
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: iconBgColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 16,
                                            color: appOrangeColor1,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Scheduled For",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: secondaryTextColor
                                                    .withAlpha(180),
                                                fontWeight: FontWeight.bold,
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
                                    if (appt.isFunded == false) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.withAlpha(60),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: CustomTextWidget(
                                                text: "Waiting for funding",
                                                color: isDark
                                                    ? Colors.amber.shade100
                                                    : Colors.amber.shade900,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
    );
  }

  Widget _buildStatusBadge(Appointment appt, BuildContext context) {
    Color color = Colors.blue;
    String text = appt.status ?? "Scheduled";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (appt.status == 'COMPLETED') {
      color = Colors.green;
      text = "Completed";
    } else if (appt.status == 'CANCELLED') {
      color = Colors.red;
      text = "Cancelled";
    } else if (appt.isFunded == true && appt.status != 'COMPLETED') {
      color = Colors.teal;
      text = "Funded & Active";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
        boxShadow: [
          BoxShadow(color: color.withAlpha(20), blurRadius: 8, spreadRadius: 0),
        ],
      ),
      child: CustomTextWidget(
        text: text.toUpperCase(),
        color: isDark ? Colors.white : color,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}
