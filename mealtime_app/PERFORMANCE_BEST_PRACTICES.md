# Guia de Boas Práticas de Performance - MealTime Flutter

**Versão:** 1.0  
**Data:** 2025-01-23  
**Objetivo:** Checklist e padrões para garantir performance ideal

---

## 📋 Checklist de Performance (Rápido)

### ✅ Antes de Commitar

- [ ] BlocBuilders têm `buildWhen` apropriado
- [ ] Sem operações pesadas (sort, firstWhere, map complexo) no build
- [ ] LogInterceptor condicionado com `kDebugMode`
- [ ] Widgets imutáveis marcados com `const`
- [ ] ListView.builder para listas (não `.map()`)
- [ ] Keys apropriadas em widgets dinâmicos
- [ ] Sem `print()` ou `debugPrint()` excessivos em produção
- [ ] Cálculos pesados movidos para isolates/compute

---

## 🎯 Padrões a Seguir

### 1. BlocBuilders SEMPRE com buildWhen

```dart
// ❌ ERRADO
BlocBuilder<CatsBloc, CatsState>(
  builder: (context, state) => Text(state.toString()),
)

// ✅ CORRETO
BlocBuilder<CatsBloc, CatsState>(
  buildWhen: (previous, current) {
    // Rebuild apenas quando necessário
    if (previous.runtimeType != current.runtimeType) return true;
    if (previous is CatsLoaded && current is CatsLoaded) {
      return previous.cats.length != current.cats.length;
    }
    return false;
  },
  builder: (context, state) => Text(state.toString()),
)
```

**Por quê:** Evita rebuilds desnecessários (cascata de rebuilds).

---

### 2. Operações Pesadas FORA do Build

```dart
// ❌ ERRADO
@override
Widget build(BuildContext context) {
  final sorted = data..sort((a, b) => b.compareTo(a)); // O(n log n) no build!
  return ListView(...);
}

// ✅ CORRETO - No Repository/BLoC
class MyRepository {
  Future<List<Item>> getSortedData() async {
    final data = await fetchData();
    data.sort((a, b) => b.compareTo(a));
    return data;
  }
}

// ✅ CORRETO - No State (pré-computado)
class MyLoadedState {
  final List<Item> items;
  final List<Item> sortedItems; // Pré-computado
  
  MyLoadedState({required this.items}) 
    : sortedItems = List.from(items)..sort(...);
}
```

**Por quê:** Build é chamado múltiplas vezes, operações pesadas se multiplicam.

---

### 3. Lookup Otimizado com Map

```dart
// ❌ ERRADO
final cat = cats.firstWhere((c) => c.id == catId); // O(n)

// ✅ CORRETO
class CatsLoaded extends CatsState {
  final List<Cat> cats;
  final Map<String, Cat>? _catsById;
  
  Cat? getCatById(String id) => _catsById?[id]; // O(1)
}
```

**Por quê:** Map lookup é O(1), firstWhere é O(n).

---

### 4. LogInterceptor APENAS em Debug

```dart
// ❌ ERRADO
dio.interceptors.add(LogInterceptor(...)); // Sempre ativo

// ✅ CORRETO
if (kDebugMode) {
  dio.interceptors.add(LogInterceptor(...)); // Apenas debug
}
```

**Por quê:** Logging em produção causa overhead significativo de I/O.

---

### 5. Widgets Imutáveis = const

```dart
// ❌ ERRADO
child: SizedBox(width: 16)

// ✅ CORRETO
child: const SizedBox(width: 16)
```

**Por quê:** Const widgets não são rebuilded, economizando memória e CPU.

---

### 6. ListView.builder para Listas

```dart
// ❌ ERRADO
ListView(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ CORRETO
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index], 
    key: ValueKey(items[index].id)),
)
```

**Por quê:** ListView.builder cria widgets sob demanda (lazy), `.map()` cria todos de uma vez.

---

### 7. Keys Apropriadas

```dart
// ❌ ERRADO
items.map((item) => ItemWidget(item)) // Sem key

// ✅ CORRETO
items.map((item) => ItemWidget(
  item,
  key: ValueKey(item.id), // Key estável e única
))
```

**Por quê:** Keys permitem que Flutter reutilize widgets existentes.

---

### 8. Cálculos Pesados em Isolates

```dart
// ❌ ERRADO
@override
Widget build(BuildContext context) {
  final result = heavyCalculation(data); // Bloqueia UI thread!
  return Text(result.toString());
}

// ✅ CORRETO
@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: compute(heavyCalculation, data), // Em isolate
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      return Text(snapshot.data.toString());
    }
  );
}
```

**Por quê:** Isolates executam em threads separadas, não bloqueiam UI.

---

## ❌ Anti-Patterns a Evitar

### 1. BlocBuilder Aninhado SEM buildWhen

