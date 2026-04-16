import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/services/tracking_service.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_button_widget.dart';

class ProviderOnTheWayPage extends StatefulWidget {
  final String appointmentId;
  final LatLng destination;

  const ProviderOnTheWayPage({
    super.key,
    required this.appointmentId,
    required this.destination,
  });

  @override
  State<ProviderOnTheWayPage> createState() => _ProviderOnTheWayPageState();
}

class _ProviderOnTheWayPageState extends State<ProviderOnTheWayPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TrackingService _trackingService = TrackingService();

  @override
  void initState() {
    super.initState();
    _trackingService.startTracking(widget.appointmentId, true);
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
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId('destination'),
                position: widget.destination,
                infoWindow: const InfoWindow(title: "Seeker's Location"),
              ),
            },
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
                          color: context.appColors.successColor.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child:  Icon(
                          FontAwesomeIcons.compass,
                          color: context.appColors.successColor,
                        ),
                      ),
                      SizedBox(width: 16.w),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "YOU ARE ON THE WAY",
                              style: TextStyle(
                                color: context.appColors.primaryTextColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 16.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "YOUR LOCATION IS SHARED WITH THE SEEKER.",
                              style: TextStyle(
                                color: context.appColors.secondaryTextColor.withAlpha(150),
                                fontWeight: FontWeight.w900,
                                fontSize: 9.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  SolidButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: "I HAVE ARRIVED",
                    allCaps: true,
                    isPrimary: true,
                    height: 50.h,
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

