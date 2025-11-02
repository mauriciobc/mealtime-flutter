import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/usecases/get_homes.dart';
import 'package:mealtime_app/features/homes/domain/usecases/create_home.dart';
import 'package:mealtime_app/features/homes/domain/usecases/update_home.dart';
import 'package:mealtime_app/features/homes/domain/usecases/delete_home.dart';
import 'package:mealtime_app/features/homes/domain/usecases/set_active_home.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';

part 'homes_event.dart';
part 'homes_state.dart';

class HomesBloc extends Bloc<HomesEvent, HomesState> {
  final GetHomes getHomes;
  final CreateHome createHome;
  final UpdateHome updateHome;
  final DeleteHome deleteHome;
  final SetActiveHome setActiveHome;

  HomesBloc({
    required this.getHomes,
    required this.createHome,
    required this.updateHome,
    required this.deleteHome,
    required this.setActiveHome,
  }) : super(HomesInitial()) {
    on<LoadHomes>(_onLoadHomes);
    on<CreateHomeEvent>(_onCreateHome);
    on<UpdateHomeEvent>(_onUpdateHome);
    on<DeleteHomeEvent>(_onDeleteHome);
    on<SetActiveHomeEvent>(_onSetActiveHome);
  }

  Future<void> _onLoadHomes(LoadHomes event, Emitter<HomesState> emit) async {
    emit(HomesLoading());

    final result = await getHomes(NoParams());

    result.fold(
      (failure) => emit(HomesError(message: failure.toString())),
      (homes) => emit(HomesLoaded(homes: homes)),
    );
  }

  Future<void> _onCreateHome(
    CreateHomeEvent event,
    Emitter<HomesState> emit,
  ) async {
    final result = await createHome(
      CreateHomeParams(name: event.name, description: event.description),
    );

    result.fold((failure) => emit(HomesError(message: failure.toString())), (
      home,
    ) {
      if (state is HomesLoaded) {
        final currentHomes = (state as HomesLoaded).homes;
        emit(HomesLoaded(homes: [...currentHomes, home]));
      }
    });
  }

  Future<void> _onUpdateHome(
    UpdateHomeEvent event,
    Emitter<HomesState> emit,
  ) async {
    final result = await updateHome(
      UpdateHomeParams(
        id: event.id,
        name: event.name,
        description: event.description,
      ),
    );

    result.fold((failure) => emit(HomesError(message: failure.toString())), (
      updatedHome,
    ) {
      if (state is HomesLoaded) {
        final currentHomes = (state as HomesLoaded).homes;
        final updatedHomes = currentHomes.map((home) {
          return home.id == event.id ? updatedHome : home;
        }).toList();
        emit(HomesLoaded(homes: updatedHomes));
      }
    });
  }

  Future<void> _onDeleteHome(
    DeleteHomeEvent event,
    Emitter<HomesState> emit,
  ) async {
    final result = await deleteHome(event.id);

    result.fold((failure) => emit(HomesError(message: failure.toString())), (
      _,
    ) {
      if (state is HomesLoaded) {
        final currentHomes = (state as HomesLoaded).homes;
        final updatedHomes = currentHomes
            .where((home) => home.id != event.id)
            .toList();
        emit(HomesLoaded(homes: updatedHomes));
      }
    });
  }

  Future<void> _onSetActiveHome(
    SetActiveHomeEvent event,
    Emitter<HomesState> emit,
  ) async {
    final result = await setActiveHome(event.id);

    result.fold((failure) => emit(HomesError(message: failure.toString())), (
      _,
    ) {
      if (state is HomesLoaded) {
        final currentHomes = (state as HomesLoaded).homes;
        final updatedHomes = currentHomes.map((home) {
          return home.copyWith(isActive: home.id == event.id);
        }).toList();
        emit(HomesLoaded(homes: updatedHomes));
      }
    });
  }
}
