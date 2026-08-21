import '../../../../models/user_model.dart';

sealed class RoleSelectionState {
  const RoleSelectionState();

  String get selectedRole;
}

final class RoleSelectionIdle extends RoleSelectionState {
  @override
  final String selectedRole;
  final String? prefillName;
  final String? prefillPhone;

  const RoleSelectionIdle({
    required this.selectedRole,
    this.prefillName,
    this.prefillPhone,
  });
}

final class RoleSelectionLoading extends RoleSelectionState {
  @override
  final String selectedRole;

  const RoleSelectionLoading({required this.selectedRole});
}

final class RoleSelectionSuccess extends RoleSelectionState {
  final UserModel user;

  const RoleSelectionSuccess({required this.user});

  @override
  String get selectedRole => user.type;
}

final class RoleSelectionFailure extends RoleSelectionState {
  @override
  final String selectedRole;
  final String message;

  const RoleSelectionFailure({
    required this.selectedRole,
    required this.message,
  });
}
