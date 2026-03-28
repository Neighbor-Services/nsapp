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
            top: 60,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: SolidContainer(
                padding: EdgeInsets.all(12),
                borderRadius: BorderRadius.circular(12),
                borderColor: context.appColors.glassBorder,
                borderWidth: 1.5,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: context.appColors.primaryTextColor,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SolidContainer(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.appColors.successColor.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child:  Icon(
                          Icons.navigation_rounded,
                          color: context.appColors.successColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                       Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "YOU ARE ON THE WAY",
                              style: TextStyle(
                                color: context.appColors.primaryTextColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "YOUR LOCATION IS SHARED WITH THE SEEKER.",
                              style: TextStyle(
                                color: context.appColors.secondaryTextColor.withAlpha(150),
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SolidButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: "I HAVE ARRIVED",
                    allCaps: true,
                    isPrimary: true,
                    height: 50,
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
