import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/cats/presentation/widgets/expressive_cat_card.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/m3_motion_helpers.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';
import 'package:mealtime_app/shared/widgets/soulful_empty_state.dart';

class CatsListPage extends StatefulWidget {
  const CatsListPage({super.key});

  @override
  State<CatsListPage> createState() => _CatsListPageState();
}

class _CatsListPageState extends State<CatsListPage> {
  bool _requestedLoadFromCatLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<CatsBloc>().add(const LoadCats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cats_title),
        actions: [
          IconButton(
            onPressed: () {
              HapticsService.lightImpact();
              context.read<CatsBloc>().add(const RefreshCats());
            },
            icon: const Icon(Icons.refresh),
            tooltip: context.l10n.common_refresh,
          ),
        ],
      ),
      body: BlocConsumer<CatsBloc, CatsState>(
        listener: (context, state) {
          if (state is CatsError) {
            _requestedLoadFromCatLoaded = false;
            HapticsService.error();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is CatOperationSuccess) {
            HapticsService.success();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state is CatLoaded) {
            final route = ModalRoute.of(context);
            if (route?.isCurrent == true && !_requestedLoadFromCatLoaded) {
              _requestedLoadFromCatLoaded = true;
              context.read<CatsBloc>().add(const LoadCats());
            }
          } else if (state is CatsLoaded) {
            _requestedLoadFromCatLoaded = false;
          }
        },
        builder: (context, state) {
          if (state is CatLoaded) {
            final route = ModalRoute.of(context);
            if (route?.isCurrent == true) {
              return const LoadingWidget();
            }
            return const SizedBox.shrink();
          } else if (state is CatsLoading) {
            return const LoadingWidget();
          } else if (state is CatsError) {
            return CustomErrorWidget(
              message: state.failure.message,
              onRetry: () {
                HapticsService.lightImpact();
                context.read<CatsBloc>().add(const LoadCats());
              },
            );
          } else if (state is CatsLoaded) {
            if (state.cats.isEmpty) {
              return _buildEmptyState();
            }
            return _buildCatsList(state.cats);
          } else if (state is CatOperationInProgress) {
            return Stack(
              children: [
                _buildCatsList(state.cats),
                Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Material3LoadingIndicator(size: 32.0),
                            SizedBox(height: M3SpacingToken.space16.value),
                            Text(state.operation),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const LoadingWidget();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticsService.mediumImpact();
          context.push(AppRouter.createCat);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SoulfulEmptyState(
      message: context.l10n.cats_emptyState,
      subMessage: context.l10n.cats_addFirstCat,
      icon: Icons.pets,
      actionLabel: context.l10n.cats_addCat,
      onAction: () {
        HapticsService.mediumImpact();
        context.push(AppRouter.createCat);
      },
    );
  }

  Widget _buildCatsList(List<Cat> cats) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticsService.mediumImpact();
        context.read<CatsBloc>().add(const RefreshCats());
      },
      child: ListView.builder(
        padding: const M3EdgeInsets.all(M3SpacingToken.space16),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cat = cats[index];
          return StaggeredEntranceBuilder(
            index: index,
            child: Padding(
              padding: EdgeInsets.only(bottom: M3SpacingToken.space12.value),
              child: ExpressiveCatCard(
                cat: cat,
                onTap: () {
                  context.push('${AppRouter.catDetail}/${cat.id}');
                },
                onEdit: () {
                  context.push('${AppRouter.editCat}/${cat.id}');
                },
                onDelete: () {
                  _showDeleteBottomSheet(context, cat);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteBottomSheet(BuildContext context, Cat cat) {
    HapticsService.mediumImpact();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const M3EdgeInsets.all(M3SpacingToken.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.delete_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: M3SpacingToken.space16.value),
              Text(
                context.l10n.cats_deleteCat,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: M3SpacingToken.space8.value),
              Text(
                context.l10n.cats_deleteConfirmation(cat.name),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: M3SpacingToken.space32.value),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(context.l10n.common_cancel),
                    ),
                  ),
                  SizedBox(width: M3SpacingToken.space16.value),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        HapticsService.heavyImpact(); // Deletion is heavy
                        Navigator.of(context).pop();
                        context.read<CatsBloc>().add(DeleteCat(cat.id));
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      child: Text(context.l10n.common_delete),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
