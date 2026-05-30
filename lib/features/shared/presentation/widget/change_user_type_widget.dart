import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import 'package:nsapp/features/shared/presentation/bloc/settings/settings_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
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
  String selectedServiceName = "";
  Profile? _currentProfile;

  @override
  void initState() {
    super.initState();
    context.read<CommonBloc>().add(GetServicesEvent());
    serviceTextController = TextEditingController();
    formKey = GlobalKey<FormState>();

    final profileState = context.read<ProfileBloc>().state;
    if (profileState is SuccessGetProfileState) {
      _currentProfile = profileState.profile;
      serviceType = _currentProfile!.service;
      userType = _currentProfile!.userType ?? "seeker";
    } else if (profileState is SuccessGetProfileStreamState) {
      _currentProfile = profileState.profile;
      serviceType = _currentProfile!.service;
      userType = _currentProfile!.userType ?? "seeker";
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
        return BlocListener<SettingsBloc, SettingsState>(
          listener: (context, settingsState) {
            if (settingsState is SuccessChangeUserTypeState) {
              Navigator.pop(context);
            }
          },
          child: BlocListener<CommonBloc, CommonState>(
            listener: (context, commonState) {
              if (commonState is SuccessAddServicesState) {
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
                            color: context.appColors.secondaryColor.withAlpha(
                              30,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: FaIcon(
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
                      buttonValues: const ["seeker", "provider"],
                      defaultSelected: Helpers.isProvider(userType)
                          ? "provider"
                          : "seeker",
                      onValueChanged: (val) {
                        if (Helpers.isProvider(val)) {
                          // Switching to Provider — check identity verification first
                          if (_currentProfile?.isIdentityVerified != true) {
                            _showVerificationWarningDialog(context);
                          } else {
                            context.read<ProfileBloc>().add(
                              SetUserTypeEvent(userType: val),
                            );
                          }
                        } else {
                          // Switching to Seeker — warn about subscription void
                          if (Helpers.isProvider(userType)) {
                            _showSwitchToSeekerConfirmationDialog(context, val);
                          } else {
                            context.read<ProfileBloc>().add(
                              SetUserTypeEvent(userType: val),
                            );
                          }
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
                                final services =
                                    (commonState is SuccessGetServicesState)
                                    ? commonState.services
                                    : <Service>[];
                                return GestureDetector(
                                  onTap: () {
                                    showServiceSelector(
                                      context: context,
                                      services: services,
                                      selectedServiceId: serviceType,
                                      onServiceSelected:
                                          (serviceId, serviceName) {
                                            setState(() {
                                              serviceType = serviceId;
                                              selectedServiceName = serviceName;
                                            });
                                            context.read<ProfileBloc>().add(
                                              ChooseOtherServiceEvent(
                                                others: false,
                                              ),
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
                                        color:
                                            serviceType != null &&
                                                serviceType != ""
                                            ? context.appColors.secondaryColor
                                                  .withAlpha(100)
                                            : unselectedBorderColor,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        FaIcon(
                                          FontAwesomeIcons.briefcase,
                                          color:
                                              serviceType != null &&
                                                  serviceType != ""
                                              ? context.appColors.secondaryColor
                                              : subtitleColor,
                                          size: 20.r,
                                        ),
                                        SizedBox(width: 14.w),
                                        Expanded(
                                          child: Text(
                                            (serviceType == null ||
                                                    serviceType == "")
                                                ? "Select Service Category"
                                                : selectedServiceName,
                                            style: TextStyle(
                                              color:
                                                  serviceType != null &&
                                                      serviceType != ""
                                                  ? textColor
                                                  : subtitleColor,
                                              fontSize: 16.sp,
                                              fontWeight:
                                                  serviceType != null &&
                                                      serviceType != ""
                                                  ? FontWeight.w400
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        FaIcon(
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
                    BlocBuilder<SettingsBloc, SettingsState>(
                      builder: (context, settingsState) {
                        return SolidButton(
                          label: "Apply Changes",
                          isPrimary: true,
                          isLoading: settingsState is LoadingSettingsState,
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
                                    (serviceType == null ||
                                        serviceType == "")) {
                                  customAlert(
                                    context,
                                    AlertType.warning,
                                    "Please select a service",
                                  );
                                  return;
                                }
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
                        );
                      },
                    ),
                  ],
                ),
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

  /// Shows a dialog warning the user they must complete identity verification
  /// before switching to a Provider account.
  void _showVerificationWarningDialog(BuildContext outerContext) {
    showDialog(
      context: outerContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: outerContext.appColors.cardBackground,
          child: Container(
            padding: EdgeInsets.all(28.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: outerContext.appColors.glassBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.shieldHalved,
                    color: Colors.redAccent,
                    size: 40.r,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Verification Required",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: outerContext.appColors.primaryTextColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  "To switch to a Provider account and offer your services, you must first complete your identity verification (background check).",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: outerContext.appColors.secondaryTextColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            side: BorderSide(
                              color: outerContext.appColors.glassBorder,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {});
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: outerContext.appColors.primaryTextColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: outerContext.appColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {});
                          outerContext.push('/pending-verification');
                        },
                        child: Text(
                          "Verify Now",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows a confirmation dialog warning the user that switching to Seeker
  /// will void their active provider subscription and clear service catalogs.
  void _showSwitchToSeekerConfirmationDialog(
    BuildContext outerContext,
    String targetUserType,
  ) {
    showDialog(
      context: outerContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: outerContext.appColors.cardBackground,
          child: Container(
            padding: EdgeInsets.all(28.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: outerContext.appColors.glassBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.triangleExclamation,
                    color: Colors.orangeAccent,
                    size: 40.r,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Void Subscription?",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: outerContext.appColors.primaryTextColor,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  "Switching to a Seeker account will immediately void your active provider subscription and clear your selected service catalogs. This action cannot be undone.",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: outerContext.appColors.secondaryTextColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                            side: BorderSide(
                              color: outerContext.appColors.glassBorder,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          setState(() {});
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: outerContext.appColors.primaryTextColor,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          outerContext.read<ProfileBloc>().add(
                            SetUserTypeEvent(userType: targetUserType),
                          );
                        },
                        child: Text(
                          "Yes, Switch",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
