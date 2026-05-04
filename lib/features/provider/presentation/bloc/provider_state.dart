part of 'provider_bloc.dart';

sealed class ProviderState {}

final class ProviderInitial extends ProviderState {}

final class LoadingProviderState extends ProviderState {}

class NavigatorProviderState extends ProviderState {
  static Widget lastWidget = const ProviderHomePage();
  static int lastPage = 1;
  final Widget widget;
  final int page;

  NavigatorProviderState({this.widget = const ProviderHomePage(), this.page = 1}) {
    NavigatorProviderState.lastWidget = widget;
    NavigatorProviderState.lastPage = page;
  }
}

class ProviderVisitedPagesState extends ProviderState {
  static List<VisitedPages> lastPages = [];
  final List<VisitedPages> pages;
  ProviderVisitedPagesState({required this.pages}) {
    ProviderVisitedPagesState.lastPages = pages;
  }
}

class SuccessGetRecentRequestState extends ProviderState {
  static Future<List<RequestData>>? lastMyRequests;
  final Future<List<RequestData>> myRequests;
  SuccessGetRecentRequestState({required this.myRequests}) {
    SuccessGetRecentRequestState.lastMyRequests = myRequests;
  }
}

class SuccessGetAcceptRequestState extends ProviderState {
  static Future<List<RequestAcceptance>>? lastAccepts;
  final Future<List<RequestAcceptance>> accepts;
  SuccessGetAcceptRequestState({required this.accepts}) {
    SuccessGetAcceptRequestState.lastAccepts = accepts;
  }
}

class FailureGetAcceptRequestState extends ProviderState {
  final String? message;
  FailureGetAcceptRequestState({this.message});
}

class FailureGetRequestsState extends ProviderState {
  final String? message;
  FailureGetRequestsState({this.message});
}

class FailureGetRecentRequestState extends ProviderState {
  final String? message;
  FailureGetRecentRequestState({this.message});
}

class ReloadState extends ProviderState {}

class RequestDetailState extends ProviderState {
  static RequestData? lastRequestData;
  final RequestData requestData;
  RequestDetailState({required this.requestData}) {
    RequestDetailState.lastRequestData = requestData;
  }
}

class RequestDirectionState extends ProviderState {
  static Request lastRequest = Request();
  final Request request;
  RequestDirectionState({required this.request}) {
    RequestDirectionState.lastRequest = request;
  }
}

class SuccessRequestAcceptState extends ProviderState {}

class FailureRequestAcceptState extends ProviderState {
  final String? message;
  FailureRequestAcceptState({this.message});
}

class SuccessRequestCancelState extends ProviderState {}

class FailureRequestCancelState extends ProviderState {
  final String? message;
  FailureRequestCancelState({this.message});
}

class SuccessReloadProfileState extends ProviderState {
  final bool exists;
  SuccessReloadProfileState({required this.exists});
}

class FailureReloadProfileState extends ProviderState {}

class SuccessAddAppointmentState extends ProviderState {}

class FailureAddAppointmentState extends ProviderState {
  final String? message;
  FailureAddAppointmentState({this.message});
}

class FailureAddPortfolioItemState extends ProviderState {
  final String? message;
  FailureAddPortfolioItemState({this.message});
}

class SuccessAddServicePackageState extends ProviderState {
  final ServicePackage package;
  SuccessAddServicePackageState({required this.package});
}

class SuccessGetRequestDetailState extends ProviderState {
  static RequestData? lastRequest;
  final RequestData request;
  SuccessGetRequestDetailState({required this.request}) {
    SuccessGetRequestDetailState.lastRequest = request;
  }
}

class FailureAddServicePackageState extends ProviderState {
  final String? message;
  FailureAddServicePackageState({this.message});
}

class FailureGetAppointmentState extends ProviderState {
  final String? message;
  FailureGetAppointmentState({this.message});
}

class FailureSearchRequestState extends ProviderState {
  final String? message;
  FailureSearchRequestState({this.message});
}

class SuccessGetAppointmentsState extends ProviderState {
  static Future<List<AppointmentData>>? lastAppointments;
  final Future<List<AppointmentData>> appointments;
  SuccessGetAppointmentsState({required this.appointments}) {
    SuccessGetAppointmentsState.lastAppointments = appointments;
  }
}

class SuccessGetRequestsState extends ProviderState {
  static Future<List<RequestData>>? lastRequests;
  final Future<List<RequestData>> requests;
  SuccessGetRequestsState({required this.requests}) {
    SuccessGetRequestsState.lastRequests = requests;
  }
}

class SuccessSearchRequestState extends ProviderState {
  static Future<List<RequestData>>? lastRequests;
  final Future<List<RequestData>> requests;
  SuccessSearchRequestState({required this.requests}) {
    SuccessSearchRequestState.lastRequests = requests;
  }
}

class SuccessGetTargetedRequestsState extends ProviderState {
  static Future<List<RequestData>>? lastRequests;
  final Future<List<RequestData>> requests;
  SuccessGetTargetedRequestsState({required this.requests}) {
    SuccessGetTargetedRequestsState.lastRequests = requests;
  }
}

class FailureGetTargetedRequestsState extends ProviderState {
  final String? message;
  FailureGetTargetedRequestsState({this.message});
}

class SearchingState extends ProviderState {
  final bool isSearching;
  SearchingState({required this.isSearching});
}

class SuccessCancelAppointmentState extends ProviderState {}

class FailureCancelAppointmentState extends ProviderState {
  final String? message;
  FailureCancelAppointmentState({this.message});
}

class IsRequestAcceptedState extends ProviderState {
  final bool accepted;
  IsRequestAcceptedState({required this.accepted});
}

class SuccessAddPortfolioItemState extends ProviderState {}

class SuccessCompleteAppointmentState extends ProviderState {}

class SuccessUpdateAppointmentState extends ProviderState {}

class FailureUpdateAppointmentState extends ProviderState {
  final String? message;
  FailureUpdateAppointmentState({this.message});
}

class FailureCompleteAppointmentState extends ProviderState {
  final String? message;
  FailureCompleteAppointmentState({this.message});
}

class VerifyAppointmentCodeLoadingState extends ProviderState {}
class SuccessVerifyAppointmentCodeState extends ProviderState {}
class FailureVerifyAppointmentCodeState extends ProviderState {
  final String? message;
  FailureVerifyAppointmentCodeState({this.message});
}



