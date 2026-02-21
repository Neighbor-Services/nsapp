import 'dart:io';

import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:nsapp/core/constants/string_constants.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';

import '../../../../core/constants/app_colors.dart';

import '../../../../core/helpers/helpers.dart';
import '../../../../core/initialize/init.dart';
import '../../../../core/models/profile.dart';
import '../../../seeker/presentation/bloc/seeker_bloc.dart' as s;
import '../../../shared/presentation/bloc/shared_bloc.dart';
import '../../../shared/presentation/widget/loading_view.dart';
import '../bloc/profile_bloc.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameTextController;
  late TextEditingController dateOfBirthTextController;
  late TextEditingController contactTextController;
  late TextEditingController countryTextController;
  late TextEditingController stateTextController;
  late TextEditingController zipCodeTextController;
  late TextEditingController serviceTextController;
  String gender = "MALE";
  String countryCode = "";
  int provider = 1;
  String serviceType = "";
  String catalogServiceId = "";
  String preferredPaymentMode = "ON_SITE";
  late GlobalKey<FormState> key;
  bool isImage = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    context.read<SharedBloc>().add(GetServicesEvent());
    context.read<ProfileBloc>().add(ChooseOtherServiceEvent(others: false));
    nameTextController = TextEditingController();
    dateOfBirthTextController = TextEditingController();

    contactTextController = TextEditingController();
    zipCodeTextController = TextEditingController();
    countryTextController = TextEditingController();
    stateTextController = TextEditingController();
    serviceTextController = TextEditingController();

    // Safe initialization
    final profile = SuccessGetProfileState.profile;

    nameTextController.text = profile.firstName ?? "";
    locController.text = profile.address ?? "";
    contactTextController = TextEditingController(text: profile.phone);
    zipCodeTextController.text = profile.zipCode ?? "";
    countryTextController.text = profile.country ?? "";
    stateTextController.text = profile.state ?? "";
    dateOfBirthTextController.text = profile.dateOfBirth != null
        ? DateFormat("MMMM-dd-yyyy").format(profile.dateOfBirth!)
        : "";

    if (profile.service != null && profile.service != "") {
      serviceType = profile.service ?? "";
    }

    countryCode = profile.countryCode ?? "";
    gender = profile.gender ?? "MALE";
    catalogServiceId = profile.catalogServiceId ?? "";
    preferredPaymentMode = profile.preferredPaymentMode ?? "BOTH";

    String initialUserType = profile.userType ?? "FEMALE";
    context.read<ProfileBloc>().add(
      SetUserTypeEvent(userType: initialUserType),
    );

    key = GlobalKey<FormState>();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    super.initState();
  }

  @override
  void dispose() {
    zipCodeTextController.dispose();
    nameTextController.dispose();
    dateOfBirthTextController.dispose();
    contactTextController.dispose();
    countryTextController.dispose();
    stateTextController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is DateOfBirthProfileState) {
            dateOfBirthTextController.text = DateFormat(
              "MMMM-dd-yyyy",
            ).format(DateOfBirthProfileState.dob);
          }
          if (state is SuccessUpdateProfileState) {
            context.read<ProfileBloc>().add(GetProfileStreamEvent());
            context.read<ProfileBloc>().add(GetProfileEvent());
            context.read<SharedBloc>().add(GetServicesEvent());
            if (Helpers.isSeeker(UserTypeProfileState.userType)) {
              context.read<SharedBloc>().add(
                ToggleDashboardEvent(isProvider: false),
              );
            }
            context.read<SharedBloc>().add(
              SharedBlocReloadEvent(UserTypeProfileState.userType),
            );
            customAlert(context, AlertType.success, "Profile updated");
            context.read<SharedBloc>().add(GetServicesEvent());
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          }
          if (state is FailureUpdateProfileState) {
            customAlert(context, AlertType.error, "An error occurred");
          }
        },
        builder: (context, state) {
          return LoadingView(
            isLoading: (state is LoadingProfileState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Form(
                          key: key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color:
                                        (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Colors.white.withAlpha(25)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          (Theme.of(context).brightness ==
                                              Brightness.dark)
                                          ? Colors.white.withAlpha(40)
                                          : Colors.black.withAlpha(10),
                                    ),
                                    boxShadow:
                                        (Theme.of(context).brightness ==
                                            Brightness.light)
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(10),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color:
                                        (Theme.of(context).brightness ==
                                            Brightness.dark)
                                        ? Colors.white
                                        : Colors.black87,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "Edit Professional Profile",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (Theme.of(context).brightness ==
                                          Brightness.dark)
                                      ? Colors.white
                                      : Colors.black87,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Keep your profile updated to build trust",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      (Theme.of(context).brightness ==
                                          Brightness.dark)
                                      ? Colors.white.withAlpha(140)
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _showImageSourceSheet(context);
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withAlpha(100)
                                                : Colors.black.withAlpha(20),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: appDeepBlueColor1
                                                  .withAlpha(isDark ? 40 : 60),
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
                                              color: isDark
                                                  ? Colors.white.withAlpha(40)
                                                  : Colors.black.withAlpha(10),
                                              width: 1,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundColor: Colors.white
                                                .withAlpha(10),
                                            backgroundImage:
                                                (ImageProfileState
                                                            .profilePicture !=
                                                        null &&
                                                    ImageProfileState
                                                        .profilePicture!
                                                        .path
                                                        .isNotEmpty)
                                                ? FileImage(
                                                    File(
                                                      ImageProfileState
                                                          .profilePicture!
                                                          .path,
                                                    ),
                                                  )
                                                : (SuccessGetProfileState
                                                              .profile
                                                              .profilePictureUrl !=
                                                          null &&
                                                      SuccessGetProfileState
                                                          .profile
                                                          .profilePictureUrl!
                                                          .isNotEmpty &&
                                                      !SuccessGetProfileState
                                                          .profile
                                                          .profilePictureUrl!
                                                          .startsWith(
                                                            "file:///",
                                                          ))
                                                ? NetworkImage(
                                                    SuccessGetProfileState
                                                        .profile
                                                        .profilePictureUrl!,
                                                  )
                                                : const AssetImage(logo2Assets)
                                                      as ImageProvider,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: appDeepBlueColor1,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withAlpha(40),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  40,
                                                ),
                                                blurRadius: 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withAlpha(15)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withAlpha(25)
                                        : Colors.black.withAlpha(10),
                                  ),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(5),
                                            blurRadius: 20,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                ),
                                child: Column(
                                  children: [
                                    SolidTextField(
                                      controller: nameTextController,
                                      hintText: "Enter your name",
                                      label: "Full name",
                                      prefixIcon: Icons.person_outline,
                                      validator: (val) {
                                        final value = val ?? "";
                                        if (value.isEmpty) {
                                          return "Name is required";
                                        } else if (containSpecial(value)) {
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
                                      defaultSelected:
                                          gender == "MALE" ? "Male" : "Female",
                                      onValueChanged: (val) {
                                        setState(() {
                                          gender = val;
                                        });
                                      },
                                      width: 240,
                                      height: 50,
                                      radius: 16,
                                      selectedColor: Colors.blueAccent.withAlpha(40),
                                      textColor: Colors.white,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildLabel("Role Type"),
                                    const SizedBox(height: 12),
                                    CustomSegmentedControl<String>(
                                      buttonLables: const [
                                        "SEEKER",
                                        "PROVIDER",
                                      ],
                                      buttonValues: const [
                                        userTypeSeeker,
                                        userTypeProvider,
                                      ],
                                      defaultSelected: Helpers.isProvider(
                                        SuccessGetProfileState.profile.userType,
                                      )
                                          ? userTypeProvider
                                          : userTypeSeeker,
                                      onValueChanged: (val) {
                                        context.read<ProfileBloc>().add(
                                              SetUserTypeEvent(userType: val),
                                            );
                                      },
                                      width: 240,
                                      height: 50,
                                      radius: 16,
                                      selectedColor: Colors.blueAccent.withAlpha(40),
                                      textColor: isDark ? Colors.white : Colors.blueAccent,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SolidTextField(
                                            controller: locController,
                                            hintText: "Location",
                                            label: "Location",
                                            prefixIcon:
                                                Icons.location_on_outlined,
                                            validator: (val) {
                                              if ((val ?? "").isEmpty) {
                                                return "Location is required";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () =>
                                              _showLocationSheet(context),
                                          child: Container(
                                            width: 58,
                                            height: 58,
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Colors.white.withAlpha(20)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                              border: Border.all(
                                                color: isDark
                                                    ? Colors.white.withAlpha(30)
                                                    : Colors.black.withAlpha(
                                                        10,
                                                      ),
                                              ),
                                              boxShadow: isDark
                                                  ? null
                                                  : [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withAlpha(5),
                                                        blurRadius: 10,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                            ),
                                            child: const Icon(
                                              Icons.map_rounded,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    SolidTextField(
                                      controller: contactTextController,
                                      hintText: "Phone number",
                                      label: "Phone number",
                                      prefixIcon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (val) {
                                        final value = val ?? "";
                                        if (value.isEmpty) {
                                          return "Phone number is required";
                                        }
                                        if (!value.isPhoneNumber) {
                                          return "Enter a valid phone number";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    SolidTextField(
                                      controller: countryTextController,
                                      hintText: "Country",
                                      label: "Country",
                                      prefixIcon: Icons.public_rounded,
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "Country is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    SolidTextField(
                                      controller: stateTextController,
                                      hintText: "State",
                                      label: "State",
                                      prefixIcon: Icons.location_city_rounded,
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "State is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 24),
                                    SolidTextField(
                                      controller: zipCodeTextController,
                                      hintText: "Zip Code",
                                      label: "Zip Code",
                                      prefixIcon: Icons.pin_drop_rounded,
                                    ),
                                    if (Helpers.isProvider(
                                      UserTypeProfileState.userType,
                                    )) ...[
                                      const SizedBox(height: 24),
                                      _buildLabel("Primary Service"),
                                      const SizedBox(height: 12),
                                      GestureDetector(
                                        onTap: () {
                                          showServiceSelector(
                                            context: context,
                                            services: SuccessGetServicesState
                                                .services,
                                            selectedServiceId: serviceType == ""
                                                ? SuccessGetProfileState
                                                      .profile
                                                      .service
                                                : serviceType,
                                            onServiceSelected:
                                                (serviceId, serviceName) {
                                                  setState(() {
                                                    serviceType = serviceName;
                                                    catalogServiceId =
                                                        serviceId;
                                                  });
                                                  context
                                                      .read<ProfileBloc>()
                                                      .add(
                                                        ChooseOtherServiceEvent(
                                                          others: false,
                                                        ),
                                                      );
                                                },
                                            onOthersSelected: () {
                                              context.read<ProfileBloc>().add(
                                                ChooseOtherServiceEvent(
                                                  others: true,
                                                ),
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
                                            color: isDark
                                                ? Colors.white.withAlpha(20)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? Colors.white.withAlpha(30)
                                                  : Colors.black.withAlpha(10),
                                            ),
                                            boxShadow: isDark
                                                ? null
                                                : [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withAlpha(5),
                                                      blurRadius: 10,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.workspace_premium_rounded,
                                                color: Colors.blueAccent
                                                    .withAlpha(180),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Text(
                                                  serviceType == ""
                                                      ? getServiceName(
                                                          SuccessGetProfileState
                                                                  .profile
                                                                  .service ??
                                                              "",
                                                        )
                                                      : serviceType,
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.unfold_more_rounded,
                                                color: isDark
                                                    ? Colors.white.withAlpha(
                                                        100,
                                                      )
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
                                          hintText: "Specify service",
                                          label: "Specify Service",
                                          prefixIcon:
                                              Icons.add_business_rounded,
                                          validator: (val) {
                                            if ((val ?? "").isEmpty) {
                                              return "Service specification is required";
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                      if (Helpers.isProvider(
                                        UserTypeProfileState.userType,
                                      )) ...[
                                        const SizedBox(height: 24),
                                        _buildLabel("Preferred Payment Mode"),
                                        const SizedBox(height: 12),
                                        CustomSegmentedControl<String>(
                                          buttonLables: const [
                                            "In-App",
                                            "On-Site",
                                          ],
                                          buttonValues: const [
                                            "IN_APP",
                                            "ON_SITE",
                                          ],
                                          defaultSelected: preferredPaymentMode,
                                          onValueChanged: (val) {
                                            setState(() {
                                              preferredPaymentMode = val;
                                            });
                                          },
                                          width: 240,
                                          height: 50,
                                          radius: 16,
                                          selectedColor: Colors.blueAccent.withAlpha(40),
                                          textColor: isDark ? Colors.white : Colors.blueAccent,
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: appDeepBlueColor1.withAlpha(80),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _updateProfile(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: appDeepBlueColor1,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    minimumSize: const Size(
                                      double.infinity,
                                      58,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
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
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: (Theme.of(context).brightness == Brightness.dark)
                  ? Colors.white.withAlpha(200)
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final handleColor = isDark
        ? Colors.white.withAlpha(60)
        : Colors.black.withAlpha(20);
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(10),
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
            const SizedBox(height: 12),
            _buildSheetItem(
              icon: Icons.camera_alt_rounded,
              label: "Take a Photo",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromCameraEvent());
                Get.back();
              },
            ),
            const SizedBox(height: 20),
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
        ? Colors.white.withAlpha(10)
        : Colors.black.withAlpha(5);
    final borderColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.black.withAlpha(10);
    final textColor = isDark ? Colors.white : Colors.black87;
    final arrowColor = isDark
        ? Colors.white.withAlpha(100)
        : Colors.black.withAlpha(50);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: arrowColor, size: 14),
          ],
        ),
      ),
    );
  }

  void _showLocationSheet(BuildContext context) {
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(20)
                : Colors.black.withAlpha(10),
          ),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _buildSheetItem(
              icon: Icons.my_location_rounded,
              label: "Use Current Location",
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
            const SizedBox(height: 12),
            _buildSheetItem(
              icon: Icons.map_rounded,
              label: "Choose from Map",
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _updateProfile(BuildContext context) {
    if (Helpers.isProvider(UserTypeProfileState.userType) &&
        serviceType == "" &&
        !OtherServiceSelectState.others) {
      customAlert(context, AlertType.warning, "Please select your service");
      return;
    }
    if (zipCodeTextController.text != "" &&
        !zipCodeTextController.text.isNumericOnly) {
      customAlert(context, AlertType.warning, "Zipcode must be numeric");
      return;
    }
    if (key.currentState?.validate() ?? false) {
      final profileData = SuccessGetProfileState.profile;
      Profile profile = Profile(
        firstName: nameTextController.text.trim(),
        lastName: nameTextController.text.trim(),
        phone: contactTextController.text.trim(),
        city: profileData.city,
        rating: profileData.rating,
        country: countryTextController.text.trim(),
        ratings: profileData.ratings,
        address: locController.text.trim(),
        gender: gender,
        profilePictureUrl: profileData.profilePictureUrl,
        dateOfBirth: profileData.dateOfBirth,
        createdAt: profileData.createdAt,
        zipCode: zipCodeTextController.text.trim(),
        state: stateTextController.text.trim(),
        countryCode: countryCode,
        updatedAt: DateTime.now(),
        service: (OtherServiceSelectState.others)
            ? serviceTextController.text.trim()
            : serviceType,
        userType: UserTypeProfileState.userType,
        catalogServiceId: catalogServiceId,
        preferredPaymentMode: preferredPaymentMode,
        longitude: (UseMapState.useMap)
            ? MapLocationState.location.longitude.toString()
            : profileData.longitude,
        latitude: (UseMapState.useMap)
            ? MapLocationState.location.latitude.toString()
            : profileData.latitude,
      );

      if (OtherServiceSelectState.others) {
        context.read<SharedBloc>().add(
          AddServiceEvent(
            model: Service(
              description:
                  "The user selected others and added this a his specific services",
              name: serviceTextController.text.trim(),
            ),
          ),
        );
      }
      context.read<ProfileBloc>().add(UpdateProfileEvent(profile: profile));
    }
  }
}
