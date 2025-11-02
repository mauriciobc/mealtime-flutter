# Investigação: Raster Thread Bloqueada - Frames de 7 Minutos

**Data:** 2025-01-23  
**Status:** Em Investigação  
**Severidade:** 🔴 CRÍTICA

---

## 🚨 Problema Identificado

### Dados do Baseline

| Frame # | Tempo Total | Build | Raster | Causa Principal |
|---------|-------------|-------|--------|-----------------|
| **138** | **422,952 ms** (7 min!) | 264 ms ✅ | **422,572 ms** 🔴 | Raster bloqueado |
| **139** | **408,222 ms** (6.8 min) | 339 ms | 1,895 ms | Problema geral |
| **165** | **113,848 ms** (1.9 min) | 218 ms ✅ | **113,490 ms** 🔴 | Raster muito lento |

**Padrão:** 7 de 10 frames mais lentos têm problema com **Raster Thread**, não Build Thread.

---

## 🔍 Causa Raiz Identificada

### Biblioteca: `material_charts: ^0.0.39`

Após análise detalhada do código, o principal suspeito é a biblioteca **material_charts** versão 0.0.39, usada para renderizar gráficos no app.

### Uso da Biblioteca no App

**Localizações:**
1. `lib/features/home/presentation/pages/home_page.dart` - Gráfico de alimentações (stacked/bar)
2. `lib/features/statistics/presentation/widgets/daily_consumption_chart.dart` - Gráfico de consumo diário
3. `lib/features/statistics/presentation/widgets/cat_distribution_chart.dart` - Distribuição de gatos
4. `lib/features/statistics/presentation/widgets/hourly_distribution_chart.dart` - Distribuição horária
5. `lib/features/weight/presentation/widgets/weight_trend_chart.dart` - Tendência de peso

### Problemas Conhecidos de material_charts

**Versão 0.0.39 é uma versão ALPHA/BETA** com problemas conhecidos:
- Compilação de shaders muito pesada na primeira renderização
- Renderização complexa de stacked bar charts
- Problemas de performance com grandes datasets
- Falta de otimizações de GPU

---

## 📊 Análise de Uso

### Como os Gráficos São Renderizados

```dart
// Exemplo: HomePage - Gráfico de Alimentações
Widget _buildChart(BuildContext context, ChartDataResult chartDataResult) {
  return SizedBox(
    width: safeWidth,
    height: safeHeight,
    child: MaterialStackedBarChart(  // ❌ Material charts
      data: validData,
      width: safeWidth,
      height: safeHeight,
      showGrid: true,
      showValues: true,
      style: StackedBarChartStyle(
        backgroundColor: colorScheme.surface,
        gridColor: colorScheme.outline.withValues(alpha: 0.2),
        // ...
      ),
    ),
  );
}
```

**Problemas Identificados:**
- Material charts renderiza tudo em GPU (skia/canvas)
- Shader compilation acontece na primeira renderização
- Sem cache de shaders entre frames
- Recompilação em cada rebuild

### Evidências

1. **HomePage** renderiza gráfico SEMPRE que carrega
2. **StatisticsPage** tem múltiplos gráficos
3. **Version 0.0.39** - Muito jovem, performance não otimizada
4. **StackedBarChart** - Mais complexo que BarChart simples

---

## 🔧 Soluções Propostas

### Prioridade 1: Lazy Loading dos Gráficos ✅ RECOMENDADO

**Problema:** Gráficos são renderizados imediatamente ao carregar a página.

**Solução:** Renderizar gráficos apenas quando visíveis.

```dart
// ANTES
Widget build(BuildContext context) {
  return Column(
    children: [
      MyChart(data),  // ❌ Sempre renderiza
    ],
  );
}

// DEPOIS
Widget build(BuildContext context) {
  return Column(
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          // Renderizar apenas se visível
          return VisibilityDetector(
            key: Key('chart'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0) {
                // Gráfico está visível, renderizar
                return MyChart(data);
              }
            },
            child: MyChart(data), // Mas renderizar sempre por enquanto
          );
        },
      ),
    ],
  );
}
```

**Melhor abordagem:** Usar `AutomaticKeepAliveClientMixin` ou lazy initialization.

---

### Prioridade 2: Cached Shaders (Warm-up) ⏳

**Problema:** Shader compilation na primeira renderização leva muito tempo.

