part of 'shared_bloc.dart';

abstract class SharedState {
  final bool isProvider;
  final ThemeMode themeMode;
  final bool usebiometric;

  SharedState({
    required this.isProvider,
    required this.themeMode,
    required this.usebiometric,
  });
}

class SharedInitialState extends SharedState {
  SharedInitialState({super.isProvider = false,
    super.themeMode = ThemeMode.system,
    super.usebiometric = false,
  });
}

class SharedLoadingState extends SharedState {
  SharedLoadingState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class DashboardState extends SharedState {
  DashboardState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class ThemeModeState extends SharedState {
  ThemeModeState({
    
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessAddNotificationsState extends SharedState {
  SuccessAddNotificationsState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureAddNotificationState extends SharedState {
  final String? message;
  FailureAddNotificationState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessGetMyNotificationsState extends SharedState {
  static int lastUnreadCount = 0;
  final Future<List<not.NotificationData>> notifications;
  final int unreadCount;

  SuccessGetMyNotificationsState({
    required this.notifications,
    required this.unreadCount,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  }) {
    SuccessGetMyNotificationsState.lastUnreadCount = unreadCount;
  }
}

class FailureGetMyNotificationsState extends SharedState {
  final String? message;
  FailureGetMyNotificationsState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessAddReportState extends SharedState {
  SuccessAddReportState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureAddReportState extends SharedState {
  final String? message;
  FailureAddReportState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessNotifyState extends SharedState {
  SuccessNotifyState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureNotifyState extends SharedState {
  final String? message;
  FailureNotifyState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class ViewImageState extends SharedState {
  static String lastUrl = "";
  final String url;
  ViewImageState({
    required this.url,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  }) {
    ViewImageState.lastUrl = url;
  }
}

class SuccessPlacesState extends SharedState {
  final List<MapPlaces> places;
  SuccessPlacesState({
    required this.places,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailurePlacesState extends SharedState {
  final String? message;
  FailurePlacesState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessPlaceState extends SharedState {
  final Place place;
  SuccessPlaceState({
    required this.place,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailurePlaceState extends SharedState {
  final String? message;
  FailurePlaceState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class MapLocationState extends SharedState {
  static LatLng lastLocation = const LatLng(0, 0);
  static String lastAddress = "";
  final LatLng location;
  final String address;
  MapLocationState({
    required this.location,
    required this.address,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  }) {
    MapLocationState.lastLocation = location;
    MapLocationState.lastAddress = address;
  }
}

class UseMapState extends SharedState {
  static bool lastUseMap = false;
  final bool useMap;
  UseMapState({
    required this.useMap,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  }) {
    UseMapState.lastUseMap = useMap;
  }
}

class UseBiometricState extends SharedState {
  UseBiometricState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class ValidUserSubscriptionState extends SharedState {
  final bool isValid;
  ValidUserSubscriptionState({
    required this.isValid,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessDeleteUserSubscriptionState extends SharedState {
  SuccessDeleteUserSubscriptionState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureDeleteUserSubscriptionState extends SharedState {
  final String? message;
  FailureDeleteUserSubscriptionState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessConnectAccountState extends SharedState {
  final AccountLink? accountLink;
  SuccessConnectAccountState({
    this.accountLink,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureConnectAccountState extends SharedState {
  final String? message;
  FailureConnectAccountState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessGetServicesState extends SharedState {
  static List<Service> lastServices = [];
  final List<Service> services;
  SuccessGetServicesState({
    required this.services,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  }) {
    SuccessGetServicesState.lastServices = services;
  }
}

class FailureGetServicesState extends SharedState {
  final String? message;
  FailureGetServicesState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureSetSeentState extends SharedState {
  final String? message;
  FailureSetSeentState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessSetSeentState extends SharedState {
  SuccessSetSeentState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureAddServiceState extends SharedState {
  final String? message;
  FailureAddServiceState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessAddServicesState extends SharedState {
  static String? lastId;
  final String? id;
  SuccessAddServicesState({
    this.id,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  }) {
    SuccessAddServicesState.lastId = id;
  }
}

class SuccessChangeUserTypeState extends SharedState {
  SuccessChangeUserTypeState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureChangeUserTypeState extends SharedState {
  final String? message;
  FailureChangeUserTypeState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class ReloadState extends SharedState {
  final String type;
  ReloadState({
    required this.type,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class GetTokenState extends SharedState {
  final String token;
  GetTokenState({
    required this.token,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessMakeSubscriptionState extends SharedState {
  SuccessMakeSubscriptionState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureMakeSubscriptionState extends SharedState {
  final String? message;
  FailureMakeSubscriptionState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessCreateDisputeState extends SharedState {
  SuccessCreateDisputeState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureCreateDisputeState extends SharedState {
  final String? message;
  FailureCreateDisputeState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessGetMyWalletState extends SharedState {
  final Wallet? wallet;
  SuccessGetMyWalletState({
    this.wallet,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureGetMyWalletState extends SharedState {
  final String? message;
  FailureGetMyWalletState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessRequestPayoutState extends SharedState {
  SuccessRequestPayoutState({
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureRequestPayoutState extends SharedState {
  final String? message;
  FailureRequestPayoutState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessGetSubscriptionPlansState extends SharedState {
  final List<SubscriptionPlan> plans;
  SuccessGetSubscriptionPlansState({
    required this.plans,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureGetSubscriptionPlansState extends SharedState {
  final String? message;
  FailureGetSubscriptionPlansState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessGetMyDisputesState extends SharedState {
  final List<Dispute> disputes;
  SuccessGetMyDisputesState({
    required this.disputes,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureGetMyDisputesState extends SharedState {
  final String? message;
  FailureGetMyDisputesState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessGetStripeDashboardLinkState extends SharedState {
  final String? dashboardUrl;
  SuccessGetStripeDashboardLinkState({
    this.dashboardUrl,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class FailureGetStripeDashboardLinkState extends SharedState {
  final String? message;
  FailureGetStripeDashboardLinkState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}

class SuccessGetLegalDocumentState extends SharedState {
  static List<LegalDocument> lastDocuments = [];
  final List<LegalDocument> documents;
  SuccessGetLegalDocumentState({
    required this.documents,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  }) {
    SuccessGetLegalDocumentState.lastDocuments = documents;
  }
}

class FailureGetLegalDocumentState extends SharedState {
  final String? message;
  FailureGetLegalDocumentState({
    this.message,
    required super.isProvider,
    required super.themeMode,
    required super.usebiometric,
  });
}


