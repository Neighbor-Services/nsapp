part of 'shared_bloc.dart';

abstract class SharedState {}

class SharedInitialState extends SharedState {}

class SharedLoadingState extends SharedState {}

class DashboardState extends SharedState {
  static bool isProvider = false;
}

class ThemeModeState extends SharedState {
  static ThemeMode themeMode = ThemeMode.system;
}

class SuccessAddNotificationsState extends SharedState {}

class FailureAddNotificationState extends SharedState {}

class SuccessGetMyNotificationsState extends SharedState {
  static Future<List<not.NotificationData>>? notifications;
  static int unreadCount = 0;
}

class FailureGetMyNotificationsState extends SharedState {}

class SuccessAddReportState extends SharedState {}

class FailureAddReportState extends SharedState {}

class SuccessNotifyState extends SharedState {}

class FailureNotifyState extends SharedState {}

class ViewImageState extends SharedState {
  static String url = "";
}

class SuccessPlacesState extends SharedState {
  static List<MapPlaces> places = [];
}

class FailurePlacesState extends SharedState {}

class SuccessPlaceState extends SharedState {
  static Place places = Place();
}

class FailurePlaceState extends SharedState {}

class MapLocationState extends SharedState {
  static LatLng location = LatLng(
    locationData.latitude,
    locationData.longitude,
  );
  static String address = "";
}

class UseMapState extends SharedState {
  static bool useMap = false;
}

class UseBiometricState extends SharedState {
  static bool usebiometric = false;
}

class ValidUserSubscriptionState extends SharedState {
  static bool isValid = false;
}

class SuccessDeleteUserSubscriptionState extends SharedState {}

class FailureDeleteUserSubscriptionState extends SharedState {}

class SuccessConnectAccountState extends SharedState {
  static AccountLink? accountLink;
}

class FailureConnectAccountState extends SharedState {}

class SuccessGetServicesState extends SharedState {
  static List<Service> services = [];
}

class FailureGetServicesState extends SharedState {}

class FailureSetSeentState extends SharedState {}

class SuccessSetSeentState extends SharedState {}

class FailureAddServiceState extends SharedState {}

class SuccessAddServicesState extends SharedState {
  static String? id;
}

class SuccessChangeUserTypeState extends SharedState {}

class FailureChangeUserTypeState extends SharedState {}

class ReloadState extends SharedState {
  static String type = SuccessGetProfileState.profile.service ?? "";
}

class GetTokenState extends SharedState {
  static String token = "";
}

class SuccessMakeSubscriptionState extends SharedState {}

class FailureMakeSubscriptionState extends SharedState {}

class SuccessCreateDisputeState extends SharedState {}

class FailureCreateDisputeState extends SharedState {}

class SuccessGetMyWalletState extends SharedState {
  static Wallet? wallet;
}

class FailureGetMyWalletState extends SharedState {}

class SuccessRequestPayoutState extends SharedState {}

class FailureRequestPayoutState extends SharedState {}

class SuccessGetSubscriptionPlansState extends SharedState {
  static List<SubscriptionPlan> plans = [];
}

class FailureGetSubscriptionPlansState extends SharedState {}

class SuccessGetMyDisputesState extends SharedState {
  static List<Dispute> disputes = [];
}

class FailureGetMyDisputesState extends SharedState {}

class SuccessGetStripeDashboardLinkState extends SharedState {
  static String? dashboardUrl;
}

class FailureGetStripeDashboardLinkState extends SharedState {}
