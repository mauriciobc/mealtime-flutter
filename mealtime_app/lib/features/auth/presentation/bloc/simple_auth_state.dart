part of 'simple_auth_bloc.dart';

abstract class SimpleAuthState extends Equatable {
  const SimpleAuthState();

  @override
  List<Object?> get props => [];
}

class SimpleAuthInitial extends SimpleAuthState {}

class SimpleAuthLoading extends SimpleAuthState {}

class SimpleAuthSuccess extends SimpleAuthState {
  final User user;

  const SimpleAuthSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class SimpleAuthFailure extends SimpleAuthState {
  final String message;

  const SimpleAuthFailure(this.message);

  @override
  List<Object> get props => [message];
}
