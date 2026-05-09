import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/service.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart' hide OtherServiceSelectState, ChooseOtherServiceEvent, SelectImageFromCameraEvent, SelectImageFromGalleryEvent;
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import 'package:nsapp/features/shared/presentation/bloc/location/location_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/seeker/presentation/widgets/request_form_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/loading_view.dart';
import 'package:nsapp/core/core.dart';

class SeekerUpdateRequestPage extends StatefulWidget {
  const SeekerUpdateRequestPage({super.key});

  @override
  State<SeekerUpdateRequestPage> createState() => _SeekerUpdateRequestPageState();
}

class _SeekerUpdateRequestPageState extends State<SeekerUpdateRequestPage>
    with TickerProviderStateMixin {
  final titleTextController = TextEditingController();
  final descriptionTextController = TextEditingController();
  final priceController = TextEditingController();
  final categoryTextController = TextEditingController();
  final scheduledTimeController = TextEditingController();
  final locController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String serviceType = "";
  String selectedServiceName = "";

  DateTime? selectedScheduledTime;
  Request? _pendingRequest;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _useMap = false;
  LatLng? _mapLocation;
  bool _isProvider = false;

  @override
  void initState() {
    super.initState();
    context.read<CommonBloc>().add(GetServicesEvent());
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

    final currentState = context.read<SeekerBloc>().state;
    Request? request;
    if (currentState is SeekerRequestDetailState) {
      request = currentState.request.request;
    }

    if (request != null) {
      serviceType = request.service?.id ?? "";
      selectedServiceName = request.service?.name ?? "";
      titleTextController.text = request.title ?? "";
      descriptionTextController.text = request.description ?? "";
      priceController.text = request.price?.toString() ?? "";

      locController.text = request.address ?? "";
      selectedScheduledTime = request.scheduledTime;
      scheduledTimeController.text = selectedScheduledTime != null
          ? DateFormat("MMM dd, yyyy | h:mm a").format(selectedScheduledTime!)
          : "";

      if (request.latitude != null && request.longitude != null) {
        context.read<CommonBloc>().add(MapLocationEvent(
          location: LatLng(request.latitude!, request.longitude!),
        ));
      }
    }
    context.read<SeekerBloc>().add(ChangeLocationEvent(change: false));
  }

  @override
  void dispose() {
    titleTextController.dispose();
    descriptionTextController.dispose();
    priceController.dispose();
    categoryTextController.dispose();
    scheduledTimeController.dispose();
    locController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.read<ProfileBloc>().state;
    String userType = "seeker";
    if (profileState is SuccessGetProfileState) {
      userType = profileState.profile.userType ?? "seeker";
    } else if (profileState is SuccessGetProfileStreamState) {
      userType = profileState.profile.userType ?? "seeker";
    }
    _isProvider = Helpers.isProvider(userType);
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
                _handleUpdateRequest(state.id!);
              }
              if (state is UseMapState) {
                setState(() => _useMap = state.useMap);
              }
            },
          ),
          BlocListener<SeekerBloc, SeekerState>(
            listener: (context, state) {
              if (state is SuccessUpdateRequestState) {
                customAlert(context, AlertType.success, "Request updated successfully");
                context.read<CommonBloc>().add(GetServicesEvent());
              }
              if (state is FailureUpdateRequestState) {
                customAlert(
                  context,
                  AlertType.error, state.message ?? "Error updating request");
              }
            },
          ),
        ],
        child: BlocBuilder<SeekerBloc, SeekerState>(
          builder: (context, seekerState) {
            return BlocBuilder<CommonBloc, CommonState>(
              builder: (context, commonState) {
                return LoadingView(
                  isLoading: (seekerState is LoadingSeekerState) || (commonState is CommonLoading),
                  child: GradientBackground(
                    child: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 550.w),
                          child: RefreshIndicator(
                            onRefresh: () async {
                              context.read<ProfileBloc>().add(GetProfileStreamEvent());
                              context.read<ProfileBloc>().add(GetProfileEvent());
                              context.read<CommonBloc>().add(GetServicesEvent());
                              await Future.delayed(const Duration(seconds: 1));
                            },
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                              padding: EdgeInsets.symmetric(
                                horizontal: isLargeScreen ? 32.w : 20.w,
                                vertical: 24.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(context),
                                  SizedBox(height: 32.h),
                                  RequestFormWidget(
                                    formKey: _formKey,
                                    titleController: titleTextController,
                                    descriptionController: descriptionTextController,
                                    serviceTextController: categoryTextController,
                                    locController: locController,
                                    scheduledTimeController: scheduledTimeController,
                                    servicePicker: _buildServicePicker(commonState),
                                    isOtherServiceSelected: seekerState is OtherServiceSelectState && seekerState.others,
                                    onLocationTap: () => _showLocationSheet(context),
                                    onScheduleTap: () => _selectDateTime(context),
                                    imageSelector: _buildImageSelector(),
                                    submitButtonLabel: "UPDATE REQUEST",
                                    onSubmit: () => _submitUpdate(context),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Get.back();
            } else {
              if (_isProvider) {
                context.read<ProviderBloc>().add(
                    ChangeProviderTabEvent(tabIndex: 1));
              } else {
                context.read<SeekerBloc>().add(
                    ChangeSeekerTabEvent(tabIndex: 1));
              }
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
              size: 20.r,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Text(
          "UPDATE REQUEST",
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
    final services = state is SuccessGetServicesState ? state.services : <Service>[];
    return GestureDetector(
      onTap: () {
        showServiceSelector(
          context: context,
          services: services,
          selectedServiceId: serviceType,
          onServiceSelected: (id, name) {
            setState(() {
              serviceType = id;
              selectedServiceName = name;
            });
            context.read<SeekerBloc>().add(ChooseOtherServiceEvent(other: false));
          },
          onOthersSelected: () {
            context.read<SeekerBloc>().add(ChooseOtherServiceEvent(other: true));
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
            Icon(FontAwesomeIcons.briefcase, color: context.appColors.primaryColor, size: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                selectedServiceName.isEmpty ? "Select a service" : selectedServiceName,
                style: TextStyle(
                  color: selectedServiceName.isEmpty ? context.appColors.hintTextColor : context.appColors.primaryTextColor,
                ),
              ),
            ),
            Icon(FontAwesomeIcons.chevronDown, size: 16.r, color: context.appColors.hintTextColor),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedScheduledTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedScheduledTime ?? DateTime.now()),
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
          scheduledTimeController.text = DateFormat("MMM dd, yyyy | h:mm a").format(selectedScheduledTime!);
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

  void _submitUpdate(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final currentState = context.read<SeekerBloc>().state;
      if (currentState is SeekerRequestDetailState) {
        final originalRequest = currentState.request.request;
        final _ = context.read<LocationBloc>().state.location;
        if (originalRequest != null) {
          final request = Request(
            id: originalRequest.id,
            title: titleTextController.text.trim(),
            description: descriptionTextController.text.trim(),
            serviceID: serviceType,
            scheduledTime: selectedScheduledTime!,
            address: locController.text.trim(),
            latitude: (_useMap && _mapLocation != null) ? _mapLocation!.latitude : originalRequest.latitude,
            longitude: (_useMap && _mapLocation != null) ? _mapLocation!.longitude : originalRequest.longitude,
            price: double.tryParse(priceController.text) ?? originalRequest.price,
          );

        final seekerState = context.read<SeekerBloc>().state;
        if (seekerState is OtherServiceSelectState && seekerState.others) {
          _pendingRequest = request;
          context.read<CommonBloc>().add(
            AddServiceEvent(
              model: Service(
                name: categoryTextController.text.trim(),
                description: "Updated custom service",
              ),
            ),
          );
        } else {
          context.read<SeekerBloc>().add(UpdateRequestEvent(request: request));
        }
      }
      }
    }
  }

  void _handleUpdateRequest(String newServiceId) {
    if (_pendingRequest != null) {
      _pendingRequest!.serviceID = newServiceId;
      context.read<SeekerBloc>().add(UpdateRequestEvent(request: _pendingRequest!));
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
