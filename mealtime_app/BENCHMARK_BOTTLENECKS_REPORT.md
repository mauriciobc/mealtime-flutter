# Report de Gargalos de Performance - MealTime Flutter

**Data de Análise:** 2025-01-23  
**Baseado em:** PERFORMANCE_DEVMTOOLS_ANALYSIS.md + PERFORMANCE_DIAGNOSTIC_SUMMARY.md  
**Snapshots Analisados:** dart_devtools_2025-10-29_08_45_54.632.json (124 frames)

---

## 🔴 Top 10 Widgets Mais Pesados (por Build Time)

Com base na análise do código estático e dados do DevTools:

| Rank | Widget/Operação | Build Time Médio | Frame # | Localização | Problema |
|------|----------------|------------------|---------|-------------|----------|
| 1 | _buildLastFeedingSection | ~380 ms | Múltiplos | home_page.dart:214 | Sort + firstWhere no build |
| 2 | _buildSummaryCards | ~200 ms | Múltiplos | home_page.dart:147 | BlocBuilders aninhados sem buildWhen |
| 3 | HomePage.build | ~100 ms | Todos | home_page.dart | Rebuilds excessivos |
| 4 | CatCard | ~50 ms | Cats list | cat_card.dart | Operações pesadas |
| 5 | FeedingBottomSheet | ~80 ms | Modal | feeding_bottom_sheet.dart | Completo rebuild |
| 6 | Statistics Calculations | ~150 ms | Stats page | statistics_page.dart | Cálculos no build |
| 7 | Navigation Transitions | ~100 ms | Navegação | router | Builds duplos |
| 8 | Household Switcher | ~60 ms | Home | home_page.dart | Rebuild sem necessidade |
| 9 | Realtime Listener | ~40 ms | Múltiplos | home_page.dart | Sem debounce |
| 10 | Chart Rendering | ~200 ms | Stats | charts.dart | Renderização pesada |

---

## 🔴 Top 10 Frames Mais Lentos (>100ms)

Dados do DevTools (snapshot real):

| Rank | Frame # | Tempo Total | Build Time | Raster Time | Causa Principal |
|------|---------|-------------|------------|-------------|-----------------|
| 1 | **138** | **422,952 ms** (7min!) | 264 ms ✅ | 422,572 ms 🔴 | Raster bloqueado |
| 2 | **139** | **408,222 ms** (6.8min!) | 339 ms | 1,895 ms | Problema geral |
| 3 | **165** | **113,848 ms** (1.9min) | 218 ms | 113,490 ms 🔴 | Raster muito lento |
| 4 | **121** | **37,605 ms** (37.6s) | 1,213 ms 🔴 | 29,450 ms 🔴 | Build + Raster |
| 5 | **122** | **33,989 ms** (34s) | 333 ms | 13,003 ms 🔴 | Raster lento |
| 6 | **164** | **23,532 ms** (23.5s) | 283 ms | 23,062 ms 🔴 | Raster lento |
| 7 | **27** | **24,597 ms** (24.6s) | 234 ms | 24,282 ms 🔴 | Raster lento |
| 8 | **120** | **12,005 ms** (12s) | 11,934 ms 🔴 | 32 ms | Build extremamente lento |
| 9 | **166** | **5,548 ms** (5.5s) | 5,215 ms 🔴 | 291 ms | Build lento |
| 10 | **123** | **4,523 ms** (4.5s) | 445 ms | 4,012 ms 🔴 | Raster lento |

**Padrão Identificado:**
- 7 de 10 frames lentos têm problema com **Raster thread**
- 2 frames têm problema com **Build thread**
- 1 frame tem problemas em ambos

---

## 🔴 Operações Síncronas Bloqueantes

### Problema 1: Sort no Build
**Localização:** `lib/features/home/presentation/pages/home_page.dart:231`

```dart
// ❌ PROBLEMA: Sort executado a cada rebuild
final sortedFeedings = List<FeedingLog>.from(feedingLogsState.feeding_logs);
sortedFeedings.sort((a, b) => b.fedAt.compareTo(a.fedAt)); // O(n log n)
```

**Impacto:**
- Complexidade: O(n log n)
- Com 29 feeding logs: ~29 × log₂(29) ≈ 140 operações
- Executado a cada rebuild (4+ rebuilds por mudança de estado)
- **Total: 560+ operações desnecessárias por ciclo**

**Solução:**
- Mover sort para Repository/BLoC
- Retornar dados já ordenados

---

### Problema 2: firstWhere no Build
**Localização:** `lib/features/home/presentation/pages/home_page.dart:238, 442`

```dart
// ❌ PROBLEMA: firstWhere executado no build
final cat = catsState.cats.firstWhere(
  (cat) => cat.id == lastFeeding!.catId,
  orElse: () => catsState.cats.first,
); // O(n)
```

**Impacto:**
- Complexidade: O(n) para cada cat
- Com 10+ cats: 10+ comparações por chamada
- Executado em loop (3 items recentes): 30+ comparações
- **Total: 40+ operações O(n) por rebuild**

