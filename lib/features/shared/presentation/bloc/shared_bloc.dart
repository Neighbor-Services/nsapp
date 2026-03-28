import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:nsapp/features/profile/presentation/bloc/profile_bloc.dart';
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

part 'shared_event.dart';
part 'shared_state.dart';

class SharedBloc extends Bloc<SharedEvent, SharedState> {
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
      DashboardState.isProvider = event.isProvider;
      emit(DashboardState());
    });
    on<ToggleThemeModeEvent>((event, emit) async {
      if (event.themeMode == ThemeMode.dark) {
        final isSuccess = await Helpers.saveBool("darkmode", true);
        if (isSuccess) {
          ThemeModeState.themeMode = event.themeMode;
        }
      } else {
        final isSuccess = await Helpers.saveBool("darkmode", false);
        if (isSuccess) {
          ThemeModeState.themeMode = event.themeMode;
        }
      }
      emit(ThemeModeState());
    });
    on<LoadThemeModeEvent>((event, emit) async {
      final prefsInstance = await prefs;
      final isDark = prefsInstance.getBool("darkmode");
      if (isDark == true) {
        ThemeModeState.themeMode = ThemeMode.dark;
      } else if (isDark == false) {
        ThemeModeState.themeMode = ThemeMode.light;
      } else {
        ThemeModeState.themeMode = ThemeMode.system;
      }
      emit(ThemeModeState());
    });
    on<AddNotificationEvent>((event, emit) async {
      final results = await addNotificationUseCase(event.notification);
      results.fold(
        (l) => emit(FailureAddNotificationState()),
        (r) => emit(SuccessAddNotificationsState()),
      );
    });

    on<AddReportEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await addReportUseCase(event.report);
      results.fold(
        (l) => emit(FailureAddReportState()),
        (r) => emit(SuccessAddReportState()),
      );
    });

    on<SearchPlaceEvent>((event, emit) async {
      final results = await searchPlaceUseCase(event.placeId);
      results.fold((l) => emit(FailurePlaceState()), (r) {
        SuccessPlaceState.places = r;
        emit(SuccessPlaceState());
      });
    });

    on<SearchPlacesEvent>((event, emit) async {
      final results = await searchPlacesUseCase(event.input);
      results.fold((l) => emit(FailurePlacesState()), (r) {
        SuccessPlacesState.places = r;
        emit(SuccessPlacesState());
      });
    });

    on<GetMyNotificationsEvent>((event, emit) async {
      final results = await getMyNotificationsUseCase(event);
      results.fold(
        (l) {
          SuccessGetMyNotificationsState.notifications = Future.value([]);
          emit(FailureGetMyNotificationsState());
        },
        (r) {
          SuccessGetMyNotificationsState.notifications = Future.value(r);
          SuccessGetMyNotificationsState.unreadCount = r
              .where((n) => n.notification?.isRead == false)
              .length;
          emit(SuccessGetMyNotificationsState());
        },
      );
    }, transformer: sequential());
    on<SetViewImageEvent>((event, emit) {
      ViewImageState.url = event.url;
      emit(ViewImageState());
    });
    on<UseMapEvent>((event, emit) {
      UseMapState.useMap = event.useMap;
      emit(UseMapState());
    });
    on<MapLocationEvent>((event, emit) async {
      MapLocationState.location = event.location;
      MapLocationState.address = await Helpers.getAddressFromMap(
        event.location,
      );
      emit(MapLocationState());
    });

    on<UseBiometricEvent>((event, emit) async {
      final bool isSuccess = await Helpers.saveBool(
        "usebiometric",
        event.usebiometric,
      );
      if (isSuccess) {
        UseBiometricState.usebiometric = event.usebiometric;
      }
      emit(UseBiometricState());
    });
    on<CheckUserSubscriptionEvent>((event, emit) async {
      final bool isValid = await Helpers.userHasTheValidSubscription();
      ValidUserSubscriptionState.isValid = isValid;
      emit(ValidUserSubscriptionState());
    });
    on<DeleteUserSubscriptionEvent>((event, emit) async {
      emit(SharedLoadingState());
      final bool isValid = await Helpers.deleteUserSubscriptionDetails();
      if (isValid) {
        emit(SuccessDeleteUserSubscriptionState());
        return;
      }
      return emit(FailureDeleteUserSubscriptionState());
    });
    on<CreateConnectAccountEvent>((event, emit) async {
      emit(SharedLoadingState());
      final account = await Payment.createAccountLink();
      if (account != null) {
        SuccessConnectAccountState.accountLink = account;
        emit(SuccessConnectAccountState());
        return;
      }
      return emit(FailureConnectAccountState());
    });

    on<GetServicesEvent>((event, emit) async {
      final results = await getServicesUsecase(event);
      results.fold((l) => emit(FailureGetServicesState()), (r) {
        SuccessGetServicesState.services = r;
        emit(SuccessGetServicesState());
      });
    });
    on<SetNotificationSeenEvent>((event, emit) async {
      final results = await seenNotificationUseCase(event.notificationID);
      results.fold((l) => emit(FailureSetSeentState()), (r) {
        add(GetMyNotificationsEvent());
        emit(SuccessSetSeentState());
      });
    });
    on<AddServiceEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await addServiceUseCase(event.model);
      results.fold((l) => emit(FailureAddServiceState()), (r) {
        SuccessAddServicesState.id = r;
        add(GetServicesEvent());
        emit(SuccessAddServicesState());
      });
    });
    on<ChangeUserTypeEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await changeUserTypeUseCase(event.type);
      results.fold(
        (l) => emit(FailureChangeUserTypeState()),
        (r) => emit(SuccessChangeUserTypeState()),
      );
    });
    on<SharedBlocReloadEvent>((event, emit) async {
      ReloadState.type = event.type;
      emit(ReloadState());
    });
    on<GetTokenEvent>((event, emit) async {
      final token = await Helpers.getToken();
      GetTokenState.token = token;
      emit(GetTokenState());
    });
    on<MakeSubscriptionEvent>((event, emit) async {
      emit(SharedLoadingState());
      final success = await Payment.createSubscription(
        event.context,
        event.planId,
      );
      if (success) {
        emit(SuccessMakeSubscriptionState());
      } else {
        emit(FailureMakeSubscriptionState());
      }
    });
    on<ConnectNotificationSocketEvent>((event, emit) async {
      await notificationSocketService.connect();
    });
    on<DisconnectNotificationSocketEvent>((event, emit) {
      notificationSocketService.disconnect();
    });
    on<CreateDisputeEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await createDisputeUseCase(event.dispute);
      results.fold(
        (l) => emit(FailureCreateDisputeState()),
        (r) => emit(SuccessCreateDisputeState()),
      );
    });

    on<GetMyWalletEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await getMyWalletUseCase();
      results.fold((l) => emit(FailureGetMyWalletState()), (r) {
        SuccessGetMyWalletState.wallet = r;
        emit(SuccessGetMyWalletState());
      });
    });

    on<RequestPayoutEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await requestPayoutUseCase(event.amount);
      results.fold(
        (l) => emit(FailureRequestPayoutState()),
        (r) => emit(SuccessRequestPayoutState()),
      );
    });

    on<GetSubscriptionPlansEvent>((event, emit) async {
      final results = await getSubscriptionPlansUseCase();
      results.fold((l) => emit(FailureGetSubscriptionPlansState()), (r) {
        SuccessGetSubscriptionPlansState.plans = r;
        emit(SuccessGetSubscriptionPlansState());
      });
    });

    on<GetMyDisputesEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await getMyDisputesUseCase(event);
      results.fold((l) => emit(FailureGetMyDisputesState()), (r) {
        SuccessGetMyDisputesState.disputes = r;
        emit(SuccessGetMyDisputesState());
      });
    });

    on<GetStripeDashboardLinkEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await getStripeDashboardLinkUseCase();
      results.fold((l) => emit(FailureGetStripeDashboardLinkState()), (r) {
        SuccessGetStripeDashboardLinkState.dashboardUrl = r;
        emit(SuccessGetStripeDashboardLinkState());
      });
    });

    on<GetLegalDocumentEvent>((event, emit) async {
      emit(SharedLoadingState());
      final results = await getLegalDocumentUseCase(event.docType);
      results.fold((l) => emit(FailureGetLegalDocumentState()), (r) {
        SuccessGetLegalDocumentState.documents = r;
        emit(SuccessGetLegalDocumentState());
      });
    });
  }
}
