import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';

import 'package:nsapp/core/constants/string_constants.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';

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

  @override
  void initState() {
    context.read<SharedBloc>().add(GetServicesEvent());
    serviceTextController = TextEditingController();
    serviceType = SuccessGetProfileState.profile.service;
    formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white.withAlpha(150) : Colors.black54;
    final unselectedColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.grey.withAlpha(30);
    final unselectedBorderColor = isDark
        ? Colors.white.withAlpha(30)
        : Colors.grey.withAlpha(50);
    final unselectedTextColor = isDark
        ? Colors.white.withAlpha(200)
        : Colors.black54;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Change User Type",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Current: ${SuccessGetProfileState.profile.userType?.toUpperCase()}",
              style: TextStyle(fontSize: 14, color: subtitleColor),
            ),
            SizedBox(height: 20),
            CustomRadioButton(
              buttonLables: const ["SEEKER", "PROVIDER"],
              defaultSelected:
                  Helpers.isProvider(SuccessGetProfileState.profile.userType)
                  ? "PROVIDER"
                  : "SEEKER",
              width: size(context).width * 0.4,
              height: 45,
              wrapAlignment: WrapAlignment.spaceEvenly,
              elevation: 0,
              buttonValues: const ["SEEKER", "PROVIDER"],
              unSelectedColor: unselectedColor,
              unSelectedBorderColor: unselectedBorderColor,
              selectedBorderColor: appOrangeColor1,
              selectedColor: appOrangeColor1,
              radius: 10,
              buttonTextStyle: ButtonTextStyle(
                selectedColor: Colors.white,
                unSelectedColor: unselectedTextColor,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              radioButtonValue: (val) {
                if (val == "PROVIDER") {
                  userType = userTypeProvider;
                  context.read<ProfileBloc>().add(
                    SetUserTypeEvent(userType: 'provider'),
                  );
                } else {
                  userType = "seeker";
                  context.read<ProfileBloc>().add(
                    SetUserTypeEvent(userType: 'seeker'),
                  );
                }
              },
            ),
            SizedBox(
              height: Helpers.isProvider(UserTypeProfileState.userType)
                  ? 20
                  : 0,
            ),
            Helpers.isProvider(UserTypeProfileState.userType)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Service Type",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          showServiceSelector(
                            context: context,
                            services: SuccessGetServicesState.services,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: unselectedColor,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: unselectedBorderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.work_outline_rounded,
                                color: subtitleColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  (serviceType == null || serviceType == "")
                                      ? "Select Service Type"
                                      : getServiceName(serviceType!),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                color: subtitleColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      (OtherServiceSelectState.others)
                          ? Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  SolidTextField(
                                    controller: serviceTextController,
                                    hintText: "Specify your service",
                                    label: "Service Name",
                                    prefixIcon: Icons.work_outline,
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return "Service is required";
                                      } else if (containSpecial(val)) {
                                        return "Special characters not allowed";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  )
                : SizedBox(),
            SizedBox(height: 30),
            SolidButton(
              label: "SAVE CHANGES",
              onPressed: () {
                if (userType != "") {
                  if (OtherServiceSelectState.others) {
                    if (formKey.currentState!.validate()) {
                      context.read<SharedBloc>().add(
                        AddServiceEvent(
                          model: Service(
                            description:
                                "The user selected others and added this a his specific service",
                            name: serviceTextController.text.trim(),
                          ),
                        ),
                      );
                    }
                  } else {
                    Navigator.pop(context);
                    context.read<SharedBloc>().add(
                      ChangeUserTypeEvent({
                        "type": UserTypeProfileState.userType,
                        "service": serviceType!,
                      }),
                    );
                  }
                } else {
                  customAlert(
                    context,
                    AlertType.warning,
                    "No changes occurred",
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
