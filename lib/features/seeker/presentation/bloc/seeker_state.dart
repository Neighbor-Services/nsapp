part of 'seeker_bloc.dart';

abstract class SeekerState {}

class LoadingSeekerState extends SeekerState {}

class InitialSeekerState extends SeekerState {}

class NavigatorSeekerState extends SeekerState {
  static Widget lastWidget = const SeekerHomePage();
  static int lastPage = 1;
  final Widget widget;
  final int page;

  NavigatorSeekerState({this.widget = const SeekerHomePage(), this.page = 1}) {
    NavigatorSeekerState.lastWidget = widget;
    NavigatorSeekerState.lastPage = page;
  }
}

class SeekerVisitedPagesState extends SeekerState {
  static List<VisitedPages> lastPages = [];
  final List<VisitedPages> pages;
  SeekerVisitedPagesState({required this.pages}) {
    SeekerVisitedPagesState.lastPages = pages;
  }
}

class ImageSeekerState extends SeekerState {
  static XFile? lastPicture;
  final XFile? picture;
  ImageSeekerState({this.picture}) {
    ImageSeekerState.lastPicture = picture;
  }
}

class RequestPriceState extends SeekerState {
  final bool fixedPrice;
  RequestPriceState({required this.fixedPrice});
}

class SuccessCreateRequestState extends SeekerState {}

class SuccessGetMyRequestState extends SeekerState {
  static Future<List<RequestData>>? lastMyRequests;
  final Future<List<RequestData>>? myRequests;
  SuccessGetMyRequestState({this.myRequests}) {
    SuccessGetMyRequestState.lastMyRequests = myRequests;
  }
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
  static RequestData lastRequest = RequestData();
  final RequestData request;
  SeekerRequestDetailState({required this.request}) {
    SeekerRequestDetailState.lastRequest = request;
  }
}

class SuccessAcceptedUsersState extends SeekerState {
  static Future<List<RequestAcceptance>>? lastUsers;
  final Future<List<RequestAcceptance>>? users;
  SuccessAcceptedUsersState({this.users}) {
    SuccessAcceptedUsersState.lastUsers = users;
  }
}

class SuccessPopularProvidersState extends SeekerState {
  static Future<List<Profile>>? lastProviders;
  final Future<List<Profile>>? providers;
  SuccessPopularProvidersState({this.providers}) {
    SuccessPopularProvidersState.lastProviders = providers;
  }
}

class SuccessGetMyFavoritesState extends SeekerState {
  static Future<List<Favorite>>? lastProfiles;
  final Future<List<Favorite>>? profiles;
  SuccessGetMyFavoritesState({this.profiles}) {
    SuccessGetMyFavoritesState.lastProfiles = profiles;
  }
}

class SuccessGetMyFavoritesNoFutureState extends SeekerState {
  static List<Favorite> lastProfiles = [];
  final List<Favorite> profiles;
  SuccessGetMyFavoritesNoFutureState({required this.profiles}) {
    SuccessGetMyFavoritesNoFutureState.lastProfiles = profiles;
  }
}

class SuccessReloadRequestState extends SeekerState {
  static Future<RequestData>? lastRequest;
  final Future<RequestData>? request;
  SuccessReloadRequestState({this.request}) {
    SuccessReloadRequestState.lastRequest = request;
  }
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
  static Future<List<AppointmentData>>? lastAppointments;
  final Future<List<AppointmentData>>? appointments;
  SuccessGetAppointmentsState({this.appointments}) {
    SuccessGetAppointmentsState.lastAppointments = appointments;
  }
}

class SuccessSearchProviderState extends SeekerState {
  static Future<List<Profile>>? lastProviders;
  final Future<List<Profile>>? providers;
  SuccessSearchProviderState({this.providers}) {
    SuccessSearchProviderState.lastProviders = providers;
  }
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
  static Profile lastProfile = Profile();
  static String? lastProviderUserId;
  final Profile profile;
  final String? providerUserId;
  ProviderToReviewState({required this.profile, this.providerUserId}) {
    ProviderToReviewState.lastProfile = profile;
    ProviderToReviewState.lastProviderUserId = providerUserId;
  }
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
  static bool lastOthers = false;
  final bool others;
  OtherServiceSelectState({required this.others}) {
    OtherServiceSelectState.lastOthers = others;
  }
}

class SuccessMatchProvidersState extends SeekerState {
  static Future<List<Profile>>? lastProviders;
  final Future<List<Profile>>? providers;
  SuccessMatchProvidersState(this.providers) {
    SuccessMatchProvidersState.lastProviders = providers;
  }
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


