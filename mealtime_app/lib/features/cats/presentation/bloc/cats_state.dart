import 'package:equatable/equatable.dart';
import 'package:mealtime_app/core/errors/failures.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';

abstract class CatsState extends Equatable {
  const CatsState();

  @override
  List<Object?> get props => [];
}

class CatsInitial extends CatsState {
  const CatsInitial();
}

class CatsLoading extends CatsState {
  const CatsLoading();
}

class CatsLoaded extends CatsState {
  final List<Cat> cats;
  final Cat? selectedCat;

  const CatsLoaded({required this.cats, this.selectedCat});

  @override
  List<Object?> get props => [cats, selectedCat];

  CatsLoaded copyWith({List<Cat>? cats, Cat? selectedCat}) {
    return CatsLoaded(
      cats: cats ?? this.cats,
      selectedCat: selectedCat ?? this.selectedCat,
    );
  }
}

class CatLoaded extends CatsState {
  final Cat cat;

  const CatLoaded(this.cat);

  @override
  List<Object?> get props => [cat];
}

class CatsError extends CatsState {
  final Failure failure;

  const CatsError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class CatOperationInProgress extends CatsState {
  final String operation;
  final List<Cat> cats;

  const CatOperationInProgress({required this.operation, required this.cats});

  @override
  List<Object?> get props => [operation, cats];
}

class CatOperationSuccess extends CatsState {
  final String message;
  final List<Cat> cats;
  final Cat? updatedCat;

  const CatOperationSuccess({
    required this.message,
    required this.cats,
    this.updatedCat,
  });

  @override
  List<Object?> get props => [message, cats, updatedCat];
}
