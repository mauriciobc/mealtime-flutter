import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

abstract class CatsEvent extends Equatable {
  const CatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCats extends CatsEvent {
  const LoadCats();
}

class LoadCatsByHome extends CatsEvent {
  final String homeId;

  const LoadCatsByHome(this.homeId);

  @override
  List<Object?> get props => [homeId];
}

class LoadCatById extends CatsEvent {
  final String catId;

  const LoadCatById(this.catId);

  @override
  List<Object?> get props => [catId];
}

class CreateCat extends CatsEvent {
  final Cat cat;

  const CreateCat(this.cat);

  @override
  List<Object?> get props => [cat];
}

class UpdateCat extends CatsEvent {
  final Cat cat;

  const UpdateCat(this.cat);

  @override
  List<Object?> get props => [cat];
}

class DeleteCat extends CatsEvent {
  final String catId;

  const DeleteCat(this.catId);

  @override
  List<Object?> get props => [catId];
}

class UpdateCatWeight extends CatsEvent {
  final String catId;
  final double weight;

  const UpdateCatWeight(this.catId, this.weight);

  @override
  List<Object?> get props => [catId, weight];
}

class RefreshCats extends CatsEvent {
  const RefreshCats();
}

class ClearCatsError extends CatsEvent {
  const ClearCatsError();
}
