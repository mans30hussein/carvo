
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data_source/auth_repo.dart';
import '../../../../data_source/model/user_cred.dart';
import '../../../../domin/auth_result.dart';
import 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _repository;
 
  SignUpCubit(this._repository) : super(const SignUpIdle());
 
  Future<void> signUp(SignUpCredentials credentials) async {
    if (!credentials.hasAllFields) {
      emit(const SignUpFailure(message: 'يرجى ملء كافة الحقول'));
      return;
    }
 
    emit(const SignUpLoading());
    final result = await _repository.signUp(credentials);
 
    switch (result) {
      case AuthSuccess():
        emit(const SignUpSuccess());
      case AuthFailure(:final message):
        emit(SignUpFailure(message: message));
    }
  }
}
 
