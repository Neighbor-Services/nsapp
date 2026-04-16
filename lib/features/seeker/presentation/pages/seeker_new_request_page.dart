import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/seeker/presentation/pages/seeker_request_page.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import '../../../shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/core/core.dart';

class SeekerNewRequestPage extends StatefulWidget {
  final String? targetProviderId;
  final String? initialServiceId;
  final String? initialServiceName;

  const SeekerNewRequestPage({
    super.key,
    this.targetProviderId,
    this.initialServiceId,
    this.initialServiceName,
  });

  @override
  State<SeekerNewRequestPage> createState() => _SeekerNewRequestPageState();
}

class _SeekerNewRequestPageState extends State<SeekerNewRequestPage>
    with TickerProviderStateMixin {
  TextEditingController titleTextController = TextEditingController();
  TextEditingController descriptionTextController = TextEditingController();
  TextEditingController serviceTextController = TextEditingController();
  TextEditingController scheduledTimeController = TextEditingController();
  GlobalKey<FormState> key = GlobalKey<FormState>();
  String serviceType = "";
  String? selectedService;
  DateTime? selectedScheduledTime;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  void clear() {
    titleTextController.text = "";
    descriptionTextController.text = "";
  }

  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetServicesEvent());
    context.read<SeekerBloc>().add(ChooseOtherServiceEvent(other: false));
    if (UseMapState.useMap) locController.text = MapLocationState.address;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    if (widget.initialServiceId != null) {
      serviceType = widget.initialServiceId!;
      selectedService = widget.initialServiceName;
    }
  }

  @override
  void dispose() {
    titleTextController.dispose();
    descriptionTextController.dispose();
    serviceTextController.dispose();
    scheduledTimeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: BlocConsumer<SeekerBloc, SeekerState>(
        listener: (context, state) {
          if (state is SuccessCreateRequestState) {
            clear();
            customAlert(
              context,
              AlertType.success,
              "Request successfully added",
            );
            Future.delayed(const Duration(seconds: 3), () {
              context.read<SeekerBloc>().add(ClearImageEvent());
              context.read<SeekerBloc>().add(
                NavigateSeekerEvent(
                  page: NavigatorSeekerState.page,
                  widget: const SeekerRequestPage(),
                ),
              );
            });
          }
          if (state is FailureCreateRequestState) {
            customAlert(context, AlertType.error, "Request failed to add");
          }
          if (state is MapLocationState) {
            locController.text = MapLocationState.address;
          }
        },
        builder: (context, state) {
          if (UseMapState.useMap) locController.text = MapLocationState.address;
          return LoadingView(
            isLoading: (state is LoadingSeekerState),
            child: GradientBackground(
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 550.w),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isLargeScreen ? 32.w : 20.w,
                        vertical: 24.h,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            SizedBox(height: 32.h),
                            SolidContainer(
                              padding: EdgeInsets.all(24.r),
                              child: Form(
                                key: key,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildServiceDropdown(),
                                    if (OtherServiceSelectState.others) ...[
                                      SizedBox(height: 20.h),
                                      SolidTextField(
                                        controller: serviceTextController,
                                        hintText: "Enter service name",
                                        label: "Specify Service",
                                        allCapsLabel: true,
                                        prefixIcon: FontAwesomeIcons.list,
                                        validator: (val) => val!.isEmpty
                                            ? "Service is required"
                                            : (containSpecial(val)
                                                  ? "Special characters not allowed"
                                                  : null),
                                      ),
                                    ],
                                    SizedBox(height: 20.h),
                                    SolidTextField(
                                      controller: titleTextController,
                                      hintText: "What do you need help with?",
                                      label: "Request Title",
                                      prefixIcon: FontAwesomeIcons.heading,
                                      validator: (val) => val!.isEmpty
                                          ? "Title is required"
                                          : (containSpecial(val)
                                                ? "Special characters not allowed"
                                                : null),
                                    ),
                                    SizedBox(height: 20.h),
                                    _buildLocationRow(context),
                                    SizedBox(height: 20.h),
                                    _buildScheduledTimePicker(context),
                                    SizedBox(height: 20.h),
                                    SolidTextField(
                                      controller: descriptionTextController,
                                      hintText:
                                          "Describe your request in detail...",
                                      label: "Description",
                                      prefixIcon: FontAwesomeIcons.fileLines,
                                      isMultiLine: true,
                                      validator: (val) => val!.isEmpty
                                          ? "Description is required"
                                          : null,
                                    ),
                                    SizedBox(height: 24.h),
                                    _buildImagePicker(context),
                                    SizedBox(height: 28.h),
                                    SolidButton(
                                      label: "CREATE REQUEST",
                                      icon: FontAwesomeIcons.paperPlane,
                                      onPressed: () => _submitRequest(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 40.h),
                          ],
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "NEW REQUEST",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: context.appColors.primaryTextColor,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "TELL US WHAT SERVICE YOU NEED",
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            color: context.appColors.secondaryTextColor,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Service Type",
          style: TextStyle(
            color: context.appColors.hintTextColor,
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () {
            showServiceSelector(
              context: context,
              services: SuccessGetServicesState.services,
              selectedServiceId: serviceType,
              onServiceSelected: (serviceId, serviceName) {
                setState(() {
                  selectedService = serviceName;
                  serviceType = serviceId;
                });
                context.read<SeekerBloc>().add(
                  ChooseOtherServiceEvent(other: false),
                );
              },
              onOthersSelected: () {
                setState(() => selectedService = "Others");
                context.read<SeekerBloc>().add(
                  ChooseOtherServiceEvent(other: true),
                );
              },
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: context.appColors.surfaceBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: context.appColors.glassBorder,
                width: 1.5.r,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.list,
                  color: context.appColors.glassBorder,
                  size: 20.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    selectedService ?? "Select a service",
                    style: TextStyle(
                      color: selectedService == null
                          ? context.appColors.secondaryTextColor
                          : context.appColors.primaryTextColor,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Icon(
                  FontAwesomeIcons.chevronDown,
                  color: context.appColors.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: SolidTextField(
            controller: locController,
            hintText: "Set your location",
            label: "Location",
            allCapsLabel: true,
            prefixIcon: FontAwesomeIcons.locationDot,
            validator: (val) => val!.isEmpty ? "Location is required" : null,
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => _showLocationPicker(context),
          child: Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: context.appColors.primaryColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: FaIcon(FontAwesomeIcons.locationCrosshairs, color: context.appColors.cardBackground),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduledTimePicker(BuildContext context) {
    return SolidTextField(
      controller: scheduledTimeController,
      hintText: "When do you need this?",
      label: "Schedule",
      allCapsLabel: true,
      prefixIcon: FontAwesomeIcons.calendar,
      readOnly: true,
      onTap: () async {
        DateTime? date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: context.appColors.primaryColor,
                primary: context.appColors.primaryColor,
                onPrimary: context.appColors.cardBackground,
                surface: context.appColors.primaryBackground,
                brightness: Theme.of(context).brightness,
              ),
            ),
            child: child!,
          ),
        );
        if (date != null) {
          TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              selectedScheduledTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              scheduledTimeController.text = DateFormat(
                "MMM dd, yyyy â€¢ h:mm a",
              ).format(selectedScheduledTime!);
            });
          }
        }
      },
      validator: (val) => val!.isEmpty ? "Schedule is required" : null,
    );
  }

  void _showLocationPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5.r,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.appColors.glassBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            ListTile(
              onTap: () async {
                context.read<SharedBloc>().add(UseMapEvent(useMap: false));
                final success = await Helpers.getLocation();
                if (success) {
                  locController.text = myAddress;
                  Get.back();
                } else {
                  Get.back();
                  customAlert(
                    context,
                    AlertType.error,
                    "Unable to get location. Please check location permissions and services.",
                  );
                }
              },
              leading: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: context.appColors.infoColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  FontAwesomeIcons.locationDot,
                  color: context.appColors.primaryColor,
                ),
              ),
              title: Text(
                "Use Current Location",
                style: TextStyle(color: context.appColors.primaryTextColor),
              ),
              subtitle: Text(
                "Auto-detect your location",
                style: TextStyle(
                  color: context.appColors.hintTextColor,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              onTap: () {
                Get.back();
                context.read<SharedBloc>().add(UseMapEvent(useMap: true));
                Helpers.getLocation();
                Get.toNamed("map-location");
              },
              leading: Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: context.appColors.successColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: FaIcon(FontAwesomeIcons.map, color: context.appColors.successColor),
              ),
              title: Text(
                "Choose From Map",
                style: TextStyle(color: context.appColors.primaryTextColor),
              ),
              subtitle: Text(
                "Pick a specific location",
                style: TextStyle(
                  color: context.appColors.hintTextColor,
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Container(
        width: double.infinity,
        height: 140.h,
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5.r,
          ),
        ),
        child: ImageSeekerState.picture == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.image,
                    size: 40.r,
                    color: context.appColors.hintTextColor,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Add Image (Optional)",
                    style: TextStyle(
                      color: context.appColors.hintTextColor,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.file(
                      File(ImageSeekerState.picture!.path),
                      width: double.infinity,
                      height: 140.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () =>
                          context.read<SeekerBloc>().add(ClearImageEvent()),
                      child: Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: context.appColors.errorColor.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FontAwesomeIcons.xmark,
                          color: context.appColors.primaryColor,
                          size: 18.r,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5.r,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            ListTile(
              onTap: () =>
                  context.read<SeekerBloc>().add(SelectImageFromGalleryEvent()),
              leading: Icon(
                FontAwesomeIcons.images,
                color: context.appColors.primaryColor,
              ),
              title: Text(
                "Choose from Gallery",
                style: TextStyle(color: context.appColors.primaryTextColor),
              ),
            ),
            ListTile(
              onTap: () =>
                  context.read<SeekerBloc>().add(SelectImageFromCameraEvent()),
              leading: FaIcon(FontAwesomeIcons.camera, color: context.appColors.primaryColor),
              title: Text(
                "Take a Photo",
                style: TextStyle(color: context.appColors.primaryTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRequest(BuildContext context) {
    Request? request = Request(
      title: titleTextController.text.trim(),
      description: descriptionTextController.text.trim(),
      approved: false,
      approvedUser: "",
      done: false,
      address: locController.text.trim(),
      latitude: UseMapState.useMap
          ? MapLocationState.location.latitude
          : locationData.latitude,
      longitude: UseMapState.useMap
          ? MapLocationState.location.longitude
          : locationData.longitude,
      withImage: ImageSeekerState.picture != null,
      targetProviderId: widget.targetProviderId,
      scheduledTime: selectedScheduledTime,
    );

    if (key.currentState!.validate()) {
      if (OtherServiceSelectState.others) {
        context.read<SeekerBloc>().add(SeekerReloadEvent());
        context.read<SharedBloc>().add(
          AddServiceEvent(
            model: Service(
              description: "User specified custom service",
              name: serviceTextController.text.trim(),
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 4), () {
          request.serviceID = SuccessAddServicesState.id ?? serviceType;
          context.read<SeekerBloc>().add(CreateRequestEvent(request: request));
        });
      } else {
        request.serviceID = serviceType;
        context.read<SeekerBloc>().add(CreateRequestEvent(request: request));
      }
    }
  }
}


