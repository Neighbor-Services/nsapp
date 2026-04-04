import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/core.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/services/location_service.dart';
import 'package:nsapp/features/provider/presentation/bloc/provider_bloc.dart';
import 'package:nsapp/features/shared/presentation/widget/solid_container_widget.dart';

class MapDirectionPage extends StatefulWidget {
  const MapDirectionPage({super.key});

  @override
  State<MapDirectionPage> createState() => _MapDirectionPageState();
}

class _MapDirectionPageState extends State<MapDirectionPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  String distance = "...";
  String duration = "...";
  List<LatLng> polylinePoints = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _fetchDirections();
  }

  Future<void> _fetchDirections() async {
    try {
      final destinationLat = RequestDirectionState.request.latitude ?? 0.0;
      final destinationLng = RequestDirectionState.request.longitude ?? 0.0;

      final results = await LocationService.getFullDirections(
        lat: destinationLat,
        lng: destinationLng,
      );
      
      final points = await LocationService.getPolylinePoints(
        sourceLat: locationData.latitude,
        sourceLng: locationData.longitude,
        destLat: destinationLat,
        destLng: destinationLng,
      );

      if (!mounted) return;
      setState(() {
        distance = results["distance"];
        duration = results["duration"];
        polylinePoints = points;
        
        markers = {
          Marker(
            markerId: const MarkerId("source"),
            position: LatLng(locationData.latitude, locationData.longitude),
            infoWindow: const InfoWindow(title: "My Location"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
          Marker(
            markerId: const MarkerId("destination"),
            position: LatLng(destinationLat, destinationLng),
            infoWindow: const InfoWindow(title: "Request Location"),
          ),
        };
      });
      
      if (points.isNotEmpty) {
        final GoogleMapController controller = await _controller.future;
        if (mounted) {
          _fitBounds(controller, destinationLat, destinationLng);
        }
      }
    } catch (e) {
      debugPrint("Error fetching directions: $e");
    }
  }

  void _fitBounds(GoogleMapController controller, double destLat, double destLng) {
    double minLat = locationData.latitude < destLat ? locationData.latitude : destLat;
    double maxLat = locationData.latitude > destLat ? locationData.latitude : destLat;
    double minLng = locationData.longitude < destLng ? locationData.longitude : destLng;
    double maxLng = locationData.longitude > destLng ? locationData.longitude : destLng;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SizedBox(
            width: size(context).width,
            height: size(context).height,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(locationData.latitude, locationData.longitude),
                zoom: 13.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                // ignore: deprecated_member_use
                controller.setMapStyle(mapStyle);
                _controller.complete(controller);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  points: polylinePoints,
                  color: context.appColors.primaryColor,
                  width: 5,
                ),
              },
            ),
          ),
          // Navigation Info Card
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 40.h,
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
                          color: context.appColors.primaryColor.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.navigation_rounded,
                          color: context.appColors.primaryColor,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Heading to Request Location",
                              style: TextStyle(
                                color: context.appColors.primaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              "Following the fastest route",
                              style: TextStyle(
                                color: context.appColors.secondaryTextColor,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Divider(color: context.appColors.secondaryTextColor),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(Icons.timer_outlined, "ETA", duration),
                      _buildInfoItem(
                        Icons.straighten_rounded,
                        "Distance",
                        distance,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: 60.h,
            left: 20.w,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: SolidContainer(
                padding: EdgeInsets.all(12.r),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: context.appColors.primaryTextColor,
                  size: 20.r,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: context.appColors.primaryColor, size: 20.r),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: context.appColors.secondaryTextColor,
                fontSize: 10.sp,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: context.appColors.primaryTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
