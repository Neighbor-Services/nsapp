part of 'seeker_bloc.dart';

abstract class SeekerState {}

class LoadingSeekerState extends SeekerState {}

class InitialSeekerState extends SeekerState {}

class NavigatorSeekerState extends SeekerState {
  static Widget widget = const SeekerHomePage();
  static int page = 1;
}

class SeekerVisitedPagesState extends SeekerState {
  static List<VisitedPages> pages = [];
}

class ImageSeekerState extends SeekerState {
  static XFile? picture;
}

class RequestPriceState extends SeekerState {
  static bool fixedPrice = true;
}

class SuccessCreateRequestState extends SeekerState {}

class SuccessGetMyRequestState extends SeekerState {
  List<RequestData> req = [];
  static Future<List<RequestData>>? myRequests;
}

class FailureCreateRequestState extends SeekerState {}

class FailureGetMyFavoritesState extends SeekerState {}

class FailureAcceptedUserstState extends SeekerState {}

class SeekerRequestDetailState extends SeekerState {
  static RequestData request = RequestData();
}

class SuccessAcceptedUsersState extends SeekerState {
  static Future<List<RequestAcceptance>>? users;
}

class SuccessPopularProvidersState extends SeekerState {
  static Future<List<Profile>>? providers;
}

class SuccessGetMyFavoritesState extends SeekerState {
  static Future<List<Favorite>>? profiles;
}

class SuccessGetMyFavoritesNoFutureState extends SeekerState {
  static List<Favorite> profiles = [];
}

class SuccessReloadRequestState extends SeekerState {
  static Future<RequestData>? request;
}

class SuccessApprovedProviderState extends SeekerState {}

class FailureApprovedProviderState extends SeekerState {}

class FailureReloadRequestState extends SeekerState {}

class FailurePopularProviderState extends SeekerState {}

class SuccessCancelApprovedProviderState extends SeekerState {}

class FailureCancelApprovedProviderState extends SeekerState {}

class SuccessDeleteRequestState extends SeekerState {}

class FailureDeleteRequestState extends SeekerState {}

class SuccessUpdateRequestState extends SeekerState {}

class FailureUpdateRequestState extends SeekerState {}

class RequestLocationChangeState extends SeekerState {
  static bool change = false;
}

class SuccessAddToFavoriteState extends SeekerState {}

class FailureAddToFavoriteState extends SeekerState {}

class SuccessRemoveFromFavoriteState extends SeekerState {}

class FailureRemoveFromFavoriteState extends SeekerState {}

class FailureSearchProviderState extends SeekerState {}

class SuccessGetAppointmentsState extends SeekerState {
  static Future<List<AppointmentData>>? appointments;
}

class SuccessSearchProviderState extends SeekerState {
  static Future<List<Profile>>? providers;
}

class FailureGetAppointmentState extends SeekerState {}

class SearchingState extends SeekerState {
  static bool isSearching = false;
}

class SuccessMarkAsDoneState extends SeekerState {}

class FailureMarkAsDoneState extends SeekerState {}

class ReviewProviderState extends SeekerState {
  static bool canReview = false;
}

class RatingValueState extends SeekerState {
  static double rate = 2.0;
}

class ProviderToReviewState extends SeekerState {
  static Profile profile = Profile();
  static String? providerUserId;
}

class SuccessRateState extends SeekerState {}

class FailureRateState extends SeekerState {}

class ClearImageState extends SeekerState {}

class SuccessCancelAppointmentState extends SeekerState {}

class FailureCancelAppointmentState extends SeekerState {}

class ResetImageState extends SeekerState {}

class OtherServiceSelectState extends SeekerState {
  static bool others = false;
}

class SuccessMatchProvidersState extends SeekerState {
  final Future<List<Profile>>? providers;
  SuccessMatchProvidersState(this.providers);
}

class FailureMatchProvidersState extends SeekerState {}

class SuccessCompleteAppointmentState extends SeekerState {}

class SuccessUpdateAppointmentState extends SeekerState {}

class FailureUpdateAppointmentState extends SeekerState {}

class FailureCompleteAppointmentState extends SeekerState {}
