import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/appointment.dart';
import '../../../shared/presentation/widget/appointment_input_field_widget.dart';
import '../../../shared/presentation/widget/custom_text_widget.dart';
import '../bloc/provider_bloc.dart';
import 'provider_on_the_way_page.dart';

class ProviderAppointmentCalendarPage extends StatefulWidget {
  const ProviderAppointmentCalendarPage({super.key});

  @override
  State<ProviderAppointmentCalendarPage> createState() =>
      _ProviderAppointmentCalendarPageState();
}

class _ProviderAppointmentCalendarPageState
    extends State<ProviderAppointmentCalendarPage>
    with TickerProviderStateMixin {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? appointmentDate;
  DateTime? appointmentStartTime;
  DateTime? appointmentEndTime;
  bool isConsultation = false;
  List<CalendarEventData> events = [];
  String? selectedProposalId;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<ProviderBloc>().add(GetAppointmentsEvent());

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
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final secondaryTextColor = isDark
        ? Colors.white.withAlpha(200)
        : const Color(0xFF1E1E2E).withAlpha(160);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: BlocConsumer<ProviderBloc, ProviderState>(
        listener: (context, state) {
          if (state is SuccessCancelAppointmentState) {
            context.read<ProviderBloc>().add(GetAppointmentsEvent());
            customAlert(context, AlertType.success, "Appointment canceled");
          }
          if (state is FailureCancelAppointmentState) {
            customAlert(context, AlertType.error, "An error occurred");
          }
          if (state is SuccessAddAppointmentState) {
            context.read<ProviderBloc>().add(GetAppointmentsEvent());
            customAlert(context, AlertType.success, "Appointment scheduled");
          }
          if (state is SuccessCompleteAppointmentState) {
            context.read<ProviderBloc>().add(GetAppointmentsEvent());
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
            isLoading: (state is LoadingProviderState),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Calendar",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Manage your schedule",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: secondaryTextColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                _buildAddButton(),
                              ],
                            ),
                          ),

                          // Calendar
                          Expanded(
                            child: _buildCalendarView(
                              context,
                              isDark,
                              textColor,
                              secondaryTextColor,
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

  void _handleAddToCalendar(String appointmentId) async {
    try {
      final list = await SuccessGetAppointmentsState.appointments!;
      final appointmentWrapper = list.firstWhere(
        (element) => element.appointment?.id == appointmentId,
      );
      if (appointmentWrapper.appointment != null) {
        DialogUtils.addToCalendar(appointmentWrapper.appointment!);
      }
    } catch (e) {
      debugPrint("Error adding to calendar: $e");
    }
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        context.read<ProviderBloc>().add(GetAcceptedRequestEvent());
        Get.bottomSheet(
          _buildAddAppointmentSheet(context, isDark),
          isScrollControlled: true,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [appOrangeColor1, appOrangeColor2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: appOrangeColor1.withAlpha(80),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              "Schedule",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return FutureBuilder<List<AppointmentData>>(
      future: SuccessGetAppointmentsState.appointments,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          events.clear();
          for (var data in snapshot.data!) {
            AppointmentData appointmentData = data;
            events.add(
              CalendarEventData(
                event: appointmentData.appointment?.id,
                title: appointmentData.appointment?.title ?? 'Appointment',
                date:
                    appointmentData.appointment?.appointmentDate ??
                    DateTime.now(),
                description: appointmentData.appointment?.description,
                startTime: appointmentData.appointment?.effectiveDate,
                endTime: appointmentData.appointment?.endDate,
                color: appOrangeColor1,
              ),
            );
          }
          final borderColor = isDark
              ? Colors.white.withAlpha(15)
              : Colors.black.withAlpha(15);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CalendarControllerProvider(
              controller: EventController()..addAll(events),
              child: SolidContainer(
                child: MonthView(
                  borderColor: borderColor,
                  onCellTap: (events, date) {
                    if (events.isNotEmpty) {
                      Get.bottomSheet(
                        _buildEventDetailsSheet(events[0], context, isDark),
                        isScrollControlled: true,
                        barrierColor: Colors.black.withAlpha(150),
                      );
                    }
                  },
                  onEventTap: (event, date) {
                    Get.bottomSheet(
                      _buildEventDetailsSheet(event, context, isDark),
                      isScrollControlled: true,
                      barrierColor: Colors.black.withAlpha(150),
                    );
                  },
                  headerStyle: HeaderStyle(
                    headerTextStyle: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: -0.5,
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

  Widget _buildEventDetailsSheet(
    CalendarEventData data,
    BuildContext context,
    bool isDark,
  ) {
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final handleColor = isDark ? Colors.white30 : Colors.black.withAlpha(40);

    return SolidContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
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
                      (element) =>
                          element.appointment?.id == data.event.toString(),
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
                                    "This project is not yet funded by the seeker.",
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
                        if (appt.isFunded == true && appt.status != 'COMPLETED')
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(20),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withAlpha(50),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Project is funded. Funds will be released upon completion.",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.blue[100]
                                          : Colors.blue[900],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (appt.isFunded == true && appt.status == 'COMPLETED')
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
            const SizedBox(height: 12),
            CustomTextWidget(
              text: "Appointment Details",
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: textColor,
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.title_rounded, "Title", data.title, isDark),
            _buildDetailRow(
              Icons.schedule_rounded,
              "Time",
              "${data.startTime != null ? DateFormat.jm().format(data.startTime!.toLocal()) : ''} - ${data.endTime != null ? DateFormat.jm().format(data.endTime!.toLocal()) : ''}",
              isDark,
            ),
            if (data.description != null && data.description!.isNotEmpty)
              _buildDetailRow(
                Icons.notes_rounded,
                "Description",
                data.description!,
                isDark,
              ),
            const SizedBox(height: 32),

            // Escrow Action for Provider
            if (SuccessGetAppointmentsState.appointments != null)
              FutureBuilder<List<AppointmentData>>(
                future: SuccessGetAppointmentsState.appointments,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  try {
                    final appointmentData = snapshot.data!.firstWhere(
                      (element) =>
                          element.appointment?.id == data.event.toString(),
                    );
                    final appt = appointmentData.appointment!;

                    if (appt.isFunded == true && appt.status != 'COMPLETED') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SolidButton(
                          onPressed: () {
                            context.read<ProviderBloc>().add(
                              CompleteAppointmentEvent(
                                id: appt.id!,
                                amount: appt.totalPrice ?? 0,
                              ),
                            );
                            Get.back();
                          },
                          icon: Icons.verified_rounded,
                          label: "Mark as Completed",
                          height: 55,
                        ),
                      );
                    }
                    return const SizedBox();
                  } catch (e) {
                    return const SizedBox();
                  }
                },
              ),

            SolidButton(
              onPressed: () {
                Get.back();
                _handleAddToCalendar(data.event.toString());
              },
              icon: Icons.event_available,
              label: "Add to Calendar",
              isPrimary: false,
              height: 55,
            ),
            const SizedBox(height: 16),
            SolidButton(
              onPressed: () async {
                if (SuccessGetAppointmentsState.appointments != null) {
                  try {
                    final list =
                        await SuccessGetAppointmentsState.appointments!;
                    final appointmentData = list.firstWhere(
                      (element) =>
                          element.appointment?.id == data.event.toString(),
                    );
                    if (appointmentData.appointment != null) {
                      Get.back();
                      Get.to(
                        () => ProviderOnTheWayPage(
                          appointmentId: appointmentData.appointment?.id ?? "",
                          destination: LatLng(
                            double.tryParse(
                                  appointmentData.user?.latitude ?? "0.0",
                                ) ??
                                0.0,
                            double.tryParse(
                                  appointmentData.user?.longitude ?? "0.0",
                                ) ??
                                0.0,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint("Appointment not found: $e");
                  }
                }
              },
              icon: Icons.navigation_rounded,
              label: "On the Way",
              isPrimary: false,
              height: 55,
            ),
            const SizedBox(height: 16),
            SolidButton(
              onPressed: () {
                context.read<ProviderBloc>().add(
                  CancelAppointmentEvent(id: data.event.toString()),
                );
                Get.back();
              },
              label: "Cancel Appointment",
              isPrimary: false,
              height: 55,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    final iconBg = isDark
        ? Colors.white.withAlpha(15)
        : Colors.black.withAlpha(5);
    final iconColor = isDark
        ? Colors.white.withAlpha(180)
        : Colors.black.withAlpha(160);
    final labelColor = isDark
        ? Colors.white.withAlpha(100)
        : Colors.black.withAlpha(120);
    final valueColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: labelColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAppointmentSheet(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
    final handleColor = isDark ? Colors.white30 : Colors.black.withAlpha(40);

    return SolidContainer(
      width: size(context).width,
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Schedule Appointment",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            AppointmentInputFieldWidget(
              controller: titleController,
              readOnly: false,
              label: "Title",
            ),
            const SizedBox(height: 16),
            AppointmentInputFieldWidget(
              controller: dateController,
              label: "Date",
              onPressed: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: appOrangeColor1,
                          onPrimary: Colors.white,
                          surface: const Color(0xFF1E1E2E),
                        ),
                        dialogTheme: const DialogThemeData(
                          backgroundColor: Color(0xFF1E1E2E),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  appointmentDate = date;
                  dateController.text = DateFormat(
                    "EEEE, MMM dd, yyyy",
                  ).format(date);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppointmentInputFieldWidget(
                    controller: startTimeController,
                    label: "Start Time",
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final now = DateTime.now();
                        appointmentStartTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          time.hour,
                          time.minute,
                        );
                        startTimeController.text = DateFormat.jm().format(
                          appointmentStartTime!,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppointmentInputFieldWidget(
                    controller: endTimeController,
                    label: "End Time",
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        final now = DateTime.now();
                        appointmentEndTime = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          time.hour,
                          time.minute,
                        );
                        endTimeController.text = DateFormat.jm().format(
                          appointmentEndTime!,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppointmentInputFieldWidget(
              controller: descriptionController,
              label: "Notes",
              readOnly: false,
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setSheetState) {
                return CheckboxListTile(
                  title: Text(
                    "Consultation Call (Video/Audio)",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  value: isConsultation,
                  onChanged: (val) {
                    setSheetState(() => isConsultation = val ?? false);
                  },
                  activeColor: appOrangeColor1,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildProposalDropdown(context, isDark),
            const SizedBox(height: 32),
            SolidButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty ||
                    appointmentEndTime == null ||
                    appointmentStartTime == null ||
                    appointmentDate == null) {
                  customAlert(
                    context,
                    AlertType.error,
                    "Missing required fields",
                  );
                  return;
                }
                if (appointmentEndTime!.isBefore(appointmentStartTime!)) {
                  customAlert(context, AlertType.error, "Invalid time range");
                  return;
                }
                context.read<ProviderBloc>().add(
                  AddAppointmentEvent(
                    appointment: Appointment(
                      title: titleController.text,
                      description: descriptionController.text,
                      startDate: appointmentStartTime,
                      endDate: appointmentEndTime,
                      appointmentDate: appointmentDate,
                      scheduledTime: appointmentStartTime,
                      fromUser: "",
                      fromChat: true,
                      isConsultation: isConsultation,
                      consultationChannel: isConsultation
                          ? "channel_${DateTime.now().millisecondsSinceEpoch}"
                          : null,
                      proposalId: selectedProposalId,
                    ),
                  ),
                );
                Get.back();
                setState(() {
                  selectedProposalId = null;
                });
              },
              label: "SCHEDULE",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProposalDropdown(BuildContext context, bool isDark) {
    return FutureBuilder<List<RequestAcceptance>>(
      future: SuccessGetAcceptRequestState.accepts,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "Loading proposals...",
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ),
          );
        }
        if (snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              "No accepted proposals found to link.",
              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
            ),
          );
        }

        debugPrint(
          "Proposal Dropdown: Found ${snapshot.data!.length} proposals",
        );

        final proposals = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Link Proposal (Optional)",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SolidContainer(
              child: DropdownButtonFormField<String>(
                initialValue: selectedProposalId,
                dropdownColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                hint: Text(
                  "Select a proposal",
                  style: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                ),
                items: proposals.map((proposal) {
                  return DropdownMenuItem<String>(
                    value: proposal.acceptance?.id,
                    child: Text(
                      proposal.acceptance?.request?.title ??
                          "Untitled Proposal",
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProposalId = value;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
