import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

class RequestFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController serviceTextController;
  final TextEditingController locController;
  final TextEditingController scheduledTimeController;
  
  final Widget servicePicker;
  final bool isOtherServiceSelected;
  final VoidCallback onLocationTap;
  final VoidCallback onScheduleTap;
  final Widget imageSelector;
  
  final String submitButtonLabel;
  final VoidCallback onSubmit;

  const RequestFormWidget({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.serviceTextController,
    required this.locController,
    required this.scheduledTimeController,
    required this.servicePicker,
    required this.isOtherServiceSelected,
    required this.onLocationTap,
    required this.onScheduleTap,
    required this.imageSelector,
    required this.submitButtonLabel,
    required this.onSubmit,
  });

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: context.appColors.primaryTextColor,
        letterSpacing: 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SolidContainer(
      padding: EdgeInsets.all(24.r),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(context, "Request Title"),
            SizedBox(height: 12.h),
            SolidTextField(
              controller: titleController,
              hintText: "Title",
              prefixIcon: FontAwesomeIcons.heading,
              validator: (val) => val!.isEmpty ? "Title is required" : null,
            ),
            SizedBox(height: 24.h),
            _buildLabel(context, "Description"),
            SizedBox(height: 12.h),
            SolidTextField(
              controller: descriptionController,
              hintText: "Description",
              isMultiLine: true,
              prefixIcon: FontAwesomeIcons.alignLeft,
              validator: (val) => val!.isEmpty ? "Description is required" : null,
            ),
            SizedBox(height: 24.h),
            _buildLabel(context, "Service Category"),
            SizedBox(height: 12.h),
            servicePicker,
            if (isOtherServiceSelected) ...[
              SizedBox(height: 24.h),
              SolidTextField(
                controller: serviceTextController,
                hintText: "Enter custom service name",
                label: "Custom Service",
                prefixIcon: FontAwesomeIcons.penNib,
                validator: (val) => val!.isEmpty ? "Service name is required" : null,
              ),
            ],
            SizedBox(height: 24.h),
            _buildLabel(context, "Location"),
            SizedBox(height: 12.h),
            SolidTextField(
              controller: locController,
              hintText: "Where is the service needed?",
              prefixIcon: FontAwesomeIcons.locationDot,
              readOnly: true,
              onTap: onLocationTap,
              validator: (val) => val!.isEmpty ? "Location is required" : null,
            ),
            SizedBox(height: 24.h),
            _buildLabel(context, "Schedule Time"),
            SizedBox(height: 12.h),
            SolidTextField(
              controller: scheduledTimeController,
              hintText: "When should it start?",
              prefixIcon: FontAwesomeIcons.calendarDay,
              readOnly: true,
              onTap: onScheduleTap,
              validator: (val) => val!.isEmpty ? "Time is required" : null,
            ),
            SizedBox(height: 24.h),
            _buildLabel(context, "Reference Image (Optional)"),
            SizedBox(height: 12.h),
            imageSelector,
            SizedBox(height: 40.h),
            SolidButton(
              label: submitButtonLabel,
              isPrimary: true,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
