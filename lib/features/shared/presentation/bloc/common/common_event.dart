import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/models/service.dart';

abstract class CommonEvent {}

class GetServicesEvent extends CommonEvent {}

class AddServiceEvent extends CommonEvent {
  final Service model;
  AddServiceEvent({required this.model});
}

class SearchPlacesEvent extends CommonEvent {
  final String input;
  SearchPlacesEvent({required this.input});
}

class SearchPlaceEvent extends CommonEvent {
  final String placeId;
  SearchPlaceEvent({required this.placeId});
}

class MapLocationEvent extends CommonEvent {
  final LatLng location;
  MapLocationEvent({required this.location});
}

class UseMapEvent extends CommonEvent {
  final bool useMap;
  UseMapEvent({required this.useMap});
}

class SetViewImageEvent extends CommonEvent {
  final String url;
  SetViewImageEvent({required this.url});
}
