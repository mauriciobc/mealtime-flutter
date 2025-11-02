import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/statistics/domain/entities/period_filter.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:mealtime_app/features/statistics/presentation/bloc/statistics_event.dart';

/// Widget de filtros para estatísticas
class StatisticsFilters extends StatelessWidget {
  final PeriodFilter selectedPeriod;
  final String? selectedCatId;
  final String? householdId;

  const StatisticsFilters({
    super.key,
    required this.selectedPeriod,
    this.selectedCatId,
    this.householdId,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: _PeriodFilterDropdown(
            selectedPeriod: selectedPeriod,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 1,
          child: _CatFilterDropdown(
            selectedCatId: selectedCatId,
            householdId: householdId,
          ),
        ),
      ],
    );
  }
}

class _PeriodFilterDropdown extends StatelessWidget {
  final PeriodFilter selectedPeriod;

  const _PeriodFilterDropdown({required this.selectedPeriod});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PeriodFilter>(
      initialValue: selectedPeriod,
      decoration: const InputDecoration(
        labelText: 'Período',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: PeriodFilter.values.map((period) {
        return DropdownMenuItem<PeriodFilter>(
          value: period,
          child: Text(period.displayName),
        );
      }).toList(),
      onChanged: (period) {
        if (period != null) {
          context.read<StatisticsBloc>().add(
                UpdatePeriodFilter(periodFilter: period),
              );
        }
      },
    );
  }
}

class _CatFilterDropdown extends StatelessWidget {
  final String? selectedCatId;
  final String? householdId;

  const _CatFilterDropdown({
    required this.selectedCatId,
    this.householdId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      builder: (context, catsState) {
        if (catsState is CatsLoaded) {
          // Filtrar gatos por householdId se especificado
          final cats = householdId != null
              ? catsState.cats
                  .where((cat) => cat.homeId == householdId)
                  .toList()
              : catsState.cats;

          return DropdownButtonFormField<String>(
            initialValue: selectedCatId,
            decoration: const InputDecoration(
              labelText: 'Gato',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Todos os Gatos'),
              ),
              ...cats.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          cat.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (catId) {
              context.read<StatisticsBloc>().add(
                    UpdateCatFilter(catId: catId),
                  );
            },
          );
        } else {
          return DropdownButtonFormField<String>(
            initialValue: selectedCatId,
            decoration: const InputDecoration(
              labelText: 'Gato',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Carregando...',
            ),
            items: const [],
            onChanged: null,
          );
        }
      },
    );
  }
}

