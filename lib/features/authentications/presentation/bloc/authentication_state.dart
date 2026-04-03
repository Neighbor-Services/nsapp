part of 'authentication_bloc.dart';

abstract class AuthenticationState {}

class InitialAuthenticationState extends AuthenticationState {}

class LoadingAuthenticationState extends AuthenticationState {}

class SuccessLoginAuthenticationState extends AuthenticationState {}

class SuccessRegisterAuthenticationState extends AuthenticationState {}

class SuccessResetPasswordAuthenticationState extends AuthenticationState {}

class SuccessGoogleRegisterAuthenticationState extends AuthenticationState {}

class SuccessLogoutAuthenticationState extends AuthenticationState {}

class FailureLoginAuthenticationState extends AuthenticationState {
  final String message;
  FailureLoginAuthenticationState({
    this.message = "Email or password is incorrect",
  });
}

class FailureRegisterAuthenticationState extends AuthenticationState {}

class FailureResetPasswordAuthenticationState extends AuthenticationState {}

class FailureLogoutAuthenticationState extends AuthenticationState {}

class FailureVerifyOtpState extends AuthenticationState {}

class SuccessVerifyOtpState extends AuthenticationState {}

class FailureChangePasswordState extends AuthenticationState {}

class SuccessChangePasswordState extends AuthenticationState {}

class FailureSendEmailVerificationState extends AuthenticationState {}

class SuccessSendEmailVerificationState extends AuthenticationState {}

class FailureVerifyEmailState extends AuthenticationState {}

class SuccessVerifyEmailState extends AuthenticationState {}

class SuccessDeleteAccountState extends AuthenticationState {}

class FailureDeleteAccountState extends AuthenticationState {}
