import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/helpers/helpers.dart';

import 'package:nsapp/features/shared/presentation/bloc/common/common_bloc.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_event.dart';
import 'package:nsapp/features/shared/presentation/bloc/common/common_state.dart';
import '../bloc/location/location_bloc.dart';
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

  late CameraPosition initialCameraPosition;
  LatLng? pos;

  bool isMoving = false;

  @override
  void initState() {
    super.initState();
    final location = context.read<LocationBloc>().state.location;
    initialCameraPosition = CameraPosition(
      target: LatLng(location.position.latitude, location.position.longitude),
      zoom: 15,
    );
    pos = initialCameraPosition.target;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: BlocConsumer<CommonBloc, CommonState>(
        listener: (context, state) async {
          if (state is SuccessPlaceState) {
            context.read<CommonBloc>().add(
              MapLocationEvent(
                location: LatLng(
                  state.place.lat!,
                  state.place.lng!,
                ),
              ),
            );
            pos = LatLng(
              state.place.lat!,
              state.place.lng!,
            );
            GoogleMapController con = await _controller.future;
            con.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(
                    state.place.lat!,
                    state.place.lng!,
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
                    context.read<CommonBloc>().add(
                      MapLocationEvent(location: position.target),
                    );
                    pos = position.target;
                    locationTextController.text =
                        await Helpers.getAddressFromMap(position.target);
                  },
                  onTap: (position) {
                    context.read<CommonBloc>().add(
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
                                FontAwesomeIcons.locationDot,
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
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
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
                              FontAwesomeIcons.magnifyingGlass,
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
                                  fontWeight: FontWeight.w400,
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
                      final locState = context.read<LocationBloc>().state;
                      con.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              locState.location.position.latitude,
                              locState.location.position.longitude,
                            ),
                            zoom: 15,
                          ),
                        ),
                      );
                      context.read<CommonBloc>().add(
                        MapLocationEvent(
                          location: LatLng(
                            locState.location.position.latitude,
                            locState.location.position.longitude,
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
                        FontAwesomeIcons.locationCrosshairs,
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
            final userLocation = await LocationService.getUserLocationFromLatLng(pos!);
            if (userLocation != null) {
              if (mounted) {
                context.read<LocationBloc>().add(UpdateLocationEvent(location: userLocation));
                locationTextController.text = userLocation.address;
              }
            } else {
              locationTextController.text = await Helpers.getAddressFromMap(pos!);
            }
          }
          context.pop(locationTextController.text);
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
              FaIcon(FontAwesomeIcons.circleCheck,
                  color: Colors.white, size: 24.r),
              SizedBox(width: 8.w),
              Text(
                "Confirm Location",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
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


