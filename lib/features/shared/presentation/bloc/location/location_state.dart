part of 'location_bloc.dart';

abstract class LocationState {
  final UserLocation location;
  LocationState({required this.location});
}

class LocationInitial extends LocationState {
  LocationInitial({required super.location});
}

class LocationLoading extends LocationState {
  LocationLoading({required super.location});
}

class LocationSuccess extends LocationState {
  LocationSuccess({required super.location});
}

class LocationFailure extends LocationState {
  final String message;
  LocationFailure({required super.location, required this.message});
}
