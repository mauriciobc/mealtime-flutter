import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/usecases/get_active_home.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/domain/usecases/get_statistics.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatistics getStatistics;
  final GetActiveHome getActiveHome;

  // Estado atual dos filtros
  PeriodFilter _currentPeriodFilter = PeriodFilter.week;
  String? _currentCatId;
  String? _currentHouseholdId;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  StatisticsBloc({
    required this.getStatistics,
    required this.getActiveHome,
  }) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<UpdatePeriodFilter>(_onUpdatePeriodFilter);
    on<UpdateCatFilter>(_onUpdateCatFilter);
    on<UpdateHouseholdFilter>(_onUpdateHouseholdFilter);
    on<RefreshStatistics>(_onRefreshStatistics);
    on<ClearStatisticsError>(_onClearStatisticsError);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    debugPrint(
      '[StatisticsBloc] LoadStatistics chamado: '
      'periodFilter=${event.periodFilter}, '
      'catId=${event.catId}, '
      'householdId=${event.householdId}',
    );
    
    emit(const StatisticsLoading());

    String? householdId = event.householdId;
    
    // Se não houver householdId, tenta obter o ativo
    if (householdId == null) {
      final result = await getActiveHome(NoParams());
      final ok = result.fold<bool>(
        (failure) {
          debugPrint(
            '[StatisticsBloc] getActiveHome falhou: ${failure.message}',
          );
          emit(StatisticsError(failure));
          return false;
        },
        (home) {
          householdId = home?.id;
          debugPrint(
            '[StatisticsBloc] getActiveHome ok: '
            'householdId=${householdId ?? "nenhum"}',
          );
          return true;
        },
      );
      if (!ok) return;
    }

    // Atualizar filtros atuais
    _currentPeriodFilter = event.periodFilter;
    _currentCatId = event.catId;
    _currentHouseholdId = householdId;
    _customStartDate = event.customStartDate;
    _customEndDate = event.customEndDate;

    final params = GetStatisticsParams(
      periodFilter: event.periodFilter,
      catId: event.catId,
      householdId: householdId,
      customStartDate: event.customStartDate,
      customEndDate: event.customEndDate,
    );

    debugPrint('[StatisticsBloc] Chamando getStatistics...');
    final result = await getStatistics(params);

    result.fold(
      (failure) {
        debugPrint('[StatisticsBloc] Erro: ${failure.message}');
        emit(StatisticsError(failure));
      },
      (statistics) {
        debugPrint(
          '[StatisticsBloc] Estatísticas obtidas: '
          'totalFeedings=${statistics.totalFeedings}, '
          'hasData=${statistics.hasData}',
        );
        emit(
        StatisticsLoaded(
          statistics: statistics,
          periodFilter: _currentPeriodFilter,
          catId: _currentCatId,
          householdId: _currentHouseholdId,
        ),
        );
      },
    );
  }

  Future<void> _onUpdatePeriodFilter(
    UpdatePeriodFilter event,
    Emitter<StatisticsState> emit,
  ) async {
    _currentPeriodFilter = event.periodFilter;
    _customStartDate = event.customStartDate;
    _customEndDate = event.customEndDate;

    // Recarregar com novo filtro
    add(
      LoadStatistics(
        periodFilter: _currentPeriodFilter,
        catId: _currentCatId,
        householdId: _currentHouseholdId,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
      ),
    );
  }

  Future<void> _onUpdateCatFilter(
    UpdateCatFilter event,
    Emitter<StatisticsState> emit,
  ) async {
    _currentCatId = event.catId;

    // Recarregar com novo filtro
    add(
      LoadStatistics(
        periodFilter: _currentPeriodFilter,
        catId: _currentCatId,
        householdId: _currentHouseholdId,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
      ),
    );
  }

  Future<void> _onUpdateHouseholdFilter(
    UpdateHouseholdFilter event,
    Emitter<StatisticsState> emit,
  ) async {
    _currentHouseholdId = event.householdId;

    // Recarregar com novo filtro
    add(
      LoadStatistics(
        periodFilter: _currentPeriodFilter,
        catId: _currentCatId,
        householdId: _currentHouseholdId,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
      ),
    );
  }

  Future<void> _onRefreshStatistics(
    RefreshStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    // Recarregar com filtros atuais
    add(
      LoadStatistics(
        periodFilter: _currentPeriodFilter,
        catId: _currentCatId,
        householdId: _currentHouseholdId,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
      ),
    );
  }

  Future<void> _onClearStatisticsError(
    ClearStatisticsError event,
    Emitter<StatisticsState> emit,
  ) async {
    if (state is StatisticsLoaded) {
      // Manter estado atual se já estiver carregado
      return;
    }
    emit(const StatisticsInitial());
  }
}

