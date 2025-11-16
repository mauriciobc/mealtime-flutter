import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';

class HomeSelector extends StatelessWidget {
  final Home? selectedHome;
  final ValueChanged<Home?>? onHomeChanged;
  final String? label;

  const HomeSelector({
    super.key,
    this.selectedHome,
    this.onHomeChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomesBloc, HomesState>(
      builder: (context, state) {
        if (state is HomesLoaded) {
          return _buildDropdown(context, state.homes);
        } else if (state is HomesLoading) {
          return _buildLoadingDropdown(context);
        } else {
          return _buildErrorDropdown(context);
        }
      },
    );
  }

  Widget _buildDropdown(BuildContext context, List<Home> homes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<Home>(
          key: ValueKey('home_${selectedHome?.id}'),
          initialValue: selectedHome,
          onChanged: onHomeChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
            hintText: 'Selecione uma residência',
          ),
          items: homes.map((home) {
            return DropdownMenuItem<Home>(
              value: home,
              child: Row(
                children: [
                  Icon(
                    Icons.home,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: M3SpacingToken.space8.value),
                  Expanded(
                    child: Text(home.name, overflow: TextOverflow.ellipsis),
                  ),
                  if (home.isActive) ...[
                    SizedBox(width: M3SpacingToken.space8.value),
                    Container(
                      padding: const M3EdgeInsets.symmetric(
                        horizontal: M3SpacingToken.space8,
                        vertical: M3SpacingToken.space4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: M3Shapes.shapeSmall,
                      ),
                      child: Text(
                        'ATIVA',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          validator: (value) {
            if (value == null) {
              return 'Selecione uma residência';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLoadingDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: M3SpacingToken.space8.value),
        ],
        DropdownButtonFormField<String>(
          initialValue: null,
          onChanged: null,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.home),
            border: OutlineInputBorder(),
            hintText: 'Carregando residências...',
          ),
          items: const [],
        ),
      ],
    );
  }

  Widget _buildErrorDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelMedium),
          SizedBox(height: M3SpacingToken.space8.value),
        ],
        DropdownButtonFormField<String>(
          initialValue: null,
          onChanged: null,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.error),
            border: OutlineInputBorder(),
            hintText: 'Erro ao carregar residências',
          ),
          items: const [],
        ),
      ],
    );
  }
}
