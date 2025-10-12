import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Verificar autenticação após um pequeno delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<SimpleAuthBloc>().add(const SimpleAuthCheckRequested());
      }
    });
    
    // Fallback: Se após 10 segundos ainda não tiver navegado, ir para login
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        final state = context.read<SimpleAuthBloc>().state;
        if (state is SimpleAuthLoading || 
            (state is! SimpleAuthSuccess && state is! SimpleAuthInitial && state is! SimpleAuthFailure)) {
          // Se ainda está em loading ou em algum estado indefinido, ir para login
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleAuthBloc, SimpleAuthState>(
      listener: (context, state) {
        print('[SplashPage] State changed: ${state.runtimeType}');
        if (state is SimpleAuthSuccess) {
          // Usuário autenticado, ir para home
          print('[SplashPage] Going to /home');
          context.go('/home');
        } else if (state is SimpleAuthInitial || state is SimpleAuthFailure) {
          // Usuário não autenticado ou erro na autenticação, ir para login
          print('[SplashPage] Going to /login');
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.orange,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 120, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'MealTime',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gerencie a alimentação dos seus gatos',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
