
 
 
import '../../../../../models/user_model.dart';

sealed class LoginState  {
  const LoginState();
 
  @override
  List<Object?> get props => [];
}
 
final class LoginIdle extends LoginState {
  const LoginIdle();
}
 
final class LoginLoading extends LoginState {
  final bool isGoogle;
  const LoginLoading({required this.isGoogle});
    List<Object?> get props => [isGoogle];

}
 
/// profile is null when the user has no Firestore profile yet (edge case,
/// e.g. auth account exists but profile write previously failed) — the UI
/// decides what screen that routes to.
final class LoginSuccess extends LoginState {
  final UserModel? profile;
 
  const LoginSuccess({required this.profile});
 
  @override
  List<Object?> get props => [profile];
}
 
final class LoginFailure extends LoginState {
  final String message;
 
  const LoginFailure({required this.message});
 
  @override
  List<Object?> get props => [message];
}
 
