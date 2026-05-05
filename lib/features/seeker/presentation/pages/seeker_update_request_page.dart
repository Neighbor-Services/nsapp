import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/service.dart';
import 'package:nsapp/features/seeker/presentation/bloc/seeker_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import 'package:nsapp/features/shared/presentation/bloc/location/location_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/gradient_background_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_text_field_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
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
  String paymentMode = "IN_APP";

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _useMap = false;
  LatLng? _mapLocation;

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
          ? DateFormat("MMM dd, yyyy • h:mm a").format(selectedScheduledTime!)
          : "";
      paymentMode = request.paymentMode ?? "IN_APP";

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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildLabel("Request Title"),
                                          SizedBox(height: 12.h),
                                          SolidTextField(
                                            controller: titleTextController,
                                            hintText: "Update title",
                                            prefixIcon: FontAwesomeIcons.heading,
                                            validator: (val) => val!.isEmpty ? "Title is required" : null,
                                          ),
                                          SizedBox(height: 24.h),
                                          _buildLabel("Description"),
                                          SizedBox(height: 12.h),
                                          SolidTextField(
                                            controller: descriptionTextController,
                                            hintText: "Description",
                                          ),
                                          SizedBox(height: 24.h),
                                          _buildLabel("Service Category"),
                                          SizedBox(height: 12.h),
                                          _buildServicePicker(commonState),
                                          if (seekerState is OtherServiceSelectState && seekerState.others) ...[
                                            SizedBox(height: 24.h),
                                            SolidTextField(
                                              controller: categoryTextController,
                                              hintText: "Enter custom service name",
                                              label: "Custom Service",
                                              prefixIcon: FontAwesomeIcons.penNib,
                                              validator: (val) => val!.isEmpty ? "Service name is required" : null,
                                            ),
                                          ],
                                          SizedBox(height: 24.h),
                                          _buildLabel("Location"),
                                          SizedBox(height: 12.h),
                                          SolidTextField(
                                            controller: locController,
                                            hintText: "Where is the service needed?",
                                            prefixIcon: FontAwesomeIcons.locationDot,
                                            readOnly: true,
                                            onTap: () => _showLocationSheet(context),
                                            validator: (val) => val!.isEmpty ? "Location is required" : null,
                                          ),
                                          SizedBox(height: 24.h),
                                          _buildLabel("Schedule Time"),
                                          SizedBox(height: 12.h),
                                          SolidTextField(
                                            controller: scheduledTimeController,
                                            hintText: "When should it start?",
                                            prefixIcon: FontAwesomeIcons.calendarDay,
                                            readOnly: true,
                                            onTap: () => _selectDateTime(context),
                                            validator: (val) => val!.isEmpty ? "Time is required" : null,
                                          ),
                                          SizedBox(height: 24.h),
                                          _buildLabel("Payment Mode"),
                                          SizedBox(height: 12.h),
                                          _buildPaymentModeSelector(),
                                          SizedBox(height: 40.h),
                                          SolidButton(
                                            label: "UPDATE REQUEST",
                                            isPrimary: true,
                                            onPressed: () => _submitUpdate(context),
                                          ),
                                        ],
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
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: context.appColors.cardBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: context.appColors.glassBorder),
            ),
            child: Icon(FontAwesomeIcons.chevronLeft, size: 20.r),
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

  Widget _buildLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: context.appColors.secondaryTextColor,
        letterSpacing: 1.1,
      ),
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
          scheduledTimeController.text = DateFormat("MMM dd, yyyy • h:mm a").format(selectedScheduledTime!);
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
            paymentMode: paymentMode,
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

  Widget _buildPaymentModeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentOption(
            "In-App",
            "IN_APP",
            FontAwesomeIcons.creditCard,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildPaymentOption(
            "On-Site",
            "ON_SITE",
            FontAwesomeIcons.moneyBillWave,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String label, String value, IconData icon) {
    bool isSelected = paymentMode == value;
    return GestureDetector(
      onTap: () => setState(() => paymentMode = value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? context.appColors.primaryColor.withAlpha(40) : context.appColors.cardBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? context.appColors.primaryColor : context.appColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? context.appColors.primaryColor : context.appColors.hintTextColor,
              size: 24.r,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? context.appColors.primaryTextColor : context.appColors.hintTextColor,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
