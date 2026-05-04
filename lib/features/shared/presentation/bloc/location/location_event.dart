part of 'location_bloc.dart';

abstract class LocationEvent {}

class GetLocationEvent extends LocationEvent {}

class UpdateLocationEvent extends LocationEvent {
  final UserLocation location;
  UpdateLocationEvent({required this.location});
}
