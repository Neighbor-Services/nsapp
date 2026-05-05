import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';

import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' as s;
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:nsapp/features/shared/presentation/bloc/location/location_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';

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
  late TextEditingController locController;
  
  String gender = "Male";
  String countryCode = "";
  int provider = 1;
  String serviceType = "";
  late GlobalKey<FormState> key;
  bool isImage = true;
  String catalogServiceId = "";
  String preferredPaymentMode = "ON_SITE";

  // Track local form state instead of relying on global statics
  DateTime? _dob;
  XFile? _profilePicture;
  String _userType = userTypeProvider;
  bool _others = false;
  bool _useMap = false;
  LatLng? _mapLocation;
  List<Service> _services = [];

  @override
  void initState() {
    context.read<CommonBloc>().add(GetServicesEvent());
    context.read<ProfileBloc>().add(ChooseOtherServiceEvent(others: false));
    nameTextController = TextEditingController();
    dateOfBirthTextController = TextEditingController();
    serviceTextController = TextEditingController();
    contactTextController = TextEditingController();
    locController = TextEditingController();
    key = GlobalKey<FormState>();
    
    // Attempt to pre-fill from BLoC if available immediately
    final commonState = context.read<CommonBloc>().state;
    if (commonState is SuccessGetServicesState) {
      _services = commonState.services;
    }
    
    super.initState();
  }

  @override
  void dispose() {
    nameTextController.dispose();
    dateOfBirthTextController.dispose();
    serviceTextController.dispose();
    contactTextController.dispose();
    locController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is DateOfBirthProfileState) {
                _dob = state.dob;
                dateOfBirthTextController.text = DateFormat(
                  "MMMM-dd-yyyy",
                ).format(state.dob);
              } else if (state is ImageProfileState) {
                setState(() => _profilePicture = state.profilePicture);
              } else if (state is UserTypeProfileState) {
                setState(() => _userType = state.userType);
              } else if (state is OtherServiceSelectState) {
                setState(() => _others = state.others);
              } else if (state is SuccessCreateProfileState) {
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
              } else if (state is FailureCreateProfileState) {
                customAlert(context, AlertType.error, "An error occurred");
              }
            },
          ),
          BlocListener<CommonBloc, CommonState>(
            listener: (context, state) {
              if (state is SuccessGetServicesState) {
                setState(() => _services = state.services);
              } else if (state is MapLocationState) {
                setState(() {
                  _mapLocation = state.location;
                  locController.text = state.address;
                });
              } else if (state is UseMapState) {
                setState(() => _useMap = state.useMap);
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<CommonBloc, CommonState>(
              builder: (context, commonState) {
                return LoadingView(
                  isLoading: (profileState is LoadingProfileState) || (commonState is CommonLoading),
              child: GradientBackground(
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 32.h),
                        Text(
                          "Create Your Profile",
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w500,
                            color: context.appColors.primaryTextColor,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "Complete your information to get started",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: context.appColors.secondaryTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        GestureDetector(
                          onTap: () => _showImagePickerBottomSheet(context),
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
                                    radius: 65.r,
                                    backgroundColor: Colors.white.withAlpha(15),
                                    backgroundImage: (_profilePicture != null)
                                        ? FileImage(File(_profilePicture!.path))
                                        : const AssetImage(logo2Assets) as ImageProvider,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 6.r,
                                right: 6.r,
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  decoration: BoxDecoration(
                                    color: context.appColors.primaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.r,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(60),
                                        blurRadius: 12.r,
                                        offset: Offset(0, 4.h),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.camera,
                                    color: Colors.white,
                                    size: 20.r,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Container(
                          padding: EdgeInsets.all(28.r),
                          decoration: BoxDecoration(
                            color: context.appColors.cardBackground,
                            borderRadius: BorderRadius.circular(32.r),
                            border: Border.all(
                              color: context.appColors.glassBorder,
                            ),
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
                                  prefixIcon: FontAwesomeIcons.user,
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
                                SizedBox(height: 24.h),
                                _buildLabel("Gender"),
                                SizedBox(height: 12.h),
                                CustomSegmentedControl<String>(
                                  buttonLables: const ["Male", "Female"],
                                  buttonValues: const ["Male", "Female"],
                                  defaultSelected: gender,
                                  onValueChanged: (val) {
                                    setState(() {
                                      gender = val;
                                    });
                                  },
                                  width: 270.w,
                                  height: 52.h,
                                  radius: 18.r,
                                  selectedColor: context.appColors.primaryColor.withAlpha(50),
                                  textColor: context.appColors.primaryTextColor,
                                ),
                                SizedBox(height: 24.h),
                                SolidTextField(
                                  controller: dateOfBirthTextController,
                                  hintText: "Select birth date",
                                  label: "Date Of Birth",
                                  prefixIcon: FontAwesomeIcons.calendar,
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
                                SizedBox(height: 24.h),
                                _buildLabel("User Role"),
                                SizedBox(height: 12.h),
                                CustomSegmentedControl<String>(
                                  buttonLables: const [
                                    userTypeSeeker,
                                    userTypeProvider,
                                  ],
                                  buttonValues: const [
                                    userTypeSeeker,
                                    userTypeProvider,
                                  ],
                                  defaultSelected: _userType == 'provider' ? userTypeProvider : userTypeSeeker,
                                  onValueChanged: (val) {
                                    context.read<ProfileBloc>().add(
                                      SetUserTypeEvent(
                                        userType: Helpers.isProvider(val)
                                            ? 'provider'
                                            : 'seeker',
                                      ),
                                    );
                                  },
                                  width: 270.w,
                                  height: 52.h,
                                  radius: 18.r,
                                  selectedColor: context.appColors.primaryColor.withAlpha(50),
                                  textColor: context.appColors.primaryTextColor,
                                ),
                                SizedBox(height: 24.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SolidTextField(
                                        controller: locController,
                                        hintText: "Location address",
                                        label: "Location",
                                        prefixIcon: FontAwesomeIcons.locationDot,
                                        validator: (val) {
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    GestureDetector(
                                      onTap: () => _showLocationBottomSheet(context),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 25.h),
                                          Container(
                                            width: 58.w,
                                            height: 58.h,
                                            decoration: BoxDecoration(
                                              color: context.appColors.cardBackground,
                                              borderRadius: BorderRadius.circular(20.r),
                                              border: Border.all(
                                                color: context.appColors.glassBorder,
                                              ),
                                            ),
                                            child: Icon(
                                              FontAwesomeIcons.locationCrosshairs,
                                              color: context.appColors.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 24.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: SolidTextField(
                                        controller: contactTextController,
                                        hintText: "023456789",
                                        label: "Phone Number",
                                        prefixIcon: FontAwesomeIcons.phone,
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
                                if (Helpers.isProvider(_userType)) ...[
                                  SizedBox(height: 24.h),
                                  _buildLabel("Service Type"),
                                  SizedBox(height: 12.h),
                                  GestureDetector(
                                    onTap: () {
                                      showServiceSelector(
                                        context: context,
                                        services: _services,
                                        selectedServiceId: serviceType.isEmpty ? null : serviceType,
                                        onServiceSelected: (serviceId, serviceName) {
                                          setState(() {
                                            serviceType = serviceName;
                                            catalogServiceId = serviceId;
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
                                        horizontal: 20.w,
                                        vertical: 18.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.appColors.cardBackground,
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: context.appColors.glassBorder,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.briefcase,
                                            color: context.appColors.primaryColor.withAlpha(200),
                                          ),
                                          SizedBox(width: 14.w),
                                          Expanded(
                                            child: Text(
                                              serviceType.isEmpty
                                                  ? "Select Your Profession"
                                                  : serviceType,
                                              style: TextStyle(
                                                color: context.appColors.secondaryTextColor,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            FontAwesomeIcons.upDown,
                                            color: context.appColors.secondaryTextColor,
                                            size: 20.r,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_others) ...[
                                    SizedBox(height: 24.h),
                                    SolidTextField(
                                      controller: serviceTextController,
                                      hintText: "Enter your custom service",
                                      label: "Custom Service",
                                      prefixIcon: FontAwesomeIcons.buildingCircleCheck,
                                    ),
                                  ],
                                  SizedBox(height: 24.h),
                                  _buildLabel("Preferred Payment Method"),
                                  SizedBox(height: 12.h),
                                  CustomSegmentedControl<String>(
                                    buttonLables: const ["In-App", "On-Site"],
                                    buttonValues: const ["IN_APP", "ON_SITE"],
                                    defaultSelected: "ON_SITE",
                                    onValueChanged: (val) {
                                      setState(() {
                                        preferredPaymentMode = val;
                                      });
                                    },
                                    width: 270.w,
                                    height: 52.h,
                                    radius: 18.r,
                                    selectedColor: context.appColors.primaryColor.withAlpha(50),
                                    textColor: context.appColors.primaryTextColor,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Container(
                          width: double.infinity,
                          height: 60.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22.r),
                            boxShadow: [
                              BoxShadow(
                                color: context.appColors.primaryColor.withAlpha(100),
                                blurRadius: 20.r,
                                offset: Offset(0, 8.h),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (Helpers.isProvider(_userType) && !_others && serviceType == "") {
                                customAlert(
                                  context,
                                  AlertType.warning,
                                  "Please select your service",
                                );
                                return;
                              }
                              
                              if (_dob == null) {
                                customAlert(context, AlertType.warning, "Please select your date of birth");
                                return;
                              }

                              final userLoc = context.read<LocationBloc>().state.location;
                              Profile profile = Profile(
                                firstName: nameTextController.text.trim(),
                                lastName: nameTextController.text.trim(),
                                phone: contactTextController.text.trim(),
                                city: userLoc.city,
                                rating: "0.0",
                                country: userLoc.country,
                                ratings: [],
                                address: locController.text,
                                gender: gender,
                                dateOfBirth: _dob!,
                                createdAt: DateTime.now(),
                                zipCode: userLoc.zipCode,
                                state: userLoc.state,
                                countryCode: countryCode,
                                updatedAt: DateTime.now(),
                                service: _others ? serviceTextController.text.trim() : serviceType,
                                userType: _userType,
                                preferredPaymentMode: preferredPaymentMode,
                                catalogServiceId: catalogServiceId,
                                latitude: (locController.text.isNotEmpty)
                                    ? (_useMap && _mapLocation != null)
                                        ? _mapLocation!.latitude.toString()
                                        : userLoc.position.latitude.toString()
                                    : null,
                                longitude: (locController.text.isNotEmpty)
                                    ? (_useMap && _mapLocation != null)
                                        ? _mapLocation!.longitude.toString()
                                        : userLoc.position.longitude.toString()
                                    : null,
                              );

                              if (key.currentState!.validate()) {
                                if (_others) {
                                  context.read<CommonBloc>().add(
                                    AddServiceEvent(
                                      model: Service(
                                        description: "Custom service added by user during profile creation",
                                        name: serviceTextController.text.trim(),
                                      ),
                                    ),
                                  );
                                }
                                context.read<ProfileBloc>().add(
                                  AddProfileEvent(
                                    profile: profile,
                                    profilePicturePath: _profilePicture?.path,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.appColors.primaryColor,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                            ),
                            child: Text(
                              "Complete Profile Creation",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  ),
);
}

  void _showImagePickerBottomSheet(BuildContext context) {
    final handleColor = context.appColors.glassBorder;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(
            color: context.appColors.glassBorder,
          ),
        ),
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45.w,
              height: 6.h,
              margin: EdgeInsets.only(bottom: 28.h),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(12.r),
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
            SizedBox(height: 16.h),
            _buildSheetItem(
              icon: FontAwesomeIcons.camera,
              label: "Take a Photo",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromCameraEvent());
                Get.back();
              },
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _showLocationBottomSheet(BuildContext context) {
    final handleColor = context.appColors.glassBorder;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(
            color: context.appColors.glassBorder,
          ),
        ),
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 45.w,
              height: 6.h,
              margin: EdgeInsets.only(bottom: 28.h),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            _buildSheetItem(
              icon: FontAwesomeIcons.locationCrosshairs,
              label: "Current Location",
              onTap: () async {
                context.read<CommonBloc>().add(UseMapEvent(useMap: false));
                context.read<s.SeekerBloc>().add(
                  s.ChangeLocationEvent(change: true),
                );
                final userLocation = await Helpers.getLocation();
                if (userLocation != null) {
                  if (mounted) {
                    context.read<LocationBloc>().add(UpdateLocationEvent(location: userLocation));
                    locController.text = userLocation.address;
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
            SizedBox(height: 16.h),
            _buildSheetItem(
              icon: FontAwesomeIcons.map,
              label: "Pick from Map",
              onTap: () {
                context.read<s.SeekerBloc>().add(
                  s.ChangeLocationEvent(change: true),
                );
                Get.back();
                context.read<CommonBloc>().add(UseMapEvent(useMap: true));
                Helpers.getLocation();
                Get.toNamed("map-location")?.then((result) {
                  if (result != null && result is String) {
                    locController.text = result;
                  }
                });
              },
            ),
            SizedBox(height: 24.h),
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
    final itemBg = context.appColors.cardBackground;
    final borderColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: itemBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.appColors.primaryColor, size: 26.r),
            SizedBox(width: 18.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 17.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            FaIcon(FontAwesomeIcons.chevronRight, color: context.appColors.primaryColor, size: 16.r),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: context.appColors.primaryTextColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}


