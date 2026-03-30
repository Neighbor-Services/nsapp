import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/message.dart';
import 'package:nsapp/features/messages/presentation/bloc/message_bloc.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/appointment_input_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/core/core.dart';

class AppointmentChatWidget extends StatefulWidget {
  const AppointmentChatWidget({super.key});

  @override
  State<AppointmentChatWidget> createState() => _AppointmentChatWidgetState();
}

class _AppointmentChatWidgetState extends State<AppointmentChatWidget> {
  TextEditingController messageController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime today = DateTime.now();
  DateTime? appointmentDate;
  DateTime? appointmentStartTime;
  @override
  Widget build(BuildContext context) {
    final bgColor = context.appColors.primaryBackground;
    final textColor = context.appColors.primaryTextColor;

    return Container(
      width: size(context).width,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                margin: EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: context.appColors.glassBorder,
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
                        colorScheme: ColorScheme.fromSeed(seedColor: context.appColors.cardBackground),
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
            AppointmentInputFieldWidget(
              onPressed: () async {
                TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: context.appColors.cardBackground,
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
              controller: startTimeController,
            ),
            const SizedBox(height: 24),
            SolidTextField(
              controller: messageController,
              hintText: 'Add a message (optional)',
              suffixIcon: IconButton(
                icon: Icon(Icons.send_rounded, color: context.appColors.secondaryColor),
                onPressed: () async {
                  if (appointmentStartTime == null ||
                      appointmentDate == null) {
                    customAlert(
                      context,
                      AlertType.error,
                      "Please complete the form before sending",
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
