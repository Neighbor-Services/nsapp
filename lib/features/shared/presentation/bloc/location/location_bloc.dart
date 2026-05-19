
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nsapp/core/models/user_location.dart';
import 'package:nsapp/core/services/location_service.dart';

part 'location_event.dart';
part 'location_state.dart';


class LocationBloc extends HydratedBloc<LocationEvent, LocationState> {

  LocationBloc() : super(LocationInitial(location: UserLocation.initial())) {
    on<GetLocationEvent>((event, emit) async {
      emit(LocationLoading(location: state.location));
      final userLocation = await LocationService.getLocation();
      if (userLocation != null) {
        emit(LocationSuccess(location: userLocation));
      } else {
        emit(LocationFailure(
          location: state.location,
          message: "Failed to get location",
        ));
      }
    });

    on<UpdateLocationEvent>((event, emit) {
      emit(LocationSuccess(location: event.location));
    });
  }

  @override
  LocationState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('location')) {
        final location = UserLocation.fromJson(json['location']);
        return LocationSuccess(location: location);
      }
    } catch (_) {}
    return null;
  }

  @override
  Map<String, dynamic>? toJson(LocationState state) {
    return {
      'location': state.location.toJson(),
    };
  }
}
