import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/report.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';

import '../../../provider/presentation/bloc/provider_bloc.dart';
import '../../../provider/presentation/pages/provider_home_page.dart';
import '../../../seeker/presentation/bloc/seeker_bloc.dart';
import '../../../seeker/presentation/pages/seeker_home_page.dart';
import '../bloc/shared_bloc.dart';
import 'package:nsapp/core/core.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TextEditingController descriptionController = TextEditingController();
  String title = "Fraud Issue"; // Default value
  GlobalKey<FormState> key = GlobalKey<FormState>();

  final List<String> reportIssues = [
    "Fraud Issue",
    "Scam Issue",
    "Unsatisfied Work",
    "In app issues",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) {
          if (state is SuccessAddReportState) {
            customAlert(context, AlertType.success, "Report Sent Successfully");
            Future.delayed(const Duration(seconds: 3), () {
              if (DashboardState.isProvider) {
                context.read<ProviderBloc>().add(
                  NavigateProviderEvent(
                    page: 1,
                    widget: const ProviderHomePage(),
                  ),
                );
              } else {
                context.read<SeekerBloc>().add(
                  NavigateSeekerEvent(page: 1, widget: const SeekerHomePage()),
                );
              }
            });
          } else if (state is FailureAddReportState) {
            customAlert(context, AlertType.error, "Failed To Send Report");
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is SharedLoadingState),
            child: SizedBox.expand(
              child: GradientBackground(
                child: SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.r),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 600.w,
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: Form(
                          key: key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (DashboardState.isProvider) {
                                    context.read<ProviderBloc>().add(
                                      ProviderBackPressedEvent(),
                                    );
                                  } else {
                                    context.read<SeekerBloc>().add(
                                      SeekerBackPressedEvent(),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: context.appColors.glassBorder,
                                    borderRadius: BorderRadius.circular(14.r),
                                    border: Border.all(
                                      color: context.appColors.glassBorder,
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(5),
                                              blurRadius: 10.r,
                                              spreadRadius: 2.r,
                                            ),
                                          ],
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.chevronLeft,
                                    color: context.appColors.primaryTextColor,
                                    size: 20.r,
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.h),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  "REPORT AN ISSUE",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.primaryTextColor,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  "HELP US IMPROVE BY REPORTING ANY ISSUES",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.secondaryTextColor,
                                    letterSpacing: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 30.h),
                                SolidContainer(
                                  padding: EdgeInsets.all(20.r),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Issue Type"),
                                      SizedBox(height: 10.h),
                                      SolidContainer(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        borderRadius: BorderRadius.circular(15.r),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: title,
                                            isExpanded: true,
                                            dropdownColor:
                                                context.appColors.cardBackground,
                                            icon: Icon(
                                              FontAwesomeIcons.chevronDown,
                                              color: context
                                                  .appColors.primaryTextColor,
                                            ),
                                            style: TextStyle(
                                              color: context
                                                  .appColors.primaryTextColor,
                                            ),
                                            items: reportIssues.map((
                                              String value,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                title = val!;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                    SolidTextField(
                                      controller: descriptionController,
                                      hintText:
                                          "Describe your issue in detail...",
                                      label: "Description",
                                      isMultiLine: true,
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return "Description is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 30.h),
                                    Container(
                                      width: double.infinity,
                                      height: 55.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: context.appColors.secondaryColor.withAlpha(
                                              100,
                                            ),
                                            blurRadius: 15.r,
                                            offset: Offset(0, 5.h),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (title == "") {
                                            customAlert(
                                              context,
                                              AlertType.error,
                                              "Please select a title for your report",
                                            );
                                            return;
                                          }
                                          if (key.currentState!.validate()) {
                                            context.read<SharedBloc>().add(
                                                  AddReportEvent(
                                                    report: Report(
                                                      reason:
                                                          "[$title] ${descriptionController.text}",
                                                      resourceType: "system",
                                                      resourceId: "global",
                                                    ),
                                                  ),
                                                );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              context.appColors.primaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.r,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "SUBMIT REPORT",
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 100), // Extra space
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
        color: context.appColors.primaryTextColor,
        letterSpacing: 1.2,
      ),
    );
  }
}



