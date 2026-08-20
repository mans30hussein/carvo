import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
import '../../../../constants/app_colors.dart';
 
import '../../../../core/depandency_injection/depandency_injection.dart';
import '../maneger/login_cubit/login_cubit.dart';
import '../maneger/login_cubit/login_state.dart';
import '../widget/login_state_listener.dart';
import '../widget/login_view_body.dart';

/// Entry point for the login route. Provides the Cubit, sets up the
/// listener, and hands the actual UI to LoginViewBody. Nothing else lives
/// here — no fields, no buttons, no strings. If this file grows past
/// this size again, that's the signal something belongs in a section
/// instead.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocListener<LoginCubit, LoginState>(
            listener: handleLoginStateChange,
            child: const LoginViewBody(),
          ),
        ),
      ),
    );
  }
}
