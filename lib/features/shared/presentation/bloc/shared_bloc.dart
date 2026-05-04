import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/initialize/init.dart';
import 'package:nsapp/core/models/account_link.dart';
import 'package:nsapp/core/models/map_places.dart';
import 'package:nsapp/core/models/notification.dart' as not;
import 'package:nsapp/core/models/notify.dart';
import 'package:nsapp/core/models/place.dart';
import 'package:nsapp/core/models/report.dart';
import 'package:nsapp/core/models/services_model.dart';
import 'package:nsapp/features/shared/domain/usecase/add_notification_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/add_report_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/add_service_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/change_user_type_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_notifications_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_services_usecase.dart';
import 'package:nsapp/features/shared/domain/usecase/search_place_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/search_places_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/set_seen_notification_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/create_dispute_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_wallet_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/request_payout_use_case.dart';
import 'package:nsapp/core/services/notification_socket_service.dart';
import 'package:nsapp/core/models/dispute.dart';
import 'package:nsapp/core/models/legal_document.dart';
import 'package:nsapp/core/models/wallet.dart';
import 'package:nsapp/core/models/subscription_plan.dart';
import 'package:nsapp/features/shared/domain/usecase/get_subscription_plans_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_my_disputes_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_stripe_dashboard_link_use_case.dart';
import 'package:nsapp/features/shared/domain/usecase/get_legal_document_use_case.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'shared_event.dart';
part 'shared_state.dart';

class SharedBloc extends HydratedBloc<SharedEvent, SharedState> {
  final AddNotificationUseCase addNotificationUseCase;
  final GetMyNotificationsUseCase getMyNotificationsUseCase;
  final AddReportUseCase addReportUseCase;
  final SearchPlaceUseCase searchPlaceUseCase;
  final SearchPlacesUseCase searchPlacesUseCase;
  final GetServicesUsecase getServicesUsecase;
  final SetSeenNotificationUseCase seenNotificationUseCase;
  final AddServiceUseCase addServiceUseCase;
  final ChangeUserTypeUseCase changeUserTypeUseCase;

  final NotificationSocketService notificationSocketService;
  final CreateDisputeUseCase createDisputeUseCase;
  final GetMyWalletUseCase getMyWalletUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;
  final GetSubscriptionPlansUseCase getSubscriptionPlansUseCase;
  final GetMyDisputesUseCase getMyDisputesUseCase;
  final GetStripeDashboardLinkUseCase getStripeDashboardLinkUseCase;
  final GetLegalDocumentUseCase getLegalDocumentUseCase;

  // Internal state tracking
  bool _isProvider = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _usebiometric = false;
  

