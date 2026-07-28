import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:intl/intl.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/core/theme/m3_shapes.dart';
import 'package:mealtime_app/core/theme/m3e.dart';
import 'package:mealtime_app/core/utils/haptics_service.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/household_cat_card.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/member_list_item.dart';
import 'package:mealtime_app/services/api/cats_api_service.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:mealtime_app/shared/widgets/expressive_dialogs.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';

class HomeDetailPage extends StatefulWidget {
  final Home home;

  const HomeDetailPage({super.key, required this.home});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  HouseholdModel? _householdDetail;
  List<Cat>? _cats;
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = SupabaseConfig.client.auth.currentUser?.id;
    _loadHouseholdDetails();
  }

  Future<void> _loadHouseholdDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final homesApi = sl<HomesApiService>();
      final catsApi = sl<CatsApiService>();

      final householdsResponse = await homesApi.getHouseholds();
      final household = householdsResponse.data?.firstWhere(
        (h) => h.id == widget.home.id,
      );

      final catsResponse = await catsApi.getCats(householdId: widget.home.id);
      final cats = catsResponse.data
          ?.map((catModel) => catModel.toEntity())
          .toList();

      setState(() {
        _householdDetail = household;
        _cats = cats ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar detalhes: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: M3EAppBar.top(
          titleText: widget.home.name,
          automaticallyImplyLeading: true,
        ),
        body: const LoadingWidget(),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: M3EAppBar.top(
          titleText: widget.home.name,
          automaticallyImplyLeading: true,
        ),
        body: CustomErrorWidget(
          message: _error!,
          onRetry: _loadHouseholdDetails,
        ),
      );
    }

    final theme = Theme.of(context);
    final owner = _householdDetail?.owner;
    final createdAt = widget.home.createdAt;
    final formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);
    final ownerName = owner?.name ?? 'Desconhecido';

    return Scaffold(
      body: M3ERefreshIndicator(
        onRefresh: _loadHouseholdDetails,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              pinned: true,
              floating: true,
              stretch: true,
              title: Text(widget.home.name),
              actions: [
                PopupMenuButton<String>(
                  tooltip: 'Opções da Residência',
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        HapticsService.lightImpact();
                        context.push('/homes/${widget.home.id}/edit');
                        break;
                      case 'set_active':
                        _setActiveHome(context);
                        break;
                      case 'delete':
                        _showDeleteBottomSheet(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          SizedBox(width: M3SpacingToken.space8.value),
                          const Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'set_active',
                      child: Row(
                        children: [
                          const Icon(Icons.home),
                          SizedBox(width: M3SpacingToken.space8.value),
                          const Text('Definir como Ativa'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          SizedBox(width: M3SpacingToken.space8.value),
                          Text(
                            'Excluir',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const M3EdgeInsets.all(M3SpacingToken.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criada em $formattedDate por $ownerName',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: M3SpacingToken.space24.value),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          M3EButton.icon(
                            style: M3EButtonStyle.filled,
                            size: M3EButtonSize.md,
                            shape: M3EButtonShape.round,
                            onPressed: _inviteMember,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Convidar'),
                          ),
                          SizedBox(width: M3SpacingToken.space12.value),
                          M3EButton.icon(
                            style: M3EButtonStyle.tonal,
                            size: M3EButtonSize.md,
                            shape: M3EButtonShape.round,
                            onPressed: _addCat,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Gato'),
                          ),
                          SizedBox(width: M3SpacingToken.space12.value),
                          if (!widget.home.isActive)
                            M3EButton.icon(
                              style: M3EButtonStyle.outlined,
                              size: M3EButtonSize.md,
                              shape: M3EButtonShape.round,
                              onPressed: () => _setActiveHome(context),
                              icon: const Icon(Icons.star_border),
                              label: const Text('Tornar Ativa'),
                            )
                          else
                            Chip(
                              label: const Text('Residência Ativa'),
                              avatar: const Icon(Icons.star, size: 16),
                              backgroundColor:
                                  theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: M3SpacingToken.space32.value),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildMembersSection(context)),
            SliverToBoxAdapter(
              child: SizedBox(height: M3SpacingToken.space32.value),
            ),
            SliverToBoxAdapter(child: _buildCatsSection(context)),
            SliverToBoxAdapter(
              child: SizedBox(height: M3SpacingToken.space32.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    final theme = Theme.of(context);
    final members = _householdDetail?.householdMembers ?? [];

    return Padding(
      padding: const M3EdgeInsets.symmetric(horizontal: M3SpacingToken.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: theme.colorScheme.primary),
              SizedBox(width: M3SpacingToken.space8.value),
              Text(
                'Membros (${members.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          if (members.isEmpty)
            _buildEmptyState(
              context,
              icon: Icons.people_outline,
              message: 'Nenhum membro ainda',
              submessage: 'Convide pessoas para participar desta residência',
              buttonText: 'Convidar Membro',
              onPressed: _inviteMember,
            )
          else
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: M3Shapes.shapeLarge,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const M3EdgeInsets.symmetric(
                  vertical: M3SpacingToken.space8,
                ),
                child: Column(
                  children: members.map((member) {
                    final isLast = member == members.last;
                    return Column(
                      children: [
                        MemberListItem(
                          member: member,
                          isCurrentUser: member.userId == _currentUserId,
                          onPromote: () => _promoteMember(member),
                          onRemove: () => _removeMemberBottomSheet(member),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            indent: M3SpacingToken.space16.value,
                            endIndent: M3SpacingToken.space16.value,
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCatsSection(BuildContext context) {
    final theme = Theme.of(context);
    final cats = _cats ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const M3EdgeInsets.symmetric(
            horizontal: M3SpacingToken.space16,
          ),
          child: Row(
            children: [
              Icon(Icons.pets, color: theme.colorScheme.primary),
              SizedBox(width: M3SpacingToken.space8.value),
              Text(
                'Gatos (${cats.length})',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: M3SpacingToken.space16.value),
        if (cats.isEmpty)
          Padding(
            padding: const M3EdgeInsets.symmetric(
              horizontal: M3SpacingToken.space16,
            ),
            child: _buildEmptyState(
              context,
              icon: Icons.pets_outlined,
              message: 'Nenhum gato cadastrado',
              submessage: 'Adicione os gatos que moram nesta residência',
              buttonText: 'Adicionar Gato',
              onPressed: _addCat,
            ),
          )
        else
          SizedBox(
            height: 280,
            child: ListView.separated(
              padding: const M3EdgeInsets.symmetric(
                horizontal: M3SpacingToken.space16,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: cats.length,
              separatorBuilder: (context, index) =>
                  SizedBox(width: M3SpacingToken.space16.value),
              itemBuilder: (context, index) {
                final cat = cats[index];
                return SizedBox(
                  width: 220,
                  child: HouseholdCatCard(
                    cat: cat,
                    onTap: () => context.push('/cats/${cat.id}'),
                    onEdit: () => context.push('/cats/${cat.id}/edit'),
                    onDelete: () => _deleteCatBottomSheet(cat),
                    lastFeedingStatus: 'Nunca alimentado',
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
    required String submessage,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const M3EdgeInsets.all(M3SpacingToken.space24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: M3Shapes.shapeLarge,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          SizedBox(height: M3SpacingToken.space16.value),
          Text(
            message,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: M3SpacingToken.space8.value),
          Text(
            submessage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: M3SpacingToken.space24.value),
          M3EButton.icon(
            style: M3EButtonStyle.tonal,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            onPressed: onPressed,
            icon: const Icon(Icons.add),
            label: Text(buttonText),
          ),
        ],
      ),
    );
  }

  void _setActiveHome(BuildContext context) {
    HapticsService.selectionClick();
    context.read<HomesBloc>().add(SetActiveHomeEvent(widget.home.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.home.name} definida como residência ativa'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteBottomSheet(BuildContext context) {
    HapticsService.mediumImpact();
    final theme = Theme.of(context);
    ExpressiveBottomSheet.show(
      context: context,
      title: 'Excluir Residência',
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            Text(
              'Tem certeza que deseja excluir a residência "${widget.home.name}"?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                SizedBox(width: M3SpacingToken.space16.value),
                Expanded(
                  child: M3EButton(
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.md,
                    shape: M3EButtonShape.round,
                    decoration: M3EButtonDecoration.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                    onPressed: () {
                      HapticsService.heavyImpact();
                      Navigator.of(context).pop();
                      context.read<HomesBloc>().add(
                        DeleteHomeEvent(widget.home.id),
                      );
                      context.pop();
                    },
                    child: const Text('Excluir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _inviteMember() {
    HapticsService.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de convite será implementada em breve'),
      ),
    );
  }

  void _promoteMember(HouseholdMemberDetailed member) {
    HapticsService.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promover ${member.user.fullName} - Em desenvolvimento'),
      ),
    );
  }

  void _removeMemberBottomSheet(HouseholdMemberDetailed member) {
    HapticsService.mediumImpact();
    final theme = Theme.of(context);
    ExpressiveBottomSheet.show(
      context: context,
      title: 'Remover Membro',
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_remove_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            Text(
              'Tem certeza que deseja remover ${member.user.fullName} desta residência?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                SizedBox(width: M3SpacingToken.space16.value),
                Expanded(
                  child: M3EButton(
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.md,
                    shape: M3EButtonShape.round,
                    decoration: M3EButtonDecoration.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                    onPressed: () {
                      HapticsService.heavyImpact();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Remoção de membros - Em desenvolvimento',
                          ),
                        ),
                      );
                    },
                    child: const Text('Remover'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addCat() {
    HapticsService.mediumImpact();
    context.push('/cats/create?homeId=${widget.home.id}');
  }

  void _deleteCatBottomSheet(Cat cat) {
    HapticsService.mediumImpact();
    final theme = Theme.of(context);
    ExpressiveBottomSheet.show(
      context: context,
      title: 'Excluir Gato',
      child: Padding(
        padding: const M3EdgeInsets.all(M3SpacingToken.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_forever_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: M3SpacingToken.space16.value),
            Text(
              'Tem certeza que deseja excluir ${cat.name}?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: M3SpacingToken.space24.value),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                SizedBox(width: M3SpacingToken.space16.value),
                Expanded(
                  child: M3EButton(
                    style: M3EButtonStyle.tonal,
                    size: M3EButtonSize.md,
                    shape: M3EButtonShape.round,
                    decoration: M3EButtonDecoration.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                    onPressed: () {
                      HapticsService.heavyImpact();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${cat.name} será excluído - Em desenvolvimento',
                          ),
                        ),
                      );
                    },
                    child: const Text('Excluir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
