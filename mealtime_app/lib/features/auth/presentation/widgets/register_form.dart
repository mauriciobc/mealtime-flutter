import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleAuthBloc, SimpleAuthState>(
      listener: (context, state) {
        if (state is SimpleAuthSuccess) {
          if (state.hasHousehold) {
            context.go(AppRouter.home);
          } else {
            context.go(AppRouter.onboarding);
          }
        } else if (state is SimpleAuthNeedsEmailConfirmation) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: M3Shapes.shapeMedium,
              ),
            ),
          );
          context.go('/login');
        } else if (state is SimpleAuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: M3Shapes.shapeMedium,
              ),
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Campo de nome
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.auth_fullName,
                prefixIcon: const Icon(Icons.person),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.auth_nameRequired;
                }
                if (value.length < 2) {
                  return context.l10n.auth_nameMinLength;
                }
                return null;
              },
            ),
            SizedBox(height: M3SpacingToken.space16.value),

            // Campo de email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.l10n.common_email,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.auth_emailRequired;
                }
                if (!value.contains('@')) {
                  return context.l10n.auth_emailInvalid;
                }
                return null;
              },
            ),
            SizedBox(height: M3SpacingToken.space16.value),

            // Campo de senha
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: context.l10n.auth_passwordPlaceholder,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: M3EIconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.auth_passwordRequired;
                }
                if (value.length < 6) {
                  return context.l10n.auth_passwordMinLength;
                }
                return null;
              },
            ),
            SizedBox(height: M3SpacingToken.space16.value),

            // Campo de confirmação de senha
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: context.l10n.auth_confirmPassword,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: M3EIconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return context.l10n.auth_passwordRequired;
                }
                if (value != _passwordController.text) {
                  return context.l10n.auth_passwordsDoNotMatch;
                }
                return null;
              },
            ),
            SizedBox(height: M3SpacingToken.space24.value),

            // Botão de registro
            BlocBuilder<SimpleAuthBloc, SimpleAuthState>(
              builder: (context, state) {
                final theme = Theme.of(context);
                return SizedBox(
                  width: double.infinity,
                  child: M3EButton(
                    style: M3EButtonStyle.filled,
                    size: M3EButtonSize.md,
                    shape: M3EButtonShape.round,
                    onPressed: state is SimpleAuthLoading
                        ? null
                        : _handleRegister,
                    child: state is SimpleAuthLoading
                        ? const Material3LoadingIndicator(size: 20.0)
                        : Text(
                            context.l10n.auth_register,
                            style: theme.textTheme.titleMediumEmphasized
                                ?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<SimpleAuthBloc>().add(
        SimpleAuthRegisterRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}
