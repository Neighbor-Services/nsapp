import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
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
import '../../../shared/presentation/widget/loading_widget.dart';
import '../../../../features/shared/presentation/pages/create_dispute_page.dart';
import '../../../../features/shared/presentation/pages/live_tracking_page.dart';
import 'package:nsapp/core/core.dart';
import 'seeker_request_details_page.dart';

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
                                Text(
                                  "APPOINTMENTS",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "MANAGE YOUR SCHEDULED MEETINGS",
                                  style: TextStyle(
                                    fontSize: 10.sp,
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
                            child: _buildCalendarView(context, isLargeScreen),
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

  Widget _buildCalendarView(BuildContext context, bool isLargeScreen) {
    final textColor = context.appColors.primaryTextColor;
    final borderColor = context.appColors.glassBorder;

    return FutureBuilder<List<AppointmentData>>(
      future: SuccessGetAppointmentsState.appointments,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          events.clear();
          for (var data in snapshot.data!) {
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
                            _showAppointmentDetails(context, [event]);
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
                          fontWeight: FontWeight.w900,
                          fontSize: 12.sp,
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
                                  Icon(
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
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: context.appColors.glassBorder),
                    ),
                    child: Icon(
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
                            fontWeight: FontWeight.w900,
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
                "${data[0].startTime != null ? DateFormat.jm().format(data[0].startTime!.toLocal()) : ''}",
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
                      final req = appt.serviceRequest;

                      if (req == null) return const SizedBox();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 32.h),
                          CustomTextWidget(
                            text: "LINKED REQUEST",
                            fontWeight: FontWeight.w900,
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
                                Get.back();
                                RequestData request = RequestData(
                                  request: req,
                                  user: appointmentData.user,
                                );

                                if (req.userId ==
                                    SuccessGetProfileState.profile.user?.id) {
                                      SeekerRequestDetailState.request =
                                      RequestData(
                                        request: req,
                                        user: appointmentData.user,
                                      );
                                  context.read<SeekerBloc>().add(
                                    SeekerRequestDetailEvent(request: request),
                                  );

                                  context.read<SeekerBloc>().add(
                                    NavigateSeekerEvent(
                                      page: 1,
                                      widget: const SeekerRequestDetailsPage(),
                                    ),
                                  );
                                 
                                } else {
                                  customAlert(context, AlertType.error, "You are not authorized to view this request");
                                }
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
                                  fontWeight: FontWeight.w900,
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
              SizedBox(height: 24.h),

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
                            element.appointment?.id == data[0].event.toString(),
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
                  Get.back();
                  _handleAddToCalendar(data[0].event.toString());
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
                height: 50.h,
              ),
              SizedBox(height: 16.h),
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
                height: 50.h,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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
            child: Icon(icon, color: iconColor, size: 18.r),
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
                    fontWeight: FontWeight.w900,
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


