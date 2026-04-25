import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/constants/urls.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';

class DisputeCenterPage extends StatefulWidget {
  final Appointment appointment;
  final Profile currentUser;
  final Profile otherUser;

  const DisputeCenterPage({
    super.key,
    required this.appointment,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<DisputeCenterPage> createState() => _DisputeCenterPageState();
}

class _DisputeCenterPageState extends State<DisputeCenterPage> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedReason;
  File? _evidenceFile;
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'No Show',
    'Unprofessional Behavior',
    'Poor Quality of Service',
    'Payment Issue',
    'Safety Concern',
    'Other'
  ];

  Future<void> _pickEvidence() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _evidenceFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitDispute() async {
    if (_selectedReason == null || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason and description.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await Helpers.getString("token");
      final dio = Dio();
      
      // Step 1: Create Dispute
      final createResponse = await dio.post(
        '$baseUrl/interactions/disputes/',
        data: {
          'appointment': widget.appointment.id,
          'defendant': widget.otherUser.user?.id,
          'reason': _selectedReason,
          'description': _descriptionController.text.trim(),
        },
        options: Options(headers: dioHeaders(token)),
      );

      final disputeId = createResponse.data['id'];

      // Step 2: Upload Evidence if exists
      if (_evidenceFile != null) {
        String fileName = _evidenceFile!.path.split('/').last;
        FormData formData = FormData.fromMap({
          "evidence": await MultipartFile.fromFile(
            _evidenceFile!.path,
            filename: fileName,
          ),
        });

        await dio.post(
            '$baseUrl/interactions/disputes/$disputeId/upload_evidence/',
            data: formData,
            options: Options(
                headers: dioHeaders(token)
                  ..addAll({'Content-Type': 'multipart/form-data'}),
            ),
        );
      }

      if (mounted) {
        setState(() => _isSubmitting = false);
        // Show Success and Pop
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: context.appColors.cardBackground,
            title: Text('Dispute Raised', style: TextStyle(color: context.appColors.primaryTextColor)),
            content: Text(
              'Your dispute has been sent to our resolution center. We will review it shortly within 24-48 hours.',
              style: TextStyle(color: context.appColors.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // close dispute page
                },
                child: Text('OK', style: TextStyle(color: context.appColors.primaryColor)),
              )
            ],
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit dispute: ${e.response?.data}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine colors based on context
    final textColor = context.appColors.primaryTextColor;
    final hintColor = context.appColors.secondaryTextColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dispute Center", style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        backgroundColor: context.appColors.primaryBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      backgroundColor: context.appColors.primaryBackground,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: context.appColors.errorColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.appColors.errorColor.withAlpha(50)),
              ),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.circleExclamation, color: context.appColors.errorColor, size: 24.r),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      "Raising a dispute will temporarily freeze the appointment funds while we review the case.",
                      style: TextStyle(
                        color: context.appColors.errorColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Defendant Info
            CustomTextWidget(text: "DISPUTING AGAINST", color: hintColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 8.h),
            SolidContainer(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                   CircleAvatar(
                    backgroundImage: widget.otherUser.profilePictureUrl != null && widget.otherUser.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(widget.otherUser.profilePictureUrl!)
                        : null,
                    radius: 20.r,
                    child: widget.otherUser.profilePictureUrl == null ? Icon(Icons.person, color: Colors.grey) : null,
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    "${widget.otherUser.firstName} ${widget.otherUser.lastName}",
                    style: TextStyle(color: textColor, fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Reason Dropdown
            CustomTextWidget(text: "REASON FOR DISPUTE", color: hintColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.appColors.glassBorder),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedReason,
                dropdownColor: context.appColors.cardBackground,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: InputBorder.none,
                ),
                hint: Text("Select a reason", style: TextStyle(color: hintColor)),
                items: _reasons.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r, style: TextStyle(color: textColor)),
                )).toList(),
                onChanged: (val) => setState(() => _selectedReason = val),
              ),
            ),
            SizedBox(height: 24.h),

            // Description
            CustomTextWidget(text: "DETAILED DESCRIPTION", color: hintColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.appColors.glassBorder),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Explain what happened comprehensively...",
                  hintStyle: TextStyle(color: hintColor),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Evidence Upload
            CustomTextWidget(text: "EVIDENCE (OPTIONAL)", color: hintColor, fontSize: 12.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: _pickEvidence,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  color: context.appColors.primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: context.appColors.primaryColor.withAlpha(100),
                    width: 1.5.r,
                    // style: BorderStyle.solid // Consider dotted later
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_evidenceFile != null) ...[
                      Icon(FontAwesomeIcons.solidImage, color: context.appColors.primaryColor, size: 32.r),
                      SizedBox(height: 8.h),
                      Text("File selected: ${_evidenceFile!.path.split('/').last}", style: TextStyle(color: textColor, fontSize: 12.sp), textAlign: TextAlign.center),
                    ] else ...[
                      Icon(FontAwesomeIcons.cloudArrowUp, color: context.appColors.primaryColor, size: 32.r),
                      SizedBox(height: 8.h),
                      Text("Tap to upload photo evidence", style: TextStyle(color: context.appColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                    ]
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 48.h),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : SolidButton(
                    onPressed: _submitDispute,
                    label: "SUBMIT DISPUTE",
                    color: context.appColors.errorColor,
                    textColor: Colors.white,
                    height: 55.h,
                  ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