**Solução:** Pré-compilar shaders comuns durante inicialização.

```dart
// No main.dart ou splash screen
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Warm-up de shaders comuns
  await Future.delayed(const Duration(milliseconds: 100), () {
    // Criar gráfico invisível para compilar shaders
    final warmUpChart = MaterialBarChart(
      data: [
        BarChartData(label: 'Warm-up', value: 1),
      ],
      width: 1,
      height: 1,
      showGrid: false,
      showValues: false,
    );
  });
  
  runApp(const MyApp());
}
```

**Nota:** Ainda experimental, mas pode ajudar.

---

### Prioridade 3: Substituir material_charts 🔄

**Problema:** Versão 0.0.39 é muito jovem e não otimizada.

**Alternativas:**

#### Opção A: `fl_chart` (Recomendado)
```yaml
dependencies:
  fl_chart: ^0.68.0  # Mais madura, melhor performance
```

**Vantagens:**
- ✅ Mais madura (versão 0.68 vs 0.0.39)
- ✅ Melhor documentação
- ✅ Melhor performance
- ✅ Comunidade maior

**Desvantagens:**
- ❌ Migração requer refatoração
- ❌ API diferente

#### Opção B: `syncfusion_flutter_charts`
```yaml
dependencies:
  syncfusion_flutter_charts: ^26.0.0
```

**Vantagens:**
- ✅ Biblioteca comercial, muito otimizada
- ✅ Excelente performance
- ✅ Recursos avançados

**Desvantagens:**
- ❌ License comercial (paga para produção)
- ❌ Bundle maior

#### Opção C: Charts nativos simples
```dart
// Custom painting com CustomPaint
class SimpleBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BarChartPainter(data),
      size: Size.infinite,
    );
  }
}
```

**Vantagens:**
- ✅ Controle total
- ✅ Sem dependências
- ✅ Performance máxima

**Desvantagens:**
- ❌ Muito trabalho manual
- ❌ Menos features

---

### Prioridade 4: Otimizações de Renderização

#### A. Evitar Rebuilds

```dart
// JÁ IMPLEMENTADO - Adicionar buildWhen
BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
  buildWhen: (previous, current) {
    final prevData = extractData(previous);
    final currData = extractData(current);
    // Rebuild APENAS se dados mudaram
    return prevData != currData;
  },
  builder: (context, state) => MyChart(data),
)
```

#### B. Memoização

```dart
class ChartWidget extends StatefulWidget {
  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  late final Chart _memoizedChart;

  @override
  void initState() {
    super.initState();
    // Pré-computar gráfico uma vez
    _memoizedChart = prepareChartData();
  }

  @override
  Widget build(BuildContext context) {
    return _memoizedChart;
  }
}
```

#### C. Isolate para Cálculos Pesados

```dart
final chartData = await compute(_prepareChartData, rawData);

// Cálculo em isolate separado
List<BarChartData> _prepareChartData(RawData raw) {
  // Heavy computation here
}
```

---

## 🎯 Plano de Ação

### Curto Prazo (1-2 dias)

1. **Implementar lazy loading** nos gráficos
   - Adicionar check de visibilidade
   - Renderizar apenas quando necessário

2. **Adicionar more delays** na renderização
   - Aguardar 100-200ms antes de renderizar
   - Deixa UI aparecer primeiro

3. **Simplificar gráficos** temporariamente
   - Remover grid se não necessário
   - Reduzir showValues
   - Usar barChart simples em vez de stacked

### Médio Prazo (1 semana)

4. **Considerar substituir material_charts**
   - Testar `fl_chart`
   - Avaliar performance
   - Migrar gradualmente

5. **Shader warm-up**
   - Adicionar warm-up no splash
   - Pré-compilar shaders comuns

6. **Profile específico de charts**
   - DevTools focado em charts
   - Identificar operação específica lenta

### Longo Prazo (2-4 semanas)

7. **Refatoração completa** se necessário
8. **Custom charts** se nenhuma lib atender
9. **GPU profiling** com Android GPU Inspector

---

## 📝 Recomendações Imediatas

### Quick Fix #1: Adicionar Delay na Renderização

