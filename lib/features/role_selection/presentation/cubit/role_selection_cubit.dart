import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/role_selection_repository.dart';
import '../../domain/role_selection_result.dart';
import 'role_selection_state.dart';

class RoleSelectionCubit extends Cubit<RoleSelectionState> {
  final RoleSelectionRepository _repository;

  RoleSelectionCubit(this._repository)
      : super(const RoleSelectionIdle(selectedRole: 'vendor'));

  void loadPrefill() {
    final prefill = _repository.authPrefill();
    emit(
      RoleSelectionIdle(
        selectedRole: state.selectedRole,
        prefillName: prefill.name,
        prefillPhone: prefill.phone,
      ),
    );
  }

  void selectRole(String role) {
    emit(RoleSelectionIdle(selectedRole: role));
  }

  Future<void> saveProfile({
    required String name,
    required String phone,
    required String address,
    String specialization = '',
  }) async {
    final role = state.selectedRole;
    emit(RoleSelectionLoading(selectedRole: role));

    final result = await _repository.saveRoleProfile(
      name: name,
      phone: phone,
      address: address,
      role: role,
      specialization: specialization,
    );

    switch (result) {
      case RoleSelectionSuccessResult(:final data):
        emit(RoleSelectionSuccess(user: data));
      case RoleSelectionFailureResult(:final message):
        emit(RoleSelectionFailure(selectedRole: role, message: message));
    }
  }
}
