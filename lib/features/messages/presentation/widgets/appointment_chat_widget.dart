import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/appointment_input_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

class AppointmentChatWidget extends StatefulWidget {
  const AppointmentChatWidget({super.key});

  @override
  State<AppointmentChatWidget> createState() => _AppointmentChatWidgetState();
}

class _AppointmentChatWidgetState extends State<AppointmentChatWidget> {
  TextEditingController messageController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime today = DateTime.now();
  DateTime? appointmentDate;
  DateTime? appointmentStartTime;
  DateTime? appointmentEndTime;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);

    return Container(
      width: size(context).width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            CustomTextWidget(
              text: "Send Appointment",
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            const SizedBox(height: 24),
            AppointmentInputFieldWidget(
              controller: dateController,
              label: "Appointment Date",
              onPressed: () async {
                DateTime? date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: isDark
                            ? ColorScheme.dark(
                                primary: appOrangeColor1,
                                onPrimary: Colors.white,
                                surface: const Color(0xFF1E1E2E),
                                onSurface: Colors.white,
                              )
                            : ColorScheme.light(
                                primary: appOrangeColor1,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: const Color(0xFF1E1E2E),
                              ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  appointmentDate = date;
                  dateController.text = DateFormat(
                    "EEEE yyyy-MMMM-dd",
                  ).format(date);
                }
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: size(context).width * 0.42,
                  child: AppointmentInputFieldWidget(
                    controller: startTimeController,
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: isDark
                                  ? ColorScheme.dark(
                                      primary: appOrangeColor1,
                                      onPrimary: Colors.white,
                                      surface: const Color(0xFF1E1E2E),
                                      onSurface: Colors.white,
                                    )
                                  : ColorScheme.light(
                                      primary: appOrangeColor1,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: const Color(0xFF1E1E2E),
                                    ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        DateTime now = DateTime.now();
                        DateTime date = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          time.hour,
                          time.minute,
                        );
                        appointmentStartTime = date;
                        startTimeController.text = DateFormat.jm().format(date);
                      }
                    },
                    label: "Start At",
                  ),
                ),
                SizedBox(
                  width: size(context).width * 0.42,
                  child: AppointmentInputFieldWidget(
                    controller: endTimeController,
                    onPressed: () async {
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: isDark
                                  ? ColorScheme.dark(
                                      primary: appOrangeColor1,
                                      onPrimary: Colors.white,
                                      surface: const Color(0xFF1E1E2E),
                                      onSurface: Colors.white,
                                    )
                                  : ColorScheme.light(
                                      primary: appOrangeColor1,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: const Color(0xFF1E1E2E),
                                    ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        DateTime now = DateTime.now();
                        DateTime date = DateTime(
                          now.year,
                          now.month,
                          now.day,
                          time.hour,
                          time.minute,
                        );
                        appointmentEndTime = date;
                        endTimeController.text = DateFormat.jm().format(date);
                      }
                    },
                    label: "End At",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SolidTextField(
              controller: messageController,
              hintText: 'Add a message (optional)',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, color: appOrangeColor1),
                onPressed: () async {
                  if (appointmentEndTime == null ||
                      appointmentStartTime == null ||
                      appointmentDate == null) {
                    customAlert(
                      context,
                      AlertType.error,
                      "Please complete the form before sending",
                    );
                    return;
                  }
                  if (appointmentEndTime!.isBefore(appointmentStartTime!)) {
                    customAlert(
                      context,
                      AlertType.error,
                      "Start and End time is invalid",
                    );
                    return;
                  }
                  Message message = Message(
                    isCalender: true,
                    chatRoomId: Helpers.createChatRoom(
                      sender: SuccessGetProfileState.profile.user!.id!,
                      receiver: MessageReceiverState.profile.user!.id!,
                    ),
                    withImage: false,
                    withImageAndText: false,
                    message: messageController.text.trim(),
                    sender: SuccessGetProfileState.profile.user!.id!,
                    receiver: MessageReceiverState.profile.user!.id!,
                    calenderDate: appointmentDate,
                    calenderEndDate: appointmentEndTime,
                    calenderStartDate: appointmentStartTime,
                  );
                  context.read<MessageBloc>().add(ChatEvent(message: message));
                  messageController.text = "";
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
