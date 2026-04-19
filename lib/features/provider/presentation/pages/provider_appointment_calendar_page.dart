import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_widget.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/models/request_data.dart';
import '../../../shared/presentation/widget/appointment_input_field_widget.dart';
import '../../../shared/presentation/widget/custom_text_widget.dart';
import '../bloc/provider_bloc.dart';
import 'provider_on_the_way_page.dart';
import 'provider_request_detail_page.dart';
import 'package:nsapp/core/core.dart';

class ProviderAppointmentCalendarPage extends StatefulWidget {
  const ProviderAppointmentCalendarPage({super.key});

  @override
  State<ProviderAppointmentCalendarPage> createState() =>
      _ProviderAppointmentCalendarPageState();
}

class _ProviderAppointmentCalendarPageState
    extends State<ProviderAppointmentCalendarPage>
    with TickerProviderStateMixin {
  DateTime? _calendarSelectedDate;
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? appointmentDate;
  DateTime? appointmentStartTime;
  bool isConsultation = false;
  List<CalendarEventData> events = [];
  String? selectedProposalId;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _calendarSelectedDate = DateTime.now();
    context.read<ProviderBloc>().add(GetAppointmentsEvent());
    
    // Pre-initialize date controller with today
    dateController.text = DateFormat("EEEE, MMM dd, yyyy").format(_calendarSelectedDate!);
    appointmentDate = _calendarSelectedDate;

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
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.secondaryTextColor;

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
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<ProviderBloc>().add(GetAppointmentsEvent());
              }
            });
            customAlert(context, AlertType.success, "Appointment scheduled");
          }
          if (state is FailureAddAppointmentState) {
            customAlert(context, AlertType.error, "Failed to schedule appointment");
          }
          if (state is SuccessUpdateAppointmentState) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<ProviderBloc>().add(GetAppointmentsEvent());
              }
            });
            customAlert(context, AlertType.success, "Appointment updated");
          }
          if (state is FailureUpdateAppointmentState) {
            customAlert(context, AlertType.error, "Failed to update appointment");
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
                    constraints: BoxConstraints(maxWidth: 700.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 32.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CALENDAR",
                                      style: TextStyle(
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "MANAGE YOUR SCHEDULE",
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: secondaryTextColor,
                                        letterSpacing: 0.8,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.appColors.secondaryColor, context.appColors.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: context.appColors.secondaryColor.withAlpha(100),
            width: 1.5.r,
          ),
        ),
        child: Row(
          children: [
            FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              "SCHEDULE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                letterSpacing: 1.0,
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
            final appt = appointmentData.appointment;
            if (appt == null) continue;
            print(appt.effectiveDate);
            final isSeeker = appointmentData.role == 'seeker';
            events.add(
              CalendarEventData(
                event: appt.id,
                title: appt.title ?? 'Appointment',
                date: appt.effectiveDate ?? DateTime.now(),
                description: appt.description,
                startTime: appt.effectiveDate,
                color: isSeeker
                    ? context.appColors.secondaryColor
                    : context.appColors.primaryColor,
              ),
            );
          }
          final borderColor = context.appColors.glassBorder;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CalendarControllerProvider(
              controller: EventController()..addAll(events),
              child: SolidContainer(
                child: MonthView(
                  borderColor: borderColor,
                  cellBuilder: (date, events, isToday, isInMonth, hideDaysNotInMonth) {
                    return FilledCell(
                      date: date,
                      shouldHighlight: isToday,
                      backgroundColor: isInMonth
                          ? context.appColors.cardBackground
                          : context.appColors.primaryBackground,
                      events: events,
                      isInMonth: isInMonth,
                      hideDaysNotInMonth: hideDaysNotInMonth,
                      titleColor: isInMonth
                          ? context.appColors.primaryTextColor
                          : context.appColors.secondaryTextColor,
                      highlightColor: context.appColors.secondaryColor,
                      tileColor: context.appColors.secondaryColor,
                      onTileTap: (event, date) {
                        Get.bottomSheet(
                          _buildEventDetailsSheet(event, context, isDark),
                          isScrollControlled: true,
                          barrierColor: Colors.black.withAlpha(150),
                        );
                      },
                    );
                  },
                  weekDayBuilder: (day) {
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(color: borderColor, width: 0.5.r),
                      ),
                      child: Text(
                        ["M", "T", "W", "T", "F", "S", "S"][day],
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  },
                  onCellTap: (events, date) {
                    setState(() {
                      _calendarSelectedDate = date;
                      appointmentDate = date;
                      dateController.text = DateFormat("EEEE, MMM dd, yyyy").format(date);
                    });
                    
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
                      fontSize: 18.sp,
                      letterSpacing: 0.5,
                    ),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    leftIconConfig: IconDataConfig(color: textColor),
                    rightIconConfig: IconDataConfig(color: textColor),
                  ),
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
    final textColor = context.appColors.primaryTextColor;
    final handleColor = context.appColors.glassBorder;

    return SolidContainer(
      padding: EdgeInsets.all(24.r),
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            if (SuccessGetAppointmentsState.appointments != null)
             
            SizedBox(height: 12.h),
            CustomTextWidget(
              text: "APPOINTMENT DETAILS",
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: textColor,
              letterSpacing: 1.0,
            ),
            SizedBox(height: 24.h),
            _buildDetailRow(FontAwesomeIcons.heading, "TITLE", data.title, isDark),
            _buildDetailRow(
              FontAwesomeIcons.calendar,
              "TIME",
              data.startTime != null ? DateFormat.jm().format(data.startTime!.toLocal()) : '',
              isDark,
            ),
            if (data.description != null && data.description!.isNotEmpty)
              _buildDetailRow(
                FontAwesomeIcons.noteSticky,
                "DESCRIPTION",
                data.description!,
                isDark,
              ),
            SizedBox(height: 16.h),
            
            // Linked Request Details
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
                    final req = appt.serviceRequest;

                    if (req == null) return const SizedBox();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(height: 32.h),
                        CustomTextWidget(
                          text: "LINKED REQUEST",
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: context.appColors.secondaryTextColor,
                          letterSpacing: 1.0,
                        ),
                        SizedBox(height: 16.h),
                        _buildDetailRow(
                          FontAwesomeIcons.fileLines,
                          "ORIGINAL TITLE",
                          req.title ?? "N/A",
                          isDark,
                        ),
                        _buildDetailRow(
                          FontAwesomeIcons.list,
                          "SERVICE",
                          req.service?.name ?? "N/A",
                          isDark,
                        ),
                        if (req.price != null)
                          _buildDetailRow(
                            FontAwesomeIcons.creditCard,
                            "REQUEST PRICE",
                            "\$${req.price}",
                            isDark,
                          ),
                        if (req.description != null && req.description!.isNotEmpty)
                           _buildDetailRow(
                            FontAwesomeIcons.fileLines,
                            "REQ. DESCRIPTION",
                            req.description!,
                            isDark,
                          ),
                        SizedBox(height: 12.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              Get.back();
                              final requestData = RequestData(
                                request: req,
                                user: appointmentData.user,
                              );
                              context.read<ProviderBloc>().add(
                                RequestDetailEvent(request: requestData),
                              );
                              context.read<ProviderBloc>().add(
                                ReloadProfileEvent(request: requestData.request!.id!),
                              );
                              context.read<ProviderBloc>().add(
                                NavigateProviderEvent(
                                  page: 1,
                                  widget: const ProviderRequestDetailPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              FontAwesomeIcons.arrowUpRightFromSquare,
                              size: 18.r,
                              color: context.appColors.primaryColor,
                            ),
                            label: Text(
                              "VIEW FULL DETAILS",
                                style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: context.appColors.primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 32.h),
                      ],
                    );
                  } catch (e) {
                    return const SizedBox();
                  }
                },
              ),

            SizedBox(height: 16.h),

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
                        padding: EdgeInsets.only(bottom: 16.h),
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
                          icon: FontAwesomeIcons.circleCheck,
                          label: "Mark as Completed",
                          height: 55.h,
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
              icon: FontAwesomeIcons.calendarCheck,
              label: "Add to Calendar",
              isPrimary: false,
              color: context.appColors.primaryTextColor,
              height: 55.h,
            ),
            SizedBox(height: 16.h),
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
              icon: FontAwesomeIcons.compass,
              label: "On the Way",
              isPrimary: false,
              
              color: context.appColors.successColor.withAlpha(50),
              textColor: context.appColors.successColor,
              height: 55.h,
            ),
            SizedBox(height: 16.h),
            SolidButton(
              onPressed: () {
                context.read<ProviderBloc>().add(
                  CancelAppointmentEvent(id: data.event.toString()),
                );
                Get.back();
              },
              label: "Cancel Appointment",
              isPrimary: false,
              color: context.appColors.errorColor.withAlpha(50),
              textColor: context.appColors.errorColor,
              height: 55.h,
            ),
            SizedBox(height: 20.h),
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
    final iconBg = context.appColors.primaryColor.withAlpha(50);
    final iconColor = context.appColors.primaryColor;
    final labelColor = context.appColors.secondaryTextColor;
    final valueColor = context.appColors.primaryTextColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: labelColor,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
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
    final textColor = context.appColors.primaryTextColor;
    final handleColor = context.appColors.glassBorder;

    return SolidContainer(
      width: size(context).width,
      padding: EdgeInsets.fromLTRB(
        24.w,
        20.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "SCHEDULE APPOINTMENT",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 24.h),
            AppointmentInputFieldWidget(
              controller: titleController,
              readOnly: false,
              label: "TITLE",
            ),
            SizedBox(height: 16.h),
            AppointmentInputFieldWidget(
              controller: dateController,
              label: "DATE",
              onPressed: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: context.appColors.secondaryColor,
                          onPrimary: Colors.white,
                          surface:  Color(0xFF1E1E2E),
                        ),
                        dialogTheme:  DialogThemeData(
                          backgroundColor: Color(0xFF1E1E2E),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() {
                    appointmentDate = date;
                  });
                  dateController.text = DateFormat(
                    "EEEE, MMM dd, yyyy",
                  ).format(date);
                }
              },
            ),
            SizedBox(height: 16.h),
            AppointmentInputFieldWidget(
              controller: startTimeController,
              label: "START TIME",
              onPressed: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  final now = DateTime.now();
                  final mergedDateTime = DateTime(
                    appointmentDate?.year ?? now.year,
                    appointmentDate?.month ?? now.month,
                    appointmentDate?.day ?? now.day,
                    time.hour,
                    time.minute,
                  );
                  appointmentStartTime = mergedDateTime;
                  appointmentDate = mergedDateTime; // Preserve time in appointmentDate
                  
                  startTimeController.text = DateFormat.jm().format(
                    appointmentStartTime!,
                  );
                }
              },
            ),
            SizedBox(height: 16.h),
            AppointmentInputFieldWidget(
              controller: descriptionController,
              label: "NOTES",
              readOnly: false,
            ),
            SizedBox(height: 16.h),
            StatefulBuilder(
              builder: (context, setSheetState) {
                return CheckboxListTile(
                  title: Text(
                    "Consultation Call (Video/Audio)",
                    style: TextStyle(
                      color: context.appColors.primaryTextColor,
                      fontSize: 15.sp,
                    ),
                  ),
                  value: isConsultation,
                  onChanged: (val) {
                    setSheetState(() => isConsultation = val ?? false);
                  },
                  activeColor: context.appColors.secondaryColor,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
            SizedBox(height: 16.h),
            _buildProposalDropdown(context, isDark),
            SizedBox(height: 32.h),
            SolidButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    appointmentStartTime == null ||
                    appointmentDate == null) {
                  customAlert(
                    context,
                    AlertType.error,
                    "Missing required fields",
                  );
                  return;
                }

                if (selectedProposalId == null) {
                  customAlert(
                    context,
                    AlertType.error,
                    "Please link a proposal to identify the seeker",
                  );
                  return;
                }

                final profile = SuccessGetProfileState.profile;
                final String? providerId = profile.user?.id;

                // Find the seeker (user) from the selected proposal
                String? seekerId;
                final proposals = await SuccessGetAcceptRequestState.accepts;
                if (proposals != null) {
                  try {
                    final selectedP = proposals.firstWhere(
                      (p) => p.acceptance?.id == selectedProposalId,
                    );
                    // Use the User ID from the profile, not the Profile ID
                    seekerId = selectedP.user?.user?.id;
                  } catch (_) {}
                }

                if (seekerId == null) {
                  customAlert(
                    context,
                    AlertType.error,
                    "Could not resolve seeker from selected proposal",
                  );
                  return;
                }

                context.read<ProviderBloc>().add(
                  AddAppointmentEvent(
                    appointment: Appointment(
                      title: titleController.text,
                      description: descriptionController.text,
                      appointmentDate: appointmentDate,
                      fromUser: providerId,
                      seekerId: seekerId, // Mapped to 'seeker' in Appointment.toJson()
                      providerId: providerId,
                      fromChat: false,
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
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              "Loading proposals...",
              style: TextStyle(color: context.appColors.secondaryTextColor),
            ),
          );
        }
        if (snapshot.data!.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Text(
              "No accepted proposals found to link.",
              style: TextStyle(color: context.appColors.secondaryTextColor),
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
                color: context.appColors.secondaryTextColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: context.appColors.glassBorder,
                  width: 1.5.r,
                ),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: selectedProposalId,
                dropdownColor: context.appColors.primaryBackground,
                icon: Icon(
                  FontAwesomeIcons.chevronDown,
                  color: context.appColors.secondaryTextColor,
                ),
                style: TextStyle(color: context.appColors.primaryTextColor),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  border: InputBorder.none,
                ),
                hint: Text(
                  "Select a proposal",
                  style: TextStyle(
                    color: context.appColors.glassBorder,
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




