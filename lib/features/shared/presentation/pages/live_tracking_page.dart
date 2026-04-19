import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/services/tracking_service.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

class LiveTrackingPage extends StatefulWidget {
  final String appointmentId;
  final String providerName;

  const LiveTrackingPage({
    super.key,
    required this.appointmentId,
    required this.providerName,
  });

  @override
  State<LiveTrackingPage> createState() => _LiveTrackingPageState();
}

class _LiveTrackingPageState extends State<LiveTrackingPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TrackingService _trackingService = TrackingService();
  LatLng? _providerLocation;
  double _heading = 0.0;

  @override
  void initState() {
    super.initState();
    _trackingService.startTracking(widget.appointmentId, false);
    _trackingService.locationStream.listen((data) {
      if (mounted) {
        setState(() {
          _providerLocation = LatLng(data['latitude'], data['longitude']);
          _heading = (data['heading'] ?? 0.0).toDouble();
        });
        _moveCamera();
      }
    });
  }

  Future<void> _moveCamera() async {
    if (_providerLocation != null) {
      final controller = await _controller.future;
      if (mounted) {
        controller.animateCamera(CameraUpdate.newLatLng(_providerLocation!));
      }
    }
  }

  @override
  void dispose() {
    _trackingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(locationData.latitude, locationData.longitude),
              zoom: 15,
            ),
            style: mapStyle,
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
            markers: {
              if (_providerLocation != null)
                Marker(
                  markerId: const MarkerId('provider'),
                  position: _providerLocation!,
                  rotation: _heading,
                  infoWindow: InfoWindow(title: widget.providerName),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueCyan,
                  ),
                ),
            },
          ),
          Positioned(
            top: 60.h,
            left: 20.w,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: context.appColors.cardBackground,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: context.appColors.glassBorder,
                    width: 1.5.w,
                  ),
                ),
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
                          color: context.appColors.infoColor.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          FontAwesomeIcons.motorcycle,
                          color: context.appColors.infoColor,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.providerName} IS ON THE WAY!"
                                  .toUpperCase(),
                              style: TextStyle(
                                color: context.appColors.primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "TRACKING LIVE LOCATION...",
                              style: TextStyle(
                                color: context.appColors.secondaryTextColor,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
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



