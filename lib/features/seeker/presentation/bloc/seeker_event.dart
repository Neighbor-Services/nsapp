part of 'seeker_bloc.dart';

abstract class SeekerEvent {}

class NavigateSeekerEvent extends SeekerEvent {
  final Widget widget;
  final int page;

  NavigateSeekerEvent({required this.page, required this.widget});
}

class RequestPriceEvent extends SeekerEvent {
  final bool fixedPrice;

  RequestPriceEvent({required this.fixedPrice});
}

class CreateRequestEvent extends SeekerEvent {
  final Request request;

  CreateRequestEvent({required this.request});
}

class SelectImageFromCameraEvent extends SeekerEvent {}

class SelectImageFromGalleryEvent extends SeekerEvent {}

class ResetImageEvent extends SeekerEvent {}

class GetMyRequestEvent extends SeekerEvent {}

class GetMyFavoritesEvent extends SeekerEvent {}

class GetPopularProvidersEvent extends SeekerEvent {}

class SeekerRequestDetailEvent extends SeekerEvent {
  final RequestData request;

  SeekerRequestDetailEvent({required this.request});
}

class GetAcceptedUsersSeekerEvent extends SeekerEvent {
  final String request;

  GetAcceptedUsersSeekerEvent({required this.request});
}

class ApprovedRequestEvent extends SeekerEvent {
  final RequestAccept requestAccept;

  ApprovedRequestEvent({required this.requestAccept});
}

class ReloadRequestEvent extends SeekerEvent {
  final String request;

  ReloadRequestEvent({required this.request});
}

class CancelApprovedRequestEvent extends SeekerEvent {
  final String request;

  CancelApprovedRequestEvent({required this.request});
}

class DeleteRequestEvent extends SeekerEvent {
  final String request;

  DeleteRequestEvent({required this.request});
}

class UpdateRequestEvent extends SeekerEvent {
  final Request request;

  UpdateRequestEvent({required this.request});
}

class ChangeLocationEvent extends SeekerEvent {
  final bool change;

  ChangeLocationEvent({required this.change});
}

class AddToFavoriteEvent extends SeekerEvent {
  final String userId;

  AddToFavoriteEvent({required this.userId});
}

class RemoveFromFavoriteEvent extends SeekerEvent {
  final String userId;

  RemoveFromFavoriteEvent({required this.userId});
}

class SeekerBackPressedEvent extends SeekerEvent {}

class SeekerReloadEvent extends SeekerEvent {}

class GetAppointmentsEvent extends SeekerEvent {}

class SearchProviderEvent extends SeekerEvent {
  final double? ratingMin;
  final double? priceMin;
  final double? priceMax;
  final String? categoryName;
  final String? serviceName;
  final String? city;

  SearchProviderEvent({
    this.ratingMin,
    this.priceMin,
    this.priceMax,
    this.categoryName,
    this.serviceName,
    this.city,
  });
}

class SearchEvent extends SeekerEvent {
  final bool isSearching;

  SearchEvent({required this.isSearching});
}

class MarkAsDoneEvent extends SeekerEvent {
  final Request request;

  MarkAsDoneEvent({required this.request});
}

class ReviewProviderEvent extends SeekerEvent {
  final bool canWriteReview;

  ReviewProviderEvent({required this.canWriteReview});
}

class SetRatingValueEvent extends SeekerEvent {
  final double rate;

  SetRatingValueEvent({required this.rate});
}

class SetProviderToReviewEvent extends SeekerEvent {
  final Profile provider;
  final String? providerUserId;

  SetProviderToReviewEvent({required this.provider, this.providerUserId});
}

class RateEvent extends SeekerEvent {
  final Rate rate;

  RateEvent({required this.rate});
}

class ClearImageEvent extends SeekerEvent {}

class CancelAppointmentEvent extends SeekerEvent {
  final String id;

  CancelAppointmentEvent({required this.id});
}

class ChooseOtherServiceEvent extends SeekerEvent {
  final bool other;

  ChooseOtherServiceEvent({required this.other});
}

class MatchProvidersEvent extends SeekerEvent {
  final String description;

  MatchProvidersEvent({required this.description});
}

class CompleteAppointmentEvent extends SeekerEvent {
  final String id;
  final double amount;

  CompleteAppointmentEvent({required this.id, required this.amount});
}

class UpdateSeekerAppointmentEvent extends SeekerEvent {
  final Appointment appointment;

  UpdateSeekerAppointmentEvent({required this.appointment});
}
