part of 'homes_bloc.dart';

abstract class HomesState extends Equatable {
  const HomesState();

  @override
  List<Object?> get props => [];
}

class HomesInitial extends HomesState {}

class HomesLoading extends HomesState {}

class HomesLoaded extends HomesState {
  final List<Home> homes;

  const HomesLoaded({required this.homes});

  @override
  List<Object> get props => [homes];
}

class HomesError extends HomesState {
  final String message;

  const HomesError({required this.message});

  @override
  List<Object> get props => [message];
}
