import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/customer/customer_home_screen.dart';
import '../../features/vandor/presentation/screeens/vendor_dashboard_screen.dart';
import '../../screens/mechanic/mechanic_dashboard_screen.dart';
import '../../screens/winch/winch_dashboard_screen.dart';

/// Single source of truth for "which dashboard does this user's role map
/// to" — shared by SplashScreen and LoginScreen so the mapping only lives
/// in one place.
class RoleRouter {
  const RoleRouter._();

  static Widget dashboardFor(UserModel user) {
    switch (user.type) {
      case 'admin':
        return const AdminDashboardScreen();
      case 'vendor':
        return VendorDashboardScreen(user: user);
      case 'mechanic':
        return MechanicDashboardScreen(user: user);
      case 'winch':
        return WinchDashboardScreen(user: user);
      case 'customer':
      default:
        return CustomerHomeScreen(user: user);
    }
  }
}