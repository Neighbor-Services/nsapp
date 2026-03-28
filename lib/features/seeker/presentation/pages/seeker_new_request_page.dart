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
                    constraints: BoxConstraints(maxWidth: 550),
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
                            _buildHeader(),
                            const SizedBox(height: 32),
                            SolidContainer(
                              padding: EdgeInsets.all(24),
                              child: Form(
                                key: key,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildServiceDropdown(),
                                    if (OtherServiceSelectState.others) ...[
                                      const SizedBox(height: 20),
                                      SolidTextField(
                                        controller: serviceTextController,
                                        hintText: "Enter service name",
                                        label: "Specify Service",
                                        allCapsLabel: true,
                                        prefixIcon: Icons.category_rounded,
                                        validator: (val) => val!.isEmpty
                                            ? "Service is required"
                                            : (containSpecial(val)
                                                  ? "Special characters not allowed"
                                                  : null),
                                      ),
                                    ],
                                    const SizedBox(height: 20),
                                    SolidTextField(
                                      controller: titleTextController,
                                      hintText: "What do you need help with?",
                                      label: "Request Title",
                                      prefixIcon: Icons.title_rounded,
                                      validator: (val) => val!.isEmpty
                                          ? "Title is required"
                                          : (containSpecial(val)
                                                ? "Special characters not allowed"
                                                : null),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildLocationRow(context),
                                    const SizedBox(height: 20),
                                    _buildScheduledTimePicker(context),
                                    const SizedBox(height: 20),
                                    SolidTextField(
                                      controller: descriptionTextController,
                                      hintText:
                                          "Describe your request in detail...",
                                      label: "Description",
                                      prefixIcon: Icons.description_rounded,
                                      isMultiLine: true,
                                      validator: (val) => val!.isEmpty
                                          ? "Description is required"
                                          : null,
                                    ),
                                    const SizedBox(height: 24),
                                    _buildImagePicker(context),
                                    const SizedBox(height: 28),
                                    SolidButton(
                                      label: "CREATE REQUEST",
                                      icon: Icons.send_rounded,
                                      onPressed: () => _submitRequest(context),
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
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: context.appColors.primaryTextColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "TELL US WHAT SERVICE YOU NEED",
          style: TextStyle(
            fontSize: 10,
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
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: context.appColors.surfaceBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.appColors.glassBorder,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.category_rounded,
                  color: context.appColors.glassBorder,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedService ?? "Select a service",
                    style: TextStyle(
                      color: selectedService == null
                          ? context.appColors.secondaryTextColor
                          : context.appColors.primaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down_rounded,
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
            prefixIcon: Icons.location_on_rounded,
            validator: (val) => val!.isEmpty ? "Location is required" : null,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _showLocationPicker(context),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.appColors.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.my_location_rounded, color: context.appColors.cardBackground),
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
      prefixIcon: Icons.calendar_today_rounded,
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
                "MMM dd, yyyy • h:mm a",
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.glassBorder,
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
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.appColors.infoColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_rounded,
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
            const SizedBox(height: 8),
            ListTile(
              onTap: () {
                Get.back();
                context.read<SharedBloc>().add(UseMapEvent(useMap: true));
                Helpers.getLocation();
                Get.toNamed("map-location");
              },
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.appColors.successColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.map_rounded, color: context.appColors.successColor),
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
            const SizedBox(height: 16),
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
        height: 140,
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: ImageSeekerState.picture == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 40,
                    color: context.appColors.hintTextColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add Image (Optional)",
                    style: TextStyle(
                      color: context.appColors.hintTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              )
            : Stack(
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
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.appColors.errorColor.withAlpha(200),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: context.appColors.primaryColor,
                          size: 18,
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.appColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: context.appColors.glassBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.cardBackground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              onTap: () =>
                  context.read<SeekerBloc>().add(SelectImageFromGalleryEvent()),
              leading: Icon(
                Icons.photo_library_rounded,
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
              leading: Icon(Icons.camera_alt_rounded, color: context.appColors.primaryColor),
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