  SharedBloc(
    this.addNotificationUseCase,
    this.getMyNotificationsUseCase,
    this.addReportUseCase,
    this.searchPlaceUseCase,
    this.searchPlacesUseCase,
    this.getServicesUsecase,
    this.seenNotificationUseCase,
    this.addServiceUseCase,
    this.changeUserTypeUseCase,
    this.notificationSocketService,
    this.createDisputeUseCase,
    this.getMyWalletUseCase,
    this.requestPayoutUseCase,
    this.getSubscriptionPlansUseCase,
    this.getMyDisputesUseCase,
    this.getStripeDashboardLinkUseCase,
    this.getLegalDocumentUseCase,
  ) : super(SharedInitialState()) {
    
    on<ToggleDashboardEvent>((event, emit) {
      _isProvider = event.isProvider;
      emit(DashboardState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<ToggleThemeModeEvent>((event, emit) async {
      final isDark = event.themeMode == ThemeMode.dark;
      final isSuccess = await Helpers.saveBool("darkmode", isDark);
      if (isSuccess) {
        _themeMode = event.themeMode;
      }
      emit(ThemeModeState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<LoadThemeModeEvent>((event, emit) async {
      final prefsInstance = await prefs;
      final isDark = prefsInstance.getBool("darkmode");
      if (isDark == true) {
        _themeMode = ThemeMode.dark;
      } else if (isDark == false) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
      emit(ThemeModeState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<AddNotificationEvent>((event, emit) async {
      final results = await addNotificationUseCase(event.notification);
      results.fold(
        (l) => emit(FailureAddNotificationState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessAddNotificationsState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<AddReportEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await addReportUseCase(event.report);
      results.fold(
        (l) => emit(FailureAddReportState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessAddReportState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<SearchPlaceEvent>((event, emit) async {
      final results = await searchPlaceUseCase(event.placeId);
      results.fold(
        (l) => emit(FailurePlaceState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessPlaceState(
          place: r,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<SearchPlacesEvent>((event, emit) async {
      final results = await searchPlacesUseCase(event.input);
      results.fold(
        (l) => emit(FailurePlacesState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessPlacesState(
          places: r,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<GetMyNotificationsEvent>((event, emit) async {
      final results = await getMyNotificationsUseCase(event);
      results.fold(
        (l) => emit(FailureGetMyNotificationsState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) {
          emit(SuccessGetMyNotificationsState(
            notifications: r,
            unreadCount: r.where((n) => n.notification?.isRead == false).length,
            isProvider: _isProvider,
            themeMode: _themeMode,
            usebiometric: _usebiometric,
          ));
        },
      );
    }, transformer: sequential());

    on<SetViewImageEvent>((event, emit) {
      emit(ViewImageState(
        url: event.url,
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<UseMapEvent>((event, emit) {
      emit(UseMapState(
        useMap: event.useMap,
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<MapLocationEvent>((event, emit) async {
      final address = await Helpers.getAddressFromMap(event.location);
      emit(MapLocationState(
        location: event.location,
        address: address,
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<UseBiometricEvent>((event, emit) async {
      final bool isSuccess = await Helpers.saveBool("usebiometric", event.usebiometric);
      if (isSuccess) {
        _usebiometric = event.usebiometric;
      }
      emit(UseBiometricState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<CheckUserSubscriptionEvent>((event, emit) async {
      final bool isValid = await Helpers.userHasTheValidSubscription();
      emit(ValidUserSubscriptionState(
        isValid: isValid,
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<DeleteUserSubscriptionEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final bool isValid = await Helpers.deleteUserSubscriptionDetails();
      if (isValid) {
        emit(SuccessDeleteUserSubscriptionState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        ));
      } else {
        emit(FailureDeleteUserSubscriptionState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        ));
      }
    });

    on<CreateConnectAccountEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final account = await Payment.createAccountLink();
      if (account != null) {
        emit(SuccessConnectAccountState(
          accountLink: account,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        ));
      } else {
        emit(FailureConnectAccountState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        ));
      }
    });

    on<GetServicesEvent>((event, emit) async {
      final results = await getServicesUsecase(event);
      results.fold(
        (l) => emit(FailureGetServicesState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) {
          emit(SuccessGetServicesState(
            services: r,
            isProvider: _isProvider,
            themeMode: _themeMode,
            usebiometric: _usebiometric,
          ));
        },
      );
    });

    on<SetNotificationSeenEvent>((event, emit) async {
      final results = await seenNotificationUseCase(event.notificationID);
      results.fold(
        (l) => emit(FailureSetSeentState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) {
          add(GetMyNotificationsEvent());
          emit(SuccessSetSeentState(
            isProvider: _isProvider,
            themeMode: _themeMode,
            usebiometric: _usebiometric,
          ));
        },
      );
    });

    on<AddServiceEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await addServiceUseCase(event.model);
      results.fold(
        (l) => emit(FailureAddServiceState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) {
          add(GetServicesEvent());
          emit(SuccessAddServicesState(
            id: r,
            isProvider: _isProvider,
            themeMode: _themeMode,
            usebiometric: _usebiometric,
          ));
        },
      );
    });

    on<ChangeUserTypeEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await changeUserTypeUseCase(event.type);
      results.fold(
        (l) => emit(FailureChangeUserTypeState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessChangeUserTypeState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<SharedBlocReloadEvent>((event, emit) {
      emit(ReloadState(
        type: event.type,
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<GetTokenEvent>((event, emit) async {
      final token = await Helpers.getToken();
      emit(GetTokenState(
        token: token,
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
    });

    on<MakeSubscriptionEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final success = await Payment.createSubscription(event.context, event.planId);
      if (success) {
        emit(SuccessMakeSubscriptionState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        ));
      } else {
        emit(FailureMakeSubscriptionState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        ));
      }
    });

    on<ConnectNotificationSocketEvent>((event, emit) async {
      await notificationSocketService.connect();
    });

    on<DisconnectNotificationSocketEvent>((event, emit) {
      notificationSocketService.disconnect();
    });

    on<CreateDisputeEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await createDisputeUseCase(event.dispute);
      results.fold(
        (l) => emit(FailureCreateDisputeState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessCreateDisputeState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<GetMyWalletEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await getMyWalletUseCase();
      results.fold(
        (l) => emit(FailureGetMyWalletState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) {
          emit(SuccessGetMyWalletState(
            wallet: r,
            isProvider: _isProvider,
            themeMode: _themeMode,
            usebiometric: _usebiometric,
          ));
        },
      );
    });

    on<RequestPayoutEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await requestPayoutUseCase(event.amount);
      results.fold(
        (l) => emit(FailureRequestPayoutState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessRequestPayoutState(
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<GetSubscriptionPlansEvent>((event, emit) async {
      final results = await getSubscriptionPlansUseCase();
      results.fold(
        (l) => emit(FailureGetSubscriptionPlansState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) {
          emit(SuccessGetSubscriptionPlansState(
            plans: r,
            isProvider: _isProvider,
            themeMode: _themeMode,
            usebiometric: _usebiometric,
          ));
        },
      );
    });

    on<GetMyDisputesEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await getMyDisputesUseCase(event);
      results.fold(
        (l) => emit(FailureGetMyDisputesState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessGetMyDisputesState(
          disputes: r,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<GetStripeDashboardLinkEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await getStripeDashboardLinkUseCase();
      results.fold(
        (l) => emit(FailureGetStripeDashboardLinkState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessGetStripeDashboardLinkState(
          dashboardUrl: r,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });

    on<GetLegalDocumentEvent>((event, emit) async {
      emit(SharedLoadingState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      ));
      final results = await getLegalDocumentUseCase(event.docType);
      results.fold(
        (l) => emit(FailureGetLegalDocumentState(
          message: l.message,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
        (r) => emit(SuccessGetLegalDocumentState(
          documents: r,
          isProvider: _isProvider,
          themeMode: _themeMode,
          usebiometric: _usebiometric,
        )),
      );
    });
  }

  @override
  SharedState? fromJson(Map<String, dynamic> json) {
    try {
      if (json.containsKey('isProvider')) _isProvider = json['isProvider'];
      if (json.containsKey('themeMode')) _themeMode = ThemeMode.values[json['themeMode']];
      if (json.containsKey('usebiometric')) _usebiometric = json['usebiometric'];
      return SharedInitialState(
        isProvider: _isProvider,
        themeMode: _themeMode,
        usebiometric: _usebiometric,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(SharedState state) {
    return {
      'isProvider': _isProvider,
      'themeMode': _themeMode.index,
      'usebiometric': _usebiometric,
    };
  }
}
