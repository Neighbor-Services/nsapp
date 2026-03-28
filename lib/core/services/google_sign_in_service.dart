import 'package:google_sign_in/google_sign_in.dart' as gsi;

class GoogleSignInService {
  final gsi.GoogleSignIn _googleSignIn = gsi.GoogleSignIn.instance;

  /// Triggers the Google Sign-In flow
  Future<gsi.GoogleSignInAccount?> signIn() async {
    try {
      // Explicit initialization is mandatory in version 7.0.0+
      await _googleSignIn.initialize();
      return await _googleSignIn.authenticate(
        scopeHint: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );
    } catch (e) {
      return null;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore sign out errors
    }
  }

  /// Retrieves the authentication tokens (idToken, accessToken)
  Future<gsi.GoogleSignInAuthentication?> getAuthentication(
    gsi.GoogleSignInAccount account,
  ) async {
    try {
      return account.authentication;
    } catch (e) {
      return null;
    }
  }
}
