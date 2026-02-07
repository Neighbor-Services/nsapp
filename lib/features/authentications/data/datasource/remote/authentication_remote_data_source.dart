abstract class AuthenticationRemoteDataSource {
  Future<bool> register(String email, String password);
  Future<bool> registerWithGoogle();
  Future<bool?> login(String email, String password);
  Future<bool> changePassword(String oldPassword, String nwPassword);
  Future<bool> resetPassword(String otp, String password);
  Future<bool> verifyEmail(String otp);
  Future<bool> loginWithGoogle();
  Future<bool> verifyRegistration(String otp);
  Future<bool> sendEmailVerification(String email);
  Future<bool> requestPasswordReset(String email);
  Future<bool> logout();
}
