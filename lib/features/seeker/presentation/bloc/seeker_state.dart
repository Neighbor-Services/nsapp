part of 'seeker_bloc.dart';

sealed class SeekerState {}

class LoadingSeekerState extends SeekerState {}

class InitialSeekerState extends SeekerState {}

class NavigatorSeekerState extends SeekerState {
  final Widget widget;
  final int page;

  NavigatorSeekerState({this.widget = const SeekerHomePage(), this.page = 1});
}

class SeekerVisitedPagesState extends SeekerState {
  final List<VisitedPages> pages;
  SeekerVisitedPagesState({required this.pages});
}

class ImageSeekerState extends SeekerState {
  final XFile? picture;
  ImageSeekerState({this.picture});
}

class RequestPriceState extends SeekerState {
  final bool fixedPrice;
  RequestPriceState({required this.fixedPrice});
}

class SuccessCreateRequestState extends SeekerState {}

class SuccessGetMyRequestState extends SeekerState {
  final List<RequestData> myRequests;
  SuccessGetMyRequestState({required this.myRequests});
}

class FailureCreateRequestState extends SeekerState {
  final String? message;
  FailureCreateRequestState({this.message});
}

class FailureGetMyFavoritesState extends SeekerState {
  final String? message;
  FailureGetMyFavoritesState({this.message});
}

class FailureAcceptedUserstState extends SeekerState {
  final String? message;
  FailureAcceptedUserstState({this.message});
}

class SeekerRequestDetailState extends SeekerState {
  final RequestData request;
  SeekerRequestDetailState({required this.request});
}

class SuccessAcceptedUsersState extends SeekerState {
  final List<RequestAcceptance> users;
  SuccessAcceptedUsersState({required this.users});
}

class SuccessPopularProvidersState extends SeekerState {
  final List<Profile> providers;
  SuccessPopularProvidersState({required this.providers});
}

class SuccessGetMyFavoritesState extends SeekerState {
  final List<Favorite> profiles;
  SuccessGetMyFavoritesState({required this.profiles});
}

class SuccessReloadRequestState extends SeekerState {
  final RequestData request;
  SuccessReloadRequestState({required this.request});
}

class SuccessApprovedProviderState extends SeekerState {}

class FailureApprovedProviderState extends SeekerState {
  final String? message;
  FailureApprovedProviderState({this.message});
}

class FailureReloadRequestState extends SeekerState {
  final String? message;
  FailureReloadRequestState({this.message});
}

class FailurePopularProviderState extends SeekerState {
  final String? message;
  FailurePopularProviderState({this.message});
}

class SuccessCancelApprovedProviderState extends SeekerState {}

class FailureCancelApprovedProviderState extends SeekerState {
  final String? message;
  FailureCancelApprovedProviderState({this.message});
}

class SuccessDeleteRequestState extends SeekerState {}

class FailureDeleteRequestState extends SeekerState {
  final String? message;
  FailureDeleteRequestState({this.message});
}

class SuccessUpdateRequestState extends SeekerState {}

class FailureUpdateRequestState extends SeekerState {
  final String? message;
  FailureUpdateRequestState({this.message});
}

class RequestLocationChangeState extends SeekerState {
  final bool change;
  RequestLocationChangeState({required this.change});
}

class SuccessAddToFavoriteState extends SeekerState {}

class FailureAddToFavoriteState extends SeekerState {
  final String? message;
  FailureAddToFavoriteState({this.message});
}

class SuccessRemoveFromFavoriteState extends SeekerState {}

class FailureRemoveFromFavoriteState extends SeekerState {
  final String? message;
  FailureRemoveFromFavoriteState({this.message});
}

class FailureSearchProviderState extends SeekerState {
  final String? message;
  FailureSearchProviderState({this.message});
}

class SuccessGetAppointmentsState extends SeekerState {
  final List<AppointmentData> appointments;
  SuccessGetAppointmentsState({required this.appointments});
}

class SuccessSearchProviderState extends SeekerState {
  final List<Profile> providers;
  SuccessSearchProviderState({required this.providers});
}

class FailureGetAppointmentState extends SeekerState {
  final String? message;
  FailureGetAppointmentState({this.message});
}

class SearchingState extends SeekerState {
  final bool isSearching;
  SearchingState({required this.isSearching});
}

class SuccessMarkAsDoneState extends SeekerState {}

class FailureMarkAsDoneState extends SeekerState {
  final String? message;
  FailureMarkAsDoneState({this.message});
}

class ReviewProviderState extends SeekerState {
  final bool canReview;
  ReviewProviderState({required this.canReview});
}

class RatingValueState extends SeekerState {
  final double rate;
  RatingValueState({required this.rate});
}

class ProviderToReviewState extends SeekerState {
  final Profile profile;
  final String? providerUserId;
  ProviderToReviewState({required this.profile, this.providerUserId});
}

class SuccessRateState extends SeekerState {}

class FailureRateState extends SeekerState {
  final String? message;
  FailureRateState({this.message});
}

class ClearImageState extends SeekerState {}

class SuccessCancelAppointmentState extends SeekerState {}

class FailureCancelAppointmentState extends SeekerState {
  final String? message;
  FailureCancelAppointmentState({this.message});
}

class ResetImageState extends SeekerState {}

class OtherServiceSelectState extends SeekerState {
  final bool others;
  OtherServiceSelectState({required this.others});
}

class SuccessMatchProvidersState extends SeekerState {
  final List<Profile> providers;
  SuccessMatchProvidersState({required this.providers});
}

class FailureMatchProvidersState extends SeekerState {
  final String? message;
  FailureMatchProvidersState({this.message});
}

class SuccessCompleteAppointmentState extends SeekerState {}

class SuccessUpdateAppointmentState extends SeekerState {}

class FailureUpdateAppointmentState extends SeekerState {
  final String? message;
  FailureUpdateAppointmentState({this.message});
}

class FailureCompleteAppointmentState extends SeekerState {
  final String? message;
  FailureCompleteAppointmentState({this.message});
}
