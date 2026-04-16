import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';


import '../../../../core/helpers/helpers.dart';
import '../../../../core/initialize/init.dart';
import '../../../../core/models/profile.dart';
import '../../../seeker/presentation/bloc/seeker_bloc.dart' as s;
import '../../../shared/presentation/bloc/shared_bloc.dart';
import '../../../shared/presentation/widget/loading_view.dart';
import '../bloc/profile_bloc.dart';
import 'package:nsapp/core/core.dart';

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
                    constraints: BoxConstraints(maxWidth: 700.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 24.h,
                        ),
                        child: Form(
                          key: key,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: context.appColors.cardBackground,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: context.appColors.glassBorder,
                                      width: 1.5.r,
                                    ),
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.chevronLeft,
                                    color: context.appColors.primaryTextColor,
                                    size: 20.r,
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),
                              Text(
                                "EDIT PROFESSIONAL PROFILE",
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w900,
                                  color: context.appColors.primaryTextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                "KEEP YOUR PROFILE UPDATED TO BUILD TRUST",
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w900,
                                  color: context.appColors.secondaryTextColor,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 30.h),
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    _showImageSourceSheet(context);
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: context.appColors.glassBorder,
                                            width: 2.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: context.appColors.primaryColor.withAlpha(50),
                                              blurRadius: 40.r,
                                              spreadRadius: -5.r,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.all(2.r),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: context.appColors.glassBorder,
                                              width: 1.r,
                                            ),
                                          ),
                                          child: CircleAvatar(
                                            radius: 60.r,
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
                                        bottom: 4.r,
                                        right: 4.r,
                                        child: Container(
                                          padding: EdgeInsets.all(10.r),
                                          decoration: BoxDecoration(
                                            color: context.appColors.primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withAlpha(40),
                                              width: 2.r,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  40,
                                                ),
                                                blurRadius: 10.r,
                                                offset: Offset(0, 4.h),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            FontAwesomeIcons.camera,
                                            color: Colors.white,
                                            size: 18.r,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.h),
                              Container(
                                padding: EdgeInsets.all(24.r),
                                decoration: BoxDecoration(
                                  color: context.appColors.cardBackground,
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: context.appColors.glassBorder,
                                    width: 1.5.r,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    SolidTextField(
                                      controller: nameTextController,
                                      hintText: "ENTER YOUR NAME",
                                      label: "FULL NAME",
                                      allCapsLabel: true,
                                      prefixIcon: FontAwesomeIcons.user,
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
                                    SizedBox(height: 24.h),
                                    _buildLabel("Gender"),
                                    SizedBox(height: 12.h),
                                    CustomSegmentedControl<String>(
                                      buttonLables: const ["MALE", "FEMALE"],
                                      buttonValues: const ["Male", "Female"],
                                      defaultSelected:
                                          gender == "MALE" ? "Male" : "Female",
                                      onValueChanged: (val) {
                                        setState(() {
                                          gender = val;
                                        });
                                      },
                                      width: 240.w,
                                      height: 50.h,
                                      radius: 16.r,
                                      selectedColor: context.appColors.primaryColor.withAlpha(40),
                                      textColor: context.appColors.primaryTextColor,
                                    ),
                                    SizedBox(height: 24.h),
                                    _buildLabel("Role Type"),
                                    SizedBox(height: 12.h),
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
                                      width: 240.w,
                                      height: 50.h,
                                      radius: 16.r,
                                      selectedColor: context.appColors.primaryColor.withAlpha(40),
                                      textColor: context.appColors.primaryTextColor,
                                    ),
                                    SizedBox(height: 24.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SolidTextField(
                                            controller: locController,
                                            hintText: "LOCATION",
                                            label: "LOCATION",
                                            allCapsLabel: true,
                                            prefixIcon:
                                                FontAwesomeIcons.locationDot,
                                            validator: (val) {
                                              if ((val ?? "").isEmpty) {
                                                return "Location is required";
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        GestureDetector(
                                          onTap: () =>
                                              _showLocationSheet(context),
                                          child: Column(
                                            children: [
                                              SizedBox(height: 25.h),
                                              Container(
                                                width: 58.r,
                                                height: 58.r,
                                                decoration: BoxDecoration(
                                                  color: context.appColors.primaryColor.withAlpha(40),
                                                  borderRadius:
                                                      BorderRadius.circular(18.r),
                                                  border: Border.all(
                                                    color: context.appColors.primaryColor,
                                                  ),
                                                  
                                                ),
                                                child: Icon(
                                                  FontAwesomeIcons.map,
                                                  color: context.appColors.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 24.h),
                                    SolidTextField(
                                      controller: contactTextController,
                                      hintText: "PHONE NUMBER",
                                      label: "PHONE NUMBER",
                                      allCapsLabel: true,
                                      prefixIcon: FontAwesomeIcons.phone,
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
                                    SizedBox(height: 24.h),
                                    SolidTextField(
                                      controller: countryTextController,
                                      hintText: "COUNTRY",
                                      label: "COUNTRY",
                                      allCapsLabel: true,
                                      prefixIcon: FontAwesomeIcons.globe,
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "Country is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 24.h),
                                    SolidTextField(
                                      controller: stateTextController,
                                      hintText: "State",
                                      label: "State",
                                      prefixIcon: FontAwesomeIcons.building,
                                      validator: (val) {
                                        if ((val ?? "").isEmpty) {
                                          return "State is required";
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 24.h),
                                    SolidTextField(
                                      controller: zipCodeTextController,
                                      hintText: "Zip Code",
                                      label: "Zip Code",
                                      prefixIcon: FontAwesomeIcons.mapPin,
                                    ),
                                    if (Helpers.isProvider(
                                      UserTypeProfileState.userType,
                                    )) ...[
                                      SizedBox(height: 24.h),
                                      _buildLabel("Primary Service"),
                                      SizedBox(height: 12.h),
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
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20.w,
                                            vertical: 18.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appColors.cardBackground,
                                            borderRadius: BorderRadius.circular(
                                              18.r,
                                            ),
                                            border: Border.all(
                                              color: context.appColors.glassBorder,
                                            ),
                                            
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                FontAwesomeIcons.crown,
                                                color: context.appColors.primaryColor
                                                    .withAlpha(180),
                                              ),
                                              SizedBox(width: 14.w),
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
                                                    color: context.appColors.primaryTextColor,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                FontAwesomeIcons.upDown,
                                                color: context.appColors.glassBorder,
                                                size: 20.r,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (OtherServiceSelectState.others) ...[
                                        SizedBox(height: 24.h),
                                        SolidTextField(
                                          controller: serviceTextController,
                                          hintText: "Specify service",
                                          label: "Specify Service",
                                          prefixIcon:
                                              FontAwesomeIcons.buildingCircleCheck,
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
                                        SizedBox(height: 24.h),
                                        _buildLabel("Preferred Payment Mode"),
                                        SizedBox(height: 12.h),
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
                                          width: 240.w,
                                          height: 50.h,
                                          radius: 16.r,
                                          selectedColor: context.appColors.primaryColor.withAlpha(40),
                                          textColor: context.appColors.primaryTextColor,
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: 40.h),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.appColors.primaryColor.withAlpha(80),
                                      blurRadius: 15.r,
                                      offset: Offset(0, 5.h),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _updateProfile(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.appColors.primaryColor,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    minimumSize: Size(
                                      double.infinity,
                                      58.h,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "SAVE CHANGES",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
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
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              color: context.appColors.primaryTextColor,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {

    final handleColor = context.appColors.glassBorder;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(
            color: context.appColors.glassBorder,
          ),
        ),
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 5.h,
              margin: EdgeInsets.only(bottom: 28.h),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            _buildSheetItem(
              icon: FontAwesomeIcons.images,
              label: "Choose from Gallery",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromGalleryEvent());
                Get.back();
              },
            ),
            SizedBox(height: 12.h),
            _buildSheetItem(
              icon: FontAwesomeIcons.camera,
              label: "Take a Photo",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromCameraEvent());
                Get.back();
              },
            ),
            SizedBox(height: 20.h),
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
    final itemBg = context.appColors.glassBorder;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final arrowColor = context.appColors.glassBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.appColors.infoColor, size: 24.r),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            FaIcon(FontAwesomeIcons.chevronRight, color: arrowColor, size: 14.r),
          ],
        ),
      ),
    );
  }

  void _showLocationSheet(BuildContext context) {
    
    final handleColor = context.appColors.glassBorder;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(
            color: context.appColors.glassBorder,
          ),
        ),
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 5.h,
              margin: EdgeInsets.only(bottom: 28.h),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            _buildSheetItem(
              icon: FontAwesomeIcons.locationCrosshairs,
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
            SizedBox(height: 12.h),
            _buildSheetItem(
              icon: FontAwesomeIcons.map,
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
            SizedBox(height: 20.h),
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


