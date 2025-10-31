# 🛠️ Exemplos Práticos de Correções de Performance

Este documento contém exemplos práticos de como corrigir os problemas identificados no relatório de performance.

---

## 1. Adicionar `buildWhen` aos BlocBuilders

### ❌ Antes (Problema)

```dart
Widget _buildSummaryCards(BuildContext context) {
  return BlocBuilder<CatsBloc, CatsState>(
    builder: (context, catsState) {
      return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
        builder: (context, feedingLogsState) {
          final catsCount = catsState is CatsLoaded ? catsState.cats.length : 0;
          final todayCount = feedingLogsState is FeedingLogsLoaded 
              ? feedingLogsState.feeding_logs.length 
              : 0;
          // ...
        },
      );
    },
  );
}
```

### ✅ Depois (Otimizado)

```dart
Widget _buildSummaryCards(BuildContext context) {
  return BlocBuilder<CatsBloc, CatsState>(
    buildWhen: (previous, current) {
      // Rebuild apenas se o número de gatos mudou ou estado mudou
      if (previous is CatsLoaded && current is CatsLoaded) {
        return previous.cats.length != current.cats.length;
      }
      return previous.runtimeType != current.runtimeType;
    },
    builder: (context, catsState) {
      return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
        buildWhen: (previous, current) {
          // Rebuild apenas se o número de registros mudou ou estado mudou
          if (previous is FeedingLogsLoaded && current is FeedingLogsLoaded) {
            return previous.feeding_logs.length != current.feeding_logs.length;
          }
          return previous.runtimeType != current.runtimeType;
        },
        builder: (context, feedingLogsState) {
          final catsCount = catsState is CatsLoaded ? catsState.cats.length : 0;
          final todayCount = feedingLogsState is FeedingLogsLoaded 
              ? feedingLogsState.feeding_logs.length 
              : 0;
          // ...
        },
      );
    },
  );
}
```

---

## 2. Mover Operações Pesadas Para Fora do Build

### ❌ Antes (Problema)

```dart
Widget _buildLastFeedingSection(BuildContext context) {
  return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
    builder: (context, feedingLogsState) {
      if (feedingLogsState is FeedingLogsLoaded) {
        if (feedingLogsState.feeding_logs.isNotEmpty) {
          // ⚠️ Sort executado a cada rebuild
          final sortedFeedings = List<FeedingLog>.from(feedingLogsState.feeding_logs);
          sortedFeedings.sort((a, b) => b.fedAt.compareTo(a.fedAt));
          lastFeeding = sortedFeedings.first;
        }
      }
      // ...
    },
  );
}
```

### ✅ Depois (Otimizado - Opção 1: Computar no BLoC)

**No FeedingLogsBloc:**
```dart
// No estado FeedingLogsLoaded, manter lista já ordenada
class FeedingLogsLoaded extends FeedingLogsState {
  final List<FeedingLog> feeding_logs;
  final FeedingLog? lastFeeding; // ✅ Pré-computado
  
  const FeedingLogsLoaded({
    required this.feeding_logs,
    this.lastFeeding,
  });
  
  factory FeedingLogsLoaded.fromList(List<FeedingLog> logs) {
    if (logs.isEmpty) {
      return const FeedingLogsLoaded(feeding_logs: [], lastFeeding: null);
    }
    
    // Ordenar uma vez
    final sorted = List<FeedingLog>.from(logs)
      ..sort((a, b) => b.fedAt.compareTo(a.fedAt));
    
    return FeedingLogsLoaded(
      feeding_logs: sorted,
      lastFeeding: sorted.first,
    );
  }
}
```

**No Widget:**
```dart
Widget _buildLastFeedingSection(BuildContext context) {
  return BlocSelector<FeedingLogsBloc, FeedingLogsState, FeedingLog?>(
    selector: (state) {
      if (state is FeedingLogsLoaded) {
        return state.lastFeeding; // ✅ Já computado
      }
      return null;
    },
    builder: (context, lastFeeding) {
      // Usar lastFeeding diretamente
      // ...
    },
  );
}
```

### ✅ Depois (Otimizado - Opção 2: Usar BlocSelector)

```dart
Widget _buildLastFeedingSection(BuildContext context) {
  return BlocSelector<FeedingLogsBloc, FeedingLogsState, FeedingLog?>(
    selector: (state) {
      if (state is! FeedingLogsLoaded || state.feeding_logs.isEmpty) {
        return null;
      }
      // Esta computação só roda quando a lista muda
      final sorted = [...state.feeding_logs];
      sorted.sort((a, b) => b.fedAt.compareTo(a.fedAt));
      return sorted.first;
    },
    buildWhen: (previous, current) {
      // Só rebuild se a lista mudou
      if (previous is FeedingLogsLoaded && current is FeedingLogsLoaded) {
        return previous.feeding_logs.length != current.feeding_logs.length ||
               previous.feeding_logs.firstOrNull?.id != current.feeding_logs.firstOrNull?.id;
      }
      return false;
    },
    builder: (context, lastFeeding) {
      // ...
    },
  );
}
```

