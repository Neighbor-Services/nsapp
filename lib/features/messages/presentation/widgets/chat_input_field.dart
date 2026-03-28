import 'package:flutter/material.dart';
import 'package:nsapp/core/core.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onImagePick;
  final VoidCallback? onSchedule;

  const ChatInputField({
    super.key,
    required this.controller,
    this.onSend,
    this.onImagePick,
    this.onSchedule,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final hintColor = context.appColors.hintTextColor;
    final iconColor = context.appColors.secondaryTextColor;

    return Row(
      children: [
        
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: textColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Type a message...",
              hintStyle: TextStyle(color: hintColor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: onImagePick,
          icon: const Icon(Icons.add_photo_alternate_rounded),
          color: iconColor,
          tooltip: "Send Image",
        ),
        IconButton(
          onPressed: onSchedule,
          icon: const Icon(Icons.calendar_today_rounded),
          color: iconColor,
          tooltip: "Schedule Appointment",
        ),
        GestureDetector(
          onTap: onSend,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.appColors.primaryColor,
              shape: BoxShape.circle,
             
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
