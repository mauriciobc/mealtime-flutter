import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_charts/material_charts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealtime_app/core/router/app_router.dart';
import 'package:mealtime_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:mealtime_app/core/di/injection_container.dart';
import 'package:mealtime_app/core/supabase/supabase_config.dart';
import 'package:mealtime_app/features/auth/presentation/bloc/simple_auth_bloc.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_bloc.dart';
import 'package:mealtime_app/services/notifications/realtime_notification_service.dart';
import 'package:mealtime_app/services/notifications/notification_service.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_event.dart';
import 'package:mealtime_app/features/cats/presentation/bloc/cats_state.dart';
import 'package:mealtime_app/features/homes/presentation/bloc/homes_bloc.dart';
import 'package:mealtime_app/features/cats/domain/entities/cat.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_event.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/bloc/feeding_logs_state.dart';
import 'package:mealtime_app/features/feeding_logs/domain/entities/feeding_log.dart';
import 'package:mealtime_app/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart';
import 'package:mealtime_app/shared/widgets/loading_widget.dart';

/// Resultado do processamento de dados do gráfico
class ChartDataResult {
  final List<StackedBarData>? stackedData;
  final List<BarChartData>? barData;

  ChartDataResult._({this.stackedData, this.barData});

  factory ChartDataResult.stacked(List<StackedBarData> data) {
    return ChartDataResult._(stackedData: data);
  }

  factory ChartDataResult.bar(List<BarChartData> data) {
    return ChartDataResult._(barData: data);
  }