---

## 3. Consolidar Múltiplos BlocBuilders

### ❌ Antes (Problema)

```dart
// Cada widget tem seu próprio BlocBuilder
_buildSummaryCards(context)      // BlocBuilder CatsBloc + FeedingLogsBloc
_buildLastFeedingSection(context) // BlocBuilder FeedingLogsBloc + CatsBloc
_buildRecentRecordsSection(context) // BlocBuilder FeedingLogsBloc
_buildMyCatsSection(context)     // BlocBuilder CatsBloc
```

### ✅ Depois (Otimizado)

```dart
@override
Widget build(BuildContext context) {
  return BlocBuilder<CatsBloc, CatsState>(
    buildWhen: (previous, current) {
      // Lógica de buildWhen otimizada
      return previous.runtimeType != current.runtimeType ||
             (previous is CatsLoaded && current is CatsLoaded && 
              previous.cats.length != current.cats.length);
    },
    builder: (context, catsState) {
      return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
        buildWhen: (previous, current) {
          return previous.runtimeType != current.runtimeType ||
                 (previous is FeedingLogsLoaded && current is FeedingLogsLoaded && 
                  previous.feeding_logs.length != current.feeding_logs.length);
        },
        builder: (context, feedingLogsState) {
          // ✅ Único ponto de rebuild, dados passados como parâmetros
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildSummaryCards(context, catsState, feedingLogsState),
                  const SizedBox(height: 24),
                  _buildLastFeedingSection(context, catsState, feedingLogsState),
                  const SizedBox(height: 24),
                  _buildRecentRecordsSection(context, feedingLogsState),
                  const SizedBox(height: 24),
                  _buildMyCatsSection(context, catsState),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ✅ Métodos agora recebem estado como parâmetro
Widget _buildSummaryCards(
  BuildContext context,
  CatsState catsState,
  FeedingLogsState feedingLogsState,
) {
  // Sem BlocBuilder aqui!
  final catsCount = catsState is CatsLoaded ? catsState.cats.length : 0;
  final todayCount = feedingLogsState is FeedingLogsLoaded 
      ? feedingLogsState.feeding_logs.length 
      : 0;
  // ...
}
```

---

## 4. Usar ListView.builder em vez de List.map()

### ❌ Antes (Problema)

```dart
if (recentFeedings.isNotEmpty)
  ...recentFeedings.map((feeding) => _buildRecentRecordItem(feeding))
```

### ✅ Depois (Otimizado)

```dart
if (recentFeedings.isNotEmpty)
  ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: recentFeedings.length,
    itemBuilder: (context, index) {
      return _buildRecentRecordItem(recentFeedings[index]);
    },
  )
```

**Ou melhor ainda, se os dados vêm do BLoC:**

```dart
Widget _buildRecentRecordsSection(
  BuildContext context,
  FeedingLogsState state,
  List<Cat> cats, // ✅ Passado como parâmetro
) {
  List<FeedingLog> recentFeedings = [];
  if (state is FeedingLogsLoaded) {
    recentFeedings = state.feeding_logs.take(3).toList();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
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
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentFeedings.length,
            itemBuilder: (context, index) {
              return _buildRecentRecordItem(
                recentFeedings[index],
                cats, // ✅ Passado como parâmetro
              );
            },
          )
        else
          // Empty state
      ],
    ),
  );
}

Widget _buildRecentRecordItem(
  FeedingLog feeding,
  List<Cat> cats, // ✅ Sem BlocBuilder aqui!
) {
  // Buscar cat uma vez
  final cat = cats.firstWhereOrNull(
    (cat) => cat.id == feeding.catId,
  );
  final catName = cat?.name ?? 'Gato';
  
  // ...
}
```

---

## 5. Remover Debug Prints e Adicionar Const

### ❌ Antes (Problema)

```dart
@override
Widget build(BuildContext context) {
  print('🎨 [DEBUG] Building Last Feeding Section'); // ❌
  print('🎨 [DEBUG] FeedingLogsState: $feedingLogsState'); // ❌
  
  return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
    builder: (context, feedingLogsState) {
      print('🎨 [DEBUG] FeedingLogs loaded, count: ${feedingLogsState.feeding_logs.length}'); // ❌
      // ...
    },
  );
}
```

### ✅ Depois (Otimizado)

```dart
@override
Widget build(BuildContext context) {
  // ✅ Removido todos os prints
  
  return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
    buildWhen: (previous, current) {
      // Lógica otimizada
      return previous.runtimeType != current.runtimeType ||
             (previous is FeedingLogsLoaded && current is FeedingLogsLoaded && 
              previous.feeding_logs.length != current.feeding_logs.length);
    },
    builder: (context, feedingLogsState) {
      // ...
    },
  );
}

// ✅ Adicionar const onde possível
const SizedBox(height: 24),
const Icon(Icons.pets),
```

