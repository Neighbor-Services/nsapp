// ignore: avoid_types_as_parameter_names
abstract class UseCase<Type, Params> {
  Future call(Params params);
}

abstract class Params {}

class AuthParams extends Params {
  final String email;
  final String password;

  AuthParams({required this.email, required this.password});
}

class PasswordParam extends Params {
  final String oldPassword;
  final String newPassword;

  PasswordParam({required this.oldPassword, required this.newPassword});
}

class ResetPasswordParams extends Params {
  final String otp;
  final String password;

  ResetPasswordParams({required this.otp, required this.password});
}
