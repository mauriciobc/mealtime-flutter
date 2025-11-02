import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_indicator_m3e/loading_indicator_m3e.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

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
        if (state is SimpleAuthSuccess) {
          // Usuário autenticado, ir para home
          context.go('/home');
        } else if (state is SimpleAuthInitial || state is SimpleAuthFailure) {
          // Usuário não autenticado ou erro na autenticação, ir para login
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 120,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 24),
              Text(
                'MealTime',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gerencie a alimentação dos seus gatos',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 48),
              Material3LoadingIndicator(
                variant: LoadingIndicatorM3EVariant.contained,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
