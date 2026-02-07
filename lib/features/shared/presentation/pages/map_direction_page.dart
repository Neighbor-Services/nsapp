import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_widget/google_maps_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchDirections();
  }

  Future<void> _fetchDirections() async {
    try {
      final results = await LocationService.getDistance(
        lat: RequestDirectionState.request.latitude ?? 0.0,
        lng: RequestDirectionState.request.longitude ?? 0.0,
      );
      setState(() {
        distance = results.text;
        duration = results.text;
      });
    } catch (e) {
      debugPrint("Error fetching directions: $e");
    }
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
            child: GoogleMapsWidget(
              defaultCameraZoom: 15.0,
              indoorViewEnabled: true,
              trafficEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                // ignore: deprecated_member_use
                controller.setMapStyle(mapStyle);
                _controller.complete(controller);
              },
              apiKey: mapAPIKey,
              compassEnabled: true,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              routeWidth: 4,
              routeColor: appDeepBlueColor1,
              sourceLatLng: LatLng(
                locationData.latitude,
                locationData.longitude,
              ),
              destinationLatLng: LatLng(
                RequestDirectionState.request.latitude ?? 0.0,
                RequestDirectionState.request.longitude ?? 0.0,
              ),
            ),
          ),
          // Navigation Info Card
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: SolidContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: appDeepBlueColor1.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Heading to Request Location",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Following the fastest route",
                              style: TextStyle(
                                color: Colors.white.withAlpha(150),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white12),
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
            top: 60,
            left: 20,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const SolidContainer(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
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
        Icon(icon, color: appDeepBlueColor1, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(100),
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
