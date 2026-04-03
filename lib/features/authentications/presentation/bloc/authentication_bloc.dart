import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nsapp/core/helpers/helpers.dart';
import 'package:nsapp/core/helpers/use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/change_password_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/login_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/login_with_google_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/logout_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/register_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/register_with_google_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/reset_password_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/verify_registered_email_usecase.dart';
import 'package:nsapp/features/authentications/domain/usecase/request_password_reset_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/verify_email_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/send_email_verification_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/login_with_apple_use_case.dart';
import 'package:nsapp/features/authentications/domain/usecase/delete_account_use_case.dart';
import 'package:nsapp/core/services/background_notification_service.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final RegisterWithGoogleUseCase registerWithGoogleUseCase;
  final VerifyRegisteredEmailUsecase verifyRegisteredEmailUsecase;
  final ChangePasswordUseCase changePasswordUseCase;
  final VerifyEmailUseCase verifyEmailUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final LoginWithAppleUseCase loginWithAppleUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final FlutterSecureStorage secureStorage;

  AuthenticationBloc(
    this.loginUseCase,
    this.registerUseCase,
    this.logoutUseCase,
    this.resetPasswordUseCase,
    this.loginWithGoogleUseCase,
    this.registerWithGoogleUseCase,
    this.verifyRegisteredEmailUsecase,
    this.changePasswordUseCase,
    this.verifyEmailUseCase,
    this.sendEmailVerificationUseCase,
    this.requestPasswordResetUseCase,
    this.loginWithAppleUseCase,
    this.deleteAccountUseCase,
    this.secureStorage,
  ) : super(InitialAuthenticationState()) {
    on<LoginAuthenticationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await loginUseCase.call(
        AuthParams(email: event.email, password: event.password),
      );

      bool isSuccess = false;
      String? message;

      results.fold(
        (l) {
          isSuccess = false;
          message = l.massege ?? "Email or password is incorrect";
        },
        (r) {
          isSuccess = true;
        },
      );

      if (isSuccess) {
        final useBiometric = await Helpers.getBool("usebiometric");
        if (useBiometric) {
          await secureStorage.write(key: "email", value: event.email);
          await secureStorage.write(key: "password", value: event.password);
        }
        emit(SuccessLoginAuthenticationState());
      } else {
        emit(FailureLoginAuthenticationState(message: message!));
      }
    });
    on<RegisterAuthenticationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await registerUseCase.call(
        AuthParams(email: event.email, password: event.password),
      );
      results.fold(
        (l) => emit(FailureRegisterAuthenticationState()),
        (r) => emit(SuccessRegisterAuthenticationState()),
      );
    });
    on<LogoutAuthenticationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      BackgroundNotificationService.disconnectForeground();
      final results = await logoutUseCase.call(event);
      results.fold(
        (l) => emit(FailureLoginAuthenticationState()),
        (r) => emit(SuccessLogoutAuthenticationState()),
      );
    });
    on<ResetPasswordAuthenticationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await resetPasswordUseCase.call(
        ResetPasswordParams(otp: event.otp, password: event.password),
      );
      results.fold(
        (l) => emit(FailureResetPasswordAuthenticationState()),
        (r) => emit(SuccessResetPasswordAuthenticationState()),
      );
    });
    on<RegisterWithGoogleAuthenticationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await registerWithGoogleUseCase.call(event);
      results.fold(
        (l) => emit(FailureRegisterAuthenticationState()),
        (r) => emit(SuccessGoogleRegisterAuthenticationState()),
      );
    });
    on<LoginWithGoogleAuthenticationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await loginWithGoogleUseCase.call(event);
      results.fold(
        (l) => emit(FailureLoginAuthenticationState()),
        (r) => emit(SuccessLoginAuthenticationState()),
      );
    });
    on<VerifyEmailOtpEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await verifyRegisteredEmailUsecase.call(event.otp);
      results.fold(
        (l) => emit(FailureVerifyOtpState()),
        (r) => emit(SuccessVerifyOtpState()),
      );
    });
    on<ChangePasswordEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await changePasswordUseCase.call(event.param);
      results.fold(
        (l) => emit(FailureChangePasswordState()),
        (r) => emit(SuccessChangePasswordState()),
      );
    });
    on<SendEmailVerificationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await sendEmailVerificationUseCase.call(event.email);
      results.fold(
        (l) => emit(FailureSendEmailVerificationState()),
        (r) => emit(SuccessSendEmailVerificationState()),
      );
    });
    on<VerifiEmailEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await verifyEmailUseCase.call(event.otp);
      results.fold(
        (l) => emit(FailureVerifyEmailState()),
        (r) => emit(SuccessVerifyEmailState()),
      );
    });
    on<RequestPasswordResetEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await requestPasswordResetUseCase.call(event.email);
      results.fold(
        (l) => emit(FailureSendEmailVerificationState()),
        (r) => emit(SuccessSendEmailVerificationState()),
      );
    });
    on<LoginWithAppleAuthenticationEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await loginWithAppleUseCase.call();
      results.fold(
        (l) => emit(FailureLoginAuthenticationState()),
        (r) => emit(SuccessLoginAuthenticationState()),
      );
    });
    on<DeleteAccountEvent>((event, emit) async {
      emit(LoadingAuthenticationState());
      final results = await deleteAccountUseCase.call();
      results.fold(
        (l) => emit(FailureDeleteAccountState()),
        (r) => emit(SuccessDeleteAccountState()),
      );
    });
  }
}
