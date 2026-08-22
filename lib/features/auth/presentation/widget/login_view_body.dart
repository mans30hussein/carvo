import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
import '../../../../core/routing/app_routes.dart';
 
import '../maneger/login_cubit/login_cubit.dart';
import '../maneger/login_cubit/login_state.dart';
import 'login_footer_section.dart';
import 'login_form_section.dart';
import 'login_header_section.dart';
import 'login_social_section.dart';

/// Composes the four sections into the scrollable body. This is the only
/// file that knows the *order* sections appear in — each section itself
/// knows nothing about its neighbors. Owns the TextEditingControllers
/// since they're input state tied to this screen's lifetime, not
/// something the Cubit needs to hold.
class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
      final isEmailLoading = state is LoginLoading && !state.isGoogle;
final isGoogleLoading = state is LoginLoading && state.isGoogle;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const LoginHeaderSection(),
                const SizedBox(height: 32),
                LoginFormSection(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  isLoading: isEmailLoading,
                  onPressed: () {
                    cubit.signIn(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                  }
                ),
                const SizedBox(height: 20),
                LoginFooterSection(
                  // isLoading: isLoading,
                  onCreateAccountTap: () => Navigator.pushNamed(context, AppRoutes.signUp),
                ),
                const SizedBox(height: 16),
                LoginSocialSection(
                  isLoading: isEmailLoading,
                  onGoogleTap: cubit.signInWithGoogle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
