import 'dart:io';

import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' as s;
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import '../../../shared/presentation/bloc/shared_bloc.dart';

class AddProfileAuthPage extends StatefulWidget {
  const AddProfileAuthPage({super.key});

  @override
  State<AddProfileAuthPage> createState() => _AddProfileAuthPageState();
}

class _AddProfileAuthPageState extends State<AddProfileAuthPage> {
  late TextEditingController nameTextController;
  late TextEditingController dateOfBirthTextController;
  late TextEditingController serviceTextController;

  late TextEditingController contactTextController;
  String gender = "Male";
  String countryCode = "";
  int provider = 1;
  String serviceType = "";
  late GlobalKey<FormState> key;
  bool isImage = true;
  String catalogServiceId = "";
  String preferredPaymentMode = "ON_SITE";

  @override
  void initState() {
    context.read<SharedBloc>().add(GetServicesEvent());
    context.read<ProfileBloc>().add(ChooseOtherServiceEvent(others: false));
    nameTextController = TextEditingController();
    dateOfBirthTextController = TextEditingController();
    serviceTextController = TextEditingController();

    contactTextController = TextEditingController();
    key = GlobalKey<FormState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    locController.text = MapLocationState.address;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is DateOfBirthProfileState) {
            dateOfBirthTextController.text = DateFormat(
              "MMMM-dd-yyyy",
            ).format(DateOfBirthProfileState.dob);
          }
          if (state is SuccessCreateProfileState) {
            context.read<ProfileBloc>().add(GetProfileEvent());
            customAlert(
              context,
              AlertType.success,
              "Profile created successfully",
            );
            Future.delayed(
              const Duration(seconds: 3),
              () {
                if (mounted) {
                  Get.offAllNamed("/home");
                }
              },
            );
          }
          if (state is FailureCreateProfileState) {
            customAlert(context, AlertType.error, "An error occurred");
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingProfileState),
            child: GradientBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        "Create Your Profile",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color:
                              (Theme.of(context).brightness == Brightness.dark)
                              ? Colors.white
                              : Colors.black87,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Complete your information to get started",
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              (Theme.of(context).brightness == Brightness.dark)
                              ? Colors.white.withAlpha(160)
                              : Colors.black54,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),
                      GestureDetector(
                        onTap: () => _showImagePickerBottomSheet(context),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      (Theme.of(context).brightness ==
                                          Brightness.dark)
                                      ? Colors.white.withAlpha(80)
                                      : Colors.black.withAlpha(20),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: appDeepBlueColor1.withAlpha(
                                      (Theme.of(context).brightness ==
                                              Brightness.dark)
                                          ? 40
                                          : 60,
                                    ),
                                    blurRadius: 40,
                                    spreadRadius: -5,
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Colors.white.withAlpha(40)
                                        : Colors.black.withAlpha(10),
                                    width: 1,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 65,
                                  backgroundColor: Colors.white.withAlpha(15),
                                  backgroundImage:
                                      (ImageProfileState.profilePicture != null)
                                      ? FileImage(
                                          File(
                                            ImageProfileState
                                                .profilePicture!
                                                .path,
                                          ),
                                        )
                                      : const AssetImage(logo2Assets)
                                            as ImageProvider,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: appDeepBlueColor1,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(60),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color:
                              (Theme.of(context).brightness == Brightness.dark)
                              ? Colors.white.withAlpha(15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color:
                                (Theme.of(context).brightness ==
                                    Brightness.dark)
                                ? Colors.white.withAlpha(25)
                                : Colors.black.withAlpha(10),
                          ),
                          boxShadow:
                              (Theme.of(context).brightness == Brightness.light)
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Form(
                          key: key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SolidTextField(
                                controller: nameTextController,
                                hintText: "Enter full name",
                                label: "Full Name",
                                prefixIcon: Icons.person_outline_rounded,
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Name is required";
                                  }
                                  if (containSpecial(val)) {
                                    return "Special characters not allowed";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _buildLabel("Gender"),
                              const SizedBox(height: 12),
                                CustomSegmentedControl<String>(
                                  buttonLables: const ["Male", "Female"],
                                  buttonValues: const ["Male", "Female"],
                                  defaultSelected: gender,
                                  onValueChanged: (val) {
                                    setState(() {
                                      gender = val;
                                    });
                                  },
                                  width: 270,
                                  height: 52,
                                  radius: 18,
                                  selectedColor: Colors.blueAccent.withAlpha(50),
                                  textColor: Colors.white,
                                ),
                              const SizedBox(height: 24),
                              SolidTextField(
                                controller: dateOfBirthTextController,
                                hintText: "Select birth date",
                                label: "Date Of Birth",
                                prefixIcon: Icons.calendar_today_outlined,
                                readOnly: true,
                                onTap: () => context.read<ProfileBloc>().add(
                                  SelectDateOfBirthEvent(context: context),
                                ),
                                validator: (val) {
                                  if (val!.isEmpty) {
                                    return "Date of Birth is required";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              _buildLabel("User Role"),
                              const SizedBox(height: 12),
                                CustomSegmentedControl<String>(
                                  buttonLables: const [
                                    userTypeSeeker,
                                    userTypeProvider,
                                  ],
                                  buttonValues: const [
                                    userTypeSeeker,
                                    userTypeProvider,
                                  ],
                                  defaultSelected: userTypeProvider,
                                  onValueChanged: (val) {
                                    context.read<ProfileBloc>().add(
                                          SetUserTypeEvent(
                                            userType: Helpers.isProvider(val)
                                                ? 'provider'
                                                : 'seeker',
                                          ),
                                        );
                                  },
                                  width: 270,
                                  height: 52,
                                  radius: 18,
                                  selectedColor: Colors.blueAccent.withAlpha(50),
                                  textColor: Colors.white,
                                ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: SolidTextField(
                                      controller: locController,
                                      hintText: "Location address",
                                      label: "Location",
                                      prefixIcon: Icons.location_on_outlined,
                                      validator: (val) {
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () =>
                                        _showLocationBottomSheet(context),
                                    child: Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        color:
                                            (Theme.of(context).brightness ==
                                                Brightness.dark)
                                            ? Colors.white.withAlpha(20)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              (Theme.of(context).brightness ==
                                                  Brightness.dark)
                                              ? Colors.white.withAlpha(30)
                                              : Colors.black.withAlpha(10),
                                        ),
                                        boxShadow:
                                            (Theme.of(context).brightness ==
                                                Brightness.light)
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    5,
                                                  ),
                                                  blurRadius: 10,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: const Icon(
                                        Icons.my_location_rounded,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: SolidTextField(
                                      controller: contactTextController,
                                      hintText: "023456789",
                                      label: "Phone Number",
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (val) {
                                        if (val!.isEmpty) {
                                          return "Phone number is required";
                                        }
                                        if (!val.isPhoneNumber) {
                                          return "Invalid phone number";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              if (Helpers.isProvider(
                                UserTypeProfileState.userType,
                              )) ...[
                                const SizedBox(height: 24),
                                _buildLabel("Service Type"),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () {
                                    showServiceSelector(
                                      context: context,
                                      services:
                                          SuccessGetServicesState.services,
                                      selectedServiceId: serviceType.isEmpty
                                          ? null
                                          : serviceType,
                                      onServiceSelected:
                                          (serviceId, serviceName) {
                                            setState(() {
                                              serviceType = serviceName;
                                              catalogServiceId = serviceId;
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          (Theme.of(context).brightness ==
                                              Brightness.dark)
                                          ? Colors.white.withAlpha(20)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            (Theme.of(context).brightness ==
                                                Brightness.dark)
                                            ? Colors.white.withAlpha(30)
                                            : Colors.black.withAlpha(10),
                                      ),
                                      boxShadow:
                                          (Theme.of(context).brightness ==
                                              Brightness.light)
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  5,
                                                ),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.work_outline_rounded,
                                          color: Colors.blueAccent.withAlpha(
                                            200,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Text(
                                            serviceType.isEmpty
                                                ? "Select Your Profession"
                                                : serviceType,
                                            style: TextStyle(
                                              color:
                                                  (Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark)
                                                  ? (serviceType.isEmpty
                                                        ? Colors.white
                                                              .withAlpha(140)
                                                        : Colors.white)
                                                  : (serviceType.isEmpty
                                                        ? Colors.black54
                                                        : Colors.black87),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.unfold_more_rounded,
                                          color:
                                              (Theme.of(context).brightness ==
                                                  Brightness.dark)
                                              ? Colors.white.withAlpha(100)
                                              : Colors.black38,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (OtherServiceSelectState.others) ...[
                                  const SizedBox(height: 24),
                                  SolidTextField(
                                    controller: serviceTextController,
                                    hintText: "Enter your custom service",
                                    label: "Custom Service",
                                    prefixIcon: Icons.add_business_outlined,
                                  ),
                                  ],
                                  const SizedBox(height: 24),
                                  _buildLabel("Preferred Payment Method"),
                                  const SizedBox(height: 12),
                                    CustomSegmentedControl<String>(
                                      buttonLables: const ["In-App", "On-Site"],
                                      buttonValues: const ["IN_APP", "ON_SITE"],
                                      defaultSelected: "ON_SITE",
                                      onValueChanged: (val) {
                                        setState(() {
                                          preferredPaymentMode = val;
                                        });
                                      },
                                      width: 270,
                                      height: 52,
                                      radius: 18,
                                      selectedColor: Colors.blueAccent.withAlpha(50),
                                      textColor: Colors.white,
                                    ),
                                ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: appDeepBlueColor1.withAlpha(100),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (Helpers.isProvider(
                                  UserTypeProfileState.userType,
                                ) &&
                                !OtherServiceSelectState.others &&
                                serviceType == "") {
                              customAlert(
                                context,
                                AlertType.warning,
                                "Please select your service",
                              );
                              return;
                            }
                            Profile profile = Profile(
                              firstName: nameTextController.text.trim(),
                              lastName: nameTextController.text.trim(),
                              phone: contactTextController.text.trim(),
                              city: city,
                              rating: "0.0",
                              country: country,
                              ratings: [],
                              address: locController.text,
                              gender: gender,
                              dateOfBirth: DateOfBirthProfileState.dob,
                              createdAt: DateTime.now(),
                              zipCode: zipCode,
                              state: countryState,
                              countryCode: countryCode,
                              updatedAt: DateTime.now(),
                              service: (OtherServiceSelectState.others)
                                  ? serviceTextController.text.trim()
                                  : serviceType,
                                userType: UserTypeProfileState.userType,
                                preferredPaymentMode: preferredPaymentMode,
                                catalogServiceId: catalogServiceId,
                              latitude: (locController.text.isNotEmpty)
                                  ? (UseMapState.useMap)
                                        ? MapLocationState.location.latitude
                                              .toString()
                                        : locationData.latitude.toString()
                                  : null,
                              longitude: (locController.text.isNotEmpty)
                                  ? (UseMapState.useMap)
                                        ? MapLocationState.location.longitude
                                              .toString()
                                        : locationData.longitude.toString()
                                  : null,
                            );
                            if (key.currentState!.validate()) {
                              if (OtherServiceSelectState.others) {
                                context.read<SharedBloc>().add(
                                  AddServiceEvent(
                                    model: Service(
                                      description:
                                          "Custom service added by user during profile creation",
                                      name: serviceTextController.text.trim(),
                                    ),
                                  ),
                                );
                              }
                              context.read<ProfileBloc>().add(
                                AddProfileEvent(profile: profile),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appDeepBlueColor1,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Text(
                            "Complete Profile Creation",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImagePickerBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final sheetBg = isDark
    //     ? const Color(0xFF1E1E2E).withAlpha(200)
    //     : Colors.white.withAlpha(240);
    final handleColor = isDark
        ? Colors.white.withAlpha(60)
        : Colors.black.withAlpha(20);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 6,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            _buildSheetItem(
              icon: Icons.photo_library_rounded,
              label: "Choose from Gallery",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromGalleryEvent());
                Get.back();
              },
            ),
            const SizedBox(height: 16),
            _buildSheetItem(
              icon: Icons.camera_alt_rounded,
              label: "Take a Photo",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromCameraEvent());
                Get.back();
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // final sheetBg = isDark
    //     ? const Color(0xFF1E1E2E).withAlpha(200)
    //     : Colors.white.withAlpha(240);
    final handleColor = isDark
        ? Colors.white.withAlpha(60)
        : Colors.black.withAlpha(20);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45,
              height: 6,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            _buildSheetItem(
              icon: Icons.my_location_rounded,
              label: "Current Location",
              onTap: () async {
                context.read<SharedBloc>().add(UseMapEvent(useMap: false));
                context.read<s.SeekerBloc>().add(
                  s.ChangeLocationEvent(change: true),
                );
                final success = await Helpers.getLocation();
                if (success) {
                  if (mounted) {
                    locController.text = myAddress;
                    Get.back();
                  }
                } else {
                  if (mounted) {
                    Get.back();
                    customAlert(
                      context,
                      AlertType.error,
                      "Unable to get location. Please check location permissions and services.",
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            _buildSheetItem(
              icon: Icons.map_rounded,
              label: "Pick from Map",
              onTap: () {
                context.read<s.SeekerBloc>().add(
                  s.ChangeLocationEvent(change: true),
                );
                Get.back();
                context.read<SharedBloc>().add(UseMapEvent(useMap: true));
                Helpers.getLocation();
                Get.toNamed("map-location");
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemBg = isDark
        ? Colors.white.withAlpha(12)
        : Colors.black.withAlpha(5);
    final borderColor = isDark
        ? Colors.white.withAlpha(18)
        : Colors.black.withAlpha(10);
    final textColor = isDark ? Colors.white : Colors.black87;
    final arrowColor = isDark
        ? Colors.white.withAlpha(100)
        : Colors.black.withAlpha(50);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 26),
            const SizedBox(width: 18),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: (Theme.of(context).brightness == Brightness.dark)
              ? Colors.white.withAlpha(200)
              : Colors.black54,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
