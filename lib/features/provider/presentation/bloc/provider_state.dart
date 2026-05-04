part of 'provider_bloc.dart';

sealed class ProviderState {}

final class ProviderInitial extends ProviderState {}

final class LoadingProviderState extends ProviderState {}

class NavigatorProviderState extends ProviderState {
  final Widget widget;
  final int page;

  NavigatorProviderState({this.widget = const ProviderHomePage(), this.page = 1});
}

class ProviderVisitedPagesState extends ProviderState {
  final List<VisitedPages> pages;
  ProviderVisitedPagesState({required this.pages});
}

class SuccessGetRecentRequestState extends ProviderState {
  final List<RequestData> myRequests;
  SuccessGetRecentRequestState({required this.myRequests});
}

class SuccessGetAcceptRequestState extends ProviderState {
  final List<RequestAcceptance> accepts;
  SuccessGetAcceptRequestState({required this.accepts});
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
  final RequestData requestData;
  RequestDetailState({required this.requestData});
}

class RequestDirectionState extends ProviderState {
  final Request request;
  RequestDirectionState({required this.request});
}

class SuccessRequestAcceptState extends ProviderState {
}

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
  final RequestData request;
  SuccessGetRequestDetailState({required this.request});
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
  final List<AppointmentData> appointments;
  SuccessGetAppointmentsState({required this.appointments});
}

class SuccessGetRequestsState extends ProviderState {
  final List<RequestData> requests;
  SuccessGetRequestsState({required this.requests});
}

class SuccessSearchRequestState extends ProviderState {
  final List<RequestData> requests;
  SuccessSearchRequestState({required this.requests});
}

class SuccessGetTargetedRequestsState extends ProviderState {
  final List<RequestData> requests;
  SuccessGetTargetedRequestsState({required this.requests});
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
