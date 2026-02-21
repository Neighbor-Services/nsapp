import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nsapp/core/constants/app_colors.dart';
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
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 600,
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
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withAlpha(20)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withAlpha(40)
                                          : Colors.black.withAlpha(10),
                                    ),
                                    boxShadow: isDark
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(5),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  "Report An Issue",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  "Help us improve by reporting any issues",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.white.withAlpha(200)
                                        : Colors.black54,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 30),
                              SolidContainer(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel("Issue Type", isDark),
                                    const SizedBox(height: 10),
                                    SolidContainer(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: title,
                                          isExpanded: true,
                                          dropdownColor: isDark
                                              ? const Color(0xFF1E1E2E)
                                              : Colors.white,
                                          icon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black54,
                                          ),
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
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
                                    const SizedBox(height: 20),
                                    SolidTextField(
                                      controller: descriptionController,
                                      hintText:
                                          "Describe your issue in detail...",
                                      label: "Description",
                                      isMultiLine: true,
                                      prefixIcon: Icons.description_outlined,
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return "Description is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 30),
                                    Container(
                                      width: double.infinity,
                                      height: 55,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            appOrangeColor1,
                                            appOrangeColor2,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: appOrangeColor1.withAlpha(
                                              100,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 5),
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
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "SUBMIT REPORT",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
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

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white.withAlpha(200) : Colors.black87,
      ),
    );
  }
}
