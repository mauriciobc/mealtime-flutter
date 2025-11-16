import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
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
          // Navegar para a tela principal
          context.go('/home');
        } else if (state is SimpleAuthFailure) {
          // Mostrar erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message), 
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Criar Conta' : 'Entrar'),
        centerTitle: true,
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
              'MealTime',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: M3SpacingToken.space8.value),

            Text(
              'Gerenciamento de alimentação para gatos',
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
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: M3SpacingToken.space16.value),
            ],

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: M3SpacingToken.space16.value),

            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: M3SpacingToken.space16.value),

            // Botão principal
            BlocBuilder<SimpleAuthBloc, SimpleAuthState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state is SimpleAuthLoading ? null : _handleAuth,
                    child: state is SimpleAuthLoading
                        ? const Material3LoadingIndicator(size: 20.0)
                        : Text(_isSignUp ? 'Criar Conta' : 'Entrar'),
                  ),
                );
              },
            ),
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
                    ? 'Já tem uma conta? Entrar'
                    : 'Não tem uma conta? Criar conta',
              ),
            ),

            if (!_isSignUp) ...[
              SizedBox(height: M3SpacingToken.space16.value),
              TextButton(
                onPressed: () {
                  // TODO: Implementar recuperação de senha
                  context.showSnackBar('Funcionalidade em desenvolvimento');
                },
                child: const Text('Esqueci minha senha'),
              ),
            ],
          ],
        ),
      ),
    ),
    );
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, digite seu email'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, digite sua senha'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_isSignUp) {
      final name = _nameController.text.trim();

      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Por favor, digite seu nome completo'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      // TODO: Implementar registro via AuthBloc
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Funcionalidade de cadastro em desenvolvimento',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
      return;
    }

    // Login usando SimpleAuthBloc
    context.read<SimpleAuthBloc>().add(
      SimpleAuthLoginRequested(
        email: email,
        password: password,
      ),
    );
  }
}
