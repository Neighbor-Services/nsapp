import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/core/core.dart';

class ChangeUserTypeWidget extends StatefulWidget {
  const ChangeUserTypeWidget({super.key});

  @override
  State<ChangeUserTypeWidget> createState() => _ChangeUserTypeWidgetState();
}

class _ChangeUserTypeWidgetState extends State<ChangeUserTypeWidget> {
  String userType = "";
  late TextEditingController serviceTextController;
  late GlobalKey<FormState> formKey;
  String? serviceType;
  bool isOthersSelected = false;

  @override
  void initState() {
    super.initState();
    context.read<CommonBloc>().add(GetServicesEvent());
    serviceTextController = TextEditingController();
    formKey = GlobalKey<FormState>();

    final profileState = context.read<ProfileBloc>().state;
    if (profileState is SuccessGetProfileState) {
      serviceType = profileState.profile.service;
      userType = profileState.profile.userType ?? "seeker";
    }
  }

  @override
  void dispose() {
    serviceTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = context.appColors.primaryTextColor;
    final subtitleColor = context.appColors.secondaryTextColor;
    final unselectedBorderColor = context.appColors.glassBorder;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is UserTypeProfileState) {
          setState(() {
            userType = state.userType;
          });
        }
        if (state is OtherServiceSelectState) {
          setState(() {
            isOthersSelected = state.others;
          });
        }
      },
      builder: (context, profileState) {
        return BlocListener<CommonBloc, CommonState>(
          listener: (context, commonState) {
            if (commonState is SuccessAddServicesState) {
              Navigator.pop(context);
              context.read<SettingsBloc>().add(
                ChangeUserTypeEvent({
                  "type": userType,
                  "service": commonState.id ?? "",
                }),
              );
            }
          },
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 400),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 24.h),
                      decoration: BoxDecoration(
                        color: unselectedBorderColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: context.appColors.secondaryColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          FontAwesomeIcons.rightLeft,
                          color: context.appColors.secondaryColor,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Change User Type",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              "Switching from ${((profileState is SuccessGetProfileState) ? profileState.profile.userType : userType)?.toUpperCase() ?? ""}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: subtitleColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  CustomSegmentedControl<String>(
                    buttonLables: const ["SEEKER", "PROVIDER"],
                    buttonValues: const ["SEEKER", "PROVIDER"],
                    defaultSelected: Helpers.isProvider(userType)
                        ? "PROVIDER"
                        : "SEEKER",
                    onValueChanged: (val) {
                      if (val == "PROVIDER") {
                        context.read<ProfileBloc>().add(
                              SetUserTypeEvent(userType: 'provider'),
                            );
                      } else {
                        context.read<ProfileBloc>().add(
                              SetUserTypeEvent(userType: 'seeker'),
                            );
                      }
                    },
                    height: 50,
                    radius: 14,
                    selectedColor: context.appColors.secondaryColor,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Column(
                      children: [
                        if (Helpers.isProvider(userType)) ...[
                          SizedBox(height: 32.h),
                          _buildSectionLabel("Specialization", subtitleColor),
                          SizedBox(height: 12.h),
                          BlocBuilder<CommonBloc, CommonState>(
                            builder: (context, commonState) {
                              final services = (commonState is SuccessGetServicesState) 
                                  ? commonState.services 
                                  : <Service>[];
                              return GestureDetector(
                                onTap: () {
                                  showServiceSelector(
                                    context: context,
                                    services: services,
                                    selectedServiceId: serviceType,
                                    onServiceSelected: (serviceId, serviceName) {
                                      setState(() {
                                        serviceType = serviceId;
                                      });
                                      context.read<ProfileBloc>().add(
                                        ChooseOtherServiceEvent(others: false),
                                      );
                                    },
                                    onOthersSelected: () {
                                      context.read<ProfileBloc>().add(
                                        ChooseOtherServiceEvent(others: true),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 18.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.appColors.glassBorder,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                      color: serviceType != null && serviceType != ""
                                          ? context.appColors.secondaryColor.withAlpha(100)
                                          : unselectedBorderColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.briefcase,
                                        color: serviceType != null &&
                                                serviceType != ""
                                            ? context.appColors.secondaryColor
                                            : subtitleColor,
                                        size: 20.r,
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Text(
                                          (serviceType == null || serviceType == "")
                                              ? "Select Service Category"
                                              : getServiceName(serviceType!),
                                          style: TextStyle(
                                            color: serviceType != null &&
                                                    serviceType != ""
                                                ? textColor
                                                : subtitleColor,
                                            fontSize: 16.sp,
                                            fontWeight: serviceType != null &&
                                                    serviceType != ""
                                                ? FontWeight.w400
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        FontAwesomeIcons.chevronDown,
                                        color: subtitleColor,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (isOthersSelected) ...[
                            SizedBox(height: 20.h),
                            Form(
                              key: formKey,
                              child: SolidTextField(
                                controller: serviceTextController,
                                hintText: "e.g. Home Cleaning, Tutor",
                                label: "Detail Your Service",
                                prefixIcon: FontAwesomeIcons.penToSquare,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Service name is required";
                                  } else if (containSpecial(val)) {
                                    return "Special characters not allowed";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  SolidButton(
                    label: "Apply Changes",
                    isPrimary: true,
                    onPressed: () {
                      if (userType != "") {
                        if (isOthersSelected) {
                          if (formKey.currentState!.validate()) {
                            context.read<CommonBloc>().add(
                              AddServiceEvent(
                                model: Service(
                                  description:
                                      "Custom user service via Change User Type",
                                  name: serviceTextController.text.trim(),
                                ),
                              ),
                            );
                          }
                        } else {
                          if (userType == "provider" &&
                              (serviceType == null || serviceType == "")) {
                            customAlert(
                              context,
                              AlertType.warning,
                              "Please select a service",
                            );
                            return;
                          }
                          Navigator.pop(context);
                          context.read<SettingsBloc>().add(
                            ChangeUserTypeEvent({
                              "type": userType,
                              "service": serviceType ?? "",
                            }),
                          );
                        }
                      } else {
                        customAlert(
                          context,
                          AlertType.warning,
                          "No changes detected",
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: color.withAlpha(180),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}


