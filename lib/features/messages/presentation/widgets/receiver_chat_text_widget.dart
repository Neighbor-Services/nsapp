import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReceiverChatTextWidget extends StatelessWidget {
  final String message;
  final DateTime dateTime;

  const ReceiverChatTextWidget({
    super.key,
    required this.message,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isDark
        ? const Color(0xFF2E2E3E)
        : const Color(0xFFEFEFEF);
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final timestampColor = isDark
        ? Colors.white.withAlpha(100)
        : Colors.black54;
    final shadowColor = isDark
        ? Colors.black.withAlpha(30)
        : Colors.grey.withAlpha(20);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4, left: 8, right: 40),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: const BorderRadius.only(
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
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SelectableText(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                DateFormat("HH:mm").format(dateTime.toLocal()),
                style: TextStyle(
                  color: timestampColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
