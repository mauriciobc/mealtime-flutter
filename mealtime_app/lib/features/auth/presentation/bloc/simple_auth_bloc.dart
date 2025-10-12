import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';
import 'package:mealtime_app/features/auth/domain/usecases/simple_login_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/register_usecase.dart';

part 'simple_auth_event.dart';
part 'simple_auth_state.dart';

class SimpleAuthBloc extends Bloc<SimpleAuthEvent, SimpleAuthState> {
  final SimpleLoginUseCase loginUseCase;
  final SimpleRegisterUseCase registerUseCase;
  final SimpleLogoutUseCase logoutUseCase;
  final SimpleGetCurrentUserUseCase getCurrentUserUseCase;

  SimpleAuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(SimpleAuthInitial()) {
    on<SimpleAuthLoginRequested>(_onLoginRequested);
    on<SimpleAuthRegisterRequested>(_onRegisterRequested);
    on<SimpleAuthLogoutRequested>(_onLogoutRequested);
    on<SimpleAuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    SimpleAuthLoginRequested event,
    Emitter<SimpleAuthState> emit,
  ) async {
    emit(SimpleAuthLoading());

    try {
      final result = await loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );

      result.fold(
        (failure) => emit(SimpleAuthFailure(failure.message)),
        (user) => emit(SimpleAuthSuccess(user)),
      );
    } catch (e) {
      emit(SimpleAuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(
    SimpleAuthRegisterRequested event,
    Emitter<SimpleAuthState> emit,
  ) async {
    emit(SimpleAuthLoading());

    try {
      final result = await registerUseCase(
        RegisterParams(
          email: event.email,
          password: event.password,
          fullName: event.name,
        ),
      );

      result.fold(
        (failure) => emit(SimpleAuthFailure(failure.message)),
        (user) => emit(SimpleAuthSuccess(user)),
      );
    } catch (e) {
      emit(SimpleAuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    SimpleAuthLogoutRequested event,
    Emitter<SimpleAuthState> emit,
  ) async {
    emit(SimpleAuthLoading());

    try {
      await logoutUseCase(NoParams());
      emit(SimpleAuthInitial());
    } catch (e) {
      emit(SimpleAuthFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  Future<void> _onCheckRequested(
    SimpleAuthCheckRequested event,
    Emitter<SimpleAuthState> emit,
  ) async {
    try {
      print('[SimpleAuthBloc] Checking authentication...');
      final result = await getCurrentUserUseCase(NoParams());

      result.fold(
        (failure) {
          print('[SimpleAuthBloc] Auth check failed: ${failure.message}');
          emit(SimpleAuthInitial());
        },
        (user) {
          print('[SimpleAuthBloc] Auth check success: ${user.email}');
          emit(SimpleAuthSuccess(user));
        },
      );
    } catch (e) {
      print('[SimpleAuthBloc] Auth check error: $e');
      emit(SimpleAuthInitial());
    }
  }
}
