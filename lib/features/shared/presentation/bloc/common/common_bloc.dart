import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/features/shared/domain/usecase/get_services_usecase.dart';
import 'package:nsapp/features/shared/domain/usecase/add_service_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/search_places_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/search_place_use_case.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'common_event.dart';
import 'common_state.dart';

class CommonBloc extends Bloc<CommonEvent, CommonState> {
  final GetServicesUsecase getServicesUsecase;
  final AddServiceUseCase addServiceUseCase;
  final SearchPlacesUseCase searchPlacesUseCase;
  final SearchPlaceUseCase searchPlaceUseCase;

  CommonBloc({
    required this.getServicesUsecase,
    required this.addServiceUseCase,
    required this.searchPlacesUseCase,
    required this.searchPlaceUseCase,
  }) : super(CommonInitial()) {
    on<GetServicesEvent>((event, emit) async {
      final results = await getServicesUsecase(null);
      results.fold(
        (l) => emit(CommonFailure(l.message)),
        (r) => emit(SuccessGetServicesState(services: r)),
      );
    });

    on<AddServiceEvent>((event, emit) async {
      final results = await addServiceUseCase(event.model);
      results.fold(
        (l) => emit(CommonFailure(l.message)),
        (r) => emit(SuccessAddServicesState(id: r)),
      );
    });

    on<SearchPlacesEvent>((event, emit) async {
      final results = await searchPlacesUseCase(event.input);
      results.fold(
        (l) => emit(CommonFailure(l.message)),
        (r) => emit(SuccessPlacesState(places: r)),
      );
    });

    on<SearchPlaceEvent>((event, emit) async {
      final results = await searchPlaceUseCase(event.placeId);
      results.fold(
        (l) => emit(CommonFailure(l.message)),
        (r) => emit(SuccessPlaceState(place: r)),
      );
    });

    on<MapLocationEvent>((event, emit) async {
      final address = await Helpers.getAddressFromMap(event.location);
      emit(MapLocationState(location: event.location, address: address));
    });

    on<UseMapEvent>((event, emit) {
      emit(UseMapState(useMap: event.useMap));
    });

    on<SetViewImageEvent>((event, emit) {
      emit(ViewImageState(url: event.url));
    });
  }
}
