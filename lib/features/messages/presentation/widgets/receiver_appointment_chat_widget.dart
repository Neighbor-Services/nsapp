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
  final DateTime endTime;
  final String message;
  final String from;
  final String chatID;

  const ReceiverAppointmentChatWidget({
    super.key,
    required this.startTime,
    required this.appointmentDate,
    required this.endTime,
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
      padding: EdgeInsets.only(bottom: 12, top: 4, left: 8, right: 40),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(6),
                ),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4),
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
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today_rounded,
                              color: iconColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Appointment",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      PopupMenuButton(
                        icon: Icon(Icons.more_horiz_rounded, color: iconColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
                                  startDate: startTime,
                                  endDate: endTime,
                                  appointmentDate: appointmentDate,
                                  fromUser: from,
                                  fromChat: true,
                                  userId: SuccessGetProfileState
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
                                  Icons.add_to_drive_rounded,
                                  size: 18,
                                  color: secondaryTextColor,
                                ),
                                const SizedBox(width: 10),
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
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: dividerColor, height: 1),
                  ),
                  _buildInfoRow(
                    Icons.event_available_rounded,
                    DateFormat("EEEE, MMM dd, yyyy").format(appointmentDate),
                    textColor,
                    secondaryTextColor,
                    iconBgColor,
                    context,
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    Icons.access_time_rounded,
                    "${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}",
                    textColor,
                    secondaryTextColor,
                    iconBgColor,
                    context,
                  ),
                  if (message.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: dividerColor, height: 1),
                    ),
                    Text(
                      message,
                      style: TextStyle(
                        color: context.appColors.primaryTextColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                DateFormat("HH:mm").format(appointmentDate.toLocal()),
                style: TextStyle(
                  color: timestampColor,
                  fontSize: 10,
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
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.appColors.primaryTextColor, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
