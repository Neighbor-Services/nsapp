import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
import 'package:nsapp/core/models/user.dart';
import 'package:nsapp/core/models/rate.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/features/seeker/domain/usecase/add_to_favorite_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/approve_provider_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/cancel_appointment_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/cancel_approved_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/create_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/delete_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_accepted_users_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_appointments_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_my_favorites_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_my_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/get_popular_provider_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/mark_as_done_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/rate_provider_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/reload_request_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/remove_from_favorite_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/search_provider_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/update_request_use_case.dart';
// Removed UI imports and visited_pages.dart since BLoC no longer stores Widgets
import 'package:nsapp/features/seeker/domain/usecase/match_providers_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/complete_appointment_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/update_appointment_use_case.dart';

part 'seeker_event.dart';
part 'seeker_state.dart';

class SeekerBloc extends HydratedBloc<SeekerEvent, SeekerState> {
  final CreateRequestUseCase createRequestUseCase;
  final GetMyRequestUseCase getMyRequestUseCase;
  final GetAcceptedUsersUseCase getAcceptedUsersUseCase;
  final ReloadRequestUseCase reloadRequestUseCase;
  final ApproveProviderUseCase approveProviderUseCase;
  final CancelApprovedRequestUseCase cancelApprovedRequestUseCase;
  final DeleteRequestUseCase deleteRequestUseCase;
  final UpdateRequestUseCase updateRequestUseCase;
  final GetPopularProviderRequestUseCase getPopularProviderRequestUseCase;
  final AddToFavoriteUseCase addToFavoriteUseCase;
  final RemoveFromFavoriteUseCase removeFromFavoriteUseCase;
  final GetMyFavoritesUseCase getMyFavoritesUseCase;
  final SearchProviderUseCase searchProviderUseCase;
  final MarkAsDoneUseCase markAsDoneUseCase;
  final GetSeekerAppointmentsUseCase getSeekerAppointmentsUseCase;
  final RateProviderUseCase rateProviderUseCase;
  final CancelAppointmentUseCase cancelAppointmentUseCase;
  final MatchProvidersUseCase matchProvidersUseCase;
  final CompleteAppointmentUseCase completeAppointmentUseCase;
  final UpdateSeekerAppointmentUseCase updateSeekerAppointmentUseCase;

  // Local storage for data and active tab
  int _currentTab = 1;
  XFile? _selectedPicture;
  
  List<RequestData> _myRequests = [];
  List<Favorite> _myFavorites = [];
  List<AppointmentData> _appointments = [];
  List<Profile> _popularProviders = [];
  
  // Getters for data
  int get currentTab => _currentTab;
  XFile? get selectedPicture => _selectedPicture;
  List<RequestData> get myRequests => _myRequests;
  List<Favorite> get myFavorites => _myFavorites;
  List<AppointmentData> get appointments => _appointments;
  List<Profile> get popularProviders => _popularProviders;

