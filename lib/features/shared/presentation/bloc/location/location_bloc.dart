import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/user_location.dart';
import 'package:nsapp/core/services/location_service.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
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
}
