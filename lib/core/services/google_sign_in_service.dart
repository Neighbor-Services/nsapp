import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Triggers the Google Sign-In flow
  Future<GoogleSignInAccount?> signIn() async {
    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      return account;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Retrieves the authentication tokens (idToken, accessToken)
  Future<GoogleSignInAuthentication?> getAuthentication(
    GoogleSignInAccount account,
  ) async {
    try {
      return await account.authentication;
    } catch (e) {
      print("Google Auth Error: $e");
      return null;
    }
  }
}
