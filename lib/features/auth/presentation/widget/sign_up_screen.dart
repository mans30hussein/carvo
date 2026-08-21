import 'package:carvo/features/auth/presentation/maneger/login_cubit/sign_up_cubit/sign_up_cubit.dart';
import 'package:carvo/features/auth/presentation/widget/auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_string.dart';
import '../../../../core/app_style.dart';
import '../../../../core/depandency_injection/depandency_injection.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../data_source/model/user_cred.dart';
import '../maneger/login_cubit/sign_up_cubit/sign_up_state.dart';
 

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SignUpCubit>(),
      child: const _SignUpView(),
    );
  }
}

class _SignUpView extends StatefulWidget {
  const _SignUpView();

  @override
  State<_SignUpView> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<_SignUpView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleStateChange(BuildContext context, SignUpState state) {
    if (state is SignUpSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.signUpSuccessMessage, style: AppStyles.snackBarText),
          backgroundColor: AppColors.surface,
        ),
      );
      // Per the chosen flow: back to LoginScreen, not straight into the app.
      Navigator.pop(context);
    } else if (state is SignUpFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message, style: AppStyles.snackBarText),
          backgroundColor: AppColors.surface,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<SignUpCubit, SignUpState>(
          listener: _handleStateChange,
          builder: (context, state) {
            final isLoading = state is SignUpLoading;
            final cubit = context.read<SignUpCubit>();

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    const AuthHeader(
                      title: AppStrings.signUpTitle,
                      subtitle: AppStrings.signUpSubtitle,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      controller: _nameController,
                      label: AppStrings.nameLabel,
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: AppStrings.emailLabel,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phoneController,
                      label: AppStrings.phoneLabel,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passwordController,
                      label: AppStrings.passwordLabel,
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: AppStrings.signUpButton,
                      isLoading: isLoading,
                      onPressed: () => cubit.signUp(
                        SignUpCredentials(
                          name: _nameController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                          password: _passwordController.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(context),
                      child: Text(AppStrings.hasAccountPrompt, style: AppStyles.linkText),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
