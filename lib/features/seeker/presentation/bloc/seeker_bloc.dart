import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/favorite.dart';
import 'package:nsapp/core/models/profile.dart';
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
import 'package:nsapp/features/seeker/presentation/pages/seeker_home_page.dart';

import '../../../../core/models/visited_pages.dart';
import 'package:nsapp/features/seeker/domain/usecase/match_providers_use_case.dart';
import 'package:nsapp/features/seeker/domain/usecase/complete_appointment_use_case.dart';

import 'package:nsapp/features/seeker/domain/usecase/update_appointment_use_case.dart';

part 'seeker_event.dart';
part 'seeker_state.dart';

class SeekerBloc extends Bloc<SeekerEvent, SeekerState> {
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
    on<NavigateSeekerEvent>((event, emit) {
      SeekerVisitedPagesState.pages.add(
        VisitedPages(
          widget: NavigatorSeekerState.widget,
          page: NavigatorSeekerState.page,
        ),
      );
      NavigatorSeekerState.page = event.page;
      NavigatorSeekerState.widget = event.widget;
      emit(NavigatorSeekerState());
    });
    on<RequestPriceEvent>((event, emit) {
      RequestPriceState.fixedPrice = event.fixedPrice;
      emit(RequestPriceState());
    });
    on<ChangeLocationEvent>((event, emit) {
      RequestLocationChangeState.change = event.change;
      emit(RequestLocationChangeState());
    });
    on<CreateRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await createRequestUseCase(event.request);
      results.fold(
        (l) => emit(FailureCreateRequestState()),
        (r) => emit(SuccessCreateRequestState()),
      );
    });
    on<MarkAsDoneEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await markAsDoneUseCase(event.request);
      results.fold(
        (l) => emit(FailureMarkAsDoneState()),
        (r) => emit(SuccessMarkAsDoneState()),
      );
    });

    on<GetMyRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await getMyRequestUseCase(event);
      results.fold(
        (l) {
          SuccessGetMyRequestState.myRequests = Future.value([]);
          emit(FailureCreateRequestState());
        },
        (r) {
          SuccessGetMyRequestState.myRequests = Future.value(r);
          emit(SuccessGetMyRequestState());
        },
      );
    }, transformer: sequential());
    on<SelectImageFromGalleryEvent>((event, emit) async {
      await Helpers.selectImageFromGallery();
      if (image != null) {
        ImageSeekerState.picture = image;
      }
      emit(ImageSeekerState());
    });
    on<SelectImageFromCameraEvent>((event, emit) async {
      await Helpers.selectImageFromCamera();
      if (image != null) {
        ImageSeekerState.picture = image;
      }
      emit(ImageSeekerState());
    });
    on<SeekerRequestDetailEvent>((event, emit) {
      SeekerRequestDetailState.request = event.request;
      emit(SeekerRequestDetailState());
    });
    on<GetAcceptedUsersSeekerEvent>((event, emit) async {
      final results = await getAcceptedUsersUseCase(event.request);
      results.fold(
        (l) {
          SuccessAcceptedUsersState.users = Future.error(
            "Failed to load providers",
          );
          emit(FailureAcceptedUserstState());
        },
        (r) {
          SuccessAcceptedUsersState.users = Future.value(r);
          emit(SuccessAcceptedUsersState());
        },
      );
    }, transformer: sequential());

    on<ReloadRequestEvent>((event, emit) async {
      final results = await reloadRequestUseCase(event.request);
      results.fold(
        (l) {
          SuccessReloadRequestState.request = Future.error(
            "Failed to load request",
          );
          emit(FailureReloadRequestState());
        },
        (r) {
          SuccessReloadRequestState.request = Future.value(r);
          emit(SuccessReloadRequestState());
        },
      );
    }, transformer: sequential());
    on<ApprovedRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await approveProviderUseCase(event.requestAccept);
      results.fold(
        (l) => emit(FailureApprovedProviderState()),
        (r) => emit(SuccessApprovedProviderState()),
      );
    });
    on<DeleteRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await deleteRequestUseCase(event.request);
      results.fold(
        (l) => emit(FailureDeleteRequestState()),
        (r) => emit(SuccessDeleteRequestState()),
      );
    });
    on<UpdateRequestEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await updateRequestUseCase(event.request);
      results.fold(
        (l) => emit(FailureUpdateRequestState()),
        (r) => emit(SuccessUpdateRequestState()),
      );
    });
    on<GetPopularProvidersEvent>((event, emit) async {
      final results = await getPopularProviderRequestUseCase(event);
      results.fold(
        (l) {
          SuccessPopularProvidersState.providers = Future.value([]);
          emit(FailurePopularProviderState());
        },
        (r) {
          SuccessPopularProvidersState.providers = Future.value(r);
          emit(SuccessPopularProvidersState());
        },
      );
    }, transformer: sequential());

    on<AddToFavoriteEvent>((event, emit) async {
      final results = await addToFavoriteUseCase(event.userId);
      results.fold(
        (l) => emit(FailureAddToFavoriteState()),
        (r) => emit(SuccessAddToFavoriteState()),
      );
    });
    on<RemoveFromFavoriteEvent>((event, emit) async {
      final results = await removeFromFavoriteUseCase(event.userId);
      results.fold(
        (l) => emit(FailureRemoveFromFavoriteState()),
        (r) => emit(SuccessRemoveFromFavoriteState()),
      );
    });

    on<GetMyFavoritesEvent>((event, emit) async {
      final results = await getMyFavoritesUseCase(event);
      results.fold(
        (l) {
          SuccessGetMyFavoritesNoFutureState.profiles = [];
          SuccessGetMyFavoritesState.profiles = Future.value([]);
          emit(FailureGetMyFavoritesState());
        },
        (r) {
          SuccessGetMyFavoritesNoFutureState.profiles = r;
          SuccessGetMyFavoritesState.profiles = Future.value(r);
          emit(SuccessGetMyFavoritesState());
        },
      );
    }, transformer: sequential());
    on<SeekerBackPressedEvent>((event, emit) {
      if (SeekerVisitedPagesState.pages.isNotEmpty) {
        NavigatorSeekerState.page = SeekerVisitedPagesState.pages.last.page;
        NavigatorSeekerState.widget = SeekerVisitedPagesState.pages.last.widget;
        SeekerVisitedPagesState.pages.removeLast();
        emit(SeekerVisitedPagesState());
      }
    });
    on<CancelApprovedRequestEvent>((event, emit) async {
      final results = await cancelApprovedRequestUseCase(event.request);
      results.fold((l) => emit(FailureCancelApprovedProviderState()), (r) {
        emit(SuccessCancelApprovedProviderState());
      });
    }, transformer: sequential());
    on<GetAppointmentsEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await getSeekerAppointmentsUseCase(event);
      results.fold(
        (l) {
          SuccessGetAppointmentsState.appointments = Future.value([]);
          emit(FailureGetAppointmentState());
        },
        (r) {
          SuccessGetAppointmentsState.appointments = Future.value(r);
          emit(SuccessGetAppointmentsState());
        },
      );
    }, transformer: sequential());
    on<SearchProviderEvent>((event, emit) async {
      final params = SearchProviderParams(
        ratingMin: event.ratingMin,
        priceMin: event.priceMin,
        priceMax: event.priceMax,
        categoryName: event.categoryName,
        serviceName: event.serviceName,
        city: event.city,
      );
      final results = await searchProviderUseCase(params);
      results.fold(
        (l) {
          SuccessSearchProviderState.providers = Future.value([]);
          emit(FailureSearchProviderState());
        },
        (r) {
          SuccessSearchProviderState.providers = Future.value(r);
          emit(SuccessSearchProviderState());
        },
      );
    }, transformer: sequential());
    on<SearchEvent>((event, emit) {
      SearchingState.isSearching = event.isSearching;
      emit(SearchingState());
    });
    on<ReviewProviderEvent>((event, emit) {
      ReviewProviderState.canReview = event.canWriteReview;
      emit(ReviewProviderState());
    });
    on<SetRatingValueEvent>((event, emit) {
      RatingValueState.rate = event.rate;
      emit(RatingValueState());
    });
    on<SetProviderToReviewEvent>((event, emit) async {
      ProviderToReviewState.profile = event.provider;
      ProviderToReviewState.providerUserId =
          event.providerUserId ?? event.provider.user?.id;
      emit(ProviderToReviewState());
    });
    on<RateEvent>((event, emit) async {
      final results = await rateProviderUseCase(event.rate);
      results.fold((l) => emit(FailureRateState()), (r) {
        emit(SuccessRateState());
      });
    });
    on<ClearImageEvent>((event, emit) async {
      ImageSeekerState.picture = null;
      emit(ClearImageState());
    });
    on<CancelAppointmentEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await cancelAppointmentUseCase(event.id);
      results.fold(
        (l) => emit(FailureCancelAppointmentState()),
        (r) => emit(SuccessCancelAppointmentState()),
      );
    });
    on<ChooseOtherServiceEvent>((event, emit) {
      OtherServiceSelectState.others = event.other;
      emit(OtherServiceSelectState());
    });
    on<SeekerReloadEvent>((event, emit) async {
      emit(LoadingSeekerState());
    });
    on<MatchProvidersEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await matchProvidersUseCase(
        description: event.description,
      );
      results.fold((l) => emit(FailureMatchProvidersState()), (r) {
        emit(SuccessMatchProvidersState(Future.value(r)));
      });
    });

    on<CompleteAppointmentEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await completeAppointmentUseCase(
        CompleteAppointmentParams(id: event.id, amount: event.amount),
      );
      results.fold(
        (l) => emit(FailureCompleteAppointmentState()),
        (r) => emit(SuccessCompleteAppointmentState()),
      );
    });
    on<UpdateSeekerAppointmentEvent>((event, emit) async {
      emit(LoadingSeekerState());
      final results = await updateSeekerAppointmentUseCase(event.appointment);
      results.fold(
        (l) => emit(FailureUpdateAppointmentState()),
        (r) => emit(SuccessUpdateAppointmentState()),
      );
    });
  }
}
