import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/auth/presentation/widgets/register_form.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const M3EdgeInsets.all(M3SpacingToken.space24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo e título
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
              SizedBox(height: M3SpacingToken.space24.value),
              Text(
                'Criar Conta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SizedBox(height: M3SpacingToken.space8.value),
              Text(
                'Comece a gerenciar a alimentação dos seus gatos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: M3SpacingToken.space48.value),

              // Formulário de registro
              const RegisterForm(),

              SizedBox(height: M3SpacingToken.space24.value),

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
