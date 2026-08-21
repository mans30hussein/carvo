import 'package:carvo/features/auth/data_source/model/user_cred.dart';
import 'package:carvo/features/auth/domin/auth_result.dart';
import 'package:carvo/models/user_model.dart';
import 'package:carvo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_string.dart';
 
class AuthRepository {
  Future<AuthResult<UserModel?>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final profile = await AuthService.getCurrentUserProfile();
      return AuthSuccess(profile);
    } on FirebaseAuthException {
      return const AuthFailure(AppStrings.invalidLoginError);
    } catch (_) {
      return const AuthFailure(AppStrings.genericSignInError);
    }
  }

  Future<AuthResult<UserModel?>> signInWithGoogle() async {
    try {
      final UserCredential? cred = await AuthService.signInWithGoogle();
      if (cred == null) {
        // User cancelled the Google picker — not an error, just no-op.
        return const AuthFailure('');
      }
      final profile = await AuthService.getCurrentUserProfile();
      return AuthSuccess(profile);
    } catch (_) {
      return const AuthFailure(AppStrings.googleSignInError);
    }
  }

  /// Creates the Firebase Auth account and the matching Firestore profile.
  /// Does NOT sign the resulting session in for app-navigation purposes —
  /// per the product decision, the user is sent back to LoginScreen after
  /// sign-up rather than straight into a dashboard.
  ///
  /// OTP verification is intentionally not implemented yet — this is the
  /// single call site where that step will be inserted later, before
  /// createUserWithEmailAndPassword.
  Future<AuthResult<void>> signUp(SignUpCredentials credentials) async {
    if (!credentials.hasAllFields) {
      return const AuthFailure(AppStrings.emptyFieldsError);
    }

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: credentials.email.trim(),
        password: credentials.password.trim(),
      );

      final newUser = UserModel(
        uid: cred.user!.uid,
        name: credentials.name.trim(),
        email: credentials.email.trim(),
        phone: credentials.phone.trim(),
        address: '',
        type: 'customer',
      );
      await AuthService.saveUserProfile(newUser);

      // Sign out immediately: account + profile now exist, but per the
      // chosen flow the user must log in explicitly afterward rather than
      // landing in an authenticated session automatically.
      await FirebaseAuth.instance.signOut();

      return const AuthSuccess(null);
    } on FirebaseAuthException catch (e) {
      return AuthFailure(_mapSignUpError(e));
    } catch (_) {
      return const AuthFailure(AppStrings.genericSignUpError);
    }
  }

  String _mapSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return AppStrings.emailAlreadyInUseError;
      case 'weak-password':
        return AppStrings.weakPasswordError;
      case 'invalid-email':
        return AppStrings.invalidEmailError;
      default:
        return AppStrings.genericSignUpError;
    }
  }
}