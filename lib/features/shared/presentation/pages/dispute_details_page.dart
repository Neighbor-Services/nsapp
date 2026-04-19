import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/core/core.dart';

class DisputeDetailsPage extends StatelessWidget {
  const DisputeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Dispute dispute = Get.arguments as Dispute;
    final textColor = context.appColors.primaryTextColor;
    final secondaryTextColor = context.appColors.hintTextColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'DISPUTE DETAILS',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.appColors.glassBorder),
            ),
            child: Icon(
              FontAwesomeIcons.chevronLeft,
              color: textColor,
              size: 18.r,
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: SizedBox(
          height: size(context).height,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 110.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                SolidContainer(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 64.w,
                            height: 64.h,
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                context,
                                dispute.status,
                              ).withAlpha(30),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: _getStatusColor(
                                  context,
                                  dispute.status,
                                ).withAlpha(50),
                              ),
                            ),
                            child: Icon(
                              FontAwesomeIcons.gavel,
                              color: _getStatusColor(context, dispute.status),
                              size: 32.r,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                context,
                                dispute.status,
                              ).withAlpha(30),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: _getStatusColor(
                                  context,
                                  dispute.status,
                                ).withAlpha(50),
                              ),
                            ),
                            child: Text(
                              dispute.status ?? 'OPEN',
                              style: TextStyle(
                                color: _getStatusColor(context, dispute.status),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        dispute.reason.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
          
                // Information Section
                _buildSection(
                  title: 'Information',
                  textColor: textColor,
                  secondaryTextColor: secondaryTextColor,
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        FontAwesomeIcons.calendar,
                        'Date Raised',
                        dispute.createdAt != null
                            ? DateFormat.yMMMMd().add_jm().format(
                                DateTime.parse(dispute.createdAt!),
                              )
                            : 'N/A',
                       
                        textColor,
                        secondaryTextColor
                      ),
                      Divider(color: context.appColors.glassBorder, height: 24),
                      _buildInfoRow(
                        context,
                        FontAwesomeIcons.fileLines,
                        'Appointment ID',
                        dispute.appointment ?? 'Global / General',
                        
                        textColor,
                        secondaryTextColor
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
          
                // Description Section
                  _buildSection(
                    title: 'Description',
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    child: Text(
                      dispute.description,
                      style: TextStyle(
                        color: textColor.withAlpha(200),
                        fontSize: 16.sp,
                        height: 1.6,
                      ),
                    ),
                  ),
          
                if (dispute.resolutionNotes != null &&
                    dispute.resolutionNotes!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  // Resolution Section
                  _buildSection(
                    title: 'Resolution Details',
                    color: context.appColors.successColor,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                    child: Text(
                      dispute.resolutionNotes!,
                      style: TextStyle(
                        color: textColor.withAlpha(200),
                        fontSize: 16.sp,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    required Color textColor,
    required Color secondaryTextColor,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w, bottom: 10.h),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color ?? secondaryTextColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SolidContainer(
          padding: EdgeInsets.all(20.r),
          backgroundColor: color?.withAlpha(20),
          borderColor: color?.withAlpha(40),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: context.appColors.glassBorder,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: textColor, size: 16.r),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context, String? status) {
    
        return context.appColors.primaryColor;
    
  }
}




