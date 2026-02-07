import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/appointment.dart';

import '../../../provider/presentation/bloc/provider_bloc.dart';

class SenderAppointmentChatWidget extends StatelessWidget {
  final DateTime startTime;
  final DateTime appointmentDate;
  final DateTime endTime;
  final String message;
  final String from;
  final String chatID;
  final String seekerId;
  final VoidCallback onLongPressed;

  const SenderAppointmentChatWidget({
    super.key,
    required this.startTime,
    required this.appointmentDate,
    required this.endTime,
    required this.message,
    required this.from,
    required this.onLongPressed,
    required this.chatID,
    required this.seekerId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timestampColor = isDark
        ? Colors.white.withAlpha(100)
        : Colors.black54;

    // Use brand color for sender bubble consistently, or adaptive colors if preferred.
    // For now, keeping brand color but making other elements adaptive.
    final bubbleColor = appDeepBlueColor1;
    final popupColor = isDark ? const Color(0xFF2E2E3E) : Colors.white;
    final popupIconColor = isDark ? Colors.white70 : Colors.black54;
    final popupTextColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4, right: 8, left: 40),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(6),
                  ),
                  border: Border.all(
                    color: Colors.white.withAlpha(30),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: bubbleColor.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Appointment",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        PopupMenuButton(
                          icon: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                          ),
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
                              debugPrint("Seeker ID: $seekerId");
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
                                    userId: seekerId,
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
                                    color: popupIconColor,
                                  ),
                                  const SizedBox(width: 10),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    _buildInfoRow(
                      Icons.event_available_rounded,
                      DateFormat("EEEE, MMM dd, yyyy").format(appointmentDate),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.access_time_rounded,
                      "${DateFormat.jm().format(startTime)} - ${DateFormat.jm().format(endTime)}",
                    ),
                    if (message.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.white12, height: 1),
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: timestampColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat("HH:mm").format(appointmentDate.toLocal()),
                      style: TextStyle(
                        color: timestampColor,
                        fontSize: 10,
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white.withAlpha(200), size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
