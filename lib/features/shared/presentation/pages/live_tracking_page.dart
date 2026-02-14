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
      controller.animateCamera(CameraUpdate.newLatLng(_providerLocation!));
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
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
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
                          color: Colors.blue.withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delivery_dining_rounded,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.providerName} is on the way!",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              "Tracking live location...",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
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
