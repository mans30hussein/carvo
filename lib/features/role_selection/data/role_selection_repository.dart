import 'package:carvo/core/constants/app_string.dart';
import 'package:carvo/features/role_selection/domain/role_selection_result.dart';
import 'package:carvo/models/user_model.dart';
import 'package:carvo/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleSelectionRepository {
  /// Prefills name/phone from the signed-in Firebase user when available.
  ({String? name, String? phone}) authPrefill() {
    final User? user = AuthService.currentFirebaseUser;
    if (user == null) return (name: null, phone: null);

    final String? name =
        (user.displayName != null && user.displayName!.isNotEmpty)
            ? user.displayName
            : null;
    final String? phone =
        (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
            ? user.phoneNumber
            : null;
    return (name: name, phone: phone);
  }

  /// Builds and persists the role-selection profile for the current session.
  Future<RoleSelectionResult<UserModel>> saveRoleProfile({
    required String name,
    required String phone,
    required String address,
    required String role,
    String specialization = '',
  }) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    final trimmedAddress = address.trim();
    final trimmedSpec = specialization.trim();

    if (trimmedName.isEmpty || trimmedPhone.isEmpty || trimmedAddress.isEmpty) {
      return const RoleSelectionFailureResult(AppStrings.completeRequiredFields);
    }

    try {
      final User? currentUser = AuthService.currentFirebaseUser;
      final String uid = currentUser?.uid ??
          'user_${DateTime.now().millisecondsSinceEpoch}';
      final String email = currentUser?.email ?? '';

      final userModel = UserModel(
        uid: uid,
        name: trimmedName,
        email: email,
        phone: trimmedPhone,
        address: trimmedAddress,
        type: role,
        shopName: role == 'vendor' ? trimmedName : null,
        specialization: role == 'mechanic' ? trimmedSpec : null,
      );

      await AuthService.saveUserProfile(userModel);
      return RoleSelectionSuccessResult(userModel);
    } catch (_) {
      return const RoleSelectionFailureResult(AppStrings.genericSaveProfileError);
    }
  }
}