---

## 6. Otimizar didChangeDependencies

### ❌ Antes (Problema)

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // ⚠️ Pode ser chamado múltiplas vezes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadFeedingLogs();
  });
}

void _loadFeedingLogs() {
  // ⚠️ Sem verificação se já está carregando
  final catsState = context.read<CatsBloc>().state;
  if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
    final householdId = catsState.cats.first.homeId;
    if (_currentHouseholdId != householdId) {
      _currentHouseholdId = householdId;
      context.read<FeedingLogsBloc>().add(LoadTodayFeedingLogs(householdId: householdId));
    }
  }
}
```

### ✅ Depois (Otimizado)

```dart
class _HomePageState extends State<HomePage> {
  String? _currentHouseholdId;
  bool _hasLoadedFeedingLogs = false; // ✅ Flag de controle

  @override
  void initState() {
    super.initState();
    context.read<CatsBloc>().add(LoadCats());
    context.read<HomesBloc>().add(LoadHomes());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ Executar apenas uma vez
    if (!_hasLoadedFeedingLogs) {
      _hasLoadedFeedingLogs = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadFeedingLogs();
      });
    }
  }

  void _loadFeedingLogs() {
    final catsState = context.read<CatsBloc>().state;
    final feedingLogsState = context.read<FeedingLogsBloc>().state;
    
    // ✅ Verificar se já está carregando
    if (feedingLogsState is FeedingLogsLoading) {
      return; // Já está carregando, não fazer nada
    }
    
    if (catsState is CatsLoaded && catsState.cats.isNotEmpty) {
      final householdId = catsState.cats.first.homeId;
      
      // ✅ Verificar se realmente precisa recarregar
      if (_currentHouseholdId != householdId) {
        _currentHouseholdId = householdId;
        context.read<FeedingLogsBloc>().add(LoadTodayFeedingLogs(householdId: householdId));
      }
    }
  }
}
```

---

## 7. Desabilitar LogInterceptor em Produção

### ❌ Antes (Problema)

```dart
// lib/core/di/injection_container.dart
final dio = Dio(/* ... */);
dio.interceptors.add(AuthInterceptor());
dio.interceptors.add(
  LogInterceptor(requestBody: true, responseBody: true, error: true), // ❌ Sempre ativo
);
```

### ✅ Depois (Otimizado)

```dart
// lib/core/di/injection_container.dart
import 'package:flutter/foundation.dart';

final dio = Dio(/* ... */);
dio.interceptors.add(AuthInterceptor());

// ✅ Apenas em modo debug
if (kDebugMode) {
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      // Opcional: limitar tamanho do log
      requestHeader: false,
      responseHeader: false,
    ),
  );
}
```

---

## 8. Usar BlocSelector para Extrações Específicas

### ❌ Antes (Problema)

```dart
Widget _buildMyCatsSection(BuildContext context) {
  return BlocBuilder<CatsBloc, CatsState>(
    builder: (context, state) {
      List<Cat> cats = [];
      if (state is CatsLoaded) {
        cats = state.cats.take(3).toList();
      }
      // ...
    },
  );
}
```

### ✅ Depois (Otimizado)

```dart
Widget _buildMyCatsSection(BuildContext context) {
  return BlocSelector<CatsBloc, CatsState, List<Cat>>(
    selector: (state) {
      if (state is CatsLoaded) {
        return state.cats.take(3).toList();
      }
      return [];
    },
    buildWhen: (previous, current) {
      // ✅ Rebuild apenas se a lista de gatos mudou
      if (previous is CatsLoaded && current is CatsLoaded) {
        final prevTop3 = previous.cats.take(3).map((c) => c.id).toList();
        final currTop3 = current.cats.take(3).map((c) => c.id).toList();
        return !prevTop3.equals(currTop3); // Comparar IDs
      }
      return previous.runtimeType != current.runtimeType;
    },
    builder: (context, cats) {
      // Usar cats diretamente, já processado
      // ...
    },
  );
}
```

---

## Resumo das Melhores Práticas

1. ✅ **Sempre use `buildWhen`** em BlocBuilder quando possível
2. ✅ **Não faça operações pesadas** (sort, filter, map) no método build
3. ✅ **Consolide BlocBuilders** quando estiverem escutando o mesmo Bloc
4. ✅ **Use BlocSelector/BlocListener** para extrair dados específicos
5. ✅ **Prefira ListView.builder** sobre List.map() para listas
6. ✅ **Adicione `const`** em widgets estáticos
7. ✅ **Remova debug prints** ou use `debugPrint` condicional
8. ✅ **Use flags** para evitar chamadas repetidas
9. ✅ **Verifique estado antes** de fazer novas chamadas API
10. ✅ **Desabilite logs** em produção

---

**Desenvolvido com Cursor AI**  
*Data: 12 de Outubro de 2025*  
*Versão: 1.0.0*



