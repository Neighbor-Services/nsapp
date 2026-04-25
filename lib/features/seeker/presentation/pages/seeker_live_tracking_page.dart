import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/services/tracking_service.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';
import 'package:get/get.dart';

class SeekerLiveTrackingPage extends StatefulWidget {
  final String appointmentId;
  final LatLng jobLocation;

  const SeekerLiveTrackingPage({
    super.key,
    required this.appointmentId,
    required this.jobLocation,
  });

  @override
  State<SeekerLiveTrackingPage> createState() => _SeekerLiveTrackingPageState();
}

class _SeekerLiveTrackingPageState extends State<SeekerLiveTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final TrackingService _trackingService = TrackingService();
  LatLng? _providerLocation;
  double? _providerHeading;

  @override
  void initState() {
    super.initState();
    _trackingService.startTracking(widget.appointmentId, false); // isProvider = false
    
    _trackingService.locationStream.listen((data) {
      if (mounted) {
        final lat = data['latitude'];
        final lng = data['longitude'];
        final heading = data['heading'];

        if (lat != null && lng != null) {
          setState(() {
            _providerLocation = LatLng(lat.toDouble(), lng.toDouble());
            if (heading != null) _providerHeading = heading.toDouble();
          });
          _animateToProvider();
        }
      }
    });
  }

  Future<void> _animateToProvider() async {
    if (_providerLocation == null) return;
    try {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _providerLocation!,
            zoom: 16.5,
            bearing: _providerHeading ?? 0,
            tilt: 45,
          ),
        ),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _trackingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('job_location'),
        position: widget.jobLocation,
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    if (_providerLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('provider_location'),
          position: _providerLocation!,
          rotation: _providerHeading ?? 0.0,
          infoWindow: const InfoWindow(title: "Provider"),
          // Usually we'd use a custom car/scooter icon here
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.jobLocation,
              zoom: 14,
            ),
            style: mapStyle,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            markers: markers,
          ),
          Positioned(
            top: 60.h,
            left: 20.w,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: SolidContainer(
                padding: EdgeInsets.all(12.r),
                borderRadius: BorderRadius.circular(12.r),
                borderColor: context.appColors.glassBorder,
                borderWidth: 1.5.r,
                child: Icon(
                  FontAwesomeIcons.chevronLeft,
                  color: context.appColors.primaryTextColor,
                  size: 20.r,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40.h,
            left: 20.w,
            right: 20.w,
            child: SolidContainer(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: _providerLocation != null 
                              ? context.appColors.secondaryColor
                              : Colors.grey.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child:  Icon(
                          FontAwesomeIcons.locationArrow,
                          color: _providerLocation != null 
                              ? context.appColors.secondaryColor
                              : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 16.w),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _providerLocation != null 
                                  ? "PROVIDER IS EN ROUTE" 
                                  : "WAITING FOR SIGNAL...",
                              style: TextStyle(
                                color: context.appColors.primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              _providerLocation != null
                                  ? "LIVE TRACKING ACTIVE."
                                  : "PROVIDER HAS NOT STARTED SHARING LOCATION.",
                              style: TextStyle(
                                color: context.appColors.secondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
