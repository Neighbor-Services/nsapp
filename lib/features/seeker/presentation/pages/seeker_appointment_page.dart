import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import '../../../shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/models/request_data.dart';
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
          if (state is SuccessUpdateAppointmentState) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.read<SeekerBloc>().add(GetAppointmentsEvent());
              }
            });
            customAlert(context, AlertType.success, "Appointment updated");
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
                    constraints: BoxConstraints(maxWidth: 700.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLargeScreen ? 32.w : 20.w,
                              vertical: 24.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (Navigator.of(context).canPop()) {
                                          context.pop();
                                        } else {
                                          context.read<SeekerBloc>().add(
                                              ChangeSeekerTabEvent(tabIndex: 1));
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(12.r),
                                        decoration: BoxDecoration(
                                          color: context.appColors.cardBackground,
                                          borderRadius: BorderRadius.circular(14.r),
                                          border: Border.all(
                                            color: context.appColors.glassBorder,
                                            width: 1.5.r,
                                          ),
                                        ),
                                        child: FaIcon(
                                          FontAwesomeIcons.chevronLeft,
                                          size: 18.r,
                                          color: context.appColors.primaryTextColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Text(
                                      "APPOINTMENTS",
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  "MANAGE YOUR SCHEDULED MEETINGS",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: textColor.withAlpha(150),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Calendar
                          Expanded(
                            child: _buildCalendarView(context, state, isLargeScreen),
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

  Widget _buildCalendarView(BuildContext context, SeekerState state, bool isLargeScreen) {
    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;

    List<AppointmentData> appointments = [];
    if (state is SuccessGetAppointmentsState) {
      appointments = state.appointments;
    }

    events.clear();
    for (var data in appointments) {
      AppointmentData appointmentData = data;
      final isSeeker = appointmentData.role == 'seeker';
      events.add(
        CalendarEventData(
          event: appointmentData.appointment!.id,
          title:
              "${isSeeker ? '[S] ' : '[P] '}${appointmentData.appointment!.title ?? ""}",
          date:
              appointmentData.appointment!.appointmentDate ??
              DateTime.now(),
          description: appointmentData.appointment!.description ?? "",
          startTime: appointmentData.appointment?.appointmentDate,
          color: isSeeker
              ? context.appColors.secondaryColor
              : context.appColors.primaryColor,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32.w : 16.w),
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileBloc>().add(GetProfileStreamEvent());
          context.read<ProfileBloc>().add(GetProfileEvent());
          context.read<SeekerBloc>().add(GetAppointmentsEvent());
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: SizedBox(
            height: 600.h,
            child: CalendarControllerProvider(
              controller: EventController()..addAll(events),
              child: SolidContainer(
                backgroundColor: context.appColors.cardBackground,
                child: MonthView(
                  borderColor: borderColor,
                  cellBuilder:
                      (date, events, isToday, isInMonth, hideDaysNotInMonth) {
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
                            _showAppointmentDetails(context, [event], appointments);
                          },
                        );
                      },
                  weekDayBuilder: (day) {
                    return Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: context.appColors.cardBackground,
                        border: Border.all(color: borderColor, width: 0.5.r),
                      ),
                      child: Text(
                        ["M", "T", "W", "T", "F", "S", "S"][day],
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  },
                  onCellTap: (events, date) {
                    if (events.isNotEmpty) {
                      _showAppointmentDetails(context, events, appointments);
                    }
                  },
                  onEventTap: (event, date) {
                    _showAppointmentDetails(context, [event], appointments);
                  },
                  headerStyle: HeaderStyle(
                    headerTextStyle: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18.sp,
                      letterSpacing: 0.5,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                    ),
                    leftIconConfig: IconDataConfig(color: textColor),
                    rightIconConfig: IconDataConfig(color: textColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  void _handleAddToCalendar(String appointmentId, List<AppointmentData> appointments) async {
    try {
      final data = appointments.firstWhere(
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
    List<AppointmentData> appointments,
  ) {
    final sheetColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final handleColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          border: Border.all(color: borderColor, width: 1.5.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              () {
                try {
                  final appointmentData = appointments.firstWhere(
                    (element) => element.appointment?.id == data[0].event,
                  );
                  final appt = appointmentData.appointment!;
                  return Column(
                    children: [
                      if (appt.isFunded == true &&
                          appt.status == 'COMPLETED')
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: context.appColors.successColor.withAlpha(
                              20,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: context.appColors.successColor
                                  .withAlpha(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.circleCheck,
                                color: context.appColors.successColor,
                                size: 20.r,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "Project completed and funds released."
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: context.appColors.successColor,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
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
              }(),
              Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: context.appColors.glassBorder),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.calendar,
                      color: context.appColors.primaryColor,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SCHEDULED APPOINTMENT",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          DateFormat(
                            "EEEE, MMM dd, yyyy",
                          ).format(data[0].date.toLocal()),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildDetailRow(FontAwesomeIcons.heading, "Title", data[0].title),
              _buildDetailRow(
                FontAwesomeIcons.calendar,
                "Time",
                data[0].startTime != null ? DateFormat.jm().format(data[0].startTime!.toLocal()) : '',
              ),
              if (data[0].description != null &&
                  data[0].description!.isNotEmpty)
                _buildDetailRow(
                  FontAwesomeIcons.noteSticky,
                  "Description",
                  data[0].description!,
                ),
              SizedBox(height: 16.h),
              // Linked Request Details
              () {
                try {
                  final appointmentData = appointments.firstWhere(
                    (element) => element.appointment?.id == data[0].event,
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
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: context.appColors.secondaryTextColor,
                        letterSpacing: 1.0,
                      ),
                      SizedBox(height: 16.h),
                      _buildDetailRow(
                        FontAwesomeIcons.fileLines,
                        "ORIGINAL TITLE",
                        req.title ?? "N/A",
                      ),
                      _buildDetailRow(
                        FontAwesomeIcons.list,
                        "SERVICE",
                        req.service?.name ?? "N/A",
                      ),
                      if (req.price != null)
                        _buildDetailRow(
                          FontAwesomeIcons.creditCard,
                          "REQUEST PRICE",
                          "\$${req.price}",
                        ),
                      if (req.description != null &&
                          req.description!.isNotEmpty)
                        _buildDetailRow(
                          FontAwesomeIcons.fileLines,
                          "REQ. DESCRIPTION",
                          req.description!,
                        ),
                      SizedBox(height: 12.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            RequestData request = RequestData(
                              request: req,
                              user: appointmentData.user,
                            );

                            final profileState = context.read<ProfileBloc>().state;
                            final myId = profileState is SuccessGetProfileState ? profileState.profile.user?.id : null;

                            if (req.userId == myId) {
                              context.read<SeekerBloc>().add(
                                SeekerRequestDetailEvent(request: request),
                              );

                              context.push('/app/requests/${request.request?.id}', extra: request);
                             
                            } else {
                              customAlert(context, AlertType.error, "You are not authorized to view this request");
                            }
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.arrowUpRightFromSquare,
                            size: 18.r,
                            color: context.appColors.primaryColor,
                          ),
                          label: Text(
                            "VIEW FULL DETAILS",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
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
              }(),
              SizedBox(height: 24.h),

              SolidButton(
                onPressed: () {
                  try {
                    final appointmentData = appointments.firstWhere(
                      (element) =>
                          element.appointment?.id == data[0].event.toString(),
                    );
                    if (appointmentData.appointment != null) {
                      Navigator.of(context).pop();
                      context.push('/live-tracking', extra: {
                        'appointmentId': appointmentData.appointment!.id ?? '',
                        'jobLocation': LatLng(
                          double.tryParse(appointmentData.user?.latitude ?? '0.0') ?? 0.0,
                          double.tryParse(appointmentData.user?.longitude ?? '0.0') ?? 0.0,
                        ),
                      });
                    }
                  } catch (e) {
                    debugPrint("Appointment not found: $e");
                  }
                },
                icon: FontAwesomeIcons.locationDot,
                label: "TRACK PROVIDER",
                isPrimary: true,
                color: context.appColors.successColor.withAlpha(40),
                textColor: context.appColors.successColor,
                borderColor: context.appColors.successColor.withAlpha(100),
                height: 50.h,
              ),
              SizedBox(height: 16.h),
              SolidButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleAddToCalendar(data[0].event.toString(), appointments);
                },
                icon: FontAwesomeIcons.calendarCheck,
                label: "ADD TO CALENDAR",
                isPrimary: true,
                color: context.appColors.primaryColor.withAlpha(40),
                textColor: context.appColors.primaryColor,
                borderColor: context.appColors.primaryColor.withAlpha(100),
                height: 50.h,
              ),
              SizedBox(height: 16.h),
              SolidButton(
                onPressed: () {
                  try {
                    final dataApp = appointments.firstWhere(
                      (element) => element.appointment?.id == data[0].event,
                    );
                    if (dataApp.appointment != null) {
                      context.push('/create-dispute');
                    }
                  } catch (e) {
                    debugPrint("Appointment not found: $e");
                  }
                },
                label: "RAISE DISPUTE",
                isPrimary: true,
                color: context.appColors.warningColor.withAlpha(40),
                textColor: context.appColors.warningColor,
                borderColor: context.appColors.warningColor.withAlpha(100),
                height: 50.h,
              ),
              SizedBox(height: 16.h),
              SolidButton(
                onPressed: () {
                  context.read<SeekerBloc>().add(
                    CancelAppointmentEvent(id: data[0].event.toString()),
                  );
                  Navigator.of(context).pop();
                },
                label: "CANCEL APPOINTMENT",
                isPrimary: true,
                color: context.appColors.errorColor.withAlpha(40),
                textColor: context.appColors.errorColor,
                borderColor: context.appColors.errorColor.withAlpha(100),
                height: 50.h,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(FaIconData icon, String label, String value) {
    final iconBg = context.appColors.glassBorder;
    final iconColor = context.appColors.secondaryTextColor;
    final labelColor = context.appColors.glassBorder;
    final valueColor = context.appColors.primaryTextColor;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: FaIcon(icon, color: iconColor, size: 18.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(value, style: TextStyle(fontSize: 15.sp, color: valueColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







