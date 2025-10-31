# 🔬 Guia de Profiling de Performance - Flutter DevTools

**Data:** 12 de Outubro de 2025  
**Referência:** [Flutter DevTools Performance](https://docs.flutter.dev/tools/devtools/performance)  
**Objetivo:** Coletar dados reais de performance usando o profiler oficial do Flutter

---

## 📋 Pré-requisitos

1. Flutter SDK instalado e configurado
2. Flutter DevTools instalado
3. Dispositivo ou emulador conectado
4. App compilado em **modo profile** (não debug!)

---

## 🚀 Passo 1: Executar App em Modo Profile

### Por que Profile Mode?

> **IMPORTANTE:** O modo debug não fornece métricas precisas de performance. Sempre use **profile mode** para análise de performance.

**Comando:**

```bash
# Para Android
flutter run --profile

# Para iOS
flutter run --profile

# Para Web (não suporta performance view, usa Chrome DevTools)
flutter run --profile -d chrome
```

**Verificação:**
- O app deve rodar sem hot reload automático
- Performance será mais parecida com release
- Ainda mantém informações úteis para debugging

---

## 📊 Passo 2: Abrir Flutter DevTools

### Opção 1: Via Terminal
```bash
# Abrir DevTools manualmente
flutter pub global activate devtools
flutter pub global run devtools
```

### Opção 2: Via VS Code
- Abrir Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
- Digitar: "Flutter: Open DevTools"
- Selecione a aba "Performance"

### Opção 3: Via URL Automática
- O Flutter normalmente imprime uma URL no terminal
- Copie e cole no navegador
- Exemplo: `http://127.0.0.1:9100?uri=...`

---

## 🔍 Passo 3: Usar a Performance View

### 3.1 Flutter Frames Chart

**O que observar:**

1. **Cada barra = 1 frame**
   - Verde: Frame normal (< 16ms)
   - Vermelho: Frame janky (> 16ms)
   - Vermelho escuro: Shader compilation

2. **Duas barras por frame:**
   - **UI Thread:** Executa código Dart (seu app + framework)
   - **Raster Thread:** Renderiza no GPU

3. **FPS Target:**
   - 60 FPS = ~16ms por frame
   - 120 FPS = ~8ms por frame (dispositivos 120Hz)

**Como usar:**
- Clique em um frame vermelho (janky) para analisar
- Os detalhes aparecem na aba "Frame analysis"
- Pause o chart para analisar frames específicos

### 3.2 Frame Analysis Tab

**Aparece quando você seleciona um frame janky:**

- ✅ Mostra dicas de debugging
- ✅ Identifica operações caras detectadas
- ✅ Sugere correções específicas

**Interpretação:**
```
🔴 Frame 42 (62.3ms) - JANKY
  ⚠️ Detectado: Múltiplos rebuilds do mesmo widget
  ⚠️ Detectado: Sort() executado no build method
  💡 Dica: Considere usar buildWhen em BlocBuilder
```

### 3.3 Timeline Events Tab

**Mostra todos os eventos do app:**

1. **Eventos de Build:**
   - `build()` calls de widgets
   - Nomes dos widgets sendo construídos

2. **Eventos de Layout:**
   - Posicionamento de widgets
   - Cálculos de constraints

3. **Eventos de Paint:**
   - Renderização de widgets
   - Chamadas ao GPU

4. **Eventos Customizados:**
   - HTTP requests
   - Garbage collection
   - Eventos da sua app (se adicionar)

---

## 🛠️ Passo 4: Configurar Enhanced Tracing

### Ativar Rastreamento Detalhado

No dropdown "Enhance tracing", ativar:

1. ✅ **Track Widget Builds**
   - Mostra cada chamada de `build()`
   - Nome do widget no evento
   - Custo: Leve impacto na performance (aceitável)

2. ✅ **Track Layouts**
   - Mostra cálculos de layout
   - Útil para identificar layouts caros
   - Custo: Impacto leve

3. ✅ **Track Paints**
   - Mostra operações de pintura
   - Identifica widgets caros para renderizar
   - Custo: Impacto moderado

**Nota:** Frame times podem ser afetados quando esses options estão ativadas, mas ainda fornecem dados úteis.

---

## 🎯 Passo 5: Análise Específica para Nosso App

### Cenários de Teste

**1. Carregar HomePage:**
```dart
// Reproduzir:
// 1. Abrir app
// 2. Navegar para HomePage
// 3. Observar frames iniciais
```

**2. Mudança de Estado:**
```dart
// Reproduzir:
// 1. Na HomePage
// 2. Trigger mudança em CatsBloc (ex: refresh)
// 3. Observar quantos rebuilds acontecem
```

**3. Scroll na Lista:**
```dart
// Reproduzir:
// 1. Scrolar lista de gatos
// 2. Observar frames durante scroll
// 3. Verificar se há jank
```

### Métricas a Coletar

**Para cada cenário, anotar:**

| Métrica | Onde Medir | Valor Esperado |
|---------|-----------|----------------|
| **FPS** | Frames chart | 55-60 fps |
| **Frame time** | Frames chart | < 16ms |
| **UI thread time** | Frame bars | < 8ms |
| **Raster thread time** | Frame bars | < 8ms |
| **Rebuilds por evento** | Timeline → Widget builds | 1-2 |
| **Frames janky** | Frames chart (vermelhos) | < 1% |

---

## 📈 Passo 6: Identificar Problemas Específicos

### Problema 1: Múltiplos Rebuilds

**Como detectar:**
1. Ativar "Track Widget Builds"
2. Trigger mudança de estado (ex: atualizar CatsBloc)
3. Procurar por múltiplos eventos `build()` do mesmo widget

**Exemplo:**
```
Timeline mostra:
  build: _HomePageState (2.3ms)
  build: _buildSummaryCards (1.2ms)
  build: _buildLastFeedingSection (0.8ms)
  build: _buildRecentRecordItem (0.4ms) × 3
  build: _buildRecentRecordItem (0.4ms) × 3  ← Rebuilds duplicados!
```

**Solução:**
- Adicionar `buildWhen` nos BlocBuilders
- Ver se rebuilds duplicados desaparecem

### Problema 2: Operações Pesadas no Build

**Como detectar:**
1. Selecionar frame janky
2. Ver Frame Analysis tab
3. Procurar por operações lentas no timeline

**Exemplo:**
```
Frame 42 (45ms) - JANKY
  Timeline mostra:
    build: _buildLastFeedingSection
      sort: [FeedingLog x50] (8.2ms)  ← LENTO!
      firstWhere: [Cat x10] (0.5ms)
```

**Solução:**
- Mover sort para fora do build
- Usar BlocSelector ou computar no BLoC

### Problema 3: Shader Compilation

**Como detectar:**
- Frames marcados em vermelho escuro
- Geralmente acontece na primeira renderização

**Exemplo:**
```
Frame 1-10: Vermelho escuro
  Shader compilation: 30-50ms
```

**Solução:**
- Geralmente temporário
- Se persistir, verificar uso de shaders customizados

---

## 💾 Passo 7: Exportar e Comparar

### Exportar Snapshots

1. Execute o teste
2. Capture os dados no DevTools
3. Clique no botão **Export** (canto superior direito)
4. Salve o arquivo `.json`

### Comparar Antes/Depois

1. Exportar snapshot ANTES das correções
2. Aplicar correções
3. Exportar snapshot DEPOIS das correções
4. Comparar métricas:
   - Número de rebuilds
   - Frame times
   - FPS médio
   - Frames janky

---

## 📊 Passo 8: Criar Relatório

### Template de Relatório

```markdown
# Performance Profiling Report - [Data]

## Configuração
- Device: [nome/modelo]
- Flutter version: [versão]
- Mode: Profile
- Enhanced tracing: [sim/não]

## Métricas Coletadas

### Cenário 1: [Nome]
- FPS: [valor]
- Frame time médio: [valor]ms
- Frames janky: [número] ([%])
- Rebuilds detectados: [número]

### Problemas Identificados
1. [Problema específico com evidência do timeline]

### Comparação Antes/Depois
| Métrica | Antes | Depois | Melhoria |
|---------|-------|--------|----------|
| FPS | X | Y | +Z% |
```

---

## 🎬 Executar Profiling Agora

### Comandos Prontos

```bash
# 1. Compilar em profile mode
flutter run --profile

# 2. Em outro terminal, abrir DevTools
flutter pub global run devtools

# 3. Conectar ao app rodando
# URL será mostrada no terminal do flutter run
```

### Checklist de Testes

- [ ] App rodando em profile mode
- [ ] DevTools conectado
- [ ] Enhanced tracing ativado
- [ ] Testar: Carregar HomePage
- [ ] Testar: Mudança de estado (refresh cats)
- [ ] Testar: Scroll em lista
- [ ] Anotar FPS médio
- [ ] Anotar frames janky
- [ ] Exportar snapshot

---

## 📚 Referências

- [Flutter DevTools Performance](https://docs.flutter.dev/tools/devtools/performance)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Identifying problems in the GPU graph](https://docs.flutter.dev/perf/ui-performance)
- [Reduce shader compilation jank](https://docs.flutter.dev/perf/shader)

---

## 🔧 Troubleshooting

### DevTools não conecta

```bash
# Verificar se está rodando
flutter pub global list
flutter pub global activate devtools

# Verificar porta
netstat -an | grep 9100
```

### Frames não aparecem

- Verificar se está em profile mode (não debug!)
- Verificar se app está rodando
- Tentar refresh no DevTools

### Performance diferente do esperado

- Profile mode deve ser usado (debug é lento)
- Fechar outros apps
- Verificar se device não está em modo economia de energia

---

**Próximo Passo:** Executar profiling e coletar dados reais para comparar com as estimativas do relatório.

---

**Desenvolvido com base na documentação oficial do Flutter**  
*Referência: https://docs.flutter.dev/tools/devtools/performance*  
*Data: 12 de Outubro de 2025*



