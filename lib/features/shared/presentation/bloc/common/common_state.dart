
import 'package:nsapp/core/models/map_places.dart';
import 'package:nsapp/core/models/place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/models/services_model.dart';

abstract class CommonState {}

class CommonInitial extends CommonState {}

class CommonLoading extends CommonState {}

class CommonFailure extends CommonState {
  final String? message;
  CommonFailure(this.message);
}

class SuccessAddServicesState extends CommonState {
  final String? id;
  SuccessAddServicesState({this.id});
}

class SuccessGetServicesState extends CommonState {
  final List<Service> services;
  SuccessGetServicesState({required this.services});
}

class SuccessPlacesState extends CommonState {
  final List<MapPlaces> places;
  SuccessPlacesState({required this.places});
}

class SuccessPlaceState extends CommonState {
  final Place place;
  SuccessPlaceState({required this.place});
}

class MapLocationState extends CommonState {
  final LatLng location;
  final String address;
  MapLocationState({required this.location, required this.address});
}

class UseMapState extends CommonState {
  final bool useMap;
  UseMapState({required this.useMap});
}

class ViewImageState extends CommonState {
  final String url;
  ViewImageState({required this.url});
}
