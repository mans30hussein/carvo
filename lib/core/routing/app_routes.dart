
 
 
import 'package:carvo/core/routing/role_router.dart';
import 'package:carvo/features/auth/presentation/screens/login_screen.dart';
import 'package:carvo/features/role_selection/presentation/screens/role_selection_screen.dart';
import 'package:carvo/models/user_model.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/widget/sign_up_screen.dart';

/// Route name constants. Screens navigate with `Navigator.pushNamed(...)`
/// using these instead of constructing MaterialPageRoute(builder: ...)
/// inline — that kept every screen coupled to every destination screen's
/// constructor. Now a screen only needs to know a route *name*.
class AppRoutes {
  const AppRoutes._();
 
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String roleSelection = '/role-selection';
 
  /// Expects a UserModel as `arguments` — RoleRouter maps it to the
  /// correct dashboard widget.
  static const String dashboard = '/dashboard';
}
 
/// Pass this to MaterialApp(onGenerateRoute: generateAppRoute) in main.dart.
Route<dynamic> generateAppRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
 
    case AppRoutes.signUp:
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
 
    case AppRoutes.roleSelection:
      return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
 
    case AppRoutes.dashboard:
      final user = settings.arguments as UserModel;
      return MaterialPageRoute(builder: (_) => RoleRouter.dashboardFor(user));
 
    default:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
  }
}
 
