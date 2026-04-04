import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/shared_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';

import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/core.dart';

class SeekerUpdateRequestPage extends StatefulWidget {
  const SeekerUpdateRequestPage({super.key});

  @override
  State<SeekerUpdateRequestPage> createState() =>
      _SeekerUpdateRequestPageState();
}

class _SeekerUpdateRequestPageState extends State<SeekerUpdateRequestPage>
    with TickerProviderStateMixin {
  final titleTextController = TextEditingController();
  final descriptionTextController = TextEditingController();
  final priceController = TextEditingController();
  final categoryTextController = TextEditingController();
  final scheduledTimeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String serviceType = "";
  String selectedServiceName = "";
  DateTime? selectedScheduledTime;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void dispose() {
    titleTextController.dispose();
    descriptionTextController.dispose();
    priceController.dispose();
    categoryTextController.dispose();
    scheduledTimeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<SharedBloc>().add(GetServicesEvent());
    context.read<SeekerBloc>().add(ChooseOtherServiceEvent(other: false));
    context.read<SeekerBloc>().add(ClearImageEvent());

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();

    final request = SeekerRequestDetailState.request.request;

    if (request != null) {
      serviceType = request.service?.id ?? "";
      selectedServiceName = request.service?.name ?? "";
      titleTextController.text = request.title ?? "";
      descriptionTextController.text = request.description ?? "";
      priceController.text = request.price?.toString() ?? "";

      locController.text = request.address ?? "";
      selectedScheduledTime = request.scheduledTime;
      scheduledTimeController.text = selectedScheduledTime != null
          ? DateFormat("MMM dd, yyyy • h:mm a").format(selectedScheduledTime!)
          : "";

      // Update location if it exists
      if (request.latitude != null && request.longitude != null) {
        MapLocationState.location = LatLng(
          request.latitude!,
          request.longitude!,
        );
        MapLocationState.address = request.address ?? "";
      }
    }

    context.read<SeekerBloc>().add(ChangeLocationEvent(change: false));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    // final textColor = context.appColors.primaryTextColor;
    final request = SeekerRequestDetailState.request.request;

    return Scaffold(
      body: BlocConsumer<SeekerBloc, SeekerState>(
        listener: (context, state) {
          if (state is SuccessUpdateRequestState) {
            customAlert(
              context,
              AlertType.success,
              "Request updated successfully",
            );
            context.read<SeekerBloc>().add(GetMyRequestEvent());
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                context.read<SeekerBloc>().add(SeekerBackPressedEvent());
              }
            });
          }
          if (state is FailureUpdateRequestState) {
            customAlert(context, AlertType.error, "Failed to update request");
          }
        },
        builder: (context, state) {
          return BlocBuilder<SharedBloc, SharedState>(
            builder: (context, sharedState) {
              if (UseMapState.useMap) {
                locController.text = MapLocationState.address;
              }
              return LoadingView(
                isLoading: state is LoadingSeekerState,
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
                                _buildHeader(context),
                                SizedBox(height: 32.h),
                                SolidContainer(
                                  padding: EdgeInsets.all(24.r),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel(
                                          "Service Categories",
                                          isDark,
                                        ),
                                        _buildServiceDropdown(),
                                        SizedBox(height: 20.h),
                                        SolidTextField(
                                          controller: titleTextController,
                                          hintText:
                                              "Give your request a clear title",
                                          label: "Request Title",
                                          allCapsLabel: true,
                                          prefixIcon: Icons.title_rounded,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Title is required";
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 20.h),
                                        _buildLabel("Location", isDark),
                                        _buildLocationRow(context),
                                        SizedBox(height: 20.h),
                                        _buildLabel("Schedule", isDark),
                                        _buildScheduledTimePicker(context),
                                        SizedBox(height: 20.h),
                                        SolidTextField(
                                          controller: descriptionTextController,
                                          hintText:
                                              "Describe your request in detail...",
                                          label: "Description",
                                          allCapsLabel: true,
                                          prefixIcon: Icons.description_rounded,
                                          isMultiLine: true,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Description is required";
                                            }
                                            return null;
                                          },
                                        ),

                                        SizedBox(height: 28.h),
                                        _buildLabel("Update Image", isDark),
                                        if (request != null)
                                          _buildImagePicker(context, request),
                                        SizedBox(height: 28.h),
                                        SolidButton(
                                          label: "UPDATE REQUEST",
                                          icon: Icons
                                              .check_circle_outline_rounded,
                                          onPressed: () =>
                                              _updateRequest(context),
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
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final iconBg = context.appColors.glassBorder;
    final iconColor = context.appColors.primaryTextColor;
    final titleColor = context.appColors.primaryTextColor;
    final subTitleColor = context.appColors.secondaryTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () =>
                  context.read<SeekerBloc>().add(SeekerBackPressedEvent()),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: context.appColors.glassBorder,
                    width: 1.5.r,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: iconColor,
                  size: 20.r,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              "UPDATE REQUEST",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: titleColor,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.only(left: 60.w),
          child: Text(
            "REFINE YOUR PROJECT DETAILS",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
              color: subTitleColor,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDropdown() {
    final containerColor = context.appColors.glassBorder;
    final borderColor = context.appColors.glassBorder;
    final iconColor = context.appColors.glassBorder;
    final textColor = context.appColors.primaryTextColor;
    final hintColor = context.appColors.secondaryTextColor;

    return GestureDetector(
      onTap: () {
        showServiceSelector(
          context: context,
          services: SuccessGetServicesState.services,
          selectedServiceId: serviceType,
          onServiceSelected: (id, name) {
            setState(() {
              serviceType = id;
              selectedServiceName = name;
            });
            context.read<SeekerBloc>().add(
              ChooseOtherServiceEvent(other: false),
            );
          },
          onOthersSelected: () {
            setState(() => selectedServiceName = "Others");
            context.read<SeekerBloc>().add(
              ChooseOtherServiceEvent(other: true),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: 1.5.r,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.category_rounded, color: iconColor, size: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                selectedServiceName.isEmpty
                    ? "Select a service"
                    : selectedServiceName.toUpperCase(),
                style: TextStyle(
                  color: selectedServiceName.isEmpty ? hintColor : textColor,
                  fontSize: 16.sp,
                  fontWeight: selectedServiceName.isEmpty ? FontWeight.normal : FontWeight.w900,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded, color: iconColor),
          ],
        ),
      ),
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
            prefixIcon: Icons.location_on_rounded,
            validator: (val) {
              if (val!.isEmpty) return "Location is required";
              return null;
            },
          ),
        ),
        SizedBox(width: 12.w),
        GestureDetector(
          onTap: () => _showLocationPicker(context),
          child: Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
              ),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 1.5.r,
              ),
            ),
            child: const Icon(Icons.my_location_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context, Request originalRequest) {
    final containerColor = context.appColors.glassBorder;
    final borderColor = context.appColors.glassBorder;
    final iconColor = context.appColors.glassBorder;
    final textColor = context.appColors.secondaryTextColor;
    final errorIconColor = context.appColors.glassBorder;

    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Container(
        width: double.infinity,
        height: 140.h,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: borderColor,
            width: 1.5.r,
          ),
        ),
        child: ImageSeekerState.picture != null
            ? Stack(
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
                          Icons.close,
                          color: Colors.white,
                          size: 18.r,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : (originalRequest.imageUrl != null &&
                  originalRequest.imageUrl!.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  originalRequest.imageUrl!,
                  width: double.infinity,
                  height: 140.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: errorIconColor,
                        size: 40.r,
                      ),
                    );
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 40.r,
                    color: iconColor,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Update Image (Optional)",
                    style: TextStyle(color: textColor, fontSize: 14.sp),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    final sheetColor = context.appColors.primaryBackground;
    final borderColor = context.appColors.glassBorder;
    final handleColor = context.appColors.glassBorder;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          border: Border.all(
            color: borderColor,
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
                color: handleColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: _buildPickerOption(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    color: Color(0xFF5C6BC0),
                    onTap: () {
                      Get.back();
                      context.read<SeekerBloc>().add(
                        SelectImageFromGalleryEvent(),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildPickerOption(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    color: Color(0xFF7E57C2),
                    onTap: () {
                      Get.back();
                      context.read<SeekerBloc>().add(
                        SelectImageFromCameraEvent(),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final textColor = context.appColors.primaryTextColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32.r),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    final sheetColor = context.appColors.primaryBackground;
    final borderColor = context.appColors.glassBorder;
    final handleColor = context.appColors.glassBorder;
    final titleColor = context.appColors.primaryTextColor;
    final subtitleColor = context.appColors.secondaryTextColor;
    final arrowColor = context.appColors.glassBorder;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: handleColor,
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
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Color(0xFF5C6BC0).withAlpha(30),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFF5C6BC0),
                ),
              ),
              title: Text(
                "Use Current Location",
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "Quick and accurate",
                style: TextStyle(color: subtitleColor, fontSize: 12.sp),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: arrowColor,
                size: 16.r,
              ),
            ),
            SizedBox(height: 12.h),
            ListTile(
              onTap: () {
                Get.back();
                context.read<SharedBloc>().add(UseMapEvent(useMap: true));
                Helpers.getLocation();
                Get.toNamed("map-location");
              },
              leading: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: context.appColors.secondaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.map_rounded, color: context.appColors.secondaryColor),
              ),
              title: Text(
                "Select on Map",
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "Pin your exact spot",
                style: TextStyle(color: subtitleColor, fontSize: 12.sp),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: arrowColor,
                size: 16.r,
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledTimePicker(BuildContext context) {
    return SolidTextField(
      controller: scheduledTimeController,
      hintText: "When do you need this?",
      label: "Schedule",
      prefixIcon: Icons.calendar_today_rounded,
      readOnly: true,
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedScheduledTime ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(
              selectedScheduledTime ?? DateTime.now(),
            ),
          );
          if (pickedTime != null) {
            setState(() {
              selectedScheduledTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              scheduledTimeController.text = DateFormat(
                "MMM dd, yyyy • h:mm a",
              ).format(selectedScheduledTime!);
            });
          }
        }
      },
      validator: (val) {
        if (val!.isEmpty) {
          return "Schedule is required";
        }
        return null;
      },
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          color: context.appColors.secondaryTextColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _updateRequest(BuildContext context) {
    if (!_formKey.currentState!.validate() || serviceType.isEmpty) {
      customAlert(context, AlertType.error, "Please fill all required fields");
      return;
    }

    final originalRequest = SeekerRequestDetailState.request.request;
    if (originalRequest == null) return;

    final updatedRequest = Request(
      id: originalRequest.id,
      title: titleTextController.text,
      description: descriptionTextController.text,
      price: double.tryParse(priceController.text) ?? 10.0,
      service: Service(id: serviceType, name: selectedServiceName),
      serviceID: serviceType,
      scheduledTime: selectedScheduledTime,
      latitude: UseMapState.useMap
          ? MapLocationState.location.latitude
          : locationData.latitude,
      longitude: UseMapState.useMap
          ? MapLocationState.location.longitude
          : locationData.longitude,
      address: locController.text,
      status: originalRequest.status,
      done: originalRequest.done,
      version: originalRequest.version,
      withImage:
          ImageSeekerState.picture != null ||
          (originalRequest.withImage ?? false),
    );

    context.read<SeekerBloc>().add(UpdateRequestEvent(request: updatedRequest));
  }
}
