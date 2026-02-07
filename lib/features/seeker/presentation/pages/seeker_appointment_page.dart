import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/models/appointment.dart';
import '../../../shared/presentation/widget/loading_widget.dart';
import '../../../../features/shared/presentation/pages/create_dispute_page.dart';
import '../../../../features/shared/presentation/pages/live_tracking_page.dart';

class SeekerAppointmentPage extends StatefulWidget {
  const SeekerAppointmentPage({super.key});

  @override
  State<SeekerAppointmentPage> createState() => _SeekerAppointmentPageState();
}

class _SeekerAppointmentPageState extends State<SeekerAppointmentPage>
    with TickerProviderStateMixin {
  List<CalendarEventData> events = [];
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<SeekerBloc>().add(GetAppointmentsEvent());

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : const Color(0xFF1E1E2E).withAlpha(150);
    final iconBg = isDark ? Colors.white12 : Colors.black.withAlpha(10);
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: BlocConsumer<SeekerBloc, SeekerState>(
        listener: (context, state) {
          if (state is SuccessCancelAppointmentState) {
            context.read<SeekerBloc>().add(GetAppointmentsEvent());
            customAlert(context, AlertType.success, "Appointment canceled");
          }
          if (state is FailureCancelAppointmentState) {
            customAlert(context, AlertType.error, "An error occurred");
          }
          if (state is SuccessCompleteAppointmentState) {
            context.read<SeekerBloc>().add(GetAppointmentsEvent());
            customAlert(
              context,
              AlertType.success,
              "Job completed and funds released!",
            );
          }
          if (state is FailureCompleteAppointmentState) {
            customAlert(context, AlertType.error, "Failed to complete job");
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingSeekerState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 32 : 20,
                              vertical: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Appointments",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Manage your scheduled meetings",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Calendar
                          Expanded(
                            child: _buildCalendarView(
                              context,
                              isLargeScreen,
                              isDark,
                            ),
                          ),
                        ],
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

  Widget _buildCalendarView(
    BuildContext context,
    bool isLargeScreen,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.white12 : Colors.black.withAlpha(10);

    return FutureBuilder<List<AppointmentData>>(
      future: SuccessGetAppointmentsState.appointments,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          events.clear();
          for (var data in snapshot.data!) {
            AppointmentData appointmentData = data;
            events.add(
              CalendarEventData(
                event: appointmentData.appointment!.id,
                title: appointmentData.appointment!.title ?? "",
                date:
                    appointmentData.appointment!.appointmentDate ??
                    DateTime.now(),
                description: appointmentData.appointment!.description ?? "",
                startTime: appointmentData.appointment?.startDate,
                endTime: appointmentData.appointment?.endDate,
                color: appOrangeColor1,
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16),
            child: CalendarControllerProvider(
              controller: EventController()..addAll(events),
              child: SolidContainer(
                child: MonthView(
                  borderColor: borderColor,
                  onCellTap: (events, date) {
                    if (events.isNotEmpty) {
                      _showAppointmentDetails(context, events, isDark);
                    }
                  },
                  onEventTap: (event, date) {
                    _showAppointmentDetails(context, [event], isDark);
                  },
                  headerStyle: HeaderStyle(
                    headerTextStyle: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    leftIconConfig: IconDataConfig(color: textColor),
                    rightIconConfig: IconDataConfig(color: textColor),
                  ),
                  weekDayStringBuilder: (day) =>
                      ["S", "M", "T", "W", "T", "F", "S"][day],
                ),
              ),
            ),
          );
        } else {
          return const Center(child: LoadingWidget());
        }
      },
    );
  }

  void _handleAddToCalendar(String appointmentId) async {
    try {
      final list = await SuccessGetAppointmentsState.appointments!;
      final data = list.firstWhere(
        (element) => element.appointment?.id == appointmentId,
      );
      if (data.appointment != null) {
        DialogUtils.addToCalendar(data.appointment!);
      }
    } catch (e) {
      debugPrint("Error adding to calendar: $e");
    }
  }

  void _showAppointmentDetails(
    BuildContext context,
    List<CalendarEventData> data,
    bool isDark,
  ) {
    final sheetColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.black.withAlpha(5);
    final handleColor = isDark ? Colors.white24 : Colors.grey.withAlpha(50);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(150)
        : Colors.black.withAlpha(150);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (SuccessGetAppointmentsState.appointments != null)
                FutureBuilder<List<AppointmentData>>(
                  future: SuccessGetAppointmentsState.appointments,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    try {
                      final appointmentData = snapshot.data!.firstWhere(
                        (element) => element.appointment?.id == data[0].event,
                      );
                      final appt = appointmentData.appointment!;
                      return Column(
                        children: [
                          if (appt.isFunded == false)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.amber.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "This project is not yet funded. Fund it now to secure the provider.",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.amber[100]
                                            : Colors.amber[900],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (appt.isFunded == true &&
                              appt.status == 'COMPLETED')
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Project completed and funds released.",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.green[100]
                                            : Colors.green[900],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    } catch (e) {
                      return const SizedBox();
                    }
                  },
                ),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: appBlueCardColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: appBlueCardColor.withAlpha(60)),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.lightBlueAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Scheduled Appointment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat(
                            "EEEE, MMM dd, yyyy",
                          ).format(data[0].date.toLocal()),
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                Icons.title_rounded,
                "Title",
                data[0].title,
                isDark,
              ),
              _buildDetailRow(
                Icons.schedule_rounded,
                "Time",
                "${data[0].startTime != null ? DateFormat.jm().format(data[0].startTime!.toLocal()) : ''} - ${data[0].endTime != null ? DateFormat.jm().format(data[0].endTime!.toLocal()) : ''}",
                isDark,
              ),
              if (data[0].description != null &&
                  data[0].description!.isNotEmpty)
                _buildDetailRow(
                  Icons.notes_rounded,
                  "Description",
                  data[0].description!,
                  isDark,
                ),
              const SizedBox(height: 24),

              // Escrow Actions
              if (SuccessGetAppointmentsState.appointments != null)
                FutureBuilder<List<AppointmentData>>(
                  future: SuccessGetAppointmentsState.appointments,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    try {
                      final appointmentData = snapshot.data!.firstWhere(
                        (element) => element.appointment?.id == data[0].event,
                      );
                      final appt = appointmentData.appointment!;

                      if (appt.isFunded == false) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                Get.back();
                                await PaymentService.fundAppointment(
                                  appointmentId: appt.id!,
                                  amount: (appt.totalPrice ?? 0).toString(),
                                  context: context,
                                );
                                if (context.mounted) {
                                  context.read<SeekerBloc>().add(
                                    GetAppointmentsEvent(),
                                  );
                                }
                              },
                              icon: const Icon(
                                Icons.account_balance_wallet_rounded,
                              ),
                              label: Text(
                                "Fund Project Now (\$${appt.totalPrice})",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appOrangeColor1,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        );
                      } else if (appt.status != 'COMPLETED') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.read<SeekerBloc>().add(
                                  CompleteAppointmentEvent(
                                    id: appt.id!,
                                    amount: appt.totalPrice ?? 0,
                                  ),
                                );
                                Get.back();
                              },
                              icon: const Icon(Icons.verified_rounded),
                              label: const Text(
                                "Mark as Completed & Release Funds",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    } catch (e) {
                      return const SizedBox();
                    }
                  },
                ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (SuccessGetAppointmentsState.appointments != null) {
                      try {
                        final list =
                            await SuccessGetAppointmentsState.appointments!;
                        final appointmentData = list.firstWhere(
                          (element) =>
                              element.appointment?.id ==
                              data[0].event.toString(),
                        );
                        if (appointmentData.appointment != null) {
                          Get.back();
                          Get.to(
                            () => LiveTrackingPage(
                              appointmentId: appointmentData.appointment!.id!,
                              providerName:
                                  "${appointmentData.user?.firstName ?? ''} ${appointmentData.user?.lastName ?? ''}"
                                      .trim(),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("Appointment not found: $e");
                      }
                    }
                  },
                  icon: const Icon(Icons.location_on_rounded),
                  label: const Text(
                    "Track Provider",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.withAlpha(40),
                    foregroundColor: Colors.teal[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.teal.withAlpha(100)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _handleAddToCalendar(data[0].event.toString());
                  },
                  icon: const Icon(Icons.event_available),
                  label: const Text(
                    "Add to Calendar",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.withAlpha(40),
                    foregroundColor: Colors.blue[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.blue.withAlpha(100)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (SuccessGetAppointmentsState.appointments != null) {
                      try {
                        final list =
                            await SuccessGetAppointmentsState.appointments!;
                        final dataApp = list.firstWhere(
                          (element) => element.appointment?.id == data[0].event,
                        );
                        if (dataApp.appointment != null) {
                          final providerName =
                              "${dataApp.user?.firstName ?? ''} ${dataApp.user?.lastName ?? ''}"
                                  .trim();
                          Get.to(
                            () => CreateDisputePage(
                              appointmentId: dataApp.appointment!.id!,
                              providerName: providerName.isNotEmpty
                                  ? providerName
                                  : "Provider",
                              defendantId: dataApp.user?.id,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("Appointment not found: $e");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.withAlpha(40),
                    foregroundColor: Colors.orange[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.orange.withAlpha(100)),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Raise Dispute",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<SeekerBloc>().add(
                      CancelAppointmentEvent(id: data[0].event.toString()),
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withAlpha(40),
                    foregroundColor: Colors.red[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.red.withAlpha(100)),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Cancel Appointment",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    final iconBg = isDark ? Colors.white12 : Colors.black.withAlpha(5);
    final iconColor = isDark ? Colors.white.withAlpha(150) : Colors.black54;
    final labelColor = isDark ? Colors.white.withAlpha(100) : Colors.black38;
    final valueColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
