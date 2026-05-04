import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/features/shared/presentation/widget/skeleton_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTextWidget(
          text: "Activity History",
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is LoadingProfileState) {
            return const ListSkeletonLoader();
          }

          if (state is FailureGetAuditLogsState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FontAwesomeIcons.circleExclamation, size: 40, color: Colors.grey),
                  SizedBox(height: 16.h),
                  CustomTextWidget(text: state.message),
                  TextButton(
                    onPressed: () => context.read<ProfileBloc>().add(GetAuditLogsEvent()),
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          if (state is SuccessGetAuditLogsState) {
            if (state.logs.isEmpty) {
              return const Center(child: CustomTextWidget(text: "No activity history found."));
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: state.logs.length,
              itemBuilder: (context, index) {
                final log = state.logs[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.r),
                  child: SolidContainer(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.r),
                          decoration: BoxDecoration(
                            color: context.appColors.secondaryColor.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForAction(log.action),
                            color: context.appColors.secondaryColor,
                            size: 18.r,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextWidget(
                                text: log.action ?? "Unknown action",
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                              SizedBox(height: 4.h),
                              CustomTextWidget(
                                text: log.createdAt != null 
                                    ? DateFormat.yMMMd().add_jm().format(log.createdAt!)
                                    : "Unknown time",
                                color: context.appColors.secondaryTextColor,
                                fontSize: 12.sp,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  IconData _getIconForAction(String? action) {
    if (action == null) return FontAwesomeIcons.circleQuestion;
    final a = action.toLowerCase();
    if (a.contains('login')) return FontAwesomeIcons.rightToBracket;
    if (a.contains('profile')) return FontAwesomeIcons.userPen;
    if (a.contains('payment') || a.contains('wallet')) return FontAwesomeIcons.wallet;
    if (a.contains('message')) return FontAwesomeIcons.comment;
    if (a.contains('request')) return FontAwesomeIcons.clipboardList;
    return FontAwesomeIcons.bolt;
  }
}