  SeekerBloc(
    this.createRequestUseCase,
    this.getMyRequestUseCase,
    this.getAcceptedUsersUseCase,
    this.reloadRequestUseCase,
    this.approveProviderUseCase,
    this.cancelApprovedRequestUseCase,
    this.deleteRequestUseCase,
    this.updateRequestUseCase,
    this.getPopularProviderRequestUseCase,
    this.addToFavoriteUseCase,
    this.removeFromFavoriteUseCase,
    this.getMyFavoritesUseCase,
    this.getSeekerAppointmentsUseCase,
    this.searchProviderUseCase,
    this.markAsDoneUseCase,
    this.rateProviderUseCase,
    this.cancelAppointmentUseCase,
    this.matchProvidersUseCase,
    this.completeAppointmentUseCase,
    this.updateSeekerAppointmentUseCase,
  ) : super(InitialSeekerState()) {
    
    on<ChangeSeekerTabEvent>((event, emit) {
      _currentTab = event.tabIndex;
      emit(SeekerTabChangedState(tabIndex: _currentTab));
    });

    on<RequestPriceEvent>((event, emit) {
      emit(RequestPriceState(fixedPrice: event.fixedPrice));
    });

    on<ChangeLocationEvent>((event, emit) {
      emit(RequestLocationChangeState(change: event.change));
    });

    on<CreateRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await createRequestUseCase(RequestParams(
        request: event.request,
        imagePath: _selectedPicture?.path,
      ));
      results.fold(
        (l) => emit(FailureCreateRequestState(message: l.message)),
        (r) => emit(SuccessCreateRequestState()),
      );
    });

    on<MarkAsDoneEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await markAsDoneUseCase(event.request);
      results.fold(
        (l) => emit(FailureMarkAsDoneState(message: l.message)),
        (r) => emit(SuccessMarkAsDoneState()),
      );
    });

    on<GetMyRequestEvent>((event, emit) async {
      final results = await getMyRequestUseCase(event);
      results.fold(
        (l) => emit(FailureCreateRequestState(message: l.message)),
        (r) {
          _myRequests = r;
          emit(SuccessGetMyRequestState(myRequests: r));
        },
      );
    });

    on<SelectImageFromGalleryEvent>((event, emit) async {
      _selectedPicture = await Helpers.selectImageFromGallery();
      emit(ImageSeekerState(picture: _selectedPicture));
    });

    on<SelectImageFromCameraEvent>((event, emit) async {
      _selectedPicture = await Helpers.selectImageFromCamera();
      emit(ImageSeekerState(picture: _selectedPicture));
    });

    on<SeekerRequestDetailEvent>((event, emit) {
      emit(SeekerRequestDetailState(request: event.request));
    });

    on<GetAcceptedUsersSeekerEvent>((event, emit) async {
      final results = await getAcceptedUsersUseCase(event.request);
      results.fold(
        (l) => emit(FailureAcceptedUserstState(message: l.message)),
        (r) => emit(SuccessAcceptedUsersState(users: r)),
      );
    });

    on<ReloadRequestEvent>((event, emit) async {
      final results = await reloadRequestUseCase(event.request);
      results.fold(
        (l) => emit(FailureReloadRequestState(message: l.message)),
        (r) => emit(SuccessReloadRequestState(request: r)),
      );
    });

    on<ApprovedRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await approveProviderUseCase(event.requestAccept);
      results.fold(
        (l) => emit(FailureApprovedProviderState(message: l.message)),
        (r) => emit(SuccessApprovedProviderState()),
      );
    });

    on<DeleteRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await deleteRequestUseCase(event.request);
      results.fold(
        (l) => emit(FailureDeleteRequestState(message: l.message)),
        (r) => emit(SuccessDeleteRequestState()),
      );
    });

    on<UpdateRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await updateRequestUseCase(RequestParams(
        request: event.request,
        imagePath: _selectedPicture?.path,
      ));
      results.fold(
        (l) => emit(FailureUpdateRequestState(message: l.message)),
        (r) => emit(SuccessUpdateRequestState()),
      );
    });

    on<GetPopularProvidersEvent>((event, emit) async {
      debugPrint("SeekerBloc: Fetching popular providers...");
      emit(PopularProvidersLoadingState());
      final results = await getPopularProviderRequestUseCase(event);
      results.fold(
        (l) {
          debugPrint("SeekerBloc: Failed to fetch popular providers: ${l.message}");
          emit(FailurePopularProviderState(message: l.message));
        },
        (r) {
          debugPrint("SeekerBloc: Successfully fetched ${r.length} popular providers");
          _popularProviders = r;
          emit(SuccessPopularProvidersState(providers: r));
        },
      );
    });

    on<AddToFavoriteEvent>((event, emit) async {
      // Optimistic Update: Add a temporary favorite object
      final tempFavorite = Favorite(
        id: "temp_${event.userId}",
        favoriteUser: Profile(
          id: event.userId,
          user: User(id: event.userId),
        ),
      );
      _myFavorites.add(tempFavorite);
      emit(SuccessGetMyFavoritesState(profiles: List.from(_myFavorites)));

      final results = await addToFavoriteUseCase(event.userId);
      results.fold(
        (l) {
          // Rollback on failure
          _myFavorites.removeWhere((f) => f.id == "temp_${event.userId}");
          emit(SuccessGetMyFavoritesState(profiles: List.from(_myFavorites)));
          emit(FailureAddToFavoriteState(message: l.message));
        },
        (r) {
          // Emit success — widget listeners will trigger a single
          // GetMyFavoritesEvent to sync the temp favourite with the
          // real server record.
          emit(SuccessAddToFavoriteState());
        },
      );
    }, transformer: sequential());

    on<RemoveFromFavoriteEvent>((event, emit) async {
      // Optimistic Update: Remove from local list
      final removedIndex = _myFavorites.indexWhere((f) => f.id == event.userId);
      Favorite? removedFavorite;
      if (removedIndex != -1) {
        removedFavorite = _myFavorites.removeAt(removedIndex);
      }
      emit(SuccessGetMyFavoritesState(profiles: List.from(_myFavorites)));

      final results = await removeFromFavoriteUseCase(event.userId);
      results.fold(
        (l) {
          // Rollback on failure
          if (removedFavorite != null) {
            _myFavorites.add(removedFavorite);
            emit(SuccessGetMyFavoritesState(profiles: List.from(_myFavorites)));
          }
          emit(FailureRemoveFromFavoriteState(message: l.message));
        },
        (r) {
          // Success
          emit(SuccessRemoveFromFavoriteState());
        },
      );
    }, transformer: sequential());

    on<GetMyFavoritesEvent>((event, emit) async {
      debugPrint("SeekerBloc: Fetching favorites...");
      final results = await getMyFavoritesUseCase(event);
      results.fold(
        (l) {
          debugPrint("SeekerBloc: Failed to fetch favorites: ${l.message}");
          emit(FailureGetMyFavoritesState(message: l.message));
        },
        (r) {
          debugPrint("SeekerBloc: Successfully fetched ${r.length} favorites");
          _myFavorites = r;
          emit(SuccessGetMyFavoritesState(profiles: r));
        },
      );
    }, transformer: restartable());

    // SeekerBackPressedEvent removed

    on<CancelApprovedRequestEvent>((event, emit) async {
      final results = await cancelApprovedRequestUseCase(event.request);
      results.fold(
        (l) => emit(FailureCancelApprovedProviderState(message: l.message)),
        (r) => emit(SuccessCancelApprovedProviderState()),
      );
    }, transformer: sequential());

    on<GetAppointmentsEvent>((event, emit) async {
      final results = await getSeekerAppointmentsUseCase(event);
      results.fold(
        (l) => emit(FailureGetAppointmentState(message: l.message)),
        (r) {
          _appointments = r;
          emit(SuccessGetAppointmentsState(appointments: r));
        },
      );
    });

    on<SearchProviderEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await searchProviderUseCase(SearchProviderParams(
        ratingMin: event.ratingMin,
        priceMin: event.priceMin,
        priceMax: event.priceMax,
        categoryName: event.categoryName,
        serviceName: event.serviceName,
        serviceId: event.serviceId,
        city: event.city,
      ));
      results.fold(
        (l) => emit(FailureSearchProviderState(message: l.message)),
        (r) => emit(SuccessSearchProviderState(providers: r)),
      );
    });

    on<SearchEvent>((event, emit) {
      emit(SearchingState(isSearching: event.isSearching));
    });

    on<ReviewProviderEvent>((event, emit) {
      emit(ReviewProviderState(canReview: event.canWriteReview));
    });

    on<SetRatingValueEvent>((event, emit) {
      emit(RatingValueState(rate: event.rate));
    });

    on<SetProviderToReviewEvent>((event, emit) {
      emit(ProviderToReviewState(
        profile: event.provider,
        providerUserId: event.providerUserId ?? event.provider.user?.id,
      ));
    });

    on<RateEvent>((event, emit) async {
      final results = await rateProviderUseCase(event.rate);
      results.fold(
        (l) => emit(FailureRateState(message: l.message)),
        (r) => emit(SuccessRateState()),
      );
    });

    on<ClearImageEvent>((event, emit) {
      _selectedPicture = null;
      emit(ClearImageState());
    });

    on<CancelAppointmentEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await cancelAppointmentUseCase(event.id);
      results.fold(
        (l) => emit(FailureCancelAppointmentState(message: l.message)),
        (r) => emit(SuccessCancelAppointmentState()),
      );
    });

    on<ChooseOtherServiceEvent>((event, emit) {
      emit(OtherServiceSelectState(others: event.other));
    });

    on<MatchProvidersEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await matchProvidersUseCase(description: event.description);
      results.fold(
        (l) => emit(FailureMatchProvidersState(message: l.message)),
        (r) => emit(SuccessMatchProvidersState(providers: r)),
      );
    });

    on<CompleteAppointmentEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await completeAppointmentUseCase(
        CompleteAppointmentParams(id: event.id, amount: event.amount),
      );
      results.fold(
        (l) => emit(FailureCompleteAppointmentState(message: l.message)),
        (r) => emit(SuccessCompleteAppointmentState()),
      );
    });

    on<UpdateSeekerAppointmentEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await updateSeekerAppointmentUseCase(event.appointment);
      results.fold(
        (l) => emit(FailureUpdateAppointmentState(message: l.message)),
        (r) {
          add(GetAppointmentsEvent());
          emit(SuccessUpdateAppointmentState());
        },
      );
    });

    on<SeekerReloadEvent>((event, emit) {
      add(GetMyRequestEvent());
    });

    on<ResetImageEvent>((event, emit) {
      _selectedPicture = null;
      emit(ClearImageState());
    });
  }

  @override
  SeekerState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('myRequests')) {
        _myRequests = (json['myRequests'] as List)
            .map((e) => RequestData.fromJson(e))
            .toList();
      }
      if (json.containsKey('myFavorites')) {
        _myFavorites = (json['myFavorites'] as List)
            .map((e) => Favorite.fromJson(e))
            .toList();
      }
      if (json.containsKey('appointments')) {
        _appointments = (json['appointments'] as List)
            .map((e) => AppointmentData.fromJson(e))
            .toList();
      }
      if (json.containsKey('popularProviders')) {
        _popularProviders = (json['popularProviders'] as List)
            .map((e) => Profile.fromJson(e))
            .toList();
      }
      if (json.containsKey('currentTab')) {
        _currentTab = json['currentTab'];
        return SeekerTabChangedState(tabIndex: _currentTab);
      }
      return SuccessGetMyRequestState(myRequests: _myRequests);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SeekerState state) {
    return {
      'myRequests': _myRequests.map((e) => e.toJson()).toList(),
      'myFavorites': _myFavorites.map((e) => e.toJson()).toList(),
      'appointments': _appointments.map((e) => e.toJson()).toList(),
      'popularProviders': _popularProviders.map((e) => e.toJson()).toList(),
      'currentTab': _currentTab,
    };
  }
}
