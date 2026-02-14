import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/appointment.dart';

enum AlertType { success, error, warning }

class DialogUtils {
  static void showCustomAlert(
    BuildContext context,
    AlertType type,
    String message, {
    bool autoPop = true,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        Color alertColor = (type == AlertType.success)
            ? Colors.green
            : (type == AlertType.warning)
            ? Colors.orange
            : Colors.red;

        IconData alertIcon = (type == AlertType.success)
            ? Icons.check_circle_rounded
            : (type == AlertType.warning)
            ? Icons.warning_rounded
            : Icons.error_rounded;

        String alertTitle = (type == AlertType.success)
            ? "SUCCESS"
            : (type == AlertType.warning)
            ? "WARNING"
            : "ERROR";

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
        final secondaryTextColor = isDark
            ? Colors.white.withAlpha(220)
            : const Color(0xFF1E1E2E).withAlpha(200);
        final borderColor = isDark
            ? Colors.white.withAlpha(50)
            : Colors.black.withAlpha(20);

        return Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: alertColor.withAlpha(30),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: alertColor.withAlpha(20),
                      border: Border.all(
                        color: alertColor.withAlpha(40),
                        width: 2,
                      ),
                    ),
                    child: Icon(alertIcon, color: alertColor, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    alertTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                  if (!autoPop) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.white.withAlpha(15)
                              : Colors.black.withAlpha(10),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
    if (autoPop) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });
    }
  }

  static void addToCalendar(Appointment appointment) async {
    final start =
        appointment.appointmentDate ?? appointment.startDate ?? DateTime.now();
    final end = appointment.endDate ?? start.add(const Duration(hours: 1));

    final dtstamp = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(DateTime.now());
    final dtstart = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(start.toUtc());
    final dtend = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(end.toUtc());

    final summary = appointment.title ?? "Service Appointment";
    final description = appointment.description ?? "";

    final ics =
        "BEGIN:VCALENDAR\n"
        "VERSION:2.0\n"
        "PRODID:-//Neighbor Service//NONSGML v1.0//EN\n"
        "BEGIN:VEVENT\n"
        "UID:${appointment.id}@neighborservice.com\n"
        "DTSTAMP:$dtstamp\n"
        "DTSTART:$dtstart\n"
        "DTEND:$dtend\n"
        "SUMMARY:$summary\n"
        "DESCRIPTION:$description\n"
        "END:VEVENT\n"
        "END:VCALENDAR";

    final uri = Uri.dataFromString(
      ics,
      mimeType: 'text/calendar',
      parameters: {'charset': 'utf-8'},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch calendar URI");
    }
  }
}
