part of 'simple_auth_bloc.dart';

abstract class SimpleAuthEvent extends Equatable {
  const SimpleAuthEvent();

  @override
  List<Object?> get props => [];
}

class SimpleAuthLoginRequested extends SimpleAuthEvent {
  final String email;
  final String password;

  const SimpleAuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SimpleAuthRegisterRequested extends SimpleAuthEvent {
  final String email;
  final String password;
  final String name;

  const SimpleAuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class SimpleAuthLogoutRequested extends SimpleAuthEvent {
  const SimpleAuthLogoutRequested();
}

class SimpleAuthCheckRequested extends SimpleAuthEvent {
  const SimpleAuthCheckRequested();
}
