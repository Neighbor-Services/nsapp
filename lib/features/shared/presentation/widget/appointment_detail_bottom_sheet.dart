import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class AppointmentDetailBottomSheet extends StatefulWidget {
  final AppointmentData data;

  const AppointmentDetailBottomSheet({super.key, required this.data});

  @override
  State<AppointmentDetailBottomSheet> createState() =>
      _AppointmentDetailBottomSheetState();
}

class _AppointmentDetailBottomSheetState
    extends State<AppointmentDetailBottomSheet> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _scheduleController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.data.appointment?.title,
    );
    _descriptionController = TextEditingController(
      text: widget.data.appointment?.description,
    );
    _selectedDate = widget.data.appointment?.effectiveDate;
    _scheduleController = TextEditingController(
      text: _selectedDate != null
          ? DateFormat("EEEE, MMM dd, yyyy • h:mm a").format(_selectedDate!)
          : "Date TBD",
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _scheduleController.dispose();
    super.dispose();
  }

  void _onSave() {
    final appt = widget.data.appointment;
    if (appt == null) return;

    final updatedAppt = Appointment(
      id: appt.id,
      title: _titleController.text,
      description: _descriptionController.text,
      userId: appt.userId,
      providerId: appt.providerId,
      startDate: _selectedDate,
      endDate: appt.endDate,
      scheduledTime: _selectedDate,
      appointmentDate: _selectedDate,
      status: appt.status,
      totalPrice: appt.totalPrice,
      isFunded: appt.isFunded,
    );

    final seekerBloc = context.read<SeekerBloc>();
    final providerBloc = context.read<ProviderBloc>();

    try {
      seekerBloc.add(UpdateSeekerAppointmentEvent(appointment: updatedAppt));
    } catch (_) {
      try {
        providerBloc.add(
          UpdateProviderAppointmentEvent(appointment: updatedAppt),
        );
      } catch (_) {}
    }

    setState(() {
      _isEditing = false;
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Updating appointment...")));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final contentColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white24 : Colors.black12;

    final appt = widget.data.appointment;
    final user = widget.data.user;

    if (appt == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 100 : 20),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
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
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditing)
                        TextField(
                          controller: _titleController,
                          style: TextStyle(
                            color: contentColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter title",
                            hintStyle: TextStyle(color: dividerColor),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: appOrangeColor1),
                            ),
                          ),
                        )
                      else
                        CustomTextWidget(
                          text: appt.title ?? "Appointment Details",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: contentColor,
                        ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(appt, isDark),
                    ],
                  ),
                ),
                if (!_isEditing && appt.totalPrice != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: appOrangeColor1.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: appOrangeColor1.withAlpha(50)),
                    ),
                    child: CustomTextWidget(
                      text:
                          "\$${appt.totalPrice?.toStringAsFixed(2) ?? "0.00"}",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: appOrangeColor1,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            _buildInfoSection(
              context,
              isDark: isDark,
              icon: Icons.calendar_today_rounded,
              title: "Schedule",
              subtitle: _isEditing ? null : (_scheduleController.text),
              content: _isEditing
                  ? TextField(
                      controller: _scheduleController,
                      readOnly: true,
                      style: TextStyle(color: contentColor),
                      decoration: InputDecoration(
                        hintText: "Select Date & Time",
                        hintStyle: TextStyle(color: dividerColor),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: appOrangeColor1),
                        ),
                      ),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          TimeOfDay? time = await showTimePicker(
                            context: context,
                            initialTime: _selectedDate != null
                                ? TimeOfDay.fromDateTime(_selectedDate!)
                                : TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                              _scheduleController.text = DateFormat(
                                "EEEE, MMM dd, yyyy • h:mm a",
                              ).format(_selectedDate!);
                            });
                          }
                        }
                      },
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            _buildInfoSection(
              context,
              isDark: isDark,
              icon: Icons.person_outline_rounded,
              title: "Participant",
              subtitle: user != null
                  ? "${user.firstName ?? ''} ${user.lastName ?? ''}".trim()
                  : "Unknown User",
              trailing: user?.userType?.toUpperCase() ?? "",
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: "Description",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
                if (!_isEditing)
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: appOrangeColor1,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isEditing)
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: TextStyle(color: contentColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Enter description",
                  hintStyle: TextStyle(color: dividerColor),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white10
                      : Colors.black.withAlpha(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              )
            else
              Text(
                appt.description ?? "No description provided.",
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            const SizedBox(height: 40),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: secondaryTextColor,
                        side: BorderSide(color: dividerColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appOrangeColor1,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white10
                        : Colors.black.withAlpha(20),
                    foregroundColor: contentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required bool isDark,
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailing,
    Widget? content,
  }) {
    final contentColor = isDark ? Colors.white : Colors.black87;
    final glassColor = isDark
        ? Colors.white.withAlpha(10)
        : Colors.black.withAlpha(10);
    final glassBorderColor = isDark ? Colors.white12 : Colors.black12;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glassBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appOrangeColor1.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: appOrangeColor1, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                if (content != null)
                  content
                else
                  CustomTextWidget(
                    text: subtitle ?? "",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: contentColor,
                  ),
              ],
            ),
          ),
          if (content == null && trailing != null && trailing.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withAlpha(10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomTextWidget(
                text: trailing,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: contentColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Appointment appt, bool isDark) {
    Color color = Colors.blue;
    String text = appt.status ?? "Scheduled";
    if (appt.status == 'COMPLETED')
      color = Colors.green;
    else if (appt.status == 'CANCELLED')
      color = Colors.red;
    else if (appt.isFunded == false) {
      color = Colors.amber;
      text = "Awaiting Funding";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: CustomTextWidget(
        text: text.toUpperCase(),
        color: isDark ? Colors.white : color.withAlpha(200),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
