sealed class RoleSelectionResult<T> {
  const RoleSelectionResult();
}

final class RoleSelectionSuccessResult<T> extends RoleSelectionResult<T> {
  final T data;
  const RoleSelectionSuccessResult(this.data);
}

final class RoleSelectionFailureResult<T> extends RoleSelectionResult<T> {
  final String message;
  const RoleSelectionFailureResult(this.message);
}
