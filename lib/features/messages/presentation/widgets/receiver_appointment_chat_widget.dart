import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';

import '../../../provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/core/core.dart';

class ReceiverAppointmentChatWidget extends StatelessWidget {
  final DateTime startTime;
  final DateTime appointmentDate;
  final String message;
  final String from;
  final String chatID;

  const ReceiverAppointmentChatWidget({
    super.key,
    required this.startTime,
    required this.appointmentDate,
    required this.message,
    required this.from,
    required this.chatID,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final shadowColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.glassBorder;
    final iconBgColor = context.appColors.glassBorder;
    final iconColor = context.appColors.primaryTextColor;
    final timestampColor = context.appColors.glassBorder;
    final dividerColor = context.appColors.glassBorder;
    final popupColor = context.appColors.cardBackground;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12.h,
        top: 4.h,
        left: 8.w,
        right: 40.w,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                  bottomLeft: Radius.circular(6.r),
                ),
                border: Border.all(color: borderColor, width: 1.r),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
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
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              FontAwesomeIcons.calendar,
                              color: iconColor,
                              size: 18.r,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Appointment",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton(
                        icon: FaIcon(FontAwesomeIcons.ellipsis, color: iconColor),
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
                            context.read<ProviderBloc>().add(
                              AddAppointmentEvent(
                                appointment: Appointment(
                                  chatID: chatID,
                                  title: "Scheduled Appointment From Chat",
                                  description: message,
                                  appointmentDate: appointmentDate,
                                  fromUser: from,
                                  fromChat: true,
                                  seekerId: SuccessGetProfileState
                                      .profile
                                      .user
                                      ?.id, // seeker
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
                                  FontAwesomeIcons.hardDrive,
                                  size: 18.r,
                                  color: secondaryTextColor,
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  "Add to Calendar",
                                  style: TextStyle(color: textColor),
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
                    child: Divider(color: dividerColor, height: 1.h),
                  ),
                  _buildInfoRow(
                    FontAwesomeIcons.calendarCheck,
                    DateFormat("EEEE, MMM dd, yyyy").format(appointmentDate),
                    textColor,
                    secondaryTextColor,
                    iconBgColor,
                    context,
                  ),
                  SizedBox(height: 10.h),
                  _buildInfoRow(
                    FontAwesomeIcons.clock,
                    DateFormat.jm().format(startTime),
                    textColor,
                    secondaryTextColor,
                    iconBgColor,
                    context,
                  ),
                  if (message.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Divider(color: dividerColor, height: 1.h),
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
              padding: EdgeInsets.only(top: 4.h, left: 4.w),
              child: Text(
                DateFormat("HH:mm").format(appointmentDate.toLocal()),
                style: TextStyle(
                  color: timestampColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color textColor,
    Color iconColor,
    Color iconBgColor,
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: context.appColors.primaryTextColor, size: 14.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}


