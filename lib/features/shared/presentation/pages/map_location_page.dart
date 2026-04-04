import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';

import '../bloc/shared_bloc.dart';
import '../widget/search_location_map_widget.dart';
import 'package:nsapp/core/core.dart';


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
                    padding: EdgeInsets.only(bottom: 50.h),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween(begin: 1.0, end: isMoving ? 1.3 : 1.0),
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          origin: Offset(0, 25.h),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 60.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  color: context.appColors.primaryColor
                                      .withAlpha(40),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.appColors.secondaryColor
                                          .withAlpha(30),
                                      blurRadius: 15.r,
                                      spreadRadius: 5.r,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.location_on_rounded,
                                size: 50.r,
                                color: context.appColors.errorColor,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  top: 60.h,
                  child: GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        Container(
                          padding: EdgeInsets.all(24.r),
                          width: size(context).width,
                          height: size(context).height * 0.85,
                          decoration: BoxDecoration(
                            color: context.appColors.cardBackground,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(30.r),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 14.h,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.cardBackground,
                          borderRadius: BorderRadius.circular(16.r),
                          border:
                              Border.all(color: context.appColors.glassBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: context.appColors.secondaryTextColor,
                              size: 20.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                locationTextController.text.isEmpty
                                    ? "Search for a location..."
                                    : locationTextController.text,
                                style: TextStyle(
                                  color: context.appColors.primaryTextColor,
                                  fontSize: 16.sp,
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
                  right: 20.w,
                  bottom: 120.h,
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
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: context.appColors.cardBackground,
                        borderRadius: BorderRadius.circular(12.r),
                        border:
                            Border.all(color: context.appColors.glassBorder),
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: context.appColors.primaryTextColor,
                        size: 24.r,
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
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: context.appColors.primaryColor,
            borderRadius: BorderRadius.circular(50.r),
            boxShadow: [
              BoxShadow(
                color: context.appColors.primaryColor.withAlpha(100),
                blurRadius: 15.r,
                offset: Offset(0, 5.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                "Confirm Location",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
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
