<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
=======
import 'package:hydrated_bloc/hydrated_bloc.dart';
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
import 'package:nsapp/core/models/user_location.dart';
import 'package:nsapp/core/services/location_service.dart';

part 'location_event.dart';
part 'location_state.dart';

<<<<<<< HEAD
class LocationBloc extends Bloc<LocationEvent, LocationState> {
=======
class LocationBloc extends HydratedBloc<LocationEvent, LocationState> {
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
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
<<<<<<< HEAD
=======

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
>>>>>>> cc9c85db158902495bd6a3b3dbcc216bd8feb0e7
}
