import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/messages/presentation/pages/chat_page.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_request_detail_page.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_details_page.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/core/core.dart';

class AppointmentDetailBottomSheet extends StatefulWidget {
  final AppointmentData data;

  const AppointmentDetailBottomSheet({super.key, required this.data});

  @override
  State<AppointmentDetailBottomSheet> createState() =>
      _AppointmentDetailBottomSheetState();
}

class _AppointmentDetailBottomSheetState
    extends State<AppointmentDetailBottomSheet> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _scheduleController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.data.appointment?.title,
    );
    _descriptionController = TextEditingController(
      text: widget.data.appointment?.description,
    );
    _selectedDate = widget.data.appointment?.effectiveDate;
    _scheduleController = TextEditingController(
      text: _selectedDate != null
          ? DateFormat("EEEE, MMM dd, yyyy â€¢ h:mm a").format(_selectedDate!)
          : "Date TBD",
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _onSave() {
    final appt = widget.data.appointment;
    if (appt == null) return;

    final updatedAppt = Appointment(
      id: appt.id,
      title: _titleController.text,
      description: _descriptionController.text,
      seekerId: appt.seekerId,
      providerId: appt.providerId,
      appointmentDate: _selectedDate,
      status: appt.status,
      totalPrice: appt.totalPrice,
      isFunded: appt.isFunded,
    );

    final seekerBloc = context.read<SeekerBloc>();
    final providerBloc = context.read<ProviderBloc>();

    try {
      seekerBloc.add(UpdateSeekerAppointmentEvent(appointment: updatedAppt));
    } catch (_) {
      try {
        providerBloc.add(
          UpdateProviderAppointmentEvent(appointment: updatedAppt),
        );
      } catch (_) {}
    }

    setState(() {
      _isEditing = false;
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Updating appointment...")));
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.appColors.surfaceBackground;
    final contentColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.hintTextColor;
    final dividerColor = context.appColors.glassBorder;

    final appt = widget.data.appointment;
    final user = widget.data.user;

    if (appt == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        border: Border.all(color: dividerColor, width: 1.5.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isEditing)
                  TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "Enter title",
                      hintStyle: TextStyle(color: dividerColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: context.appColors.secondaryColor,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CustomTextWidget(
                          text: (appt.title ?? "Appointment Details").toUpperCase(),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: contentColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      if (widget.data.role != null)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: context.appColors.secondaryColor.withAlpha(40),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: context.appColors.secondaryColor, width: 1.r),
                          ),
                          child: Text(
                            widget.data.role!.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.secondaryColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                SizedBox(height: 8.h),
              ],
            ),

            SizedBox(height: 32.h),
            _buildInfoSection(
              context,

              icon: FontAwesomeIcons.calendar,
              title: "Schedule",
              subtitle: _isEditing ? null : (_scheduleController.text),
              content: _isEditing
                  ? TextField(
                      controller: _scheduleController,
                      readOnly: true,
                      style: TextStyle(color: contentColor),
                      decoration: InputDecoration(
                        hintText: "Select Date & Time",
                        hintStyle: TextStyle(color: dividerColor),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: context.appColors.secondaryColor,
                          ),
                        ),
                      ),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: _selectedDate != null
                                ? TimeOfDay.fromDateTime(_selectedDate!)
                                : TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              _scheduleController.text = DateFormat(
                                "EEEE, MMM dd, yyyy â€¢ h:mm a",
                              ).format(_selectedDate!);
                            });
                          }
                        }
                      },
                    )
                  : null,
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: () {
                Get.back();
                context.read<MessageBloc>().add(
                  SetMessageReceiverEvent(profile: user!),
                );
                context.read<ProviderBloc>().add(
                  NavigateProviderEvent(page: 4, widget: const ChatPage()),
                );
              },
              child: _buildInfoSection(
                context,

                icon: FontAwesomeIcons.user,
                title: "Participant",
                subtitle: user != null
                    ? (user.firstName ?? '').trim()
                    : "Unknown User",
                trailing: user?.userType?.toUpperCase() ?? "",
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "DESCRIPTION",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                  letterSpacing: 0.5,
                ),
                if (!_isEditing)
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: Icon(
                      FontAwesomeIcons.penToSquare,
                      color: context.appColors.hintTextColor,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            if (_isEditing)
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: TextStyle(color: contentColor, fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: "Enter description",
                  hintStyle: TextStyle(color: dividerColor),
                  filled: true,
                  fillColor: context.appColors.glassBorder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              )
            else
              Text(
                appt.description ?? "No description provided.",
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 15.sp,
                  height: 1.6,
                ),
              ),
            if (!_isEditing && appt.serviceRequest != null) ...[
              Divider(height: 48.h),
              CustomTextWidget(
                text: "LINKED REQUEST",
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                color: context.appColors.secondaryTextColor,
                letterSpacing: 1.0,
              ),
              SizedBox(height: 16.h),
              _buildInfoSection(
                context,
                icon: FontAwesomeIcons.fileLines,
                title: "Original Title",
                subtitle: appt.serviceRequest?.title ?? "N/A",
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    final req = appt.serviceRequest;
                    Get.back();
                    if (req == null) return;
                    if (req.userId == SuccessGetProfileState.profile.user?.id && !DashboardState.isProvider) {
                      final requestData = RequestData(
                        request: req,
                        user: widget.data.user,
                      );
                      context.read<SeekerBloc>().add(
                        SeekerRequestDetailEvent(request: requestData),
                      );
                      context.read<SeekerBloc>().add(
                        NavigateSeekerEvent(
                          page: 1,
                          widget: const SeekerRequestDetailsPage(),
                        ),
                      );  
                    } else if (DashboardState.isProvider) {
                      final requestData = RequestData(
                        request: req,
                        user: widget.data.user,
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
                      fontWeight: FontWeight.bold,
                      color: context.appColors.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: 40.h),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: SolidButton(
                      label: "CANCEL",
                      onPressed: () => setState(() => _isEditing = false),
                      isPrimary: false,
                      color: Colors.transparent,
                      textColor: Colors.white,
                      borderColor: dividerColor,
                      height: 50.h,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: SolidButton(
                      label: "SAVE CHANGES",
                      onPressed: _onSave,
                      color: context.appColors.secondaryColor,
                      height: 50.h,
                    ),
                  ),
                ],
              )
            else
              SolidButton(
                label: "CLOSE",
                onPressed: () => Navigator.pop(context),
                isPrimary: false,
                color: context.appColors.hintTextColor,
                textColor: Colors.white,
                borderColor: dividerColor,
                height: 50.h,
              ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    Widget? content,
  }) {
    final contentColor = context.appColors.primaryTextColor;
    final glassBorderColor = context.appColors.glassBorder;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.appColors.cardBackground,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: glassBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: context.appColors.secondaryColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: context.appColors.hintTextColor, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: context.appColors.hintTextColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                if (content != null)
                  content
                else
                  CustomTextWidget(
                    text: subtitle ?? "",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: contentColor,
                  ),
              ],
            ),
          ),
          if (content == null && trailing != null && trailing.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: context.appColors.glassBorder,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: CustomTextWidget(
                text: trailing,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
            ),
        ],
      ),
    );
  }
}




