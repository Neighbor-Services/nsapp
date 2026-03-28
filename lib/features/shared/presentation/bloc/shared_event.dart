part of 'shared_bloc.dart';

abstract class SharedEvent {}

class ToggleDashboardEvent extends SharedEvent {
  final bool isProvider;

  ToggleDashboardEvent({required this.isProvider});
}

class ToggleThemeModeEvent extends SharedEvent {
  final ThemeMode themeMode;

  ToggleThemeModeEvent({required this.themeMode});
}

class LoadThemeModeEvent extends SharedEvent {}

class AddNotificationEvent extends SharedEvent {
  final not.Notification notification;

  AddNotificationEvent({required this.notification});
}

class GetMyNotificationsEvent extends SharedEvent {}

class AddReportEvent extends SharedEvent {
  final Report report;

  AddReportEvent({required this.report});
}

class SendNotificationEvent extends SharedEvent {
  final Notify notify;

  SendNotificationEvent({required this.notify});
}

class SetViewImageEvent extends SharedEvent {
  final String url;

  SetViewImageEvent({required this.url});
}

class SearchPlaceEvent extends SharedEvent {
  final String placeId;

  SearchPlaceEvent({required this.placeId});
}

class SearchPlacesEvent extends SharedEvent {
  final String input;

  SearchPlacesEvent({required this.input});
}

class MapLocationEvent extends SharedEvent {
  final LatLng location;

  MapLocationEvent({required this.location});
}

class UseMapEvent extends SharedEvent {
  final bool useMap;

  UseMapEvent({required this.useMap});
}

class UseBiometricEvent extends SharedEvent {
  final bool usebiometric;

  UseBiometricEvent({required this.usebiometric});
}

class CheckUserSubscriptionEvent extends SharedEvent {}

class DeleteUserSubscriptionEvent extends SharedEvent {}

class CreateConnectAccountEvent extends SharedEvent {}

class GetServicesEvent extends SharedEvent {}

class SetNotificationSeenEvent extends SharedEvent {
  final String notificationID;

  SetNotificationSeenEvent({required this.notificationID});
}

class AddServiceEvent extends SharedEvent {
  final Service model;

  AddServiceEvent({required this.model});
}

class ChangeUserTypeEvent extends SharedEvent {
  final Map<String, String> type;

  ChangeUserTypeEvent(this.type);
}

class SharedBlocReloadEvent extends SharedEvent {
  String type;
  SharedBlocReloadEvent(this.type);
}

class ConnectNotificationSocketEvent extends SharedEvent {}

class DisconnectNotificationSocketEvent extends SharedEvent {}

class GetTokenEvent extends SharedEvent {}

class MakeSubscriptionEvent extends SharedEvent {
  final BuildContext context;
  final String planId;

  MakeSubscriptionEvent({required this.planId, required this.context});
}

class CreateDisputeEvent extends SharedEvent {
  final Dispute dispute;

  CreateDisputeEvent({required this.dispute});
}

class GetMyWalletEvent extends SharedEvent {}

class RequestPayoutEvent extends SharedEvent {
  final double amount;
  RequestPayoutEvent({required this.amount});
}

class GetSubscriptionPlansEvent extends SharedEvent {}

class GetMyDisputesEvent extends SharedEvent {}

class GetStripeDashboardLinkEvent extends SharedEvent {}

class GetLegalDocumentEvent extends SharedEvent {
  final String docType;
  GetLegalDocumentEvent({required this.docType});
}
