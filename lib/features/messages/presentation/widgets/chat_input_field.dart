import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : Colors.black45;
    final iconColor = isDark ? Colors.white70 : Colors.black54;

    return Row(
      children: [
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
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: textColor, fontSize: 16),
            decoration: InputDecoration(
              hintText: "Type a message...",
              hintStyle: TextStyle(color: hintColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onSend,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFE94E1B).withAlpha(200)
                  : const Color(0xFFE94E1B),
              shape: BoxShape.circle,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: const Color(0xFFE94E1B).withAlpha(50),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
