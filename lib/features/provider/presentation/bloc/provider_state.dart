part of 'provider_bloc.dart';

sealed class ProviderState {}

final class ProviderInitial extends ProviderState {}

final class LoadingProviderState extends ProviderState {}

class NavigatorProviderState extends ProviderState {
  static Widget widget = const ProviderHomePage();
  static int page = 1;
}

class ProviderVisitedPagesState extends ProviderState {
  static List<VisitedPages> pages = [];
}

class SuccessGetRecentRequestState extends ProviderState {
  static Future<List<RequestData>>? myRequests;
}

class SuccessGetAcceptRequestState extends ProviderState {
  static Future<List<RequestAcceptance>>? accepts;
}

class FailureGetAcceptRequestState extends ProviderState {}

class FailureGetRequestsState extends ProviderState {}

class FailureGetRecentRequestState extends ProviderState {}

class ReloadState extends ProviderState {}

class RequestDetailState extends ProviderState {
  static RequestData requestData = RequestData();
}

class RequestDirectionState extends ProviderState {
  static Request request = Request();
}

class SuccessRequestAcceptState extends ProviderState {}

class FailureRequestAcceptState extends ProviderState {}

class SuccessRequestCancelState extends ProviderState {}

class FailureRequestCancelState extends ProviderState {}

class SuccessReloadProfileState extends ProviderState {
  static bool exists = false;
}

class FailureReloadProfileState extends ProviderState {}

class SuccessAddAppointmentState extends ProviderState {}

class FailureAddAppointmentState extends ProviderState {}

class FailureAddPortfolioItemState extends ProviderState {}

class SuccessAddServicePackageState extends ProviderState {
  static ServicePackage package = ServicePackage();
  SuccessAddServicePackageState();
}

class SuccessGetRequestDetailState extends ProviderState {
  static RequestData request = RequestData();
}

class FailureAddServicePackageState extends ProviderState {
  final Failure failure;
  FailureAddServicePackageState(this.failure);
}

class FailureGetAppointmentState extends ProviderState {}

class FailureSearchRequestState extends ProviderState {}

class SuccessGetAppointmentsState extends ProviderState {
  static Future<List<AppointmentData>>? appointments;
}

class SuccessGetRequestsState extends ProviderState {
  static Future<List<RequestData>>? requests;
}

class SuccessSearchRequestState extends ProviderState {
  static Future<List<RequestData>>? requests;
}

class SuccessGetTargetedRequestsState extends ProviderState {
  static Future<List<RequestData>>? requests;
}

class FailureGetTargetedRequestsState extends ProviderState {}

class SearchingState extends ProviderState {
  static bool isSearching = false;
}

class SuccessCancelAppointmentState extends ProviderState {}

class FailureCancelAppointmentState extends ProviderState {}

class IsRequestAcceptedState extends ProviderState {
  static bool accepted = false;
}

class SuccessAddPortfolioItemState extends ProviderState {}

class SuccessCompleteAppointmentState extends ProviderState {}

class SuccessUpdateAppointmentState extends ProviderState {}

class FailureUpdateAppointmentState extends ProviderState {}

class FailureCompleteAppointmentState extends ProviderState {}
