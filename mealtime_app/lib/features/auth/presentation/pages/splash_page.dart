import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
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
    // Dispara a checagem de auth imediatamente. Só redireciona no primeiro
    // frame se o estado já for Success (ex.: deep link OAuth); não manda
    // para login só porque o estado é Initial — assim usuário logado não
    // vê a tela de login antes do redirecionamento.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<SimpleAuthBloc>().state is SimpleAuthSuccess) {
        _redirectIfStateFinal(context);
      }
      context.read<SimpleAuthBloc>().add(const SimpleAuthCheckRequested());
    });
    // Fallback: Se após 10 segundos ainda não tiver navegado, ir para login
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        final state = context.read<SimpleAuthBloc>().state;
        if (state is SimpleAuthLoading ||
            (state is! SimpleAuthSuccess &&
                state is! SimpleAuthInitial &&
                state is! SimpleAuthFailure)) {
          context.go('/login');
        }
      }
    });
  }

  void _redirectIfStateFinal(BuildContext context) {
    final state = context.read<SimpleAuthBloc>().state;
    if (state is SimpleAuthSuccess) {
      if (state.hasHousehold) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    } else if (state is SimpleAuthInitial || state is SimpleAuthFailure) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleAuthBloc, SimpleAuthState>(
      listener: (context, state) => _redirectIfStateFinal(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/images/mealtime-symbol.svg',
                width: 120,
                height: 120,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: M3SpacingToken.space24.value),
              Text(
                'MealTime',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              SizedBox(height: M3SpacingToken.space16.value),
              Text(
                'Gerencie a alimentação dos seus gatos',
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              SizedBox(height: M3SpacingToken.space48.value),
              Material3LoadingIndicator(
                variant: M3ELoadingIndicatorVariant.contained,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
