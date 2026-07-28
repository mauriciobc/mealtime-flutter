import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/localization/auth_error_message_resolver.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/main.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  /// Erro de validação do formulário (campos vazios); exibido inline.
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
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
        }
      },
      child: Scaffold(
      appBar: M3EAppBar.top(
        titleText: _isSignUp
            ? context.l10n.auth_register
            : context.l10n.auth_signIn,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou ícone do app
            Image.asset(
              'assets/images/mealtime-symbol.png',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.pets,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
            SizedBox(height: M3SpacingToken.space32.value),

            Text(
              context.l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: M3SpacingToken.space8.value),

            Text(
              context.l10n.auth_managementDescription,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: M3SpacingToken.space48.value),

            // Formulário
            if (_isSignUp) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: context.l10n.auth_fullName,
                  prefixIcon: const Icon(Icons.person),
                ),
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: M3SpacingToken.space16.value),
            ],

            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: context.l10n.common_email,
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: M3SpacingToken.space16.value),

            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: context.l10n.common_password,
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: M3SpacingToken.space16.value),

            // Botão principal
            BlocBuilder<SimpleAuthBloc, SimpleAuthState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: M3EButton(
                    style: M3EButtonStyle.filled,
                    size: M3EButtonSize.md,
                    shape: M3EButtonShape.round,
                    onPressed: state is SimpleAuthLoading
                        ? null
                        : _handleAuth,
                    child: state is SimpleAuthLoading
                        ? const Material3LoadingIndicator(size: 20.0)
                        : Text(
                            _isSignUp
                                ? context.l10n.auth_registerShort
                                : context.l10n.auth_signInShort,
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            _buildErrorMessage(context),
            SizedBox(height: M3SpacingToken.space16.value),

            // Toggle entre login e cadastro
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(
                _isSignUp
                    ? '${context.l10n.auth_alreadyHaveAccount}${context.l10n.auth_signInShort}'
                    : '${context.l10n.auth_noAccount}${context.l10n.auth_registerShort}',
              ),
            ),

            if (!_isSignUp) ...[
              SizedBox(height: M3SpacingToken.space16.value),
              TextButton(
                onPressed: () {
                  context.showSnackBar(context.l10n.auth_featureInDevelopment);
                },
                child: Text(context.l10n.auth_forgotPassword),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  /// Exibe erros de validação e falhas do bloc inline (SelectableText.rich).
  Widget _buildErrorMessage(BuildContext context) {
    return BlocBuilder<SimpleAuthBloc, SimpleAuthState>(
      builder: (context, state) {
        final failureMessage =
            state is SimpleAuthFailure ? state.message : null;
        final message = _validationError ?? failureMessage;
        if (message == null || message.isEmpty) {
          return const SizedBox.shrink();
        }
        final displayText = context.l10n.authErrorMessage(message);
        return Padding(
          padding: const M3EdgeInsets.only(top: M3SpacingToken.space8),
          child: SelectableText.rich(
            TextSpan(
              text: displayText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleAuth() async {
    setState(() => _validationError = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      setState(() => _validationError = context.l10n.auth_pleaseEnterEmail);
      return;
    }

    if (password.isEmpty) {
      setState(() => _validationError = context.l10n.auth_pleaseEnterPassword);
      return;
    }

    if (_isSignUp) {
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        setState(
            () => _validationError = context.l10n.auth_pleaseEnterFullName);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.auth_registerInDevelopment,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
      return;
    }

    context.read<SimpleAuthBloc>().add(
      SimpleAuthLoginRequested(
        email: email,
        password: password,
      ),
    );
  }
}
