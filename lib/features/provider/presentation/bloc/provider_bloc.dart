import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/failure.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/core/models/request_search_params.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'package:nsapp/core/models/visited_pages.dart';
import 'package:nsapp/features/provider/domain/usecase/accept_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/cancel_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/cancel_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_accepted_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_appointments_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_recent_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_requests_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/is_request_accepted_use_case.dart';
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:nsapp/features/provider/domain/usecase/reload_profile_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/serach_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_portfolio_item_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_service_package_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/complete_appointment_use_case.dart';

import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'dart:io';

import '../../../../core/models/request_acceptance.dart';
import '../../../../core/helpers/helpers.dart';

import 'package:nsapp/features/provider/domain/usecase/update_appointment_use_case.dart';

part 'provider_event.dart';

part 'provider_state.dart';

class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  final GetRecentRequestUseCase getRecentRequestUseCase;
  final AcceptRequestUseCase acceptRequestUseCase;
  final CancelRequestUseCase cancelRequestUseCase;
  final ReloadProfileUseCase reloadProfileUseCase;
  final GetAcceptedRequestUseCase getAcceptedRequestUseCase;
  final AddAppointmentUseCase addAppointmentUseCase;
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final GetRequestsUseCase requestsUseCase;
  final SerachRequestUseCase serachRequestUseCase;
  final CancelProviderAppointmentUseCase cancelAppointmentUseCase;
  final IsRequestAcceptedUseCase isRequestAcceptedUseCase;
  final AddPortfolioItemUseCase addPortfolioItemUseCase;
  final AddServicePackageUseCase addServicePackageUseCase;
  final CompleteAppointmentUseCase completeAppointmentUseCase;
  final UpdateProviderAppointmentUseCase updateProviderAppointmentUseCase;

  ProviderBloc(
    this.getRecentRequestUseCase,
    this.acceptRequestUseCase,
    this.cancelRequestUseCase,
    this.reloadProfileUseCase,
    this.getAcceptedRequestUseCase,
    this.addAppointmentUseCase,
    this.getAppointmentsUseCase,
    this.requestsUseCase,
    this.serachRequestUseCase,
    this.cancelAppointmentUseCase,
    this.isRequestAcceptedUseCase,
    this.addPortfolioItemUseCase,
    this.addServicePackageUseCase,
    this.completeAppointmentUseCase,
    this.updateProviderAppointmentUseCase,
  ) : super(ProviderInitial()) {
    on<ProviderEvent>((event, emit) {});
    on<ReloadEvent>((event, emit) {
      emit(ReloadState());
    });
    on<RequestDetailEvent>((event, emit) {
      RequestDetailState.requestData = event.request;
      emit(RequestDetailState());
    });
    on<NavigateProviderEvent>((event, emit) {
      ProviderVisitedPagesState.pages.add(
        VisitedPages(
          widget: NavigatorProviderState.widget,
          page: NavigatorProviderState.page,
        ),
      );
      NavigatorProviderState.page = event.page;
      NavigatorProviderState.widget = event.widget;
      emit(NavigatorProviderState());
    });
    on<GetRecentRequestEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await getRecentRequestUseCase(
        RequestSearchParams(
          lat:
              event.lat ??
              double.parse(SuccessGetProfileState.profile.latitude!),
          lng:
              event.lng ??
              double.parse(SuccessGetProfileState.profile.longitude!),
          radius: event.radius,
          page: event.page,
        ),
      );
      results.fold(
        (l) {
          if (event.page == null || event.page == 1) {
            SuccessGetRecentRequestState.myRequests = Future.value([]);
          }
          emit(FailureGetRecentRequestState());
        },
        (r) {
          if (event.page != null && event.page! > 1) {
            SuccessGetRecentRequestState.myRequests =
                SuccessGetRecentRequestState.myRequests?.then(
                  (value) => [...value, ...r],
                ) ??
                Future.value(r);
          } else {
            SuccessGetRecentRequestState.myRequests = Future.value(r);
          }
          emit(SuccessGetRecentRequestState());
        },
      );
    }, transformer: sequential());
    on<GetAcceptedRequestEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await getAcceptedRequestUseCase(event);
      results.fold(
        (l) {
          SuccessGetAcceptRequestState.accepts = Future.value([]);
          emit(FailureGetAcceptRequestState());
        },
        (r) {
          SuccessGetAcceptRequestState.accepts = Future.value(r);
          emit(SuccessGetAcceptRequestState());
        },
      );
    }, transformer: sequential());
    on<CancelRequestAcceptEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await cancelRequestUseCase(event.requestAccept);
      results.fold((l) => emit(FailureRequestCancelState()), (r) {
        IsRequestAcceptedState.accepted = false;
        emit(SuccessRequestCancelState());
      });
    });
    on<RequestAcceptEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await acceptRequestUseCase(event.requestAccept);
      results.fold((l) => emit(FailureRequestAcceptState()), (r) {
        IsRequestAcceptedState.accepted = true;
        emit(SuccessRequestAcceptState());
      });
    });
    on<ReloadProfileEvent>((event, emit) async {
      final results = await reloadProfileUseCase(event.request);
      results.fold((l) => emit(FailureReloadProfileState()), (r) {
        SuccessReloadProfileState.exists = r;
        emit(SuccessReloadProfileState());
      });
    });
    on<AddAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await addAppointmentUseCase(event.appointment);
      results.fold((l) => emit(FailureAddAppointmentState()), (r) {
        // Save the chatID locally to remember it's added
        final chatID = event.appointment.chatID;
        if (chatID != null && chatID.isNotEmpty) {
          // We use 'true' as the value, key is chatID
          // This matches Helpers.getString(chatID) check in UI
          // Assuming Helpers is accessible here, imported via helpers.dart?
          // Wait, Helpers isn't imported in this file directly but maybe via 'package:nsapp/core/helpers/helpers.dart'.
          // Let me check imports. Yes, line 1-32 doesn't show it but I can add it if missing or assume it's there?
          // I should import it.
          Helpers.saveString(chatID, "true");
        }
        emit(SuccessAddAppointmentState());
      });
    });
    on<GetAppointmentsEvent>((event, emit) async {
      final results = await getAppointmentsUseCase(event);
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

    on<GetRequestsEvent>((event, emit) async {
      final results = await requestsUseCase(
        RequestSearchParams(
          lat:
              event.lat ??
              double.parse(SuccessGetProfileState.profile.latitude!),
          lng:
              event.lng ??
              double.parse(SuccessGetProfileState.profile.longitude!),
          radius: event.radius,
          page: event.page,
        ),
      );
      results.fold(
        (l) {
          if (event.page == null || event.page == 1) {
            SuccessGetRequestsState.requests = Future.value([]);
          }
          emit(FailureGetRequestsState());
        },
        (r) {
          if (event.page != null && event.page! > 1) {
            SuccessGetRequestsState.requests =
                SuccessGetRequestsState.requests?.then(
                  (value) => [...value, ...r],
                ) ??
                Future.value(r);
          } else {
            SuccessGetRequestsState.requests = Future.value(r);
          }
          emit(SuccessGetRequestsState());
        },
      );
    }, transformer: sequential());

    on<GetTargetedRequestsEvent>((event, emit) async {
      final results = await requestsUseCase(
        RequestSearchParams(
          lat:
              event.lat ??
              double.parse(SuccessGetProfileState.profile.latitude!),
          lng:
              event.lng ??
              double.parse(SuccessGetProfileState.profile.longitude!),
          radius: event.radius,
          page: event.page,
          targeted: true, // Specific filter
        ),
      );
      results.fold(
        (l) {
          if (event.page == null || event.page == 1) {
            SuccessGetTargetedRequestsState.requests = Future.value([]);
          }
          emit(FailureGetTargetedRequestsState());
        },
        (r) {
          if (event.page != null && event.page! > 1) {
            SuccessGetTargetedRequestsState.requests =
                SuccessGetTargetedRequestsState.requests?.then(
                  (value) => [...value, ...r],
                ) ??
                Future.value(r);
          } else {
            SuccessGetTargetedRequestsState.requests = Future.value(r);
          }
          emit(SuccessGetTargetedRequestsState());
        },
      );
    }, transformer: sequential());

    on<SearchRequestEvent>((event, emit) async {
      final results = await serachRequestUseCase(
        RequestSearchParams(
          query: event.query,
          lat:
              event.lat ??
              double.parse(SuccessGetProfileState.profile.latitude!),
          lng:
              event.lng ??
              double.parse(SuccessGetProfileState.profile.longitude!),
          radius: event.radius,
          page: event.page,
          catalogServiceId: event.catalogServiceId,
        ),
      );
      results.fold(
        (l) {
          if (event.page == null || event.page == 1) {
            SuccessSearchRequestState.requests = Future.value([]);
          }
          emit(FailureSearchRequestState());
        },
        (r) {
          if (event.page != null && event.page! > 1) {
            SuccessSearchRequestState.requests =
                SuccessSearchRequestState.requests?.then(
                  (value) => [...value, ...r],
                ) ??
                Future.value(r);
          } else {
            SuccessSearchRequestState.requests = Future.value(r);
          }
          emit(SuccessSearchRequestState());
        },
      );
    }, transformer: sequential());
    on<ProviderBackPressedEvent>((event, emit) {
      if (ProviderVisitedPagesState.pages.isNotEmpty) {
        NavigatorProviderState.page = ProviderVisitedPagesState.pages.last.page;
        NavigatorProviderState.widget =
            ProviderVisitedPagesState.pages.last.widget;
        ProviderVisitedPagesState.pages.removeLast();
        emit(NavigatorProviderState());
      }
    });
    on<SearchEvent>((event, emit) {
      SearchingState.isSearching = event.isSearching;
      emit(SearchingState());
    });
    on<CancelAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await cancelAppointmentUseCase(event.id);
      results.fold(
        (l) => emit(FailureCancelAppointmentState()),
        (r) => emit(SuccessCancelAppointmentState()),
      );
    });
    on<IsRequestAcceptedEvent>((event, emit) async {
      final results = await isRequestAcceptedUseCase(event.id);
      results.fold(
        (l) {
          IsRequestAcceptedState.accepted = false;
          emit(FailureCancelAppointmentState());
        },
        (r) {
          IsRequestAcceptedState.accepted = r;
          emit(IsRequestAcceptedState());
        },
      );
    });
    on<RequestDirectionEvent>((event, emit) {
      RequestDirectionState.request = event.request;
      emit(RequestDirectionState());
    });
    on<AddPortfolioItemEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await addPortfolioItemUseCase(
        AddPortfolioItemParams(
          image: event.image,
          description: event.description,
        ),
      );
      results.fold(
        (l) => emit(FailureAddPortfolioItemState()),
        (r) => emit(SuccessAddPortfolioItemState()),
      );
    });
    on<AddServicePackageEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await addServicePackageUseCase(event.package);
      results.fold((l) => emit(FailureAddServicePackageState(l)), (r) {
        SuccessAddServicePackageState.package = r;
        emit(SuccessAddServicePackageState());
      });
    });

    on<CompleteAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await completeAppointmentUseCase(
        CompleteAppointmentParams(id: event.id, amount: event.amount),
      );
      results.fold(
        (l) => emit(FailureCompleteAppointmentState()),
        (r) => emit(SuccessCompleteAppointmentState()),
      );
    });
    on<UpdateProviderAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await updateProviderAppointmentUseCase(event.appointment);
      results.fold(
        (l) => emit(FailureUpdateAppointmentState()),
        (r) => emit(SuccessUpdateAppointmentState()),
      );
    });
  }
}
