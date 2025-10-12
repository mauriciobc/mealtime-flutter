part of 'homes_bloc.dart';

abstract class HomesEvent extends Equatable {
  const HomesEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomes extends HomesEvent {}

class CreateHomeEvent extends HomesEvent {
  final String name;
  final String? description;

  const CreateHomeEvent({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class UpdateHomeEvent extends HomesEvent {
  final String id;
  final String name;
  final String? description;

  const UpdateHomeEvent({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class DeleteHomeEvent extends HomesEvent {
  final String id;

  const DeleteHomeEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SetActiveHomeEvent extends HomesEvent {
  final String id;

  const SetActiveHomeEvent(this.id);

  @override
  List<Object> get props => [id];
}
