import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';
import 'package:nsapp/core/models/audit_log.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetAuditLogsEvent());
  }

  FaIconData _getFaIcon(String? action) {
    if (action == null) return FontAwesomeIcons.circleQuestion;
    switch (action) {
      case 'LOGIN':
        return FontAwesomeIcons.rightToBracket;
      case 'LOGOUT':
        return FontAwesomeIcons.rightFromBracket;
      case 'REGISTER':
        return FontAwesomeIcons.userPlus;
      case 'UPDATE_PROFILE':
        return FontAwesomeIcons.userGear;
      case 'CREATE_REQUEST':
        return FontAwesomeIcons.fileSignature;
      case 'ACCEPT_REQUEST':
        return FontAwesomeIcons.handshake;
      case 'APPROVE_REQUEST':
        return FontAwesomeIcons.userCheck;
      case 'CANCEL_APPROVAL':
        return FontAwesomeIcons.userXmark;
      case 'COMPLETE_JOB':
        return FontAwesomeIcons.circleCheck;
      case 'CREATE_REVIEW':
        return FontAwesomeIcons.starHalfStroke;
      case 'RAISE_DISPUTE':
        return FontAwesomeIcons.triangleExclamation;
      case 'ADD_FAVORITE':
        return FontAwesomeIcons.heart;
      case 'FUND_APPOINTMENT':
      case 'FUND_BACKGROUND_CHECK':
      case 'CREATE_SUBSCRIPTION':
        return FontAwesomeIcons.creditCard;
      case 'REQUEST_PAYOUT':
        return FontAwesomeIcons.wallet;
      case 'AUTO_EXPIRE':
        return FontAwesomeIcons.hourglassEnd;
      default:
        return FontAwesomeIcons.clockRotateLeft;
    }
  }

  Color _getColor(String? action) {
    if (action == null) return Colors.grey;
    if (action.contains('LOGIN') || action.contains('REGISTER'))
      return Colors.blue;
    if (action.contains('FUND') ||
        action.contains('PAYOUT') ||
        action.contains('SUBSCRIPTION'))
      return Colors.green;
    if (action.contains('DISPUTE') ||
        action.contains('CANCEL') ||
        action.contains('EXPIRE'))
      return Colors.red;
    if (action.contains('COMPLETE') || action.contains('APPROVE'))
      return Colors.orange;
    return Colors.purple;
  }

  String _formatAction(String? action) {
    if (action == null) return "Unknown Action";
    return action
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return "";
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTextWidget(
          text: "Activity History",
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final logs = (state is SuccessGetAuditLogsState)
              ? state.logs
              : context.read<ProfileBloc>().auditLogs;

          if ((state is LoadingProfileState ||
                  state is LoadingAuditLogsState) &&
              logs.isEmpty) {
            return const ListSkeletonLoader();
          }

          if (state is FailureGetAuditLogsState && logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.circleExclamation,
                    size: 40,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16.h),
                  CustomTextWidget(text: state.message),
                  TextButton(
                    onPressed: () =>
                        context.read<ProfileBloc>().add(GetAuditLogsEvent()),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.clockRotateLeft,
                    size: 64,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  SizedBox(height: 16.h),
                  const CustomTextWidget(
                    text: "No activity history found.",
                    color: Colors.grey,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(GetAuditLogsEvent());
              context.read<ProfileBloc>().add(GetProfileStreamEvent());
              context.read<ProfileBloc>().add(GetProfileEvent());
            },
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: logs.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final log = logs[index];
                final color = _getColor(log.action);

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.r),
                  child: InkWell(
                    onTap: () => _showLogDetails(context, log),
                    borderRadius: BorderRadius.circular(16.r),
                    child: SolidContainer(
                      padding: EdgeInsets.all(16.r),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: FaIcon(
                              _getFaIcon(log.action),
                              color: color,
                              size: 18.r,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextWidget(
                                  text: _formatAction(log.action),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                ),
                                SizedBox(height: 4.h),
                                CustomTextWidget(
                                  text: log.createdAt != null
                                      ? DateFormat(
                                          'MMM dd, yyyy • hh:mm a',
                                        ).format(log.createdAt!.toLocal())
                                      : "Unknown time",
                                  color: context.appColors.secondaryTextColor,
                                  fontSize: 12.sp,
                                ),
                              ],
                            ),
                          ),
                          FaIcon(
                            FontAwesomeIcons.chevronRight,
                            color: context.appColors.secondaryTextColor
                                .withOpacity(0.3),
                            size: 14.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showLogDetails(BuildContext context, AuditLog log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24.r),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: context.appColors.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: _getColor(log.action).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: FaIcon(
                        _getFaIcon(log.action),
                        color: _getColor(log.action),
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            text: _formatAction(log.action),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomTextWidget(
                            text: "Action Details",
                            color: context.appColors.secondaryTextColor,
                            fontSize: 11.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                _detailRow(
                  'Date',
                  log.createdAt != null
                      ? DateFormat(
                          'MMMM dd, yyyy',
                        ).format(log.createdAt!.toLocal())
                      : 'N/A',
                ),
                _detailRow(
                  'Time',
                  log.createdAt != null
                      ? DateFormat('hh:mm:ss a').format(log.createdAt!)
                      : 'N/A',
                ),
                _detailRow('IP Address', log.ipAddress ?? 'N/A'),
                _detailRow('Resource', log.resourceType ?? 'N/A'),
                // if (log.resourceId != null) _detailRow('Resource ID', log.resourceId!),
                if (log.details != null && log.details!.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  // CustomTextWidget(
                  //   text: "Metadata",
                  //   fontWeight: FontWeight.bold,
                  //   color: context.appColors.secondaryTextColor,
                  //   fontSize: 11.sp,
                  // ),
                  // SizedBox(height: 8.h),
                  // Container(
                  //   padding: EdgeInsets.all(16.r),
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //     color: context.appColors.glassBorder.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(12.r),
                  //     border: Border.all(color: context.appColors.glassBorder),
                  //   ),
                  //   child: Text(
                  //     log.details.toString(),
                  //     style: TextStyle(
                  //       fontFamily: 'monospace',
                  //       fontSize: 12.sp,
                  //       color: context.appColors.primaryTextColor,
                  //     ),
                  //   ),
                  // ),
                ],
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextWidget(
            text: label,
            color: context.appColors.secondaryTextColor,
            fontSize: 13.sp,
          ),
          CustomTextWidget(
            text: value,
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
        ],
      ),
    );
  }
}
