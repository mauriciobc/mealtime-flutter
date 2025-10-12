import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';

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
          value: selectedHome,
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(home.name, overflow: TextOverflow.ellipsis),
                  ),
                  if (home.isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
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
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          value: null,
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
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          value: null,
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