```dart
// ❌ EVITAR
BlocBuilder<Bloc1, State1>(
  builder: (context, s1) {
    return BlocBuilder<Bloc2, State2>( // ❌ Aninhado!
      builder: (context, s2) => Widget(),
    );
  },
)

// ✅ MELHOR: Combinar estados
BlocBuilder<Bloc1, State1>(
  buildWhen: (p, c) => /* ... */,
  builder: (context, s1) {
    return BlocBuilder<Bloc2, State2>(
      buildWhen: (p, c) => /* ... */, // ✅ Com buildWhen
      builder: (context, s2) => Widget(),
    );
  },
)
```

---

### 2. Sort/Filter no Build

```dart
// ❌ EVITAR
Widget build(BuildContext context) {
  final sorted = list..sort((a, b) => a.compareTo(b));
  return ListView(...);
}

// ✅ PREFERIR: Pré-computado no Repository/BLoC
final sorted = repository.getSortedData();
```

---

### 3. Debug Prints em Produção

```dart
// ❌ EVITAR
void fetchData() {
  print('Fetching data...'); // ❌ Sempre executa
  // ...
}

// ✅ PREFERIR
void fetchData() {
  if (kDebugMode) {
    debugPrint('Fetching data...'); // ✅ Apenas debug
  }
  // ...
}
```

---

### 4. Widgets Sem const Quando Possível

```dart
// ❌ EVITAR
Widget build(BuildContext context) {
  return Column(
    children: [
      SizedBox(height: 16), // ❌ Não const
      Text('Hello'),         // ❌ Não const
    ],
  );
}

// ✅ PREFERIR
Widget build(BuildContext context) {
  return Column(
    children: [
      const SizedBox(height: 16), // ✅ Const
      const Text('Hello'),         // ✅ Const
    ],
  );
}
```

---

### 5. .map() Para Criar Widgets

```dart
// ❌ EVITAR
Column(
  children: items.map((item) => ItemWidget(item)).toList(),
)

// ✅ PREFERIR
Column(
  children: items.map((item) => 
    ItemWidget(item, key: ValueKey(item.id))
  ).toList(),
)

// ✅ PREFERIR AINDA MAIS
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => 
    ItemWidget(items[index], key: ValueKey(items[index].id)),
)
```

---

## 🔍 Como Validar Performance

### 1. DevTools Profiling

```bash
# 1. Rodar em profile mode
flutter run --profile

# 2. Abrir DevTools (URL aparece no terminal)
# 3. Ir para aba Performance
# 4. Ativar:
#    - Track Widget Builds
#    - Track Layouts
#    - Track Paints
# 5. Interagir com o app
# 6. Exportar snapshot
# 7. Analisar frame times, FPS, jank
```

### 2. Métricas a Observar

- **FPS:** Deve ser 55-60 fps
- **Frame Time:** Médio <16ms, Máximo <100ms
- **Build Time:** Médio <8ms
- **Raster Time:** Médio <8ms
- **Frames Janky:** <1%

### 3. Red Flags

- FPS <30 → Problema crítico
- Frame time >100ms → Jank visível
- Build time >50ms → Widgets muito pesados
- Raster >100ms → GPU/rendering issue
- Janky frames >5% → Experiência ruim

---

## 📊 Monitoring Contínuo

### 1. Durante Desenvolvimento

- Profiling rápido antes de commitar mudanças significativas
- Usar Performance Overlay (`MaterialApp.debugShowCheckedModeBanner`)
- Verificar console para debug prints excessivos

### 2. Em Code Review

- Verificar checklist de performance
- Pedir profiling se mudança for grande
- Confirmar que const/buildWhen foram aplicados

### 3. Em CI/CD (Futuro)

- Scripts de benchmark automatizados
- Gates de performance (rejeitar PRs com regressão)
- Alertas para degradação >10%

### 4. Em Produção

- Firebase Performance Monitoring
- Crashlytics para erros
- Analytics para métricas reais de usuários

---

## 🎓 Recursos

### Documentação Oficial

- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter DevTools Guide](https://docs.flutter.dev/tools/devtools)
- [Flutter Bloc buildWhen](https://pub.dev/documentation/flutter_bloc/latest/flutter_bloc/BlocBuilder/buildWhen.html)

### Ferramentas

- **Flutter DevTools** - Profiling e debugging
- **Flutter Performance Overlay** - Visualizar FPS em tempo real
- **Android GPU Inspector** - Profiling de GPU
- **Firebase Performance** - Monitoring em produção

### Relatórios Internos

- `PERFORMANCE_BENCHMARK_REPORT.md` - Resumo do benchmark
- `BENCHMARK_BOTTLENECKS_REPORT.md` - Gargalos identificados
- `BENCHMARK_COMPARISON_REPORT.md` - Antes vs Depois

---

## ✅ Resumo Final

**Regra de Ouro:** Se vai executar múltiplas vezes (como em build), otimize agressivamente.

**Prioridades:**
1. BlocBuilder com buildWhen
2. Operações pesadas fora do build
3. LogInterceptor apenas em debug
4. Widgets const quando possível
5. ListView.builder para listas

**Profiling:** Sempre valide mudanças de performance com DevTools.

---

**Desenvolvido para o MealTime Flutter App**  
**Última Atualização:** 2025-01-23  
**Versão:** 1.0.0