  bool get isEmpty {
    if (stackedData != null) return stackedData!.isEmpty;
    if (barData != null) return barData!.isEmpty;
    return true;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
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
      final notificationService = sl<NotificationService>();
      await notificationService.initialize();
      
      // Inicializar RealtimeNotificationService
      final realtimeService = sl<RealtimeNotificationService>();
      
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
      sl<RealtimeNotificationService>().disconnect();
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

  /// Helper para obter a última alimentação de qualquer estado que contenha logs
  FeedingLog? _getLastFeedingFromState(FeedingLogsState state) {
    // FeedingLogsLoaded já tem lastFeeding pré-computado
    if (state is FeedingLogsLoaded) {
      return state.lastFeeding;
    }
    
    // Para outros estados, fazer sort apenas se necessário
    final logs = _getFeedingLogsFromState(state);
    if (logs.isEmpty) return null;
    final sorted = List<FeedingLog>.from(logs)
      ..sort((a, b) => b.fedAt.compareTo(a.fedAt));
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimpleAuthBloc, SimpleAuthState>(
      listener: (context, state) {
        if (state is SimpleAuthInitial) {
          context.go('/login');
        }
      },
      child: BlocListener<CatsBloc, CatsState>(
        listener: (context, catsState) {
          // Load feeding logs when cats are loaded
          if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
            // Use WidgetsBinding to ensure context is ready
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadFeedingLogs();
            });
          }
        },
        child: BlocListener<FeedingLogsBloc, FeedingLogsState>(
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 24),
                            _buildSummaryCards(context),
                            const SizedBox(height: 24),
                            _buildLastFeedingSection(context),
                            const SizedBox(height: 24),
                            _buildFeedingsChartSection(context),
                            const SizedBox(height: 24),
                            _buildRecentRecordsSection(context),
                            const SizedBox(height: 24),
                            _buildMyCatsSection(context),
                            const SizedBox(height: 80), // Espaço para a navegação inferior
                          ],
                        ),
                      ),
                    ),
                    floatingActionButton: FloatingActionButton(
                      onPressed: _showFeedingBottomSheet,
                      tooltip: 'Registrar Alimentação',
                      child: const Icon(Icons.add),
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
      ),
    ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'MealTime',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                        padding: const EdgeInsets.all(4),
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

  Widget _buildSummaryCards(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          return previous.cats.length != current.cats.length;
        }
        return false;
      },
      builder: (context, catsState) {
        return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
          buildWhen: (previous, current) {
            // Always rebuild on state type change (Initial -> Loading -> Loaded/Success)
            if (previous.runtimeType != current.runtimeType) return true;
            
            // Rebuild if both are data states (Loaded or Success) and length changed
            final prevLogs = _getFeedingLogsFromState(previous);
            final currLogs = _getFeedingLogsFromState(current);
            if (prevLogs.length != currLogs.length) return true;
            
            // Rebuild if IDs changed (new feeding added)
            if (prevLogs.isNotEmpty && currLogs.isNotEmpty) {
              final prevIds = prevLogs.map((e) => e.id).toSet();
              final currIds = currLogs.map((e) => e.id).toSet();
              return prevIds != currIds;
            }
            
            return false;
          },
          builder: (context, feedingLogsState) {
            final catsCount = catsState is CatsLoaded ? catsState.cats.length : 0;
            final feedingLogs = _getFeedingLogsFromState(feedingLogsState);
            
            // Count only today's feedings for the summary card
            final now = DateTime.now();
            final todayCount = feedingLogs.where((feeding) {
              final feedingDate = feeding.fedAt;
              return feedingDate.year == now.year &&
                     feedingDate.month == now.month &&
                     feedingDate.day == now.day;
            }).length;
            
            // Calculate average portion from all feeding logs
            double averagePortion = 0.0;
            String averagePortionText = '0g';
            if (feedingLogs.isNotEmpty) {
              final amounts = feedingLogs
                  .where((f) => f.amount != null && f.amount! > 0)
                  .map((f) => f.amount!)
                  .toList();
              if (amounts.isNotEmpty) {
                averagePortion = amounts.reduce((a, b) => a + b) / amounts.length;
                // Validar que o resultado não seja NaN ou Infinity
                if (averagePortion.isFinite) {
                  averagePortionText = '${averagePortion.toStringAsFixed(1)}g';
                }
              }
            }
            
            // Get last feeding time
            String lastFeedingTime = '--:--';
            final lastFeeding = _getLastFeedingFromState(feedingLogsState);
            if (lastFeeding != null) {
              lastFeedingTime = _formatTime(lastFeeding.fedAt);
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard('Total de Gatos', catsCount.toString())),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard('Hoje', todayCount.toString())),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard('Porção Média', averagePortionText)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryCard('Última Vez', lastFeedingTime)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastFeedingSection(BuildContext context) {
    // First get cats state, then feeding logs - allows feeding logs to use cats data
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        // Always rebuild on state type change
        if (previous.runtimeType != current.runtimeType) return true;
        // Rebuild if both are loaded and cats changed
        if (previous is CatsLoaded && current is CatsLoaded) {
          if (previous.cats.length != current.cats.length) return true;
          // Compare by IDs for better performance
          final prevIds = previous.cats.map((e) => e.id).toSet();
          final currIds = current.cats.map((e) => e.id).toSet();
          return prevIds != currIds;
        }
        return false;
      },
          builder: (context, catsState) {
        // Inner BlocBuilder for FeedingLogs - has access to catsState from outer builder
        return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
          buildWhen: (previous, current) {
            // Always rebuild on state type change
            if (previous.runtimeType != current.runtimeType) return true;
            
            // Rebuild if data changed
            final prevLogs = _getFeedingLogsFromState(previous);
            final currLogs = _getFeedingLogsFromState(current);
            if (prevLogs.length != currLogs.length) return true;
            
            // Compare by IDs if same length
            if (prevLogs.isNotEmpty && currLogs.isNotEmpty) {
              final prevIds = prevLogs.map((e) => e.id).toSet();
              final currIds = currLogs.map((e) => e.id).toSet();
              return prevIds != currIds;
            }
            
            return false;
          },
          builder: (context, feedingLogsState) {
            final lastFeeding = _getLastFeedingFromState(feedingLogsState);
            Cat? cat;
            
            if (lastFeeding != null) {
              // Get cat object using optimized O(1) lookup
              if (catsState is CatsLoaded) {
                cat = catsState.getCatById(lastFeeding.catId);
                if (cat == null) {
                  debugPrint('[HomePage] _buildLastFeedingSection - WARNING: Cat not found in map, trying fallback');
                  // Fallback if cat not in map yet
                  try {
                    cat = catsState.cats.firstWhere(
                      (c) => c.id == lastFeeding.catId,
                    );
                  } catch (e) {
                    // If no exact match, just use first cat as fallback
                    if (catsState.cats.isNotEmpty) {
                      cat = catsState.cats.first;
                    }
                  }
                }
              }
            }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última Alimentação',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  debugPrint('[HomePage] Building widget - lastFeeding: ${lastFeeding?.id ?? 'null'}, cat: ${cat?.name ?? 'null'}');
                  if (lastFeeding != null && cat != null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildCatAvatar(context, cat),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Builder(
                                  builder: (context) {
                                    final currentUserId = SupabaseConfig.client.auth.currentUser?.id;
                                    final fedByText = currentUserId != null && 
                                        lastFeeding.fedBy == currentUserId
                                        ? 'Você'
                                        : 'Outro usuário';
                                    
                                    final foodTypeText = lastFeeding.foodType ?? 'Ração Seca';
                                    final amountText = lastFeeding.amount != null 
                                        ? '${lastFeeding.amount!.toStringAsFixed(0)}g de $foodTypeText'
                                        : foodTypeText;
                                    
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          amountText,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Alimentado por $fedByText',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatTime(lastFeeding.fedAt)} · ${_formatDate(lastFeeding.fedAt)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pets_outlined,
                              size: 48,
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhuma alimentação registrada',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }

  Widget _buildFeedingsChartSection(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          return previous.cats.length != current.cats.length ||
                 previous.cats.map((e) => e.id).toSet() != 
                 current.cats.map((e) => e.id).toSet();
        }
        return false;
      },
      builder: (context, catsState) {
        return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) return true;
            final prevLogs = _getFeedingLogsFromState(previous);
            final currLogs = _getFeedingLogsFromState(current);
            return prevLogs.length != currLogs.length;
          },
          builder: (context, feedingLogsState) {
            final List<Cat> cats = catsState is CatsLoaded ? catsState.cats : <Cat>[];
            final List<FeedingLog> feedingLogs = _getFeedingLogsFromState(feedingLogsState);

            // Processar dados dos últimos 7 dias
            final chartData = _prepareChartData(
              context,
              feedingLogs,
              cats,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alimentações',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Últimos 7 dias',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: !chartData.isEmpty
                        ? _buildChartWithErrorHandling(context, chartData)
                        : _buildEmptyChart(context),
                  ),
                  const SizedBox(height: 8),
                  _buildDayLabels(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Cores únicas para cada gato (até 5 gatos) - usar cores do tema
  static List<Color> _getCatColors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      colorScheme.primary,
      colorScheme.tertiary,
      colorScheme.secondary,
      colorScheme.error,
      colorScheme.inversePrimary,
    ];
  }

  /// Prepara os dados do gráfico agrupando alimentações dos últimos 7 dias
  /// Retorna dados para stacked chart (<= 5 gatos) ou bar chart simples (> 5 gatos)
  ChartDataResult _prepareChartData(BuildContext context, List<FeedingLog> feedingLogs, List<Cat> cats) {
    final now = DateTime.now();
    final int catsCount = cats.length;
    final bool useStackedChart = catsCount <= 5;
    
    if (useStackedChart && catsCount > 0) {
      // Preparar dados para stacked bar chart
      final List<StackedBarData> stackedData = [];
      
      // Processar os últimos 7 dias
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final dayLabel = DateFormat('E', 'pt_BR').format(date).substring(0, 3);
        
        // Para cada gato, contar alimentações neste dia
        final List<StackedBarSegment> segments = [];
        
        for (int catIndex = 0; catIndex < catsCount; catIndex++) {
          final cat = cats[catIndex];
          final catFeedings = feedingLogs.where((log) {
            final logDateKey = DateFormat('yyyy-MM-dd').format(log.fedAt);
            return logDateKey == dateKey && log.catId == cat.id;
          }).length;
          
          // Validar valor para evitar NaN ou Infinity
          final feedingsValue = catFeedings.toDouble();
          final safeValue = feedingsValue.isFinite && feedingsValue >= 0 
              ? feedingsValue 
              : 0.0;
          
          final colors = _getCatColors(context);
          segments.add(
            StackedBarSegment(
              value: safeValue,
              color: colors[catIndex % colors.length],
              label: cat.name,
            ),
          );
        }
        
        stackedData.add(
          StackedBarData(
            label: dayLabel,
            segments: segments,
          ),
        );
      }
      
      return ChartDataResult.stacked(stackedData);
    } else {
      // Preparar dados para bar chart simples (mais de 5 gatos ou sem gatos)
      final List<BarChartData> barData = [];
      
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final dayLabel = DateFormat('E', 'pt_BR').format(date).substring(0, 3);
        
        // Contar total de alimentações neste dia
        final dayFeedings = feedingLogs.where((log) {
          final logDateKey = DateFormat('yyyy-MM-dd').format(log.fedAt);
          return logDateKey == dateKey;
        }).length;
        
        // Validar valor para evitar NaN ou Infinity
        final feedingsValue = dayFeedings.toDouble();
        final safeValue = feedingsValue.isFinite && feedingsValue >= 0 
            ? feedingsValue 
            : 0.0;
        
        barData.add(
          BarChartData(
            value: safeValue,
            label: dayLabel,
          ),
        );
      }
      
      return ChartDataResult.bar(barData);
    }
  }


  /// Constrói o gráfico usando material_charts com tratamento de erro
  Widget _buildChartWithErrorHandling(
    BuildContext context,
    ChartDataResult chartDataResult,
  ) {
    try {
      return _buildChart(context, chartDataResult);
    } catch (e, stackTrace) {
      debugPrint('[HomePage] Erro ao renderizar gráfico: $e');
      debugPrint('[HomePage] Stack trace: $stackTrace');
      // Retornar empty chart ao invés de quebrar
      return _buildEmptyChart(context);
    }
  }

  /// Constrói o gráfico usando material_charts
  Widget _buildChart(BuildContext context, ChartDataResult chartDataResult) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Obter largura disponível do constraints
        final availableWidth = constraints.maxWidth;
        // Garantir que chartWidth seja válido e não negativo/NaN/Infinity
        final double chartWidth;
        if (availableWidth.isFinite && availableWidth > 0) {
          chartWidth = availableWidth.clamp(200.0, 800.0);
        } else {
          chartWidth = 400.0; // Fallback seguro
        }
        final chartHeight = 160.0;
        final colorScheme = Theme.of(context).colorScheme;

        if (chartDataResult.stackedData != null) {
          // Validar dados antes de renderizar
          final stackedData = chartDataResult.stackedData!;
          final validData = stackedData.where((data) {
            return data.segments.every((segment) {
              return segment.value.isFinite && segment.value >= 0;
            });
          }).toList();
          
          if (validData.isEmpty) {
            return _buildEmptyChart(context);
          }

          // Validar width e height antes de usar
          final safeWidth = chartWidth.isFinite && chartWidth > 0 
              ? chartWidth.clamp(200.0, 1000.0) 
              : 400.0;
          final safeHeight = chartHeight.isFinite && chartHeight > 0 
              ? chartHeight.clamp(150.0, 500.0) 
              : 160.0;

          // Gráfico empilhado (até 5 gatos)
          // PERFORMANCE: Desabilitar grid e values para melhorar Raster
          return SizedBox(
            width: safeWidth,
            height: safeHeight,
            child: MaterialStackedBarChart(
              data: validData,
              width: safeWidth,
              height: safeHeight,
              showGrid: false,  // ✅ Desabilitado para melhorar performance
              showValues: false,  // ✅ Desabilitado para melhorar performance
              style: StackedBarChartStyle(
                backgroundColor: colorScheme.surface,
                gridColor: colorScheme.outline.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                valueStyle: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                barSpacing: 0.3,
                cornerRadius: 2,
              ),
            ),
          );
        } else {
          // Validar dados antes de renderizar
          final barData = chartDataResult.barData!;
          final validData = barData.where((data) {
            return data.value.isFinite && data.value >= 0;
          }).toList();
          
          if (validData.isEmpty) {
            return _buildEmptyChart(context);
          }

          // Validar width e height antes de usar
          final safeWidth = chartWidth.isFinite && chartWidth > 0 
              ? chartWidth.clamp(200.0, 1000.0) 
              : 400.0;
          final safeHeight = chartHeight.isFinite && chartHeight > 0 
              ? chartHeight.clamp(150.0, 500.0) 
              : 160.0;

          // Gráfico simples (mais de 5 gatos)
          // PERFORMANCE: Desabilitar grid e values para melhorar Raster
          return SizedBox(
            width: safeWidth,
            height: safeHeight,
            child: MaterialBarChart(
              data: validData,
              width: safeWidth,
              height: safeHeight,
              showGrid: false,  // ✅ Desabilitado para melhorar performance
              showValues: false,  // ✅ Desabilitado para melhorar performance
              style: BarChartStyle(
                barColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                barSpacing: 0.3,
                labelStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
                valueStyle: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  /// Widget para quando não há dados
  Widget _buildEmptyChart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhuma alimentação registrada',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói os labels dos dias da semana
  Widget _buildDayLabels(BuildContext context) {
    final now = DateTime.now();
    final dayLabels = <String>[];
    
    // Gerar labels dos últimos 7 dias
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final weekday = DateFormat('E', 'pt_BR').format(date).substring(0, 3);
      dayLabels.add(weekday);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: dayLabels.map((label) => Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      )).toList(),
    );
  }

  Widget _buildRecentRecordsSection(BuildContext context) {
    return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        final prevLogs = _getFeedingLogsFromState(previous);
        final currLogs = _getFeedingLogsFromState(current);
        if (prevLogs.length != currLogs.length) return true;
        // Compare first 3 by IDs
        final prevFirst3 = prevLogs.take(3).map((e) => e.id).toList();
        final currFirst3 = currLogs.take(3).map((e) => e.id).toList();
        return prevFirst3.length != currFirst3.length || 
               prevFirst3.toString() != currFirst3.toString();
      },
      builder: (context, state) {
        final allFeedings = _getFeedingLogsFromState(state);
        final recentFeedings = allFeedings.take(3).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registros Recentes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (recentFeedings.isNotEmpty)
                ...recentFeedings.map((feeding) => _buildRecentRecordItem(feeding, key: ValueKey(feeding.id)))
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Nenhum registro recente',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentRecordItem(FeedingLog feeding, {Key? key}) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          // Only rebuild if the specific cat for this feeding changed
          final prevCat = previous.getCatById(feeding.catId);
          final currCat = current.getCatById(feeding.catId);
          if (prevCat == null || currCat == null) return true;
          return prevCat.name != currCat.name;
        }
        return false;
      },
        builder: (context, catsState) {
        Cat? cat;
        if (catsState is CatsLoaded) {
          // Use optimized O(1) lookup instead of firstWhere O(n)
          cat = catsState.getCatById(feeding.catId);
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              cat != null 
                  ? _buildSmallCatAvatar(context, cat)
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.pets, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat?.name ?? 'Nome não encontrado',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      feeding.amount != null 
                          ? '${feeding.amount!.toStringAsFixed(0)}g de ração'
                          : 'Ração não especificada',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatTime(feeding.fedAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyCatsSection(BuildContext context) {
    return BlocBuilder<CatsBloc, CatsState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is CatsLoaded && current is CatsLoaded) {
          // Only rebuild if the first 3 cats changed (compare by IDs)
          final prevIds = previous.cats.take(3).map((e) => e.id).toList();
          final currIds = current.cats.take(3).map((e) => e.id).toList();
          if (prevIds.length != currIds.length) return true;
          for (int i = 0; i < prevIds.length; i++) {
            if (prevIds[i] != currIds[i]) return true;
          }
        }
        return false;
      },
      builder: (context, state) {
        List<Cat> cats = [];
        if (state is CatsLoaded) {
          cats = state.cats.take(3).toList();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meus Gatos',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              if (cats.isNotEmpty)
                ...cats.map((cat) => _buildMyCatsItem(cat, key: ValueKey(cat.id)))
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Nenhum gato cadastrado',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRouter.cats),
                  child: Text(
                    'Ver todos os gatos',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyCatsItem(Cat cat, {Key? key}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSmallCatAvatar(context, cat),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cat.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${cat.currentWeight?.toStringAsFixed(1) ?? '4.5'}kg',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  void _showFeedingBottomSheet() {
    final catsBloc = context.read<CatsBloc>();
    final catsState = catsBloc.state;

    if (catsState is! CatsLoaded || catsState.cats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum gato cadastrado. Cadastre um gato primeiro.'),
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

  Widget _buildCatAvatar(BuildContext context, Cat cat) {
    final theme = Theme.of(context);
    
    // Validar se a URL existe e é válida (começa com http)
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null && 
        imageUrl.isNotEmpty && 
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    
    if (hasValidImageUrl) {
      final trimmedUrl = imageUrl.trim();
      
      return SizedBox(
        width: 60,
        height: 60,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: trimmedUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 60,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Material3LoadingIndicator(size: 24.0),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 60,
                height: 60,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.pets,
                  size: 30,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),
        ),
      );
    }
    
    return CircleAvatar(
      radius: 30,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.pets,
        size: 30,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSmallCatAvatar(BuildContext context, Cat cat) {
    final theme = Theme.of(context);
    
    // Validar se a URL existe e é válida (começa com http)
    final imageUrl = cat.imageUrl;
    final hasValidImageUrl = imageUrl != null && 
        imageUrl.isNotEmpty && 
        imageUrl.trim().isNotEmpty &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    
    if (hasValidImageUrl) {
      final trimmedUrl = imageUrl.trim();
      
      return SizedBox(
        width: 40,
        height: 40,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: trimmedUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 40,
              height: 40,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Material3LoadingIndicator(size: 20.0),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                width: 40,
                height: 40,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.pets,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
      );
    }
    
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.pets,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
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
      return GestureDetector(
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
      );
    }

    final profileAsync = ref.watch(currentUserProfileProvider);

    return GestureDetector(
      onTap: () {
        context.push(AppRouter.profile);
      },
      child: profileAsync.when(
        data: (profile) {
          final avatarUrl = profile?.avatarUrl;
          final initial = profile?.fullName?.substring(0, 1).toUpperCase() ??
              user.email?.substring(0, 1).toUpperCase() ??
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onSecondary,
                        ),
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
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ),
        error: (_, __) => GestureDetector(
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
    );
  }
}
