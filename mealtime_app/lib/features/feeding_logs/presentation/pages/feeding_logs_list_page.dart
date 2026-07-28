import 'package:flutter/material.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import 'package:material_3_expressive/components/buttons/enums/m3e_button_enums.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/domain/food_type.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart';
import 'package:mealtime_app/features/home/presentation/widgets/cat_avatar.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/shared/widgets/expressive_dialogs.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class FeedingLogsListPage extends StatefulWidget {
  const FeedingLogsListPage({super.key});

  @override
  State<FeedingLogsListPage> createState() => _FeedingLogsListPageState();
}

class _FeedingLogsListPageState extends State<FeedingLogsListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedHouseholdId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfNeeded());
  }

  void _loadIfNeeded() {
    final catsState = context.read<CatsBloc>().state;
    if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
      final householdId = _selectedHouseholdId ?? catsState.cats.first.homeId;
      _selectedHouseholdId ??= householdId;
      context.read<FeedingLogsBloc>().add(
            LoadTodayFeedingLogs(householdId: householdId),
          );
    }
  }

  void _onRefresh() {
    final catsState = context.read<CatsBloc>().state;
    if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
      final householdId =
          _selectedHouseholdId ?? catsState.cats.first.homeId;
      context.read<FeedingLogsBloc>().add(
            LoadTodayFeedingLogs(
              householdId: householdId,
              forceRemote: true,
            ),
          );
    }
  }

  void _showRegisterFeeding() {
    final catsBloc = context.read<CatsBloc>();
    final catsState = catsBloc.state;
    if (catsState is! CatsLoaded || catsState.cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.home_no_cats_register_first),
        ),
      );
      return;
    }
    final householdId =
        _selectedHouseholdId ?? catsState.cats.first.homeId;
    final authBloc = context.read<SimpleAuthBloc>();
    final feedingLogsBloc = context.read<FeedingLogsBloc>();
    ExpressiveBottomSheet.show(
      context: context,
      title: context.l10n.home_register_feeding,
      scrollable: false,
      isScrollControlled: true,
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      child: BlocProvider.value(
        value: authBloc,
        child: BlocProvider.value(
          value: feedingLogsBloc,
          child: FeedingBottomSheet(
            availableCats: catsState.cats,
            householdId: householdId,
            showHeader: false,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: M3EAppBar.top(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: _buildAppBarTitle(context),
        automaticallyImplyLeading: true,
        actions: [
          M3EIconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _onRefresh,
            tooltip: MaterialLocalizations.of(context)
                .refreshIndicatorSemanticLabel,
          ),
          M3EIconButton(
            icon: const Icon(Icons.add),
            onPressed: _showRegisterFeeding,
            tooltip: context.l10n.home_register_feeding,
          ),
        ],
      ),
      body: BlocListener<FeedingLogsBloc, FeedingLogsState>(
        listener: (context, state) {
          if (state is FeedingLogOperationSuccess) {
            _onRefresh();
          }
        },
        child: BlocBuilder<CatsBloc, CatsState>(
          builder: (context, catsState) {
            if (catsState is! CatsLoaded || catsState.cats.isEmpty) {
              return Center(
                child: Padding(
                  padding: const M3EdgeInsets.symmetric(
                    horizontal: M3SpacingToken.space24,
                  ),
                  child: Text(
                    context.l10n.home_no_cats_register_first,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }
            return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
              builder: (context, state) {
                if (state is FeedingLogsLoading &&
                    _getFeedingLogsFromState(state).isEmpty) {
                  return const Center(child: Material3LoadingIndicator());
                }
                if (state is FeedingLogsError) {
                  return Center(
                    child: Padding(
                      padding: const M3EdgeInsets.all(M3SpacingToken.space24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.failure.message,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          M3EButton(
                            style: M3EButtonStyle.filled,
                            size: M3EButtonSize.md,
                            shape: M3EButtonShape.round,
                            onPressed: _onRefresh,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final logs = _getFeedingLogsFromState(state);
                return M3ERefreshIndicator(
                  onRefresh: () async => _onRefresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (logs.isEmpty) ...[
                        SliverToBoxAdapter(
                          child: _buildEmptyState(context),
                        ),
                        const SliverToBoxAdapter(
                          child: Divider(height: 1),
                        ),
                      ],
                      SliverToBoxAdapter(
                        child: _buildSearchBar(context),
                      ),
                      if (logs.isNotEmpty)
                        ..._buildGroupedList(context, logs, catsState),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return BlocBuilder<HomesBloc, HomesState>(
      builder: (context, homesState) {
        String title = context.l10n.feeding_logs_page_title;
        if (homesState is HomesLoaded && homesState.homes.isNotEmpty) {
          final householdId = _selectedHouseholdId;
          Home? home;
          for (final h in homesState.homes) {
            if (h.id == householdId) {
              home = h;
              break;
            }
          }
          home ??= homesState.homes.first;
          title = home.name;
        }
        return GestureDetector(
          onTap: () => _showHomeSelector(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHomeSelector(BuildContext context) {
    final homesState = context.read<HomesBloc>().state;
    if (homesState is! HomesLoaded || homesState.homes.isEmpty) return;
    ExpressiveBottomSheet.show<void>(
      context: context,
      title: context.l10n.feeding_logs_page_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: homesState.homes
            .map(
              (home) => ListTile(
                title: Text(home.name),
                selected: home.id == _selectedHouseholdId,
                onTap: () {
                  setState(() => _selectedHouseholdId = home.id);
                  context.read<FeedingLogsBloc>().add(
                        LoadTodayFeedingLogs(
                          householdId: home.id,
                          forceRemote: true,
                        ),
                      );
                  Navigator.of(context).pop();
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const M3EdgeInsets.symmetric(
        horizontal: M3SpacingToken.space24,
        vertical: M3SpacingToken.space32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${context.l10n.feeding_logs_page_title}.',
            style: Theme.of(context).textTheme.titleLargeEmphasized?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          SizedBox(height: M3SpacingToken.space12.value),
          Text(
            context.l10n.feeding_logs_empty_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          SizedBox(height: M3SpacingToken.space24.value),
          M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            onPressed: _showRegisterFeeding,
            icon: const Icon(Icons.add, size: 20),
            label: Text(context.l10n.home_register_feeding),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const M3EdgeInsets.symmetric(
        horizontal: M3SpacingToken.space16,
        vertical: M3SpacingToken.space8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: context.l10n.feeding_logs_search_placeholder,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 8),
          M3EIconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filtro',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedList(
    BuildContext context,
    List<FeedingLog> logs,
    CatsLoaded catsState,
  ) {
    final filtered = _searchQuery.isEmpty
        ? logs
        : logs.where((log) {
            final cat = catsState.getCatById(log.catId);
            final name = cat?.name ?? '';
            final notes = log.notes ?? '';
            return name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                notes.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    final grouped = <DateTime, List<FeedingLog>>{};
    for (final log in filtered) {
      final date = DateTime(log.fedAt.year, log.fedAt.month, log.fedAt.day);
      grouped.putIfAbsent(date, () => []).add(log);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return [
      for (final date in sortedDates) ...[
        SliverToBoxAdapter(
          child: Padding(
            padding: const M3EdgeInsets.fromLTRB(
              M3SpacingToken.space16,
              M3SpacingToken.space16,
              M3SpacingToken.space16,
              M3SpacingToken.space8,
            ),
            child: Text(
              _formatDateHeader(context, date),
              style: Theme.of(context).textTheme.titleMediumEmphasized?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final list = List<FeedingLog>.from(grouped[date]!)
                ..sort((a, b) => b.fedAt.compareTo(a.fedAt));
              final log = list[index];
              final cat = catsState.getCatById(log.catId);
              return _FeedingLogListTile(
                feeding: log,
                cat: cat,
                onTap: () {},
                onDelete: () => _showDeleteConfirm(context, log),
              );
            },
            childCount: grouped[date]!.length,
          ),
        ),
      ],
    ];
  }

  String _formatDateHeader(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    final locale = Localizations.localeOf(context).toString();
    String prefix;
    if (dateOnly == today) {
      prefix = context.l10n.home_today;
    } else if (dateOnly == yesterday) {
      prefix = context.l10n.feeding_logs_yesterday;
    } else {
      prefix = DateFormat.E(locale).format(date);
    }
    return '$prefix, ${DateFormat.d(locale).format(date)} de '
        '${DateFormat.MMMM(locale).format(date)} de ${date.year}';
  }

  void _showDeleteConfirm(BuildContext context, FeedingLog log) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir registro?'),
        content: const Text(
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          M3EButton(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            onPressed: () {
              context.read<FeedingLogsBloc>().add(DeleteFeedingLog(log.id));
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  List<FeedingLog> _getFeedingLogsFromState(FeedingLogsState state) {
    if (state is FeedingLogsLoaded) return state.feedingLogs;
    if (state is FeedingLogOperationSuccess) return state.feedingLogs;
    if (state is FeedingLogOperationInProgress) return state.feedingLogs;
    return [];
  }
}

class _FeedingLogListTile extends StatelessWidget {
  const _FeedingLogListTile({
    required this.feeding,
    required this.cat,
    required this.onTap,
    required this.onDelete,
  });

  final FeedingLog feeding;
  final Cat? cat;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final foodTypeText = localizedFoodType(context, feeding.foodType);
    final notSpecified = context.l10n.home_food_not_specified;
    final amountText = feeding.amount != null
        ? context.l10n.home_amount_food_type(
            feeding.amount!.toStringAsFixed(0),
            foodTypeText ?? notSpecified,
          )
        : (foodTypeText ?? notSpecified);
    final timeStr = DateFormat.Hm(Localizations.localeOf(context).toString())
        .format(feeding.fedAt);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const M3EdgeInsets.symmetric(
          horizontal: M3SpacingToken.space16,
          vertical: M3SpacingToken.space8,
        ),
        child: Row(
          children: [
            cat != null
                ? CatAvatar(cat: cat!, size: 44)
                : CircleAvatar(
                    radius: 22,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.pets,
                      color: colorScheme.outline,
                    ),
                  ),
            SizedBox(width: M3SpacingToken.space16.value),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cat?.name ?? context.l10n.home_cat_name_not_found,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amountText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') onDelete();
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20),
                      SizedBox(width: 12),
                      Text('Excluir'),
                    ],
                  ),
                ),
              ],
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
