part of 'provider_bloc.dart';

sealed class ProviderEvent {}

class NavigateProviderEvent extends ProviderEvent {
  final Widget widget;
  final int page;

  NavigateProviderEvent({required this.page, required this.widget});
}

class GetRecentRequestEvent extends ProviderEvent {
  final double? lat;
  final double? lng;
  final double? radius;
  final int? page;

  GetRecentRequestEvent({this.lat, this.lng, this.radius, this.page});
}

class GetAcceptedRequestEvent extends ProviderEvent {}

class GetRequestsEvent extends ProviderEvent {
  final RequestData? requestData;
  final double? lat;
  final double? lng;
  final double? radius;
  final int? page;

  GetRequestsEvent({
    this.requestData,
    this.lat,
    this.lng,
    this.radius,
    this.page,
  });
}

class GetTargetedRequestsEvent extends ProviderEvent {
  final double? lat;
  final double? lng;
  final double? radius;
  final int? page;

  GetTargetedRequestsEvent({this.lat, this.lng, this.radius, this.page});
}

class ReloadEvent extends ProviderEvent {}

class RequestDetailEvent extends ProviderEvent {
  final RequestData request;

  RequestDetailEvent({required this.request});
}

class RequestDirectionEvent extends ProviderEvent {
  final Request request;

  RequestDirectionEvent({required this.request});
}

class CancelRequestAcceptEvent extends ProviderEvent {
  final RequestAccept requestAccept;

  CancelRequestAcceptEvent({required this.requestAccept});
}

class RequestAcceptEvent extends ProviderEvent {
  final RequestAccept requestAccept;

  RequestAcceptEvent({required this.requestAccept});
}

class ReloadProfileEvent extends ProviderEvent {
  final String request;

  ReloadProfileEvent({required this.request});
}

class AddAppointmentEvent extends ProviderEvent {
  final Appointment appointment;

  AddAppointmentEvent({required this.appointment});
}

class GetAppointmentsEvent extends ProviderEvent {}

class SearchRequestEvent extends ProviderEvent {
  final String? query;
  final double? lat;
  final double? lng;
  final double? radius;
  final int? page;
  final String? catalogServiceId;

  SearchRequestEvent({
    this.query,
    this.lat,
    this.lng,
    this.radius,
    this.page,
    this.catalogServiceId,
  });
}

class ProviderBackPressedEvent extends ProviderEvent {}

class SearchEvent extends ProviderEvent {
  final bool isSearching;

  SearchEvent({required this.isSearching});
}

class CancelAppointmentEvent extends ProviderEvent {
  final String id;

  CancelAppointmentEvent({required this.id});
}

class IsRequestAcceptedEvent extends ProviderEvent {
  final String id;

  IsRequestAcceptedEvent({required this.id});
}

class AddPortfolioItemEvent extends ProviderEvent {
  final File image;
  final String? description;

  AddPortfolioItemEvent({required this.image, this.description});
}

class AddServicePackageEvent extends ProviderEvent {
  final ServicePackage package;

  AddServicePackageEvent({required this.package});
}

class CompleteAppointmentEvent extends ProviderEvent {
  final String id;
  final double amount;

  CompleteAppointmentEvent({required this.id, required this.amount});
}

class UpdateProviderAppointmentEvent extends ProviderEvent {
  final Appointment appointment;

  UpdateProviderAppointmentEvent({required this.appointment});
}

class GetRequestDetailEvent extends ProviderEvent {
  final String id;
  GetRequestDetailEvent({required this.id});
}
