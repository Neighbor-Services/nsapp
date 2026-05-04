import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:nsapp/core/models/appointment.dart';
import 'package:nsapp/core/models/request.dart';
import 'package:nsapp/core/models/request_acceptance.dart';
import 'package:nsapp/features/provider/domain/usecase/accept_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/cancel_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_appointments_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_accepted_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_recent_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_requests_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/get_request_detail_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/serach_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/cancel_request_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/update_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/complete_appointment_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/is_request_accepted_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/reload_profile_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_portfolio_item_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/add_service_package_use_case.dart';
import 'package:nsapp/features/provider/domain/usecase/verify_appointment_code_use_case.dart';
import 'package:nsapp/features/provider/presentation/pages/provider_home_page.dart';
import 'package:nsapp/core/models/service_package.dart';
import 'package:nsapp/core/models/request_data.dart';
import 'package:nsapp/core/models/request_search_params.dart';
import 'package:nsapp/core/models/request_accept.dart';
import 'dart:io';

import '../../../../core/models/visited_pages.dart';

part 'provider_event.dart';
part 'provider_state.dart';

class ProviderBloc extends HydratedBloc<ProviderEvent, ProviderState> {
  final GetRecentRequestUseCase getRecentRequestUseCase;
  final GetRequestsUseCase getRequestsUseCase;
  final SerachRequestUseCase searchRequestUseCase;
  final AcceptRequestUseCase acceptRequestUseCase;
  final CancelRequestUseCase cancelRequestUseCase;
  final GetAcceptedRequestUseCase getAcceptedRequestUseCase;
  final GetRequestDetailUseCase getRequestDetailUseCase;
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final AddAppointmentUseCase addAppointmentUseCase;
  final CancelProviderAppointmentUseCase cancelProviderAppointmentUseCase;
  final UpdateProviderAppointmentUseCase updateProviderAppointmentUseCase;
  final CompleteAppointmentUseCase completeAppointmentUseCase;
  final IsRequestAcceptedUseCase isRequestAcceptedUseCase;
  final ReloadProfileUseCase reloadProfileUseCase;
  final AddPortfolioItemUseCase addPortfolioItemUseCase;
  final AddServicePackageUseCase addServicePackageUseCase;
  final VerifyAppointmentCodeUseCase verifyAppointmentCodeUseCase;

  // Local storage for navigation and data to avoid static members
  Widget _currentWidget = const ProviderHomePage();
  int _currentPage = 1;
  final List<VisitedPages> _visitedPages = [];
  List<RequestData> _recentRequests = [];
  List<RequestData> _allRequests = [];
  List<RequestAcceptance> _myAcceptedRequests = [];
  List<AppointmentData> _appointments = [];

