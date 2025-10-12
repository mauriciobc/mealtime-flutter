import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/features/auth/presentation/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo e título
              const Icon(Icons.pets, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              const Text(
                'Criar Conta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Comece a gerenciar a alimentação dos seus gatos',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // Formulário de registro
              const RegisterForm(),

              const SizedBox(height: 24),

              // Link para login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tem uma conta? '),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Faça login'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