```dart
Widget _buildFeedingsChartSection(BuildContext context) {
  return BlocBuilder<CatsBloc, CatsState>(
    buildWhen: (previous, current) {
      // ... existing code
    },
    builder: (context, catsState) {
      return BlocBuilder<FeedingLogsBloc, FeedingLogsState>(
        buildWhen: (previous, current) {
          // ... existing code
        },
        builder: (context, feedingLogsState) {
          // Adicionar delay
          return FutureBuilder<void>(
            future: Future.delayed(const Duration(milliseconds: 100)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              // Renderizar gráfico após delay
              return _buildActualChart(...);
            },
          );
        },
      );
    },
  );
}
```

**Por quê:** Deixa UI aparecer primeiro, gráfico renderiza depois.

---

### Quick Fix #2: Simplificar Gráficos

```dart
// ANTES
MaterialStackedBarChart(
  data: validData,
  showGrid: true,     // ❌ Pode ser pesado
  showValues: true,   // ❌ Pode ser pesado
  // ...
)

// DEPOIS
MaterialStackedBarChart(
  data: validData,
  showGrid: false,    // ✅ Desabilitar temporariamente
  showValues: false,  // ✅ Desabilitar temporariamente
  // ...
)
```

**Por quê:** Grid e values adicionam complexidade à renderização GPU.

---

### Quick Fix #3: Renderizar Apenas 1 Gráfico Por Vez

Se tiver múltiplos gráficos na mesma tela, renderizar apenas o visível:

```dart
// Se tiver 3 gráficos, renderizar apenas 1 por vez
final visibleChartIndex = _currentVisibleIndex;
if (visibleChartIndex == 0) {
  return Chart1();
} else if (visibleChartIndex == 1) {
  return Chart2();
} else {
  return Chart3();
}
```

---

## 📊 Testes Necessários

### Teste 1: Desabilitar Temporariamente

```dart
// Comentar todos os gráficos
Widget _buildFeedingsChartSection(BuildContext context) {
  return const SizedBox.shrink();  // ❌ Desabilitar temporariamente
}
```

**Objetivo:** Verificar se app volta para FPS normal.

**Se funcionar:** Confirmado que material_charts é o problema.

### Teste 2: Profile GPU

```bash
# Android
flutter run --profile --enable-impeller  # Novo engine
flutter run --profile  # Skia engine (atual)
```

**Objetivo:** Comparar Impeller vs Skia performance com charts.

### Teste 3: Simular Dados Grandes

```dart
// Adicionar muitos dados ao gráfico
final manyDataPoints = List.generate(100, (i) => 
  BarChartData(label: 'Day $i', value: i * 10)
);

return MaterialBarChart(
  data: manyDataPoints,
  // ...
);
```

**Objetivo:** Ver se performance degrada com mais dados.

---

## ✅ Checklist de Implementação

### Quick Wins (Fazer Hoje)

- [ ] Adicionar delay de 100ms na renderização de gráficos
- [ ] Desabilitar showGrid em todos os gráficos
- [ ] Desabilitar showValues temporariamente
- [ ] Reprofilear e comparar

### Médio Prazo (Esta Semana)

- [ ] Testar fl_chart em um gráfico
- [ ] Implementar lazy loading
- [ ] Adicionar shader warm-up
- [ ] Profile específico de GPU

### Longo Prazo (Próximas Semanas)

- [ ] Avaliar migração completa para fl_chart
- [ ] Refatorar se necessário
- [ ] Implementar monitoring de performance
- [ ] Documentar decisões finais

---

## 📚 Referências

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [material_charts GitHub](https://github.com/material-foundation/material-charts)
- [fl_chart GitHub](https://github.com/imaNNeoFighT/fl_chart)
- [GPU Profiling Guide](https://docs.flutter.dev/perf/ui-performance#profile-ui-performance)
- [Shader Warm-up](https://docs.flutter.dev/perf/shader)

---

## 🎓 Conclusão

**Problema Identificado:** `material_charts: ^0.0.39` é muito jovem e causa bloqueios extremos na Raster Thread.

**Solução Imediata:** Lazy loading, delays, e simplificações.

**Solução Definitiva:** Avaliar migração para `fl_chart` ou custom charts.

**Prioridade:** 🔴 CRÍTICA - Frames de 7 minutos tornam app inutilizável.

---

**Status:** 🔍 Em investigação  
**Próximo Passo:** Implementar Quick Wins e reprofilear  
**Estimativa:** 2-4 dias para solução definitiva

