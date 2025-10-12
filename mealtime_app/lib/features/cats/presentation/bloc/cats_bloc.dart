import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/domain/usecases/create_cat.dart'
    as create_cat;
import 'package:mealtime_app/features/cats/domain/usecases/delete_cat.dart'
    as delete_cat;
import 'package:mealtime_app/features/cats/domain/usecases/get_cat_by_id.dart';
import 'package:mealtime_app/features/cats/domain/usecases/get_cats.dart';
import 'package:mealtime_app/features/cats/domain/usecases/update_cat.dart'
    as update_cat;
import 'package:mealtime_app/features/cats/domain/usecases/update_cat_weight.dart'
    as update_cat_weight;
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';

class CatsBloc extends Bloc<CatsEvent, CatsState> {
  final GetCats getCats;
  final GetCatById getCatById;
  final create_cat.CreateCat createCat;
  final update_cat.UpdateCat updateCat;
  final delete_cat.DeleteCat deleteCat;
  final update_cat_weight.UpdateCatWeight updateCatWeight;

  CatsBloc({
    required this.getCats,
    required this.getCatById,
    required this.createCat,
    required this.updateCat,
    required this.deleteCat,
    required this.updateCatWeight,
  }) : super(const CatsInitial()) {
    on<LoadCats>(_onLoadCats);
    on<LoadCatsByHome>(_onLoadCatsByHome);
    on<LoadCatById>(_onLoadCatById);
    on<CreateCat>(_onCreateCat);
    on<UpdateCat>(_onUpdateCat);
    on<DeleteCat>(_onDeleteCat);
    on<UpdateCatWeight>(_onUpdateCatWeight);
    on<RefreshCats>(_onRefreshCats);
    on<ClearCatsError>(_onClearCatsError);
  }

  Future<void> _onLoadCats(LoadCats event, Emitter<CatsState> emit) async {
    emit(const CatsLoading());

    final result = await getCats(NoParams());

    result.fold(
      (failure) => emit(CatsError(failure)),
      (cats) => emit(CatsLoaded(cats: cats)),
    );
  }

  Future<void> _onLoadCatsByHome(
    LoadCatsByHome event,
    Emitter<CatsState> emit,
  ) async {
    emit(const CatsLoading());

    // Por enquanto, carregamos todos os gatos e filtramos localmente
    // Em uma implementação mais robusta, teríamos um use case específico
    final result = await getCats(NoParams());

    result.fold((failure) => emit(CatsError(failure)), (cats) {
      final filteredCats = cats
          .where((cat) => cat.homeId == event.homeId)
          .toList();
      emit(CatsLoaded(cats: filteredCats));
    });
  }

  Future<void> _onLoadCatById(
    LoadCatById event,
    Emitter<CatsState> emit,
  ) async {
    emit(const CatsLoading());

    final result = await getCatById(event.catId);

    result.fold(
      (failure) => emit(CatsError(failure)),
      (cat) => emit(CatLoaded(cat)),
    );
  }

  Future<void> _onCreateCat(CreateCat event, Emitter<CatsState> emit) async {
    final currentState = state;
    if (currentState is CatsLoaded) {
      emit(
        CatOperationInProgress(
          operation: 'Criando gato...',
          cats: currentState.cats,
        ),
      );
    }

    final result = await createCat(event.cat);

    result.fold((failure) => emit(CatsError(failure)), (newCat) {
      if (currentState is CatsLoaded) {
        final updatedCats = <Cat>[...currentState.cats, newCat];
        emit(
          CatOperationSuccess(
            message: 'Gato criado com sucesso!',
            cats: updatedCats,
            updatedCat: newCat,
          ),
        );
      } else {
        emit(
          CatOperationSuccess(
            message: 'Gato criado com sucesso!',
            cats: [newCat],
            updatedCat: newCat,
          ),
        );
      }
    });
  }

  Future<void> _onUpdateCat(UpdateCat event, Emitter<CatsState> emit) async {
    final currentState = state;
    if (currentState is CatsLoaded) {
      emit(
        CatOperationInProgress(
          operation: 'Atualizando gato...',
          cats: currentState.cats,
        ),
      );
    }

    final result = await updateCat(event.cat);

    result.fold((failure) => emit(CatsError(failure)), (updatedCat) {
      if (currentState is CatsLoaded) {
        final updatedCats = currentState.cats.map<Cat>((cat) {
          return cat.id == updatedCat.id ? updatedCat : cat;
        }).toList();
        emit(
          CatOperationSuccess(
            message: 'Gato atualizado com sucesso!',
            cats: updatedCats,
            updatedCat: updatedCat,
          ),
        );
      } else {
        emit(
          CatOperationSuccess(
            message: 'Gato atualizado com sucesso!',
            cats: [updatedCat],
            updatedCat: updatedCat,
          ),
        );
      }
    });
  }

  Future<void> _onDeleteCat(DeleteCat event, Emitter<CatsState> emit) async {
    final currentState = state;
    if (currentState is CatsLoaded) {
      emit(
        CatOperationInProgress(
          operation: 'Excluindo gato...',
          cats: currentState.cats,
        ),
      );
    }

    final result = await deleteCat(event.catId);

    result.fold((failure) => emit(CatsError(failure)), (_) {
      if (currentState is CatsLoaded) {
        final updatedCats = currentState.cats
            .where((cat) => cat.id != event.catId)
            .toList();
        emit(
          CatOperationSuccess(
            message: 'Gato excluído com sucesso!',
            cats: updatedCats,
          ),
        );
      } else {
        emit(
          const CatOperationSuccess(
            message: 'Gato excluído com sucesso!',
            cats: [],
          ),
        );
      }
    });
  }

  Future<void> _onUpdateCatWeight(
    UpdateCatWeight event,
    Emitter<CatsState> emit,
  ) async {
    final currentState = state;
    if (currentState is CatsLoaded) {
      emit(
        CatOperationInProgress(
          operation: 'Atualizando peso...',
          cats: currentState.cats,
        ),
      );
    }

    final result = await updateCatWeight(
      update_cat_weight.UpdateCatWeightParams(
        catId: event.catId,
        weight: event.weight,
      ),
    );

    result.fold((failure) => emit(CatsError(failure)), (updatedCat) {
      if (currentState is CatsLoaded) {
        final updatedCats = currentState.cats.map<Cat>((cat) {
          return cat.id == updatedCat.id ? updatedCat : cat;
        }).toList();
        emit(
          CatOperationSuccess(
            message: 'Peso atualizado com sucesso!',
            cats: updatedCats,
            updatedCat: updatedCat,
          ),
        );
      } else {
        emit(
          CatOperationSuccess(
            message: 'Peso atualizado com sucesso!',
            cats: [updatedCat],
            updatedCat: updatedCat,
          ),
        );
      }
    });
  }

  Future<void> _onRefreshCats(
    RefreshCats event,
    Emitter<CatsState> emit,
  ) async {
    add(const LoadCats());
  }

  void _onClearCatsError(ClearCatsError event, Emitter<CatsState> emit) {
    if (state is CatsError) {
      emit(const CatsInitial());
    }
  }
}
