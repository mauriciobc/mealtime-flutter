import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';
import 'package:mealtime_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/get_current_user_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (e) {
      emit(AuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await registerUseCase(
        RegisterParams(
          email: event.email,
          password: event.password,
          fullName: event.name,
        ),
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (e) {
      emit(AuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await logoutUseCase(NoParams());
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure('Erro ao fazer logout: ${e.toString()}'));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await getCurrentUserUseCase(NoParams());

      result.fold(
        (failure) => emit(AuthInitial()),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (e) {
      emit(AuthInitial());
    }
  }
}
