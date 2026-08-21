import 'package:get_it/get_it.dart';
import '../../features/auth/data_source/auth_repo.dart';
import '../../features/auth/presentation/maneger/login_cubit/login_cubit.dart';
import '../../features/auth/presentation/maneger/login_cubit/sign_up_cubit/sign_up_cubit.dart';
import '../../features/role_selection/data/role_selection_repository.dart';
import '../../features/role_selection/presentation/cubit/role_selection_cubit.dart';

final sl = GetIt.instance;

/// Call once at app startup (e.g. in main() before runApp).
/// Repository is a singleton (stateless, safe to share); Cubits are
/// factories so LoginScreen/SignUpScreen each get a fresh instance and
/// don't leak state into each other across navigations.
void setupAuthDependencies() {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl<AuthRepository>()));
  sl.registerFactory<SignUpCubit>(() => SignUpCubit(sl<AuthRepository>()));
}

void setupRoleSelectionDependencies() {
  sl.registerLazySingleton<RoleSelectionRepository>(
    () => RoleSelectionRepository(),
  );
  sl.registerFactory<RoleSelectionCubit>(
    () => RoleSelectionCubit(sl<RoleSelectionRepository>()),
  );
}
