import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design/material_design.dart';
import 'package:mealtime_app/core/providers/app_providers.dart';
import 'package:mealtime_app/core/localization/app_localizations_extension.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/core/theme/text_theme_extensions.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart';
import 'package:mealtime_app/features/home/presentation/widgets/feedings_chart_section.dart';
import 'package:mealtime_app/features/home/presentation/widgets/last_feeding_section.dart';
import 'package:mealtime_app/features/home/presentation/widgets/my_cats_section.dart';
import 'package:mealtime_app/features/home/presentation/widgets/recent_records_section.dart';
import 'package:mealtime_app/features/home/presentation/widgets/summary_cards_section.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';
import 'package:m3e_collection/m3e_collection.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  String? _currentHouseholdId;
  bool _notificationsInitialized = false;
  int _unreadNotificationsCount = 0; // Inicializar com 0, será carregado do banco
  Timer? _periodicSyncHandle; // Handle para cancelar periodic sync

  @override
  void initState() {
    super.initState();
    // Registrar observer para detectar quando app volta ao foreground
    WidgetsBinding.instance.addObserver(this);
    
    // Carregar dados iniciais
    context.read<CatsBloc>().add(LoadCats());
    // Homes loading is optional - don't block UI if it fails
    try {
      context.read<HomesBloc>().add(LoadHomes());
    } catch (e) {
      debugPrint('[HomePage] Failed to load homes (non-critical): $e');
    }
    // Inicializar notificações REALTIME
    _initializeNotifications();
    
    // Iniciar periodic sync para alimentações
    _startPeriodicSync();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recarregar dados quando app volta ao foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('[HomePage] App retornou ao foreground, recarregando dados...');
      _loadFeedingLogs();
    }
  }
  
  /// Inicia sincronização periódica de feeding logs a cada 30 segundos
  void _startPeriodicSync() {
    // Limpar handle anterior se existir
    _periodicSyncHandle?.cancel();
    
    // Criar periodic timer
    _periodicSyncHandle = _createPeriodicTimer();
    
    debugPrint('[HomePage] Periodic sync iniciado (a cada 2 minutos)');
  }
  
  /// Cria um timer periódico que sincroniza feeding logs
  Timer _createPeriodicTimer() {
    return Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      debugPrint('[HomePage] Periodic sync executando...');
      _loadFeedingLogs(forceRemote: true);
    });
  }

  Future<void> _initializeNotifications() async {
    if (_notificationsInitialized) return;
    
    try {
      // Inicializar NotificationService primeiro
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.initialize();

      // Inicializar RealtimeNotificationService
      final realtimeService = ref.read(realtimeNotificationServiceProvider);
      
      // Configurar callback para incrementar badge quando notificação for recebida
      realtimeService.onNotificationReceived = _incrementNotificationCount;
      
      await realtimeService.initialize();
      
      // Buscar notificações não lidas do banco de dados
      await _loadUnreadNotificationsCount();
      
      _notificationsInitialized = true;
      debugPrint('[HomePage] Notificações REALTIME inicializadas');
    } catch (e) {
      debugPrint('[HomePage] Erro ao inicializar notificações: $e');
    }
  }

  /// Incrementa o contador de notificações não lidas
  void _incrementNotificationCount() {
    if (mounted) {
      setState(() {
        _unreadNotificationsCount++;
      });
    }
  }


  /// Carrega a contagem de notificações não lidas do banco de dados
  Future<void> _loadUnreadNotificationsCount() async {
    try {
      final supabase = SupabaseConfig.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        debugPrint('[HomePage] Usuário não autenticado, não é possível carregar notificações');
        if (mounted) {
          setState(() {
            _unreadNotificationsCount = 0;
          });
        }
        return;
      }

      // Buscar notificações não lidas da tabela notifications
      // Tentar primeiro com is_read, se falhar, usar read_at
      try {
        final response = await supabase
            .from('notifications')
            .select('id')
            .eq('user_id', user.id)
            .eq('is_read', false);
        
        if (mounted) {
          final count = response.length;
          setState(() {
            _unreadNotificationsCount = count;
          });
          debugPrint('[HomePage] Notificações não lidas carregadas: $_unreadNotificationsCount');
        }
      } catch (_) {
        // Se is_read não existir, usar read_at (timestamp)
        final response = await supabase
            .from('notifications')
            .select('id, read_at')
            .eq('user_id', user.id);
        
        final unreadCount = (response as List)
            .where((n) => (n as Map<String, dynamic>)['read_at'] == null)
            .length;
        
        if (mounted) {
          setState(() {
            _unreadNotificationsCount = unreadCount;
          });
          debugPrint('[HomePage] Notificações não lidas carregadas: $_unreadNotificationsCount');
        }
      }
    } catch (e) {
      debugPrint('[HomePage] Erro ao carregar notificações não lidas: $e');
      // Em caso de erro, manter o valor atual ou 0
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    // Remover observer
    WidgetsBinding.instance.removeObserver(this);
    
    // Cancelar periodic sync
    _periodicSyncHandle?.cancel();
    
    // Desconectar notificações quando sair da página
    try {
      ref.read(realtimeNotificationServiceProvider).disconnect();
    } catch (e) {
      debugPrint('[HomePage] Erro ao desconectar notificações: $e');
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Removed _loadFeedingLogs call from here to prevent duplicate calls
    // Loading is now handled by BlocListener<CatsBloc> only
  }

  void _loadFeedingLogs({bool forceRemote = false}) {
    final catsState = context.read<CatsBloc>().state;
    final feedingLogsState = context.read<FeedingLogsBloc>().state;
    
    // Prevent duplicate calls - don't load if already loading
    if (feedingLogsState is FeedingLogsLoading) {
      debugPrint('[HomePage] Skipping _loadFeedingLogs: already loading');
      return;
    }
    
    if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
      final householdId = catsState.cats.first.homeId;
      
      if (_currentHouseholdId != householdId) {
        _currentHouseholdId = householdId;
        debugPrint('[HomePage] Loading feeding logs for household: $householdId');
        context.read<FeedingLogsBloc>().add(
          LoadTodayFeedingLogs(householdId: householdId, forceRemote: forceRemote),
        );
      } else {
        debugPrint('[HomePage] Household ID unchanged, checking if reload needed');
        // If household unchanged but no data, reload anyway
        final hasData = _getFeedingLogsFromState(feedingLogsState).isNotEmpty;
        if (!hasData || forceRemote) {
          debugPrint(
            '[HomePage] Reloading feeding logs (no data or not loaded or forceRemote=$forceRemote)',
          );
          context.read<FeedingLogsBloc>().add(
            LoadTodayFeedingLogs(householdId: householdId, forceRemote: forceRemote),
          );
        }
      }
    } else {
      debugPrint('[HomePage] Cannot load feeding logs: cats not loaded or empty');
    }
  }

  /// Helper para extrair feeding logs de qualquer estado que os contenha
  List<FeedingLog> _getFeedingLogsFromState(FeedingLogsState state) {
    if (state is FeedingLogsLoaded) {
      return state.feedingLogs;
    } else if (state is FeedingLogOperationSuccess) {
      return state.feedingLogs;
    } else if (state is FeedingLogOperationInProgress) {
      return state.feedingLogs;
    }
    return [];
  }


  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SimpleAuthBloc, SimpleAuthState>(
          listener: (context, state) {
            if (state is SimpleAuthInitial) {
              context.go('/login');
            }
          },
        ),
        BlocListener<CatsBloc, CatsState>(
          listener: (context, catsState) {
            // Load feeding logs when cats are loaded
            if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
              // Use WidgetsBinding to ensure context is ready
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadFeedingLogs();
              });
            }
          },
        ),
        BlocListener<FeedingLogsBloc, FeedingLogsState>(
          listener: (context, feedingLogsState) {
            // Recarregar dados quando uma operação de criação for bem-sucedida
            if (feedingLogsState is FeedingLogOperationSuccess) {
              final catsState = context.read<CatsBloc>().state;
              if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
                final householdId = catsState.cats.first.homeId;
                final feedingLogsBloc = context.read<FeedingLogsBloc>();
                debugPrint(
                  '[HomePage] Operação bem-sucedida, recarregando dados para household: $householdId',
                );
                // Aguardar um pouco para garantir que o servidor processou
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    if (!mounted) return;
                    feedingLogsBloc.add(
                      LoadTodayFeedingLogs(householdId: householdId),
                    );
                  });
                });
              }
            }
          },
        ),
      ],
      child: BlocBuilder<CatsBloc, CatsState>(
        builder: (context, catsState) {
          // Mostrar loader apenas quando está carregando pela primeira vez
          final bool isLoading = catsState is CatsLoading || 
                               (catsState is CatsInitial);

          return Stack(
            children: [
              Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                body: SafeArea(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // 1. Header
                      SliverToBoxAdapter(child: _buildHeader(context)),

                      // 2. Summary Cards
                      const SliverPadding(
                        padding: EdgeInsets.only(top: 24),
                        sliver: SliverToBoxAdapter(child: SummaryCardsSection()),
                      ),

                      // 3. Last Feeding
                      const SliverPadding(
                        padding: EdgeInsets.only(top: 24),
                        sliver: SliverToBoxAdapter(child: LastFeedingSection()),
                      ),

                      // 4. Chart Section
                      const SliverPadding(
                        padding: EdgeInsets.only(top: 24),
                        sliver: SliverToBoxAdapter(child: FeedingsChartSection()),
                      ),

                      // 5. Recent Records
                      const SliverPadding(
                        padding: EdgeInsets.only(top: 24),
                        sliver: SliverToBoxAdapter(child: RecentRecordsSection()),
                      ),

                      // 6. My Cats
                      const SliverPadding(
                        padding: EdgeInsets.only(top: 24),
                        sliver: SliverToBoxAdapter(child: MyCatsSection()),
                      ),

                      // Bottom Spacing for FAB
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
                floatingActionButton: FabM3E(
                  icon: const Icon(Icons.add),
                  onPressed: _showFeedingBottomSheet,
                  tooltip: context.l10n.home_register_feeding,
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              ),
              // Overlay de loader Material 3 que não bloqueia listeners
              if (isLoading)
                Material(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  child: const Center(
                    child: Material3LoadingIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const M3EdgeInsets.symmetric(
        horizontal: M3SpacingToken.space16,
        vertical: M3SpacingToken.space8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.l10n.home_last_7_days, // This is a misplacement from the instruction, but following it.
            style: Theme.of(context).textTheme.headlineMediumEmphasized?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButtonM3E(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    tooltip: context.l10n.navigation_notifications,
                    onPressed: () async {
                      // Navegar para a página de notificações com callback
                      await context.push(
                        AppRouter.notifications,
                        extra: {
                          'onUnreadCountChanged': _loadUnreadNotificationsCount,
                        },
                      );
                      
                      // Recarregar contagem ao voltar da página (backup)
                      if (mounted) {
                        await _loadUnreadNotificationsCount();
                      }
                    },
                  ),
                  // Badge de notificações não lidas
                  if (_unreadNotificationsCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const M3EdgeInsets.all(M3SpacingToken.space4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            _unreadNotificationsCount > 99
                                ? '99+'
                                : '$_unreadNotificationsCount',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              _UserAvatarButton(),
            ],
          ),
        ],
      ),
    );
  }


  void _showFeedingBottomSheet() {
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

    // Pegar householdId do primeiro gato (assumindo mesmo household)
    final householdId = catsState.cats.first.homeId;

    // Obter os blocs do contexto atual para passar ao bottom sheet
    final authBloc = context.read<SimpleAuthBloc>();
    final feedingLogsBloc = context.read<FeedingLogsBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      builder: (bottomSheetContext) => BlocProvider.value(
        value: authBloc,
        child: BlocProvider.value(
          value: feedingLogsBloc,
          child: SizedBox(
            height: MediaQuery.of(bottomSheetContext).size.height * 0.9,
            child: FeedingBottomSheet(
              availableCats: catsState.cats,
              householdId: householdId,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para o avatar do usuário no header da home page
class _UserAvatarButton extends ConsumerWidget {
  const _UserAvatarButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = SupabaseConfig.client.auth.currentUser;
    
    if (user == null) {
    return Semantics(
      label: context.l10n.navigation_profile,
      button: true,
      child: GestureDetector(
        onTap: () {
          context.push(AppRouter.profile);
        },
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }

  final profileAsync = ref.watch(currentUserProfileProvider);

  return Semantics(
    label: context.l10n.navigation_profile,
    button: true,
    child: GestureDetector(
      onTap: () {
        context.push(AppRouter.profile);
      },
      child: profileAsync.when(
        data: (profile) {
          final avatarUrl = profile?.avatarUrl;
          final initial = (profile?.fullName?.isNotEmpty == true
                  ? profile!.fullName!.substring(0, 1).toUpperCase()
                  : null) ??
              (user.email?.isNotEmpty == true
                  ? user.email!.substring(0, 1).toUpperCase()
                  : null) ??
              'U';

          if (avatarUrl != null && avatarUrl.isNotEmpty) {
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.secondary,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicatorM3E(
                        size: CircularProgressM3ESize.s,
                        activeColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: Text(
              initial,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        loading: () => CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicatorM3E(
              size: CircularProgressM3ESize.s,
              activeColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ),
        error: (_, _) => Semantics(
          label: context.l10n.navigation_profile,
          button: true,
          child: GestureDetector(
            onTap: () {
              context.push(AppRouter.profile);
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}
