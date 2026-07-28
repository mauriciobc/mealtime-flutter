import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';

import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/m3e.dart';
import 'package:mealtime_app/features/profile/domain/entities/profile.dart';
import 'package:mealtime_app/features/profile/presentation/widgets/profile_info_section.dart';

import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/home_card.dart';

import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/cats/presentation/widgets/cat_card.dart';

import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';

class ProfileDashboardWidget extends StatefulWidget {
  final Profile profile;

  const ProfileDashboardWidget({
    super.key,
    required this.profile,
  });

  @override
  State<ProfileDashboardWidget> createState() => _ProfileDashboardWidgetState();
}

class _ProfileDashboardWidgetState extends State<ProfileDashboardWidget> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data if in initial state
    final homesState = context.read<HomesBloc>().state;
    if (homesState is HomesInitial) {
      context.read<HomesBloc>().add(LoadHomes());
    }

    final catsState = context.read<CatsBloc>().state;
    if (catsState is CatsInitial) {
      context.read<CatsBloc>().add(const LoadCats());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
          child: ProfileInfoSection(profile: widget.profile),
        ),
        SizedBox(height: M3SpacingToken.space24.value),
        _buildSectionHeader(context, 'Minhas Residências', () => context.push('/homes')),
        SizedBox(height: M3SpacingToken.space8.value),
        SizedBox(
          height: 200,
          child: _buildHomesCarousel(context),
        ),
        SizedBox(height: M3SpacingToken.space24.value),
        _buildSectionHeader(context, 'Meus Gatos', () => context.push('/cats')),
        SizedBox(height: M3SpacingToken.space8.value),
        SizedBox(
          height: 180,
          child: _buildCatsCarousel(context),
        ),
        SizedBox(height: M3SpacingToken.space32.value),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Ver todos'),
          ),
        ],
      ),
    );
  }

  Widget _buildHomesCarousel(BuildContext context) {
    return BlocBuilder<HomesBloc, HomesState>(
      builder: (context, state) {
        if (state is HomesLoading) {
          return const LoadingWidget();
        } else if (state is HomesError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () => context.read<HomesBloc>().add(LoadHomes()),
          );
        } else if (state is HomesLoaded) {
          if (state.homes.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.home_outlined,
              message: 'Nenhuma residência',
              buttonText: 'Adicionar',
              onPressed: () => context.push('/homes/create'),
            );
          }
          return ListView.separated(
            padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
            scrollDirection: Axis.horizontal,
            itemCount: state.homes.length,
            separatorBuilder: (context, index) => SizedBox(width: M3SpacingToken.space12.value),
            itemBuilder: (context, index) {
              final home = state.homes[index];
              return SizedBox(
                width: 280,
                child: HomeCard(
                  home: home,
                  onTap: () => context.push('/homes/${home.id}'),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCatsCarousel(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      builder: (context, state) {
        if (state is CatsLoading) {
          return const LoadingWidget();
        } else if (state is CatsError) {
          return CustomErrorWidget(
            message: state.failure.message,
            onRetry: () => context.read<CatsBloc>().add(const LoadCats()),
          );
        } else if (state is CatsLoaded) {
          if (state.cats.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Icons.pets_outlined,
              message: 'Nenhum gato',
              buttonText: 'Adicionar',
              onPressed: () => context.push('/cats/create'),
            );
          }
          return ListView.separated(
            padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
            scrollDirection: Axis.horizontal,
            itemCount: state.cats.length,
            separatorBuilder: (context, index) => SizedBox(width: M3SpacingToken.space12.value),
            itemBuilder: (context, index) {
              final cat = state.cats[index];
              return SizedBox(
                width: 260,
                child: CatCard(cat: cat),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      margin: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: M3Shapes.shapeLarge,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: M3SpacingToken.space8.value),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: M3SpacingToken.space8.value),
          M3EButton(
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
