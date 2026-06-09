import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:io';

import 'package:nsapp/features/shared/presentation/widget/custom_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/core/models/subscription_plan.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart' as s;
import 'package:nsapp/features/shared/presentation/bloc/subscription/subscription_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/custom_text_widget.dart';
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

class _AddProfileAuthPageState extends State<AddProfileAuthPage>
    with TickerProviderStateMixin {
  // Controllers
  late TextEditingController nameTextController;
  late TextEditingController dateOfBirthTextController;
  late TextEditingController serviceTextController;
  late TextEditingController contactTextController;
  late TextEditingController locController;

  // Form state
  String gender = "Male";
  String countryCode = "";
  String serviceType = "";
  String catalogServiceId = "";
  String preferredPaymentMode = "ON_SITE";
  List<String> selectedCatalogServiceIds = [];
  List<String> selectedCatalogServiceNames = [];
  late GlobalKey<FormState> _formKey;
  DateTime? _dob;
  XFile? _profilePicture;
  String _userType = userTypeProvider;
  bool _others = false;
  bool _useMap = false;
  bool _pendingProfileSubmit = false;
  LatLng? _mapLocation;
  List<Service> _services = [];

  // Stepper state
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _progressController;

  // Subscription state
  List<SubscriptionPlan> _allPlans = [];
  String _selectedInterval = 'month';
  String? _selectedPlanId;

  static const int _totalSteps = 4;

  // Step titles and descriptions
  static const List<Map<String, String>> _stepInfo = [
    {'title': 'Personal Info', 'subtitle': 'Tell us about yourself'},
    {'title': 'Location', 'subtitle': 'Where are you based?'},
    {'title': 'Account Setup', 'subtitle': 'Configure your role'},
    {'title': 'Choose Plan', 'subtitle': 'Select your subscription'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<CommonBloc>().add(GetServicesEvent());
    context.read<ProfileBloc>().add(ChooseOtherServiceEvent(others: false));
    context.read<SubscriptionBloc>().add(GetSubscriptionPlansEvent());

    nameTextController = TextEditingController();
    dateOfBirthTextController = TextEditingController();
    serviceTextController = TextEditingController();
    contactTextController = TextEditingController();
    locController = TextEditingController();
    _formKey = GlobalKey<FormState>();

    _pageController = PageController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Attempt to pre-fill from BLoC if available immediately
    final commonState = context.read<CommonBloc>().state;
    if (commonState is SuccessGetServicesState) {
      _services = commonState.services;
    }
  }

  @override
  void dispose() {
    nameTextController.dispose();
    dateOfBirthTextController.dispose();
    serviceTextController.dispose();
    contactTextController.dispose();
    locController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  int get _effectiveTotalSteps {
    // If user is a seeker, skip step 3 (Account Setup) and step 4 (Plan)
    // If user is a provider, show all 4 steps
    return Helpers.isProvider(_userType) ? _totalSteps : 2;
  }

  void _goToStep(int step) {
    if (step < 0 || step >= _effectiveTotalSteps) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    // Validate current step
    if (!_validateCurrentStep()) return;

    if (_currentStep < _effectiveTotalSteps - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _submitProfile();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  bool _validateCurrentStep() {
    final actualStep = _getActualStepIndex(_currentStep);

    switch (actualStep) {
      case 0: // Personal Info
        if (nameTextController.text.trim().isEmpty) {
          customAlert(context, AlertType.warning, "Please enter your name");
          return false;
        }
        if (containSpecial(nameTextController.text.trim())) {
          customAlert(
            context,
            AlertType.warning,
            "Name cannot contain special characters",
          );
          return false;
        }
        if (_dob == null) {
          customAlert(
            context,
            AlertType.warning,
            "Please select your date of birth",
          );
          return false;
        }
        return true;
      case 1: // Location & Contact
        if (contactTextController.text.trim().isEmpty) {
          customAlert(
            context,
            AlertType.warning,
            "Please enter your phone number",
          );
          return false;
        }
        return true;
      case 2: // Account Setup (Provider only)
        if (Helpers.isProvider(_userType) && !_others && serviceType.isEmpty) {
          customAlert(context, AlertType.warning, "Please select your service");
          return false;
        }
        return true;
      case 3: // Subscription (Provider only)
        if (Helpers.isProvider(_userType) && _selectedPlanId == null) {
          customAlert(
            context,
            AlertType.warning,
            "Please select a subscription plan to continue as a provider.",
          );
          return false;
        }
        // Check if selected services are within the subscription limit
        final maxAllowed = _getSelectedPlanMaxCatalogServices();
        if (maxAllowed > 0 && selectedCatalogServiceIds.length > maxAllowed) {
          customAlert(
            context,
            AlertType.warning,
            "Your selected plan allows up to $maxAllowed services, but you have selected ${selectedCatalogServiceIds.length}. Please go back to step 3 and reduce your services, or choose a higher plan.",
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  int _getActualStepIndex(int visualStep) {
    // For seekers, steps 0 and 1 map directly
    // For providers, all 4 steps map directly
    if (Helpers.isProvider(_userType)) {
      return visualStep;
    }
    return visualStep; // Seekers only have steps 0 and 1
  }

  int _getSelectedPlanMaxCatalogServices() {
    if (_selectedPlanId == null) return 0; // Default: 0 if no plan
    try {
      final selectedPlan = _allPlans.firstWhere(
        (plan) => plan.id == _selectedPlanId,
      );
      return selectedPlan.maxCatalogServices ?? 0;
    } catch (_) {
      return 0;
    }
  }

  void _submitProfile() {
    // Enforce selected services limit against selected plan
    if (Helpers.isProvider(_userType)) {
      if (_selectedPlanId == null) {
        customAlert(
          context,
          AlertType.warning,
          "Please select a subscription plan to continue as a provider.",
        );
        return;
      }
      final maxAllowed = _getSelectedPlanMaxCatalogServices();
      if (maxAllowed > 0 && selectedCatalogServiceIds.length > maxAllowed) {
        customAlert(
          context,
          AlertType.warning,
          "Your selected plan allows up to $maxAllowed services, but you have selected ${selectedCatalogServiceIds.length}. Please go back to step 3 and reduce your services, or upgrade your plan.",
        );
        return;
      }

      // For providers with a selected plan, subscribe FIRST then create profile
      // after successful payment. This ensures the backend serializer finds an
      // active subscription when validating catalog_services.
      setState(() => _pendingProfileSubmit = true);
      context.read<SubscriptionBloc>().add(
        MakeSubscriptionEvent(planId: _selectedPlanId!, context: context),
      );
      return;
    }

    // For seekers (no subscription needed), create profile directly
    _createProfile();
  }

  /// Actually creates the profile. Called directly for seekers, or after
  /// successful subscription payment for providers.
  void _createProfile() {
    final userLoc = context.read<LocationBloc>().state.location;
    final nameParts = nameTextController.text.trim().split(" ");
    final firstName = nameParts.isNotEmpty ? nameParts[0] : "";
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

    Profile profile = Profile(
      firstName: firstName,
      lastName: lastName,
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
      catalogServiceId: selectedCatalogServiceIds.isNotEmpty
          ? selectedCatalogServiceIds.first
          : catalogServiceId,
      catalogServiceIds: selectedCatalogServiceIds,
      catalogServiceNames: selectedCatalogServiceNames,
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
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) {
                    final profile = state.profile;
                    if (profile != null &&
                        Helpers.isProvider(profile.userType) &&
                        profile.isIdentityVerified != true) {
                      context.go("/pending-verification");
                    } else {
                      context.go("/home");
                    }
                  }
                });
              } else if (state is FailureCreateProfileState) {
                customAlert(context, AlertType.error, state.message);
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
          BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              if (state is SuccessGetSubscriptionPlansState) {
                setState(() => _allPlans = state.plans);
              }
              if (state is SuccessMakeSubscriptionState) {
                context.read<SubscriptionBloc>().add(
                  CheckUserSubscriptionEvent(),
                );
              }
              if (state is ValidUserSubscriptionState) {
                if (_pendingProfileSubmit) {
                  if (state.isValid) {
                    _pendingProfileSubmit = false;
                    _createProfile();
                  } else {
                    _pendingProfileSubmit = false;
                    customAlert(
                      context,
                      AlertType.error,
                      "We could not verify your active subscription. Please try again.",
                    );
                  }
                }
              }
              if (state is SubscriptionFailure && _pendingProfileSubmit) {
                _pendingProfileSubmit = false;
                customAlert(
                  context,
                  AlertType.error,
                  state.message ?? "Subscription failed. Please try again.",
                );
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            return BlocBuilder<CommonBloc, CommonState>(
              builder: (context, commonState) {
                return LoadingView(
                  isLoading:
                      (profileState is LoadingProfileState) ||
                      (commonState is CommonLoading),
                  child: GradientBackground(
                    child: SafeArea(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Top section: Step indicator
                            _buildHeader(),
                            // Main content: Page view
                            Expanded(
                              child: PageView(
                                controller: _pageController,
                                physics: const NeverScrollableScrollPhysics(),
                                onPageChanged: (index) {
                                  setState(() => _currentStep = index);
                                },
                                children: _buildStepPages(),
                              ),
                            ),
                            // Bottom navigation buttons
                            _buildNavigationButtons(),
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

  Widget _buildHeader() {
    final actualStep = _getActualStepIndex(_currentStep);
    final stepData = _stepInfo[actualStep];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step counter and progress
          Row(
            children: [
              Text(
                "Step ${_currentStep + 1} of $_effectiveTotalSteps",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: context.appColors.secondaryTextColor,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              if (_currentStep > 0)
                GestureDetector(
                  onTap: _previousStep,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: context.appColors.glassBorder),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.chevronLeft,
                      color: context.appColors.primaryTextColor,
                      size: 14.r,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Progress bar
          _buildProgressBar(),
          SizedBox(height: 24.h),

          // Step title
          Text(
            stepData['title']!.toUpperCase(),
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              color: context.appColors.primaryTextColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            stepData['subtitle']!,
            style: TextStyle(
              fontSize: 15.sp,
              color: context.appColors.secondaryTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentStep + 1) / _effectiveTotalSteps;

    return Container(
      height: 4.h,
      decoration: BoxDecoration(
        color: context.appColors.glassBorder,
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: constraints.maxWidth * progress,
                height: 4.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.appColors.primaryColor,
                      context.appColors.primaryColor.withAlpha(180),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.primaryColor.withAlpha(80),
                      blurRadius: 6.r,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildStepPages() {
    if (Helpers.isProvider(_userType)) {
      return [
        _buildStep1PersonalInfo(),
        _buildStep2LocationContact(),
        _buildStep3AccountSetup(),
        _buildStep4Subscription(),
      ];
    } else {
      return [_buildStep1PersonalInfo(), _buildStep2LocationContact()];
    }
  }

  // ─── STEP 1: PERSONAL INFO ────────────────────────────────────

  Widget _buildStep1PersonalInfo() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Profile Picture
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
                      radius: 55.r,
                      backgroundColor: Colors.white.withAlpha(15),
                      backgroundImage: (_profilePicture != null)
                          ? FileImage(File(_profilePicture!.path))
                          : const AssetImage(person) as ImageProvider,
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
                      border: Border.all(color: Colors.white, width: 2.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(60),
                          blurRadius: 12.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.camera,
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Form card
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(color: context.appColors.glassBorder),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SolidTextField(
                    controller: nameTextController,
                    hintText: "Enter full name",
                    label: "Full Name",
                    prefixIcon: FontAwesomeIcons.user,
                    validator: (val) {
                      if (val!.isEmpty) return "Name is required";
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
                    onValueChanged: (val) => setState(() => gender = val),
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
                      if (val!.isEmpty) return "Date of Birth is required";
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  CustomTextWidget(text: "Note: You must be 18 years before you can be accepted on the platform", color: Colors.red, fontSize: 12.sp,),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  // ─── STEP 2: LOCATION & CONTACT ──────────────────────────────

  Widget _buildStep2LocationContact() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: context.appColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration icon
            Center(
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: context.appColors.primaryColor.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: context.appColors.primaryColor,
                  size: 36.r,
                ),
              ),
            ),
            SizedBox(height: 28.h),

            Row(
              children: [
                Expanded(
                  child: SolidTextField(
                    controller: locController,
                    hintText: "Location address",
                    label: "Location",
                    onTap: () => _showLocationBottomSheet(context),
                    prefixIcon: FontAwesomeIcons.locationDot,
                    validator: (val) => null,
                  ),
                ),
                SizedBox(width: 12.w),
              ],
            ),
            SizedBox(height: 24.h),
            SolidTextField(
              controller: contactTextController,
              hintText: "023456789",
              label: "Phone Number",
              prefixIcon: FontAwesomeIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (val) => ValidationUtil.validatePhone(val),
            ),
            SizedBox(height: 24.h),

            // User Role selector
            _buildLabel("User Role"),
            SizedBox(height: 12.h),
            CustomSegmentedControl<String>(
              buttonLables: const [userTypeSeeker, userTypeProvider],
              buttonValues: const [userTypeSeeker, userTypeProvider],
              defaultSelected: _userType == userTypeProvider
                  ? userTypeProvider
                  : userTypeSeeker,
              onValueChanged: (val) {
                setState(() {
                  _userType = val;
                });
                context.read<ProfileBloc>().add(
                  SetUserTypeEvent(
                    userType: Helpers.isProvider(val) ? 'provider' : 'seeker',
                  ),
                );
              },
              width: 270.w,
              height: 52.h,
              radius: 18.r,
              selectedColor: context.appColors.primaryColor.withAlpha(50),
              textColor: context.appColors.primaryTextColor,
            ),

            if (!Helpers.isProvider(_userType)) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: context.appColors.primaryColor.withAlpha(10),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: context.appColors.primaryColor.withAlpha(30),
                  ),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.circleInfo,
                      color: context.appColors.primaryColor,
                      size: 18.r,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        "As a seeker, you can browse and request services from providers.",
                        style: TextStyle(
                          color: context.appColors.secondaryTextColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─── STEP 3: ACCOUNT SETUP (Provider Only) ───────────────────

  Widget _buildStep3AccountSetup() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(28.r),
          border: Border.all(color: context.appColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration icon
            Center(
              child: Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: context.appColors.primaryColor.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.briefcase,
                  color: context.appColors.primaryColor,
                  size: 36.r,
                ),
              ),
            ),
            SizedBox(height: 28.h),

            _buildLabel("Service Type"),
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () {
                showServiceSelector(
                  context: context,
                  services: _services,
                  isMultiSelect: true,
                  selectedServiceIds: selectedCatalogServiceIds,
                  maxAllowed: _getSelectedPlanMaxCatalogServices(),
                  onServicesSelected: (serviceIds, serviceNames) {
                    setState(() {
                      selectedCatalogServiceIds = serviceIds;
                      selectedCatalogServiceNames = serviceNames;
                      if (serviceNames.isNotEmpty) {
                        serviceType = serviceNames.join(", ");
                      } else {
                        serviceType = "";
                      }
                    });
                    context.read<ProfileBloc>().add(
                      ChooseOtherServiceEvent(others: false),
                    );
                  },
                  onServiceSelected: (serviceId, serviceName) {
                    setState(() {
                      serviceType = serviceName;
                      catalogServiceId = serviceId;
                      selectedCatalogServiceIds = [serviceId];
                      selectedCatalogServiceNames = [serviceName];
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
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: context.appColors.glassBorder),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.briefcase,
                      color: context.appColors.primaryColor.withAlpha(200),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            serviceType.isEmpty
                                ? "Select Your Profession"
                                : serviceType,
                            style: TextStyle(
                              color: serviceType.isEmpty
                                  ? context.appColors.secondaryTextColor
                                  : context.appColors.primaryTextColor,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (selectedCatalogServiceIds.isNotEmpty) ...[
                            SizedBox(height: 4.h),
                            Text(
                              _getSelectedPlanMaxCatalogServices() > 0
                                  ? 'Limit: ${selectedCatalogServiceIds.length}/${_getSelectedPlanMaxCatalogServices()} services'
                                  : 'Limit: Unlimited services (${selectedCatalogServiceIds.length} selected)',
                              style: TextStyle(
                                color:
                                    _getSelectedPlanMaxCatalogServices() > 0 &&
                                        selectedCatalogServiceIds.length >=
                                            _getSelectedPlanMaxCatalogServices()
                                    ? Colors.orange
                                    : context.appColors.secondaryTextColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    FaIcon(
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
              onValueChanged: (val) =>
                  setState(() => preferredPaymentMode = val),
              width: 270.w,
              height: 52.h,
              radius: 18.r,
              selectedColor: context.appColors.primaryColor.withAlpha(50),
              textColor: context.appColors.primaryTextColor,
            ),

            SizedBox(height: 24.h),

            // Info about upgrading subscription
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: context.appColors.primaryColor.withAlpha(10),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: context.appColors.primaryColor.withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.circleInfo,
                    color: context.appColors.primaryColor,
                    size: 18.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      "You can add more services by upgrading your subscription in the next step.",
                      style: TextStyle(
                        color: context.appColors.secondaryTextColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STEP 4: SUBSCRIPTION PLAN ───────────────────────────────

  Widget _buildStep4Subscription() {
    final plans =
        _allPlans.where((plan) => plan.interval == _selectedInterval).toList()
          ..sort(
            (a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0),
          );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Crown icon
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: context.appColors.primaryColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              FontAwesomeIcons.crown,
              color: context.appColors.primaryColor,
              size: 36.r,
            ),
          ),
          SizedBox(height: 16.h),

          Text(
            "Unlock premium features and grow your business",
            style: TextStyle(
              fontSize: 14.sp,
              color: context.appColors.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // Interval toggle
          _buildIntervalToggle(),
          SizedBox(height: 24.h),

          // Plan cards

          // Plan cards
          if (plans.isEmpty)
            _buildEmptyPlans()
          else
            ...plans.map(
              (plan) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildPlanCard(plan),
              ),
            ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildIntervalToggle() {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: context.appColors.primaryColor.withAlpha(15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.appColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton("Monthly", 'month'),
          _buildToggleButton("Yearly (Save 20%)", 'year'),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String interval) {
    bool isSelected = _selectedInterval == interval;
    return GestureDetector(
      onTap: () => setState(() => _selectedInterval = interval),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected
                ? Colors.white
                : context.appColors.secondaryTextColor,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlans() {
    return Container(
      padding: EdgeInsets.all(40.r),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.faceFrown,
            size: 40.r,
            color: context.appColors.secondaryTextColor,
          ),
          SizedBox(height: 16.h),
          Text(
            "No plans available for this interval",
            style: TextStyle(
              color: context.appColors.secondaryTextColor,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;

    FaIconData tierIcon;
    switch (plan.tier) {
      case 'PLATINUM':
        tierIcon = FontAwesomeIcons.wandMagicSparkles;
        break;
      case 'GOLD':
        tierIcon = FontAwesomeIcons.crown;
        break;
      case 'SILVER':
        tierIcon = FontAwesomeIcons.shield;
        break;
      default:
        tierIcon = FontAwesomeIcons.star;
    }

    String commissionText = "20% platform fee";
    String priorityText = "Standard visibility";
    if (plan.tier == 'SILVER') {
      commissionText = "15% platform fee";
      priorityText = "1.1x visibility boost";
    } else if (plan.tier == 'GOLD') {
      commissionText = "10% platform fee";
      priorityText = "1.2x visibility boost";
    } else if (plan.tier == 'PLATINUM') {
      commissionText = "5% platform fee";
      priorityText = "1.5x matching boost";
    }

    final maxServices = plan.maxCatalogServices ?? 1;
    final limitText = maxServices == 0
        ? "Unlimited catalog services"
        : "$maxServices catalog service${maxServices > 1 ? 's' : ''}";

    final features = plan.features ?? [];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanId = isSelected ? null : plan.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(22.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected
                ? context.appColors.primaryColor
                : context.appColors.glassBorder,
            width: isSelected ? 2.r : 1.r,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.appColors.primaryColor.withAlpha(30),
                    blurRadius: 20.r,
                    spreadRadius: -5.r,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: context.appColors.primaryColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    tierIcon,
                    color: context.appColors.primaryColor,
                    size: 22.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (plan.name ?? "Plan").toUpperCase(),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primaryTextColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "\$${plan.price?.toStringAsFixed(2) ?? '0.00'}",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w500,
                              color: context.appColors.primaryTextColor,
                            ),
                          ),
                          Text(
                            "/${plan.interval == 'year' ? 'YR' : 'MO'}",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: context.appColors.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28.r,
                  height: 28.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? context.appColors.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? context.appColors.primaryColor
                          : context.appColors.glassBorder,
                      width: 2.r,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: FaIcon(
                            FontAwesomeIcons.check,
                            color: Colors.white,
                            size: 14.r,
                          ),
                        )
                      : null,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Benefits row
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildBenefitChip(commissionText, FontAwesomeIcons.wallet),
                _buildBenefitChip(priorityText, FontAwesomeIcons.arrowTrendUp),
                _buildBenefitChip(limitText, FontAwesomeIcons.briefcase),
              ],
            ),

            if (features.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Divider(color: context.appColors.glassBorder, height: 1),
              SizedBox(height: 12.h),
              ...features.map(
                (feature) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.circleCheck,
                        size: 14.r,
                        color: context.appColors.secondaryTextColor,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          feature.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: context.appColors.secondaryTextColor,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitChip(String text, FaIconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: context.appColors.primaryColor.withAlpha(10),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: context.appColors.primaryColor.withAlpha(25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 12.r, color: context.appColors.secondaryTextColor),
          SizedBox(width: 6.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: context.appColors.primaryTextColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ─── NAVIGATION BUTTONS ──────────────────────────────────────

  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == _effectiveTotalSteps - 1;
    final isSubscriptionStep =
        Helpers.isProvider(_userType) && _currentStep == 3;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
      decoration: BoxDecoration(
        color: context.appColors.primaryBackground.withAlpha(200),
        border: Border(
          top: BorderSide(color: context.appColors.glassBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back button
            if (_currentStep > 0)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _previousStep,
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: context.appColors.cardBackground,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: context.appColors.glassBorder),
                    ),
                    child: Center(
                      child: Text(
                        "BACK",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: context.appColors.primaryTextColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) SizedBox(width: 12.w),

            // Next / Submit button
            if (!isSubscriptionStep)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _nextStep,
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: context.appColors.primaryColor,
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.primaryColor.withAlpha(80),
                          blurRadius: 16.r,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        isLastStep ? "CREATE PROFILE" : "CONTINUE",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Subscribe & Create button on subscription step
            if (isSubscriptionStep)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if (_selectedPlanId != null) {
                      _submitProfile();
                    } else {
                      customAlert(
                        context,
                        AlertType.warning,
                        "Select a plan or tap 'Skip for now'",
                      );
                    }
                  },
                  child: Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: _selectedPlanId != null
                          ? context.appColors.primaryColor
                          : context.appColors.primaryColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(18.r),
                      boxShadow: _selectedPlanId != null
                          ? [
                              BoxShadow(
                                color: context.appColors.primaryColor.withAlpha(
                                  80,
                                ),
                                blurRadius: 16.r,
                                offset: Offset(0, 6.h),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        "SUBSCRIBE & CREATE",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── HELPER WIDGETS ──────────────────────────────────────────

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

  // ─── BOTTOM SHEETS ───────────────────────────────────────────

  void _showImagePickerBottomSheet(BuildContext context) {
    final handleColor = context.appColors.glassBorder;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: context.appColors.glassBorder),
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
                context.pop();
              },
            ),
            SizedBox(height: 16.h),
            _buildSheetItem(
              icon: FontAwesomeIcons.camera,
              label: "Take a Photo",
              onTap: () {
                context.read<ProfileBloc>().add(SelectImageFromCameraEvent());
                context.pop();
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          border: Border.all(color: context.appColors.glassBorder),
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
                    context.read<LocationBloc>().add(
                      UpdateLocationEvent(location: userLocation),
                    );
                    locController.text = userLocation.address;
                    context.pop();
                  }
                } else {
                  if (mounted) {
                    context.pop();
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
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetItem({
    required FaIconData icon,
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
            FaIcon(icon, color: context.appColors.primaryColor, size: 26.r),
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
            FaIcon(
              FontAwesomeIcons.chevronRight,
              color: context.appColors.primaryColor,
              size: 16.r,
            ),
          ],
        ),
      ),
    );
  }
}
