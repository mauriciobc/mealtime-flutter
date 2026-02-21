import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:mealtime_app/core/auth/simple_auth_manager.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/auth/domain/entities/user.dart';
import 'package:mealtime_app/features/auth/domain/usecases/simple_login_usecase.dart';
import 'package:mealtime_app/features/auth/domain/usecases/login_usecase.dart' show LoginParams;
import 'package:mealtime_app/features/auth/domain/usecases/register_usecase.dart' show RegisterParams;

part 'simple_auth_event.dart';
part 'simple_auth_state.dart';

class SimpleAuthBloc extends Bloc<SimpleAuthEvent, SimpleAuthState> {
  final SimpleLoginUseCase loginUseCase;
  final SimpleRegisterUseCase registerUseCase;
  final SimpleLogoutUseCase logoutUseCase;
  final SimpleGetCurrentUserUseCase getCurrentUserUseCase;
  final SimpleLoginWithGoogleUseCase loginWithGoogleUseCase;

  StreamSubscription<supabase.AuthState>? _authStateSubscription;

  SimpleAuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.loginWithGoogleUseCase,
  }) : super(SimpleAuthInitial()) {
    on<SimpleAuthLoginRequested>(_onLoginRequested);
    on<SimpleAuthRegisterRequested>(_onRegisterRequested);
    on<SimpleAuthLogoutRequested>(_onLogoutRequested);
    on<SimpleAuthCheckRequested>(_onCheckRequested);
    on<SimpleAuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<SimpleAuthSessionDetected>(_onSessionDetected);
    _authStateSubscription = SimpleAuthManager.authStateChanges.listen(
      _onAuthStateChange,
    );
  }

  void _onAuthStateChange(supabase.AuthState authState) {
    if (authState.event != supabase.AuthChangeEvent.signedIn &&
        authState.event != supabase.AuthChangeEvent.initialSession) {
      return;
    }
    if (authState.session == null) return;
    add(const SimpleAuthSessionDetected());
  }

  Future<void> _onSessionDetected(
    SimpleAuthSessionDetected event,
    Emitter<SimpleAuthState> emit,
  ) async {
    if (isClosed) return;
    final result = await getCurrentUserUseCase(NoParams());
    if (isClosed) return;
    result.fold(
      (_) => null,
      (user) {
        if (state is SimpleAuthSuccess &&
            (state as SimpleAuthSuccess).user.id == user.id) {
          return;
        }
        emit(SimpleAuthSuccess(user));
      },
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
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
      final result = await getCurrentUserUseCase(NoParams());

      result.fold(
        (failure) {
          emit(SimpleAuthInitial());
        },
        (user) {
          emit(SimpleAuthSuccess(user));
        },
      );
    } catch (e) {
      emit(SimpleAuthInitial());
    }
  }

  Future<void> _onGoogleSignInRequested(
    SimpleAuthGoogleSignInRequested event,
    Emitter<SimpleAuthState> emit,
  ) async {
    emit(SimpleAuthLoading());
    try {
      final result = await loginWithGoogleUseCase(NoParams());
      result.fold(
        (failure) => emit(SimpleAuthFailure(failure.message)),
        (_) {
          // OAuth iniciado; sessão chegará via authStateChanges
          // Mantém loading até _onAuthStateChange emitir SimpleAuthSuccess
        },
      );
    } catch (e) {
      emit(SimpleAuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }
}