  ProviderBloc(
    this.getRecentRequestUseCase,
    this.getRequestsUseCase,
    this.searchRequestUseCase,
    this.acceptRequestUseCase,
    this.cancelRequestUseCase,
    this.getAcceptedRequestUseCase,
    this.getRequestDetailUseCase,
    this.getAppointmentsUseCase,
    this.addAppointmentUseCase,
    this.cancelProviderAppointmentUseCase,
    this.updateProviderAppointmentUseCase,
    this.completeAppointmentUseCase,
    this.isRequestAcceptedUseCase,
    this.reloadProfileUseCase,
    this.addPortfolioItemUseCase,
    this.addServicePackageUseCase,
    this.verifyAppointmentCodeUseCase,
  ) : super(ProviderInitial()) {
    
    on<NavigateProviderEvent>((event, emit) {
      _visitedPages.add(
        VisitedPages(
          widget: _currentWidget,
          page: _currentPage,
        ),
      );
      _currentPage = event.page;
      _currentWidget = event.widget;
      emit(NavigatorProviderState(widget: _currentWidget, page: _currentPage));
    });

    on<ProviderBackPressedEvent>((event, emit) {
      if (_visitedPages.isNotEmpty) {
        final last = _visitedPages.removeLast();
        _currentPage = last.page;
        _currentWidget = last.widget;
        emit(NavigatorProviderState(widget: _currentWidget, page: _currentPage));
      }
    });

    on<GetRecentRequestEvent>((event, emit) async {
      final params = RequestSearchParams(
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
        page: event.page,
      );
      final results = await getRecentRequestUseCase(params);
      results.fold(
        (l) => emit(FailureGetRecentRequestState(message: l.message)),
        (r) {
          _recentRequests = r;
          emit(SuccessGetRecentRequestState(myRequests: r));
        },
      );
    }, transformer: sequential());

    on<GetRequestsEvent>((event, emit) async {
      final params = RequestSearchParams(
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
        page: event.page,
      );
      final results = await getRequestsUseCase(params);
      results.fold(
        (l) => emit(FailureGetRequestsState(message: l.message)),
        (r) {
          _allRequests = r;
          emit(SuccessGetRequestsState(requests: r));
        },
      );
    }, transformer: sequential());

    on<SearchRequestEvent>((event, emit) async {
      final params = RequestSearchParams(
        query: event.query,
        lat: event.lat,
        lng: event.lng,
        radius: event.radius,
        page: event.page,
        catalogServiceId: event.catalogServiceId,
      );
      final results = await searchRequestUseCase(params);
      results.fold(
        (l) => emit(FailureSearchRequestState(message: l.message)),
        (r) => emit(SuccessSearchRequestState(requests: r)),
      );
    }, transformer: sequential());

    on<RequestAcceptEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await acceptRequestUseCase(event.requestAccept);
      results.fold(
        (l) => emit(FailureRequestAcceptState(message: l.message)),
        (r) => emit(SuccessRequestAcceptState()),
      );
    });

    on<CancelRequestAcceptEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await cancelRequestUseCase(event.requestAccept);
      results.fold(
        (l) => emit(FailureRequestCancelState(message: l.message)),
        (r) => emit(SuccessRequestCancelState()),
      );
    });

    on<GetAcceptedRequestEvent>((event, emit) async {
      final results = await getAcceptedRequestUseCase(event);
      results.fold(
        (l) => emit(FailureGetAcceptRequestState(message: l.message)),
        (r) {
          _myAcceptedRequests = r;
          emit(SuccessGetAcceptRequestState(accepts: r));
        },
      );
    }, transformer: sequential());

    on<GetRequestDetailEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await getRequestDetailUseCase(event.id);
      results.fold(
        (l) => emit(FailureGetRequestsState(message: l.message)),
        (r) => emit(SuccessGetRequestDetailState(request: r)),
      );
    });

    on<GetAppointmentsEvent>((event, emit) async {
      final results = await getAppointmentsUseCase(event);
      results.fold(
        (l) => emit(FailureGetAppointmentState(message: l.message)),
        (r) {
          _appointments = r;
          emit(SuccessGetAppointmentsState(appointments: r));
        },
      );
    }, transformer: sequential());

    on<AddAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await addAppointmentUseCase(event.appointment);
      results.fold(
        (l) => emit(FailureAddAppointmentState(message: l.message)),
        (r) => emit(SuccessAddAppointmentState()),
      );
    });

    on<CancelAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await cancelProviderAppointmentUseCase(event.id);
      results.fold(
        (l) => emit(FailureCancelAppointmentState(message: l.message)),
        (r) => emit(SuccessCancelAppointmentState()),
      );
    });

    on<UpdateProviderAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await updateProviderAppointmentUseCase(event.appointment);
      results.fold(
        (l) => emit(FailureUpdateAppointmentState(message: l.message)),
        (r) => emit(SuccessUpdateAppointmentState()),
      );
    });

    on<CompleteAppointmentEvent>((event, emit) async {
      emit(LoadingProviderState());
      final params = CompleteAppointmentParams(id: event.id, amount: event.amount);
      final results = await completeAppointmentUseCase(params);
      results.fold(
        (l) => emit(FailureCompleteAppointmentState(message: l.message)),
        (r) => emit(SuccessCompleteAppointmentState()),
      );
    });

    on<IsRequestAcceptedEvent>((event, emit) async {
      final results = await isRequestAcceptedUseCase({
        'id': event.id,
        'uid': event.uid,
      });
      results.fold(
        (l) => emit(IsRequestAcceptedState(accepted: false)),
        (r) => emit(IsRequestAcceptedState(accepted: r)),
      );
    });

    on<ReloadProfileEvent>((event, emit) async {
      final results = await reloadProfileUseCase(event.request);
      results.fold(
        (l) => emit(FailureReloadProfileState()),
        (r) => emit(SuccessReloadProfileState(exists: r)),
      );
    });

    on<AddPortfolioItemEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await addPortfolioItemUseCase(event);
      results.fold(
        (l) => emit(FailureAddPortfolioItemState(message: l.message)),
        (r) => emit(SuccessAddPortfolioItemState()),
      );
    });

    on<AddServicePackageEvent>((event, emit) async {
      emit(LoadingProviderState());
      final results = await addServicePackageUseCase(event.package);
      results.fold(
        (l) => emit(FailureAddServicePackageState(message: l.message)),
        (r) => emit(SuccessAddServicePackageState(package: r)),
      );
    });

    on<VerifyAppointmentCodeEvent>((event, emit) async {
      emit(VerifyAppointmentCodeLoadingState());
      final results = await verifyAppointmentCodeUseCase(event.appointmentId, event.code);
      results.fold(
        (l) => emit(FailureVerifyAppointmentCodeState(message: l.message)),
        (r) => emit(SuccessVerifyAppointmentCodeState()),
      );
    });

    on<SearchEvent>((event, emit) {
      emit(SearchingState(isSearching: event.isSearching));
    });
  }

  @override
  ProviderState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('recentRequests')) {
        _recentRequests = (json['recentRequests'] as List)
            .map((e) => RequestData.fromJson(e))
            .toList();
      }
      if (json.containsKey('allRequests')) {
        _allRequests = (json['allRequests'] as List)
            .map((e) => RequestData.fromJson(e))
            .toList();
      }
      if (json.containsKey('myAcceptedRequests')) {
        _myAcceptedRequests = (json['myAcceptedRequests'] as List)
            .map((e) => RequestAcceptance.fromJson(e))
            .toList();
      }
      if (json.containsKey('appointments')) {
        _appointments = (json['appointments'] as List)
            .map((e) => AppointmentData.fromJson(e))
            .toList();
      }
      
      return SuccessGetRecentRequestState(myRequests: _recentRequests);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ProviderState state) {
    return {
      'recentRequests': _recentRequests.map((e) => e.toJson()).toList(),
      'allRequests': _allRequests.map((e) => e.toJson()).toList(),
      'myAcceptedRequests': _myAcceptedRequests.map((e) => e.toJson()).toList(),
      'appointments': _appointments.map((e) => e.toJson()).toList(),
    };
  }
}
