# Correção: Sincronização de Feeding Logs com Backend

## 🔍 Problema Identificado

Quando uma nova alimentação era registrada no **web app**, a UI do app mobile **não se atualizava automaticamente** para mostrar o novo registro. Isso acontecia porque:

### 1. Estratégia Local-First com Falha de Notificação
- O repository implementava **local-first**: retornava cache imediatamente e sincronizava em background
- A sincronização em background **não notificava** o BLoC quando novos dados chegavam
- A UI ficava desatualizada até que o usuário **recarregasse manualmente** (pull-to-refresh) ou reabrisse o app

### 2. Falta de Realtime/WebSocket
- O app **não possui** subscriptions REALTIME para feeding logs (diferente das notificações)
- Sem REALTIME, a única forma de detectar mudanças no backend seria:
  - Polling periódico
  - Refresh manual
  - Verificação ao retornar ao foreground

## ✅ Soluções Implementadas

### 1. Flag `forceRemote` em `LoadTodayFeedingLogs`

Adicionamos um parâmetro opcional `forceRemote` que permite forçar busca direta na API, ignorando o cache local:

**Arquivos modificados:**
- `lib/features/feeding_logs/presentation/bloc/feeding_logs_event.dart`
- `lib/features/feeding_logs/domain/usecases/get_today_feeding_logs.dart`
- `lib/features/feeding_logs/domain/repositories/feeding_logs_repository.dart`
- `lib/features/feeding_logs/data/repositories/feeding_logs_repository_impl.dart`
- `lib/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart`

**Implementação no repository:**

```dart
@override
Future<Either<Failure, List<FeedingLog>>> getTodayFeedingLogs({
  String? householdId,
  bool forceRemote = false,  // Novo parâmetro
}) async {
  // Se forçar busca remota, buscar diretamente da API
  if (forceRemote) {
    debugPrint('[FeedingLogsRepo] Buscando feeding logs remotamente (forceRemote=true)...');
    final feedingLogs = await remoteDataSource.getFeedingLogs(
      householdId: householdId,
    );
    // Salvar no cache para próxima busca local
    await localDataSource.cacheFeedingLogs(feedingLogs);
    return Right(feedingLogs);
  }
  
  // Comportamento original: cache-first com sync em background
  // ... resto do código
}
```

### 2. Polling Periódico na HomePage

Implementamos sincronização automática a cada **2 minutos** quando o app está ativo:

**Arquivo**: `lib/features/home/presentation/pages/home_page.dart`

**Funcionalidades:**
- Timer periódico que sincroniza automaticamente
- Usa `forceRemote=true` para garantir dados atualizados
- Cancela corretamente no dispose
- Logs de debug para rastreamento

```dart
class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Timer? _periodicSyncHandle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicSync();
  }

  /// Inicia sincronização periódica de feeding logs a cada 2 minutos
  void _startPeriodicSync() {
    _periodicSyncHandle = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      debugPrint('[HomePage] Periodic sync executando...');
      _loadFeedingLogs(forceRemote: true);  // Força busca remota
    });
    debugPrint('[HomePage] Periodic sync iniciado (a cada 2 minutos)');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _periodicSyncHandle?.cancel();
    // ... resto do dispose
    super.dispose();
  }
}
```

### 3. App Lifecycle Observer