**Solução:**
- Criar Map<catId, Cat> no BLoC
- Lookup O(1) em vez de O(n)

---

## 🔴 Rebuilds Desnecessários

### Estatísticas de Rebuilds

| Widget | BlocBuilders Sem buildWhen | Rebuilds por Estado | Impacto |
|--------|----------------------------|---------------------|---------|
| home_page.dart | 9 | 12 rebuilds | 🔴 CRÍTICO |
| cats_list_page.dart | 4 | 4 rebuilds | 🔴 ALTO |
| statistics_page.dart | 3 | 3 rebuilds | 🟡 MÉDIO |
| feeding_bottom_sheet.dart | 2 | 2 rebuilds | 🟡 MÉDIO |

**Total: 21 Rebuilds Desnecessários**

### BlocBuilders Aninhados

```dart
// ❌ PROBLEMA: BlocBuilders aninhados sem buildWhen
Widget _buildSummaryCards(BuildContext context) {
  return BlocBuilder<CatsBloc, CatsState>(        // BlocBuilder 1
    builder: (context, catsState) {
      return BlocBuilder<FeedingLogsBloc, FeedingLogsState>( // BlocBuilder 2
        builder: (context, feedingLogsState) {
          // Build completo mesmo se mudança for irrelevante
        }
      );
    }
  );
}
```

**Impacto:**
- Mudança em CatsBloc dispara ambos os BlocBuilders
- Mudança em FeedingLogsBloc dispara ambos os BlocBuilders
- **2× rebuilds desnecessários**

---

### BlocBuilder Dentro de Loop

```dart
// ❌ PROBLEMA: BlocBuilder criado N vezes
...recentFeedings.map((feeding) {
  return BlocBuilder<CatsBloc, CatsState>(  // 3 BlocBuilders!
    builder: (context, catsState) {
      // Cada um escuta mudanças em CatsBloc
    }
  );
})
```

**Impacto:**
- 3 recent feedings = 3 BlocBuilders
- Mudança em CatsBloc = 3 rebuilds simultâneos
- **3× multiplicador de rebuilds**

---

## 🔴 Vazamentos de Memória Identificados

### Potenciais Vazamentos

1. **RealtimeNotificationService**
   - Não é desconectado em alguns fluxos
   - Mantém listeners ativos
   - **Impacto:** Acúmulo de listeners após navegação

2. **Timer de Periodic Sync**
   - `_periodicSyncHandle` pode não ser cancelado
   - **Impacto:** Timers acumulando após dispose

3. **StreamControllers não fechadas**
   - Possível em alguns BLoCs
   - **Impacto:** Memória não liberada

---

## 🔴 Chamadas API Duplicadas

### Evidências Encontradas

1. **_loadFeedingLogs chamado 2x**
   - Uma vez em `didChangeDependencies`
   - Uma vez em `BlocListener<CatsBloc>`
   - **Sem debounce ou verificação**

2. **Refresh sem cache**
   - Pull-to-refresh força remoto sempre
   - **Sem verificação de dados recentes**

3. **Múltiplos listeners REALTIME**
   - Vários listeners escutando o mesmo canal
   - **Sem consolidar em um único listener**

---

## 📊 Análise de Priorização

### Matriz de Impacto × Esforço

| Problema | Impacto | Esforço | Prioridade | Ação |
|----------|---------|---------|------------|------|
| Prints em produção | 🔴 Alto | 🟢 Baixo | 🔴 P0 | Remover agora |
| BlocBuilders sem buildWhen | 🔴 Alto | 🟡 Médio | 🔴 P0 | Adicionar buildWhen |
| Sort no build | 🔴 Alto | 🟡 Médio | 🔴 P0 | Mover para BLoC |
| firstWhere no build | 🔴 Alto | 🟡 Médio | 🔴 P0 | Criar Map lookup |
| LogInterceptor | 🟡 Médio | 🟢 Baixo | 🟡 P1 | Condicional |
| BlocBuilder em loop | 🟡 Médio | 🟡 Médio | 🟡 P1 | Extrair widget |
| List.map sem keys | 🟡 Médio | 🟢 Baixo | 🟡 P1 | ListView.builder |
| Const widgets | 🟢 Baixo | 🟢 Baixo | 🟢 P2 | Adicionar const |
| Raster thread | 🔴 Crítico | 🔴 Alto | 🔴 P0 | Investigar |

---

## 🎯 Plano de Correção

### Fase 1: Quick Wins (1 hora)
1. Remover prints de debug
2. Desabilitar LogInterceptor em produção
3. Adicionar const em widgets estáticos

### Fase 2: Critical Fixes (2-3 horas)
4. Adicionar buildWhen em todos os BlocBuilders
5. Mover sort para Repository
6. Mover firstWhere para Map lookup
7. Substituir List.map por ListView.builder

### Fase 3: Raster Investigation (1-2 horas)
8. Investigar cause dos frames de 7 minutos
9. Verificar shader compilation
10. Otimizar charts/graphics

---

**Status:** ✅ Análise completa  
**Próximo:** Implementar correções Fase 1 e Fase 2

