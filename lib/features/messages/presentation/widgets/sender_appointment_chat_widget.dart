import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/appointment.dart';

import '../../../provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/core/core.dart';

class SenderAppointmentChatWidget extends StatelessWidget {
  final DateTime startTime;
  final DateTime appointmentDate;
  final String message;
  final String from;
  final String chatID;
  final String seekerId;
  final VoidCallback onLongPressed;

  const SenderAppointmentChatWidget({
    super.key,
    required this.startTime,
    required this.appointmentDate,
    required this.message,
    required this.from,
    required this.onLongPressed,
    required this.chatID,
    required this.seekerId,
  });

  @override
  Widget build(BuildContext context) {
    final timestampColor = context.appColors.glassBorder;

    // Use brand color for sender bubble consistently, or adaptive colors if preferred.
    // For now, keeping brand color but making other elements adaptive.
    final bubbleColor = context.appColors.primaryColor;
    final popupColor = context.appColors.cardBackground;
    final popupIconColor = context.appColors.secondaryTextColor;
    final popupTextColor = context.appColors.primaryTextColor;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12.h,
        top: 4.h,
        right: 8.w,
        left: 40.w,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onLongPress: onLongPressed,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: bubbleColor.withAlpha(10),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(6.r),
                ),
                border: Border.all(
                  color: context.appColors.primaryColor,
                  width: 1.r,
                ),
                boxShadow: [
                  BoxShadow(
                    color: bubbleColor.withAlpha(40),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: context.appColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white,
                                size: 18.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              "Appointment",
                              style: TextStyle(
                                color: context.appColors.primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton(
                          icon: Icon(
                            Icons.more_horiz_rounded,
                            color: context.appColors.primaryTextColor,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          color: popupColor,
                          onSelected: (val) async {
                            if (val == 1) {
                              final savedMessage = await Helpers.getString(
                                chatID,
                              );
                              if (savedMessage != "") {
                                customAlert(
                                  context,
                                  AlertType.warning,
                                  "This appointment is already in your calendar",
                                );
                                return;
                              }
                              debugPrint("Seeker ID: $seekerId");
                              context.read<ProviderBloc>().add(
                                AddAppointmentEvent(
                                  appointment: Appointment(
                                    chatID: chatID,
                                    title: "Scheduled Appointment From Chat",
                                    description: message,
                                    appointmentDate: appointmentDate,
                                    fromUser: from,
                                    fromChat: true,
                                    seekerId: seekerId,
                                    providerId: from,
                                    status: "SCHEDULED",
                                    isConsultation: false,
                                    isFunded: false,
                                    totalPrice: 0.0,
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_to_drive_rounded,
                                    size: 18.r,
                                    color: popupIconColor,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "Add to Calendar",
                                    style: TextStyle(color: popupTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Divider(color: context.appColors.primaryColor, height: 1.h),
                    ),
                    _buildInfoRow(
                      Icons.event_available_rounded,
                      DateFormat("EEEE, MMM dd, yyyy").format(appointmentDate),
                      context,
                    ),
                    SizedBox(height: 10.h),
                    _buildInfoRow(
                      Icons.access_time_rounded,
                      DateFormat.jm().format(startTime),
                      context,
                    ),
                    if (message.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(color: context.appColors.primaryColor, height: 1.h),
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          color: context.appColors.primaryTextColor,
                          fontSize: 14.sp,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 4.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 14.r,
                      color: timestampColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat("HH:mm").format(appointmentDate.toLocal()),
                      style: TextStyle(
                        color: timestampColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: context.appColors.primaryColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.white, size: 14.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.appColors.primaryTextColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