Adicionamos observer para recarregar dados quando o app **retorna ao foreground**:

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  // Recarregar dados quando app volta ao foreground
  if (state == AppLifecycleState.resumed) {
    debugPrint('[HomePage] App retornou ao foreground, recarregando dados...');
    _loadFeedingLogs();
  }
}
```

**Benefícios:**
- Usuário volta do web app → app mobile detecta e recarrega automaticamente
- Minimiza latência de percepção

### 4. Atualização da Função `_loadFeedingLogs`

Passa `forceRemote` para o BLoC quando necessário:

```dart
void _loadFeedingLogs({bool forceRemote = false}) {
  // ...
  if (!hasData || forceRemote) {
    context.read<FeedingLogsBloc>().add(
      LoadTodayFeedingLogs(householdId: householdId, forceRemote: forceRemote),
    );
  }
}
```

## 🧪 Como Testar

### Teste 1: Polling Automático
1. Abra o app no mobile
2. Deixe na HomePage por mais de 2 minutos
3. No web app, registre uma nova alimentação
4. Aguarde até 2 minutos (máximo)
5. **Resultado esperado**: UI do mobile atualiza automaticamente

### Teste 2: Retornar ao Foreground
1. Abra o app no mobile
2. Minimize o app (volta à Home)
3. No web app, registre uma nova alimentação
4. Reabra o app mobile
5. **Resultado esperado**: UI atualiza automaticamente

### Teste 3: Logs de Debug
Verifique os logs do console:

```
[HomePage] Periodic sync iniciado (a cada 2 minutos)
[HomePage] Periodic sync executando...
[FeedingLogsRepo] Buscando feeding logs remotamente (forceRemote=true)...
[HomePage] App retornou ao foreground, recarregando dados...
```

## 📊 Estratégia de Sincronização

```
┌─────────────────────────────────────────────────────────────┐
│                    Estratégia Local-First                    │
└─────────────────────────────────────────────────────────────┘

1. Busca Local
   ├─ Cache existe? → Retorna imediatamente
   └─ Cache vazio? → Busca remota e retorna

2. Sincronização Background (forceRemote=false)
   └─ Atualiza cache silenciosamente
   
3. Sincronização Forçada (forceRemote=true)
   ├─ Busca remota diretamente
   ├─ Atualiza cache
   └─ Notifica BLoC → UI atualiza

4. Polling Automático (a cada 2 minutos)
   └─ Usa forceRemote=true

5. App Lifecycle
   └─ resume → Busca remota (forceRemote=true)
```

## ⚖️ Trade-offs

### Vantagens
- ✅ UI **sempre responsiva** (cache-first)
- ✅ Sincronização **automática** sem intervenção do usuário
- ✅ **Offline-first**: funciona sem internet (mostra cache)
- ✅ **Consistência**: garante dados atualizados periodicamente

### Desvantagens
- ⚠️ **Latência**: até 2 minutos para detectar mudanças
- ⚠️ **Bateria**: polling consome energia
- ⚠️ **Network**: requisições periódicas usam banda

### Otimizações Futuras
- 🔮 **REALTIME subscriptions**: substituir polling por websockets
- 🔮 **Push notifications**: backend notifica quando alimentação é criada
- 🔮 **Smart polling**: intervalos adaptativos baseados em atividade do usuário
- 🔮 **Cache invalidation**: estratégia mais sofisticada para detectar mudanças

## 📝 Arquivos Modificados

### Domain Layer
1. `lib/features/feeding_logs/domain/repositories/feeding_logs_repository.dart`
   - Adicionado parâmetro `forceRemote` em `getTodayFeedingLogs`

2. `lib/features/feeding_logs/domain/usecases/get_today_feeding_logs.dart`
   - Adicionado parâmetro `forceRemote` e passa para repository

### Data Layer
3. `lib/features/feeding_logs/data/repositories/feeding_logs_repository_impl.dart`
   - Implementação de `forceRemote`: busca remota direta quando true

### Presentation Layer
4. `lib/features/feeding_logs/presentation/bloc/feeding_logs_event.dart`
   - Adicionado `forceRemote` em `LoadTodayFeedingLogs`

5. `lib/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart`
   - Passa `forceRemote` do event para use case

6. `lib/features/home/presentation/pages/home_page.dart`
   - **Polling periódico** (2 minutos)
   - **App lifecycle observer**
   - Atualiza `_loadFeedingLogs` para aceitar `forceRemote`

## ✅ Resultado Final

- ✅ UI atualiza automaticamente a cada 2 minutos
- ✅ Detecta quando app volta ao foreground
- ✅ Mantém local-first para performance
- ✅ Fornece flag explícita para controlar sincronização
- ✅ Logs completos para debug

## 🔗 Referências

- [FEEDING_REGISTRATION_FIX_REPORT.md](./FEEDING_REGISTRATION_FIX_REPORT.md) - Correção anterior de criação de feedings
- [Clean Architecture](../DATABASE_STRUCTURE.md) - Estrutura do projeto
- [Flutter Lifecycle](https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html) - Documentação oficial

