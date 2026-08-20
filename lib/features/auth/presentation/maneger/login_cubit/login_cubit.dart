
 
import 'package:carvo/features/auth/domin/auth_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data_source/auth_repo.dart';
import 'login_state.dart';
 
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _repository;
 
  LoginCubit(this._repository) : super(const LoginIdle());
 
  Future<void> signIn({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      emit(const LoginFailure(message: 'يرجى ملء كافة الحقول'));
      return;
    }
 
    emit(const LoginLoading());
    final result = await _repository.signIn(email: email, password: password);
    _emitFromResult(result);
  }
 
  Future<void> signInWithGoogle() async {
    emit(const LoginLoading());
    final result = await _repository.signInWithGoogle();
 
    // Empty-message failure = user cancelled the Google picker; go back to
    // idle silently instead of showing an error SnackBar for a non-error.
    if (result is AuthFailure<dynamic>) {  // && result.message.isEmpty
      emit(const LoginIdle());
      return;
    }
 
    _emitFromResult(result);
  }
 
  void _emitFromResult(AuthResult<dynamic> result) {
    switch (result) {
      case AuthSuccess(:final data):
        emit(LoginSuccess(profile: data));
      case AuthFailure(:final message):
        emit(LoginFailure(message: message));
    }
  }
}
 
