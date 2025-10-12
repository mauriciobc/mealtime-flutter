import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/household_cat_card.dart';
import 'package:mealtime_app/features/homes/presentation/widgets/member_list_item.dart';
import 'package:mealtime_app/services/api/cats_api_service.dart';
import 'package:mealtime_app/services/api/homes_api_service.dart';
import 'package:mealtime_app/shared/widgets/error_widget.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

class HomeDetailPage extends StatefulWidget {
  final Home home;

  const HomeDetailPage({super.key, required this.home});

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HouseholdModel? _householdDetail;
  List<Cat>? _cats;
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHouseholdDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHouseholdDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final homesApi = sl<HomesApiService>();
      final catsApi = sl<CatsApiService>();

      // Buscar detalhes do household da lista (já temos members básicos)
      final householdsResponse = await homesApi.getHouseholds();
      final household = householdsResponse.data?.firstWhere(
        (h) => h.id == widget.home.id,
      );

      // Buscar gatos do household
      final catsResponse = await catsApi.getCatsByHome(widget.home.id);
      final cats = catsResponse.data?.map((catModel) => catModel.toEntity()).toList();

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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadHouseholdDetails,
                )
              : Column(
                  children: [
                    _buildTabBar(context),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMembersTab(context),
                          _buildCatsTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final owner = _householdDetail?.owner;
    final createdAt = widget.home.createdAt;
    final formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);
    final ownerName = owner?.name ?? 'Desconhecido';

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.home.name,
            style: theme.textTheme.titleLarge,
          ),
          Text(
            'Criada em $formattedDate por $ownerName',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          tooltip: 'Opções da Residência',
          onSelected: (value) {
            switch (value) {
              case 'edit':
                context.push('/homes/${widget.home.id}/edit');
                break;
              case 'set_active':
                _setActiveHome(context);
                break;
              case 'delete':
                _showDeleteDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'set_active',
              child: Row(
                children: [
                  Icon(Icons.home),
                  SizedBox(width: 8),
                  Text('Definir como Ativa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final membersCount = _householdDetail?.members?.length ?? 0;
    final catsCount = _cats?.length ?? 0;

    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: const Icon(Icons.people),
            text: 'Membros ($membersCount)',
          ),
          Tab(
            icon: const Icon(Icons.pets),
            text: 'Gatos ($catsCount)',
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(BuildContext context) {
    final theme = Theme.of(context);
    final members = _householdDetail?.householdMembers ?? [];

    return RefreshIndicator(
      onRefresh: _loadHouseholdDetails,
      child: members.isEmpty
          ? _buildEmptyMembersState(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Membros da Residência',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...members.map((member) => MemberListItem(
                  member: member,
                  isCurrentUser: member.userId == _currentUserId,
                  onPromote: () => _promoteMember(member),
                  onRemove: () => _removeMember(member),
                )),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _inviteMember,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Convidar Novo Membro'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyMembersState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum membro ainda',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Convide pessoas para participar desta residência',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _inviteMember,
            icon: const Icon(Icons.person_add),
            label: const Text('Convidar Membro'),
          ),
        ],
      ),
    );
  }

  Widget _buildCatsTab(BuildContext context) {
    final theme = Theme.of(context);
    final cats = _cats ?? [];

    return RefreshIndicator(
      onRefresh: _loadHouseholdDetails,
      child: cats.isEmpty
          ? _buildEmptyCatsState(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Gatos na Residência',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gatos gerenciados nesta residência.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: cats.length,
                  itemBuilder: (context, index) {
                    final cat = cats[index];
                    return HouseholdCatCard(
                      cat: cat,
                      onTap: () => context.push('/cats/${cat.id}'),
                      onEdit: () => context.push('/cats/${cat.id}/edit'),
                      onDelete: () => _deleteCat(cat),
                      lastFeedingStatus: 'Nunca alimentado',
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _addCat,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Gato à Residência'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCatsState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum gato cadastrado',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione os gatos que moram nesta residência',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addCat,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Gato'),
          ),
        ],
      ),
    );
  }

  void _setActiveHome(BuildContext context) {
    context.read<HomesBloc>().add(SetActiveHomeEvent(widget.home.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.home.name} definida como residência ativa'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Residência'),
        content: Text(
          'Tem certeza que deseja excluir a residência "${widget.home.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<HomesBloc>().add(DeleteHomeEvent(widget.home.id));
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _inviteMember() {
    // TODO: Implementar funcionalidade de convite
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de convite será implementada em breve'),
      ),
    );
  }

  void _promoteMember(HouseholdMemberDetailed member) {
    // TODO: Implementar promoção de membro
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Promover ${member.user.fullName} - Em desenvolvimento'),
      ),
    );
  }

  void _removeMember(HouseholdMemberDetailed member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Membro'),
        content: Text(
          'Tem certeza que deseja remover ${member.user.fullName} desta residência?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar remoção de membro
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Remoção de membros - Em desenvolvimento'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _addCat() {
    context.push('/cats/create?homeId=${widget.home.id}');
  }

  void _deleteCat(Cat cat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Gato'),
        content: Text(
          'Tem certeza que deseja excluir ${cat.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar exclusão de gato
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${cat.name} será excluído - Em desenvolvimento'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
