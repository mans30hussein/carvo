 
sealed class AuthResult<T> {
  const AuthResult();
}
 
final class AuthSuccess<T> extends AuthResult<T> {
  final T data;
  const AuthSuccess(this.data);
}
 
final class AuthFailure<T> extends AuthResult<T> {
  final String message;
  const AuthFailure(this.message);
}
 
