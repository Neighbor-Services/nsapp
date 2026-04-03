part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class LoginAuthenticationEvent extends AuthenticationEvent {
  final String email;
  final String password;

  LoginAuthenticationEvent({required this.email, required this.password});
}

class RegisterAuthenticationEvent extends AuthenticationEvent {
  final String email;
  final String password;

  RegisterAuthenticationEvent({required this.email, required this.password});
}

class ResetPasswordAuthenticationEvent extends AuthenticationEvent {
  final String otp;
  final String password;

  ResetPasswordAuthenticationEvent({required this.otp, required this.password});
}

class LogoutAuthenticationEvent extends AuthenticationEvent {}

class LoginWithGoogleAuthenticationEvent extends AuthenticationEvent {}

class RegisterWithGoogleAuthenticationEvent extends AuthenticationEvent {}

class VerifyEmailOtpEvent extends AuthenticationEvent {
  final String otp;
  VerifyEmailOtpEvent(this.otp);
}

class ChangePasswordEvent extends AuthenticationEvent {
  final PasswordParam param;
  ChangePasswordEvent(this.param);
}

class SendEmailVerificationEvent extends AuthenticationEvent {
  final String email;

  SendEmailVerificationEvent({required this.email});
}

class VerifiEmailEvent extends AuthenticationEvent {
  final String otp;

  VerifiEmailEvent({required this.otp});
}

class RequestPasswordResetEvent extends AuthenticationEvent {
  final String email;

  RequestPasswordResetEvent({required this.email});
}

class LoginWithAppleAuthenticationEvent extends AuthenticationEvent {}

class DeleteAccountEvent extends AuthenticationEvent {}
