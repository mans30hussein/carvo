
 import 'package:equatable/equatable.dart';
 
sealed class SignUpState extends Equatable {
  const SignUpState();
 
  @override
  List<Object?> get props => [];
}
 
final class SignUpIdle extends SignUpState {
  const SignUpIdle();
}
 
final class SignUpLoading extends SignUpState {
  const SignUpLoading();
}
 
/// Sign-up succeeded — the screen should navigate back to LoginScreen,
/// not into a dashboard (per the chosen product flow).
final class SignUpSuccess extends SignUpState {
  const SignUpSuccess();
}
 
final class SignUpFailure extends SignUpState {
  final String message;
 
  const SignUpFailure({required this.message});
 
  @override
  List<Object?> get props => [message];
}
 
