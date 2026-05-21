import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:io';

import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import '../../../../core/helpers/helpers.dart';
import '../../../../core/models/profile.dart';
import '../../../seeker/presentation/bloc/seeker_bloc.dart' as s;
import '../../../shared/presentation/bloc/common/common_bloc.dart';
import '../../../shared/presentation/bloc/common/common_event.dart';
import '../../../shared/presentation/bloc/common/common_state.dart';
import '../../../shared/presentation/bloc/location/location_bloc.dart';
import '../../../shared/presentation/bloc/settings/settings_bloc.dart';
import '../../../shared/presentation/widget/loading_view.dart';
import '../bloc/profile_bloc.dart';
import 'package:nsapp/core/core.dart';
import 'package:image_picker/image_picker.dart';

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
  late TextEditingController locController;
  
  String gender = "MALE";
  String countryCode = "";
  String serviceType = "";
  String catalogServiceId = "";
  String preferredPaymentMode = "ON_SITE";
  String userType = "seeker";
  bool isOthersSelected = false;
  XFile? _selectedImage;
  Profile? _currentProfile;
  DateTime? _selectedDob;
  
  bool _useMap = false;
  LatLng? _mapLocation;
  List<Service> _services = [];
  
  late GlobalKey<FormState> key;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<CommonBloc>().add(GetServicesEvent());
    context.read<ProfileBloc>().add(ChooseOtherServiceEvent(others: false));
    
    nameTextController = TextEditingController();
    dateOfBirthTextController = TextEditingController();
    contactTextController = TextEditingController();
    zipCodeTextController = TextEditingController();
    countryTextController = TextEditingController();
    stateTextController = TextEditingController();
    serviceTextController = TextEditingController();
    locController = TextEditingController();
    key = GlobalKey<FormState>();

    // Initial load attempt if state is already success
    final state = context.read<ProfileBloc>().state;
    if (state is SuccessGetProfileState) {
      _initializeWithProfile(state.profile);
    } else if (state is SuccessGetProfileStreamState) {
      _initializeWithProfile(state.profile);
    }

    // Initial load attempt for common state
    final commonState = context.read<CommonBloc>().state;
    if (commonState is SuccessGetServicesState) {
      _services = commonState.services;
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  void _initializeWithProfile(Profile profile) {
    _currentProfile = profile;
    nameTextController.text = "${profile.firstName} ${profile.lastName}";
    locController.text = profile.address ?? "";
    contactTextController.text = profile.phone ?? "";
    zipCodeTextController.text = profile.zipCode ?? "";
    countryTextController.text = profile.country ?? "";
    stateTextController.text = profile.state ?? "";
    _selectedDob = profile.dateOfBirth;
    dateOfBirthTextController.text = _selectedDob != null
        ? DateFormat("MMMM-dd-yyyy").format(_selectedDob!)
        : "";

    if (profile.service != null && profile.service != "") {
      serviceType = profile.service ?? "";
    }

    countryCode = profile.countryCode ?? "";
    gender = profile.gender ?? "MALE";
    catalogServiceId = profile.catalogServiceId ?? "";
    preferredPaymentMode = profile.preferredPaymentMode ?? "BOTH";
    userType = profile.userType ?? "seeker";

    context.read<ProfileBloc>().add(SetUserTypeEvent(userType: userType));
  }

  @override
  void dispose() {
    zipCodeTextController.dispose();
    nameTextController.dispose();
    dateOfBirthTextController.dispose();
    contactTextController.dispose();
    countryTextController.dispose();
    stateTextController.dispose();
    serviceTextController.dispose();
    locController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<CommonBloc, CommonState>(
            listener: (context, state) {
              if (state is SuccessGetServicesState) {
                setState(() => _services = state.services);
              }
              if (state is SuccessAddServicesState) {
                catalogServiceId = state.id ?? "";
                _submitForm();
              }
              if (state is UseMapState) {
                setState(() => _useMap = state.useMap);
              }
              if (state is MapLocationState) {
                setState(() {
                  _mapLocation = state.location;
                  locController.text = state.address;
                });
              }
            },
          ),
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is DateOfBirthProfileState) {
            _selectedDob = state.dob;
            dateOfBirthTextController.text = DateFormat(
              "MMMM-dd-yyyy",
            ).format(_selectedDob!);
          }
          if (state is ImageProfileState) {
            setState(() {
              _selectedImage = state.profilePicture;
            });
          }
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
          if (state is SuccessUpdateProfileState) {
            context.read<ProfileBloc>().add(GetProfileStreamEvent());
            context.read<CommonBloc>().add(GetServicesEvent());
            
            if (Helpers.isSeeker(userType)) {
              context.read<SettingsBloc>().add(
                ToggleDashboardEvent(isProvider: false),
              );
            }
            customAlert(context, AlertType.success, "Profile updated successfully");
            
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                context.pop();
              }
            });
          }
          if (state is FailureUpdateProfileState) {
            customAlert(context, AlertType.error, state.message);
          }
          if (state is SuccessGetProfileState) {
            setState(() => _initializeWithProfile(state.profile));
          }
          if (state is SuccessGetProfileStreamState) {
            setState(() => _initializeWithProfile(state.profile));
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(GetProfileStreamEvent());
                context.read<ProfileBloc>().add(GetProfileEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                        onTap: () => context.pop(),
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
                        "EDIT PROFILE",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primaryTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "UPDATE YOUR INFORMATION TO KEEP IT ACCURATE",
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.secondaryTextColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      
                      // Profile Picture Section
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
                                    backgroundColor: Colors.white.withAlpha(10),
                                    backgroundImage: _buildProfileImageProvider(),
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
                      
                      // Main Form Container
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
                              prefixIcon: FontAwesomeIcons.user,
                              validator: ValidationUtil.validateName,
                            ),
                            SizedBox(height: 24.h),
                            _buildLabel("Gender"),
                            SizedBox(height: 12.h),
                            CustomSegmentedControl<String>(
                              buttonLables: const ["MALE", "FEMALE"],
                              buttonValues: const ["Male", "Female"],
                              defaultSelected: gender.isNotEmpty 
                                  ? "${gender[0].toUpperCase()}${gender.substring(1).toLowerCase()}" 
                                  : "Male",
                              onValueChanged: (val) {
                                setState(() => gender = val.toUpperCase());
                              },
                              width: 240.w,
                              height: 50.h,
                              radius: 16.r,
                              selectedColor: context.appColors.primaryColor.withAlpha(40),
                              textColor: context.appColors.primaryTextColor,
                            ),
                            SizedBox(height: 24.h),
                            _buildLabel("Account Type"),
                            SizedBox(height: 12.h),
                            CustomSegmentedControl<String>(
                              buttonLables: const ["SEEKER", "PROVIDER"],
                              buttonValues: const [userTypeSeeker, userTypeProvider],
                              defaultSelected: userType,
                              onValueChanged: (val) {
                                context.read<ProfileBloc>().add(SetUserTypeEvent(userType: val));
                              },
                              width: 240.w,
                              height: 50.h,
                              radius: 16.r,
                              selectedColor: context.appColors.primaryColor.withAlpha(40),
                              textColor: context.appColors.primaryTextColor,
                            ),
                            SizedBox(height: 24.h),
                            
                            // Location Field with Map Picker
                            Row(
                              children: [
                                Expanded(
                                  child: SolidTextField(
                                    controller: locController,
                                    hintText: "LOCATION",
                                    label: "LOCATION",
                                    prefixIcon: FontAwesomeIcons.locationDot,
                                    validator: (val) => ValidationUtil.validateRequired(val, "Location"),
                                  ),
                                ),
                                SizedBox(width: 16.w),
                                GestureDetector(
                                  onTap: () => _showLocationSheet(context),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 25.h),
                                      Container(
                                        width: 58.r,
                                        height: 58.r,
                                        decoration: BoxDecoration(
                                          color: context.appColors.primaryColor.withAlpha(40),
                                          borderRadius: BorderRadius.circular(18.r),
                                          border: Border.all(color: context.appColors.primaryColor),
                                        ),
                                        child: Icon(FontAwesomeIcons.map, color: context.appColors.primaryColor),
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
                              prefixIcon: FontAwesomeIcons.phone,
                              keyboardType: TextInputType.phone,
                              validator: ValidationUtil.validatePhone,
                            ),
                            SizedBox(height: 24.h),
                            
                            SolidTextField(
                              controller: countryTextController,
                              hintText: "COUNTRY",
                              label: "COUNTRY",
                              prefixIcon: FontAwesomeIcons.globe,
                              validator: (val) => ValidationUtil.validateRequired(val, "Country"),
                            ),
                            SizedBox(height: 24.h),
                            
                            SolidTextField(
                              controller: stateTextController,
                              hintText: "STATE",
                              label: "STATE",
                              prefixIcon: FontAwesomeIcons.building,
                              validator: (val) => ValidationUtil.validateRequired(val, "State"),
                            ),
                            SizedBox(height: 24.h),
                            
                            SolidTextField(
                              controller: zipCodeTextController,
                              hintText: "ZIP CODE",
                              label: "ZIP CODE",
                              prefixIcon: FontAwesomeIcons.mapPin,
                            ),
                            
                            // Provider Specific Fields
                            if (Helpers.isProvider(userType)) ...[
                              SizedBox(height: 24.h),
                              _buildLabel("Primary Service"),
                              SizedBox(height: 12.h),
                              _buildServicePicker(),
                              
                              if (isOthersSelected) ...[
                                SizedBox(height: 24.h),
                                SolidTextField(
                                  controller: serviceTextController,
                                  hintText: "SPECIFY SERVICE",
                                  label: "SPECIFY SERVICE",
                                  prefixIcon: FontAwesomeIcons.buildingCircleCheck,
                                  validator: (val) => ValidationUtil.validateRequired(val, "Service"),
                                ),
                              ],
                              
                              SizedBox(height: 24.h),
                              _buildLabel("Preferred Payment Mode"),
                              SizedBox(height: 12.h),
                              CustomSegmentedControl<String>(
                                buttonLables: const ["In-App", "On-Site"],
                                buttonValues: const ["IN_APP", "ON_SITE"],
                                defaultSelected: preferredPaymentMode,
                                onValueChanged: (val) => setState(() => preferredPaymentMode = val),
                                width: 240.w,
                                height: 50.h,
                                radius: 16.r,
                                selectedColor: context.appColors.primaryColor.withAlpha(40),
                                textColor: context.appColors.primaryTextColor,
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 40.h),
                      
                      // Save Button
                      _buildSaveButton(),
                    ],
                  ),
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
        );
      },
    ),
  ),
);
}

  ImageProvider _buildProfileImageProvider() {
    if (_selectedImage != null) {
      return FileImage(File(_selectedImage!.path));
    }
    if (_currentProfile?.profilePictureUrl != null &&
        _currentProfile!.profilePictureUrl!.isNotEmpty &&
        !_currentProfile!.profilePictureUrl!.startsWith("file:///")) {
      return CachedNetworkImageProvider(_currentProfile!.profilePictureUrl!);
    }
    return const AssetImage(person) as ImageProvider;
  }

  Widget _buildServicePicker() {
    return GestureDetector(
      onTap: () {
        showServiceSelector(
          context: context,
          services: _services,
          selectedServiceId: serviceType,
          onServiceSelected: (serviceId, serviceName) {
            setState(() {
              serviceType = serviceName;
              catalogServiceId = serviceId;
            });
            context.read<ProfileBloc>().add(ChooseOtherServiceEvent(others: false));
          },
          onOthersSelected: () {
            context.read<ProfileBloc>().add(ChooseOtherServiceEvent(others: true));
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: context.appColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(FontAwesomeIcons.crown, color: context.appColors.primaryColor.withAlpha(180)),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                serviceType.isEmpty ? "SELECT SERVICE" : serviceType,
                style: TextStyle(
                  color: context.appColors.primaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(FontAwesomeIcons.upDown, color: context.appColors.glassBorder, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          minimumSize: Size(double.infinity, 58.h),
          elevation: 0,
        ),
        child:  Text(
          "SAVE CHANGES",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500, letterSpacing: 1.0),
        ),
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
              fontWeight: FontWeight.w500,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(color: context.appColors.glassBorder),
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
                context.pop();
              },
            ),
            SizedBox(height: 12.h),
            _buildSheetItem(
              icon: FontAwesomeIcons.camera,
              label: "Take a Photo",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromCameraEvent());
                context.pop();
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.appColors.glassBorder,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: context.appColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.appColors.infoColor, size: 24.r),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                color: context.appColors.primaryTextColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            FaIcon(FontAwesomeIcons.chevronRight, color: context.appColors.glassBorder, size: 14.r),
          ],
        ),
      ),
    );
  }

  void _showLocationSheet(BuildContext context) {
    final handleColor = context.appColors.glassBorder;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          border: Border.all(color: context.appColors.glassBorder),
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
                context.read<CommonBloc>().add(UseMapEvent(useMap: false));
                context.read<s.SeekerBloc>().add(s.ChangeLocationEvent(change: true));
                final userLocation = await Helpers.getLocation();
                if (userLocation != null) {
                  if (mounted) {
                    context.read<LocationBloc>().add(UpdateLocationEvent(location: userLocation));
                    locController.text = userLocation.address;
                    context.pop();
                  }
                } else {
                  if (mounted) {
                    context.pop();
                    customAlert(context, AlertType.error, "Unable to get location.");
                  }
                }
              },
            ),
            SizedBox(height: 12.h),
            _buildSheetItem(
              icon: FontAwesomeIcons.map,
              label: "Choose from Map",
              onTap: () {
                context.read<s.SeekerBloc>().add(s.ChangeLocationEvent(change: true));
                context.pop();
                context.read<CommonBloc>().add(UseMapEvent(useMap: true));
                Helpers.getLocation();
                context.push("/map-location").then((result) {
                  if (result != null && result is String) {
                    locController.text = result;
                  }
                });
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  /// Called after a custom service is successfully created.
  /// At this point, [catalogServiceId] has already been populated from
  /// [SuccessAddServicesState], so we can dispatch the update directly.
  void _submitForm() {
    final profileData = _currentProfile ?? Profile();
    final nameParts = nameTextController.text.trim().split(" ");
    final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

    final profile = Profile(
      firstName: firstName,
      lastName: lastName,
      phone: contactTextController.text.trim(),
      city: profileData.city,
      rating: profileData.rating,
      country: countryTextController.text.trim(),
      ratings: profileData.ratings,
      address: locController.text.trim(),
      gender: gender,
      profilePictureUrl: profileData.profilePictureUrl,
      dateOfBirth: _selectedDob,
      createdAt: profileData.createdAt,
      zipCode: zipCodeTextController.text.trim(),
      state: stateTextController.text.trim(),
      countryCode: countryCode,
      updatedAt: DateTime.now(),
      service: serviceTextController.text.trim(),
      userType: userType,
      catalogServiceId: catalogServiceId,
      preferredPaymentMode: preferredPaymentMode,
      longitude: (_useMap && _mapLocation != null) ? _mapLocation!.longitude.toString() : profileData.longitude,
      latitude: (_useMap && _mapLocation != null) ? _mapLocation!.latitude.toString() : profileData.latitude,
    );

    context.read<ProfileBloc>().add(UpdateProfileEvent(
      profile: profile,
      profilePicturePath: _selectedImage?.path,
    ));
  }

  void _updateProfile(BuildContext context) {

    if (Helpers.isProvider(userType) && serviceType.isEmpty && !isOthersSelected) {
      customAlert(context, AlertType.warning, "Please select your service");
      return;
    }
    if (key.currentState?.validate() ?? false) {
      final profileData = _currentProfile ?? Profile();
      final nameParts = nameTextController.text.trim().split(" ");
      final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";
      
      Profile profile = Profile(
        firstName: firstName,
        lastName: lastName,
        phone: contactTextController.text.trim(),
        city: profileData.city,
        rating: profileData.rating,
        country: countryTextController.text.trim(),
        ratings: profileData.ratings,
        address: locController.text.trim(),
        gender: gender,
        profilePictureUrl: profileData.profilePictureUrl,
        dateOfBirth: _selectedDob,
        createdAt: profileData.createdAt,
        zipCode: zipCodeTextController.text.trim(),
        state: stateTextController.text.trim(),
        countryCode: countryCode,
        updatedAt: DateTime.now(),
        service: isOthersSelected ? serviceTextController.text.trim() : serviceType,
        userType: userType,
        catalogServiceId: catalogServiceId,
        preferredPaymentMode: preferredPaymentMode,
        longitude: (_useMap && _mapLocation != null) ? _mapLocation!.longitude.toString() : profileData.longitude,
        latitude: (_useMap && _mapLocation != null) ? _mapLocation!.latitude.toString() : profileData.latitude,
      );

      if (isOthersSelected) {
        context.read<CommonBloc>().add(
          AddServiceEvent(
            model: Service(
              description: "Custom service added by user",
              name: serviceTextController.text.trim(),
            ),
          ),
        );
      }
      
      // Pass the new image path if selected
      context.read<ProfileBloc>().add(UpdateProfileEvent(
        profile: profile,
        profilePicturePath: _selectedImage?.path,
      ));
    }
  }
}


