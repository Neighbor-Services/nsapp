import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart'
    hide
        ChooseOtherServiceEvent,
        OtherServiceSelectState,
        SelectImageFromCameraEvent,
        SelectImageFromGalleryEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/features/seeker/presentation/widgets/request_form_widget.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import 'package:nsapp/features/shared/presentation/bloc/location/location_bloc.dart';
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
  TextEditingController locController = TextEditingController();
  GlobalKey<FormState> key = GlobalKey<FormState>();
  String serviceType = "";
  String? selectedService;
  DateTime? selectedScheduledTime;
  Request? _pendingRequest;

  late AnimationController _fadeController;
  bool _useMap = false;
  LatLng? _mapLocation;

  void clear() {
    titleTextController.text = "";
    descriptionTextController.text = "";
  }

  @override
  void initState() {
    super.initState();
    context.read<CommonBloc>().add(GetServicesEvent());
    context.read<SeekerBloc>().add(ChooseOtherServiceEvent(other: false));
    context.read<SeekerBloc>().add(ClearImageEvent());

    final commonState = context.read<CommonBloc>().state;
    if (commonState is MapLocationState) {
      locController.text = commonState.address;
    }

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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
    locController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<CommonBloc, CommonState>(
            listener: (context, state) {
              if (state is MapLocationState) {
                setState(() {
                  _mapLocation = state.location;
                  locController.text = state.address;
                });
              }
              if (state is SuccessAddServicesState) {
                if (_pendingRequest != null) {
                  _pendingRequest!.serviceID = state.id ?? serviceType;
                  context.read<SeekerBloc>().add(
                    CreateRequestEvent(request: _pendingRequest!),
                  );
                  _pendingRequest = null;
                }
              }
              if (state is UseMapState) {
                setState(() => _useMap = state.useMap);
              }
            },
          ),
          BlocListener<SeekerBloc, SeekerState>(
            listener: (context, state) {
              if (state is SuccessCreateRequestState) {
                clear();
                customAlert(
                  context,
                  AlertType.success,
                  "Request successfully added",
                );
                Future.delayed(const Duration(seconds: 3), () {
                  context.read<SeekerBloc>().add(GetMyRequestEvent());
                  Get.offAllNamed("/home");
                });
              }
              if (state is FailureCreateRequestState) {
                customAlert(
                  context,
                  AlertType.error,
                  state.message ?? "Failed to create request",
                );
              }
            },
          ),
        ],
        child: BlocBuilder<SeekerBloc, SeekerState>(
          builder: (context, seekerState) {
            return BlocBuilder<CommonBloc, CommonState>(
              builder: (context, commonState) {
                return LoadingView(
                  isLoading:
                      (seekerState is LoadingSeekerState) ||
                      (commonState is CommonLoading),
                  child: GradientBackground(
                    child: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 550.w),
                          child: RefreshIndicator(
                            onRefresh: () async {
                              context.read<ProfileBloc>().add(
                                GetProfileStreamEvent(),
                              );
                              context.read<ProfileBloc>().add(
                                GetProfileEvent(),
                              );
                              context.read<CommonBloc>().add(
                                GetServicesEvent(),
                              );
                              await Future.delayed(const Duration(seconds: 1));
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isLargeScreen ? 32.w : 20.w,
                                vertical: 24.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(),
                                  SizedBox(height: 32.h),
                                  RequestFormWidget(
                                    formKey: key,
                                    titleController: titleTextController,
                                    descriptionController:
                                        descriptionTextController,
                                    serviceTextController:
                                        serviceTextController,
                                    locController: locController,
                                    scheduledTimeController:
                                        scheduledTimeController,
                                    servicePicker: _buildServicePicker(
                                      commonState,
                                    ),
                                    isOtherServiceSelected:
                                        context.watch<SeekerBloc>().state
                                            is OtherServiceSelectState &&
                                        (context.watch<SeekerBloc>().state
                                                as OtherServiceSelectState)
                                            .others,
                                    onLocationTap: () =>
                                        _showLocationSheet(context),
                                    onScheduleTap: () =>
                                        _selectDateTime(context),
                                    imageSelector: _buildImageSelector(),
                                    submitButtonLabel: "CREATE REQUEST",
                                    onSubmit: () =>
                                        _handleCreateRequest(context),
                                  ),
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
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              
                context.read<SeekerBloc>().add(
                  ChangeSeekerTabEvent(tabIndex: 1),
                );
              
            }
          },
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
              size: 16.r,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          "NEW REQUEST",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildServicePicker(CommonState state) {
    final services = state is SuccessGetServicesState
        ? state.services
        : <Service>[];
    return GestureDetector(
      onTap: () {
        showServiceSelector(
          context: context,
          services: services,
          selectedServiceId: serviceType,
          onServiceSelected: (id, name) {
            setState(() {
              serviceType = id;
              selectedService = name;
            });
            context.read<SeekerBloc>().add(
              ChooseOtherServiceEvent(other: false),
            );
          },
          onOthersSelected: () {
            context.read<SeekerBloc>().add(
              ChooseOtherServiceEvent(other: true),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: context.appColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.briefcase,
              color: context.appColors.primaryColor,
              size: 20.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                selectedService ?? "Select a service",
                style: TextStyle(
                  color: selectedService == null
                      ? context.appColors.hintTextColor
                      : context.appColors.primaryTextColor,
                ),
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronDown,
              size: 16.r,
              color: context.appColors.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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
            'yyyy-MM-dd HH:mm',
          ).format(selectedScheduledTime!);
        });
      }
    }
  }

  void _showLocationSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FontAwesomeIcons.locationCrosshairs),
              title: const Text("Use Current Location"),
              onTap: () async {
                context.read<CommonBloc>().add(UseMapEvent(useMap: false));
                final loc = await Helpers.getLocation();
                if (loc != null) {
                  setState(() {
                    locController.text = loc.address;
                  });
                }
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.map),
              title: const Text("Pick from Map"),
              onTap: () {
                context.read<CommonBloc>().add(UseMapEvent(useMap: true));
                Get.back();
                Get.toNamed("map-location");
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreateRequest(BuildContext context) {
    if (key.currentState!.validate()) {
      final userLoc = context.read<LocationBloc>().state.location;
      final request = Request(
        title: titleTextController.text.trim(),
        description: descriptionTextController.text.trim(),
        serviceID: serviceType,
        scheduledTime: selectedScheduledTime!,
        address: locController.text.trim(),
        latitude: (_useMap && _mapLocation != null)
            ? _mapLocation!.latitude
            : userLoc.position.latitude,
        longitude: (_useMap && _mapLocation != null)
            ? _mapLocation!.longitude
            : userLoc.position.longitude,
        targetProviderId: widget.targetProviderId,
        withImage: context.read<SeekerBloc>().selectedPicture != null,
      );

      final seekerState = context.read<SeekerBloc>().state;
      if (seekerState is OtherServiceSelectState && seekerState.others) {
        _pendingRequest = request;
        context.read<CommonBloc>().add(
          AddServiceEvent(
            model: Service(
              name: serviceTextController.text.trim(),
              description: "Custom service for request: ${request.title}",
            ),
          ),
        );
      } else {
        context.read<SeekerBloc>().add(CreateRequestEvent(request: request));
      }
    }
  }

  // ignore: unused_element
  void _createRequest(String id) {
    if (_pendingRequest != null) {
      _pendingRequest!.serviceID = id;
      context.read<SeekerBloc>().add(
        CreateRequestEvent(request: _pendingRequest!),
      );
      _pendingRequest = null;
    }
  }

  Widget _buildImageSelector() {
    return BlocBuilder<SeekerBloc, SeekerState>(
      buildWhen: (previous, current) => current is ImageSeekerState,
      builder: (context, state) {
        final image = context.read<SeekerBloc>().selectedPicture;
        return GestureDetector(
          onTap: () => _showImageSourceSheet(context),
          child: Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: context.appColors.glassBorder,
                style: image == null ? BorderStyle.solid : BorderStyle.none,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.file(File(image.path), fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.image,
                        color: context.appColors.primaryColor,
                        size: 32.r,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Tap to select image",
                        style: TextStyle(
                          color: context.appColors.secondaryTextColor,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: context.appColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FontAwesomeIcons.camera),
              title: const Text("Camera"),
              onTap: () {
                context.read<SeekerBloc>().add(SelectImageFromCameraEvent());
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.images),
              title: const Text("Gallery"),
              onTap: () {
                context.read<SeekerBloc>().add(SelectImageFromGalleryEvent());
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
