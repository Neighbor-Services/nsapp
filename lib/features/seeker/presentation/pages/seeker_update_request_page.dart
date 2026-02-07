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
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/initialize/init.dart';

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
    final textColor = isDark ? Colors.white : const Color(0xFF1E1E2E);
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
                        constraints: const BoxConstraints(maxWidth: 550),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isLargeScreen ? 32 : 20,
                            vertical: 24,
                          ),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(context),
                                const SizedBox(height: 32),
                                SolidContainer(
                                  padding: const EdgeInsets.all(24),
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
                                        const SizedBox(height: 20),
                                        SolidTextField(
                                          controller: titleTextController,
                                          hintText:
                                              "Give your request a clear title",
                                          label: "Request Title",
                                          prefixIcon: Icons.title_rounded,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Title is required";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        _buildLabel("Location", isDark),
                                        _buildLocationRow(context),
                                        const SizedBox(height: 20),
                                        _buildLabel("Schedule", isDark),
                                        _buildScheduledTimePicker(context),
                                        const SizedBox(height: 20),
                                        SolidTextField(
                                          controller: descriptionTextController,
                                          hintText:
                                              "Describe your request in detail...",
                                          label: "Description",
                                          prefixIcon: Icons.description_rounded,
                                          isMultiLine: true,
                                          validator: (val) {
                                            if (val!.isEmpty) {
                                              return "Description is required";
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 28),
                                        _buildLabel("Update Image", isDark),
                                        if (request != null)
                                          _buildImagePicker(context, request),
                                        const SizedBox(height: 28),
                                        SolidButton(
                                          label: "Update Request",
                                          icon: Icons
                                              .check_circle_outline_rounded,
                                          onPressed: () =>
                                              _updateRequest(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? Colors.white12 : Colors.black.withAlpha(10);
    final iconColor = isDark ? Colors.white : Colors.black87;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subTitleColor = isDark ? Colors.white.withAlpha(180) : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () =>
                  context.read<SeekerBloc>().add(SeekerBackPressedEvent()),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: iconBg),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "Update Request",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 52),
          child: Text(
            "Refine your project details",
            style: TextStyle(fontSize: 15, color: subTitleColor),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? Colors.white12 : Colors.black.withAlpha(5);
    final borderColor = isDark ? Colors.white12 : Colors.black.withAlpha(5);
    final iconColor = isDark
        ? Colors.white.withAlpha(150)
        : Colors.black.withAlpha(150);
    final textColor = isDark ? Colors.white : Colors.black87;
    final hintColor = isDark ? Colors.white54 : Colors.black54;

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(Icons.category_rounded, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedServiceName.isEmpty
                    ? "Select a service"
                    : selectedServiceName,
                style: TextStyle(
                  color: selectedServiceName.isEmpty ? hintColor : textColor,
                  fontSize: 16,
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
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _showLocationPicker(context),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5C6BC0), Color(0xFF7E57C2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.my_location_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context, Request originalRequest) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? Colors.white12 : Colors.black.withAlpha(5);
    final borderColor = isDark ? Colors.white24 : Colors.black.withAlpha(10);
    final iconColor = isDark
        ? Colors.white.withAlpha(150)
        : Colors.black.withAlpha(150);
    final textColor = isDark ? Colors.white.withAlpha(150) : Colors.black54;
    final errorIconColor = isDark
        ? Colors.white.withAlpha(100)
        : Colors.black38;

    return GestureDetector(
      onTap: () => _showImagePicker(context),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, style: BorderStyle.solid),
        ),
        child: ImageSeekerState.picture != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(ImageSeekerState.picture!.path),
                      width: double.infinity,
                      height: 140,
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : (originalRequest.imageUrl != null &&
                  originalRequest.imageUrl!.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  originalRequest.imageUrl!,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image_rounded,
                        color: errorIconColor,
                        size: 40,
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
                    size: 40,
                    color: iconColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Update Image (Optional)",
                    style: TextStyle(color: textColor, fontSize: 14),
                  ),
                ],
              ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.black.withAlpha(5);
    final handleColor = isDark ? Colors.white24 : Colors.grey.withAlpha(50);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _buildPickerOption(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: "Gallery",
                    color: const Color(0xFF5C6BC0),
                    onTap: () {
                      Get.back();
                      context.read<SeekerBloc>().add(
                        SelectImageFromGalleryEvent(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPickerOption(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: "Camera",
                    color: const Color(0xFF7E57C2),
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
            const SizedBox(height: 24),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : Colors.black.withAlpha(5);
    final handleColor = isDark ? Colors.white24 : Colors.grey.withAlpha(50);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white.withAlpha(150) : Colors.black54;
    final arrowColor = isDark ? Colors.white24 : Colors.black26;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          border: Border(top: BorderSide(color: borderColor)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C6BC0).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
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
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: arrowColor,
                size: 16,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              onTap: () {
                Get.back();
                context.read<SharedBloc>().add(UseMapEvent(useMap: true));
                Helpers.getLocation();
                Get.toNamed("map-location");
              },
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appOrangeColor1.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.map_rounded, color: appOrangeColor1),
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
                style: TextStyle(color: subtitleColor, fontSize: 12),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                color: arrowColor,
                size: 16,
              ),
            ),
            const SizedBox(height: 24),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white.withAlpha(200) : Colors.black87,
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
