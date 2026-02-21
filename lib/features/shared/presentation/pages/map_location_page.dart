import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/constants/app_colors.dart';
import 'package:nsapp/core/constants/dimension.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';

import '../bloc/shared_bloc.dart';
import '../widget/search_location_map_widget.dart';

class MapLocationPage extends StatefulWidget {
  const MapLocationPage({super.key});

  @override
  State<MapLocationPage> createState() => _MapLocationPageState();
}

class _MapLocationPageState extends State<MapLocationPage> {
  TextEditingController locationTextController = TextEditingController();

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(locationData.latitude, locationData.longitude),
    zoom: 15,
  );
  LatLng? pos;

  bool isMoving = false;

  @override
  void initState() {
    super.initState();
    pos = initialCameraPosition.target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<SharedBloc, SharedState>(
        listener: (context, state) async {
          if (state is SuccessPlaceState) {
            context.read<SharedBloc>().add(
              MapLocationEvent(
                location: LatLng(
                  SuccessPlaceState.places.lat!,
                  SuccessPlaceState.places.lng!,
                ),
              ),
            );
            pos = LatLng(
              SuccessPlaceState.places.lat!,
              SuccessPlaceState.places.lng!,
            );
            GoogleMapController con = await _controller.future;
            con.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(
                    SuccessPlaceState.places.lat!,
                    SuccessPlaceState.places.lng!,
                  ),
                  zoom: 15,
                ),
              ),
            );
            setState(() {});
          }
        },
        builder: (context, state) {
          return SizedBox(
            width: size(context).width,
            height: size(context).height,
            child: Stack(
              children: [
                GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  style: mapStyle,
                  initialCameraPosition: initialCameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  onCameraMoveStarted: () {
                    setState(() {
                      isMoving = true;
                    });
                  },
                  onCameraIdle: () {
                    setState(() {
                      isMoving = false;
                    });
                  },
                  onCameraMove: (position) async {
                    context.read<SharedBloc>().add(
                      MapLocationEvent(location: position.target),
                    );
                    pos = position.target;
                    locationTextController.text =
                        await Helpers.getAddressFromMap(position.target);
                    locController.text = locationTextController.text;
                  },
                  onTap: (position) {
                    context.read<SharedBloc>().add(
                      MapLocationEvent(location: position),
                    );
                  },
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween(begin: 1.0, end: isMoving ? 1.3 : 1.0),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          origin: const Offset(0, 25),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: appDeepBlueColor1.withAlpha(40),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: appOrangeColor1.withAlpha(30),
                                      blurRadius: 15,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.location_on_rounded,
                                size: 50,
                                color: Colors.redAccent,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 60,
                  child: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        Container(
                          padding: const EdgeInsets.all(24),
                          width: size(context).width,
                          height: size(context).height * 0.85,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E1E2E),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          child: const SearchLocationMapWidget(),
                        ),
                        isScrollControlled: true,
                      );
                    },
                    child: Hero(
                      tag: 'map_search',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E2E3E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                locationTextController.text.isEmpty
                                    ? "Search for a location..."
                                    : locationTextController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 120,
                  child: GestureDetector(
                    onTap: () async {
                      GoogleMapController con = await _controller.future;
                      con.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              locationData.latitude,
                              locationData.longitude,
                            ),
                            zoom: 15,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2E3E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          if (pos != null) {
            locationTextController.text = await Helpers.getAddressFromMap(pos!);
          }
          locController.text = locationTextController.text;
          Get.back();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: appDeepBlueColor1,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: appDeepBlueColor1.withAlpha(100),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "Confirm Location",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
