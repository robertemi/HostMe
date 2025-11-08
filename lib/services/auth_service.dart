import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Note: OAuth flows are started by opening the hosted authorize URL (see buildOAuthAuthorizeUrl)
  // The UI currently launches that URL with url_launcher. Keeping SDK-specific flows out of the service
  // avoids version API mismatches across supabase_flutter releases.

  /// Build the hosted authorize URL for a provider. If `redirectTo` is null the
  /// Supabase default callback will be used (for web flows).
  Uri buildOAuthAuthorizeUrl(String provider, {String? redirectTo}) {
    final base = SupabaseConfig.supabaseUrl.replaceAll(RegExp(r'/$'), '');
    final encoded = redirectTo != null ? Uri.encodeComponent(redirectTo) : '';
    final uriString = redirectTo != null
        ? '$base/auth/v1/authorize?provider=$provider&redirect_to=$encoded'
        : '$base/auth/v1/authorize?provider=$provider';
    return Uri.parse(uriString);
  }

  Future<AuthResponse> signInWithGoogleNative() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '459371788165-3kn1hmf27glg6go2kjalj73md274754d.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Failed to get ID token from Google');
      }

      try {
        final auth = _supabase.auth as dynamic;
        final response = await auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        return response as AuthResponse;
      } catch (e) {
        // Fallback: if the SDK method doesn't exist or fails, throw a descriptive error
        throw Exception('Failed to exchange Google token with Supabase: $e');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;
    
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .single();
    
    return response;
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    if (currentUser == null) throw Exception('No user logged in');
    
    await _supabase
        .from('profiles')
        .update(updates)
        .eq('id', currentUser!.id);
  }
}
