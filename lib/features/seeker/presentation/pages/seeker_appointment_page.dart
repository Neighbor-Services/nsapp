import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/models/appointment.dart';
import '../../../shared/presentation/widget/loading_widget.dart';
import '../../../../features/shared/presentation/pages/create_dispute_page.dart';
import '../../../../features/shared/presentation/pages/live_tracking_page.dart';
import 'package:nsapp/core/core.dart';

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
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final textColor = context.appColors.primaryTextColor;

    // final iconBg = context.appColors.glassBorder;
    // final iconColor = context.appColors.primaryTextColor;

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
                    constraints: BoxConstraints(maxWidth: 700),
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
                                  "APPOINTMENTS",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "MANAGE YOUR SCHEDULED MEETINGS",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: textColor.withAlpha(150),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Calendar
                          Expanded(
                            child: _buildCalendarView(
                              context,
                              isLargeScreen
                              
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
  ) {
    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;

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
                color: context.appColors.secondaryColor,
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16),
            child: CalendarControllerProvider(
              controller: EventController()..addAll(events),
              child: SolidContainer(
                backgroundColor: context.appColors.cardBackground,
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
                        _showAppointmentDetails(context, [event]);
                      },
                    );
                  },
                  weekDayBuilder: (day) {
                    return Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: context.appColors.cardBackground,
                        border: Border.all(color: borderColor, width: 0.5),
                      ),
                      child: Text(
                        ["S", "M", "T", "W", "T", "F", "S"][day],
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                  onCellTap: (events, date) {
                    if (events.isNotEmpty) {
                      _showAppointmentDetails(context, events);
                    }
                  },
                  onEventTap: (event, date) {
                    _showAppointmentDetails(context, [event]);
                  },
                  headerStyle: HeaderStyle(
                    headerTextStyle: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                    decoration: BoxDecoration(color: context.appColors.cardBackground),
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
    
  ) {
    final sheetColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final handleColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
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
                          
                          if (appt.isFunded == true &&
                              appt.status == 'COMPLETED')
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.appColors.successColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.appColors.successColor.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                children: [
                                   Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: context.appColors.successColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Project completed and funds released.".toUpperCase(),
                                      style: TextStyle(
                                        color: context.appColors.successColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
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
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: context.appColors.glassBorder),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: context.appColors.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SCHEDULED APPOINTMENT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: 0.5,
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
                data[0].title
               
              ),
              _buildDetailRow(
                Icons.schedule_rounded,
                "Time",
                "${data[0].startTime != null ? DateFormat.jm().format(data[0].startTime!.toLocal()) : ''} - ${data[0].endTime != null ? DateFormat.jm().format(data[0].endTime!.toLocal()) : ''}"
               
              ),
              if (data[0].description != null &&
                  data[0].description!.isNotEmpty)
                _buildDetailRow(
                  Icons.notes_rounded,
                  "Description",
                  data[0].description!
                 
                ),
              const SizedBox(height: 24),

              // Escrow Actions
              if (SuccessGetAppointmentsState.appointments != null)
                FutureBuilder<List<AppointmentData>>(
                  future: SuccessGetAppointmentsState.appointments,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    try {
                    
                       
                      return const SizedBox();
                    } catch (e) {
                      return const SizedBox();
                    }
                  },
                ),

              SolidButton(
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
                icon: Icons.location_on_rounded,
                label: "TRACK PROVIDER",
                isPrimary: true,
                color: context.appColors.successColor.withAlpha(40),
                textColor: context.appColors.successColor,
                borderColor: context.appColors.successColor.withAlpha(100),
                height: 50,
              ),
              const SizedBox(height: 16),
              SolidButton(
                onPressed: () {
                  Get.back();
                  _handleAddToCalendar(data[0].event.toString());
                },
                icon: Icons.event_available,
                label: "ADD TO CALENDAR",
                isPrimary: true,
                color: context.appColors.primaryColor.withAlpha(40),
                textColor: context.appColors.primaryColor,
                borderColor: context.appColors.primaryColor.withAlpha(100),
                height: 50,
              ),
              const SizedBox(height: 16),
              SolidButton(
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
                label: "RAISE DISPUTE",
                isPrimary: true,
                color: context.appColors.warningColor.withAlpha(40),
                textColor: context.appColors.warningColor,
                borderColor: context.appColors.warningColor.withAlpha(100),
                height: 50,
              ),
              const SizedBox(height: 16),
              SolidButton(
                onPressed: () {
                  context.read<SeekerBloc>().add(
                    CancelAppointmentEvent(id: data[0].event.toString()),
                  );
                  Get.back();
                },
                label: "CANCEL APPOINTMENT",
                isPrimary: true,
                color: context.appColors.errorColor.withAlpha(40),
                textColor: context.appColors.errorColor,
                borderColor: context.appColors.errorColor.withAlpha(100),
                height: 50,
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
   
  ) {
    final iconBg = context.appColors.glassBorder;
    final iconColor = context.appColors.secondaryTextColor;
    final labelColor = context.appColors.glassBorder;
    final valueColor = context.appColors.primaryTextColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
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
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: labelColor,
                    letterSpacing: 0.5,
                  ),
                ),
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
