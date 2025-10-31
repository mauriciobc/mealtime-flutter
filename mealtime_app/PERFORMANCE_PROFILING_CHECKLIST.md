# ✅ Checklist de Profiling de Performance

**Data:** 12 de Outubro de 2025  
**Objetivo:** Coletar dados reais de performance usando Flutter DevTools

---

## 🔧 Setup Inicial

- [ ] Flutter SDK instalado e funcionando
- [ ] DevTools instalado: `flutter pub global activate devtools`
- [ ] Dispositivo/Emulador conectado: `flutter devices`
- [ ] App compila sem erros

---

## 🚀 Executar Profiling

### Preparação

- [ ] Executar: `./scripts/profile_app.sh` (ou seguir instruções manuais)
- [ ] Abrir terminal 1: `flutter run --profile`
- [ ] Abrir terminal 2: `flutter pub global run devtools`
- [ ] Conectar DevTools ao app (URL aparece no terminal 1)

### Configuração DevTools

- [ ] Abrir aba **Performance**
- [ ] Ativar **Track Widget Builds**
- [ ] Ativar **Track Layouts**
- [ ] Ativar **Track Paints**
- [ ] Verificar que frames estão sendo registrados

---

## 📊 Cenários de Teste

### Cenário 1: Carregar HomePage

**Ações:**
- [ ] Iniciar app
- [ ] Navegar para HomePage
- [ ] Aguardar 5 segundos após carregar

**Observar:**
- [ ] FPS médio: _____ (ideal: 55-60)
- [ ] Frame time médio: _____ ms (ideal: <16ms)
- [ ] Frames janky: _____ / total (ideal: <1%)
- [ ] Rebuilds detectados: _____ (contar no timeline)

**Screenshot/Captura:**
- [ ] Screenshot do Frames Chart
- [ ] Screenshot do Timeline Events (primeiros frames)

---

### Cenário 2: Mudança de Estado (CatsBloc)

**Ações:**
- [ ] Estar na HomePage
- [ ] Pull-to-refresh ou trigger mudança em CatsBloc
- [ ] Observar frames durante a mudança

**Observar:**
- [ ] FPS durante mudança: _____
- [ ] Frame time máximo: _____ ms
- [ ] Frames janky: _____
- [ ] Rebuilds do `_buildSummaryCards`: _____
- [ ] Rebuilds do `_buildLastFeedingSection`: _____
- [ ] Rebuilds do `_buildRecentRecordsSection`: _____
- [ ] Rebuilds do `_buildMyCatsSection`: _____
- [ ] Rebuilds de `_buildRecentRecordItem`: _____ × N items

**Screenshot/Captura:**
- [ ] Screenshot do Frame Analysis (se houver frame janky)
- [ ] Screenshot do Timeline mostrando rebuilds

**Análise:**
- [ ] Identificar rebuilds duplicados: _____
- [ ] Widget mais reconstruído: _____
- [ ] Tempo gasto em rebuilds: _____ ms

---

### Cenário 3: Scroll em Lista

**Ações:**
- [ ] Navegar para lista de gatos (ou homes)
- [ ] Fazer scroll rápido
- [ ] Fazer scroll lento

**Observar:**
- [ ] FPS durante scroll rápido: _____
- [ ] FPS durante scroll lento: _____
- [ ] Frame time médio durante scroll: _____ ms
- [ ] Frames janky durante scroll: _____

**Screenshot/Captura:**
- [ ] Screenshot do Frames Chart durante scroll

---

### Cenário 4: Abrir Bottom Sheet

**Ações:**
- [ ] Na HomePage, clicar no FAB
- [ ] Abrir FeedingBottomSheet
- [ ] Fechar bottom sheet

**Observar:**
- [ ] Frame time para abrir: _____ ms
- [ ] Frame time para fechar: _____ ms
- [ ] Frames janky: _____
- [ ] Rebuilds durante abertura: _____

---

### Cenário 5: Operações Pesadas (Identificar)

**Ações:**
- [ ] Reproduzir ação que causa jank
- [ ] Selecionar frame janky no chart
- [ ] Analisar Frame Analysis tab

**Observar:**
- [ ] Frame número: _____
- [ ] Frame time: _____ ms
- [ ] Dicas no Frame Analysis: _____
- [ ] Operações lentas detectadas:
  - [ ] Sort: _____ ms
  - [ ] firstWhere: _____ ms
  - [ ] Map/Transform: _____ ms
  - [ ] Outros: _____

**Screenshot/Captura:**
- [ ] Screenshot do Frame Analysis
- [ ] Screenshot do Timeline Events para esse frame

---

## 📈 Métricas Gerais

### Performance Geral do App

- [ ] FPS médio (HomePage idle): _____
- [ ] FPS médio (durante interações): _____
- [ ] Frame time médio: _____ ms
- [ ] Frame time máximo: _____ ms
- [ ] Total de frames janky: _____
- [ ] Percentual de frames janky: _____ %

### Rebuilds

- [ ] Rebuilds por mudança de estado CatsBloc: _____
- [ ] Rebuilds por mudança de estado FeedingLogsBloc: _____
- [ ] Widget com mais rebuilds: _____
- [ ] Rebuilds desnecessários identificados: _____

### Operações Pesadas

- [ ] Sorts executados no build: _____
- [ ] firstWhere executados no build: _____
- [ ] Maps/Transforms no build: _____
- [ ] Tempo total em operações pesadas: _____ ms

---

## 🎯 Comparação com Benchmark

### Antes das Otimizações

| Métrica | Valor Coletado | Valor Esperado (Ideal) | Gap |
|---------|----------------|------------------------|-----|
| FPS | _____ | 55-60 | _____ |
| Frame time médio | _____ ms | <16ms | _____ |
| Frames janky % | _____ % | <1% | _____ |
| Rebuilds/estado | _____ | 1-2 | _____ |

---

## 📸 Capturas de Tela

### Obrigatórias

- [ ] Frames Chart (overview)
- [ ] Frame Analysis de um frame janky
- [ ] Timeline Events mostrando rebuilds
- [ ] Timeline Events com Track Widget Builds ativado

### Opcionais (mas recomendadas)

- [ ] Frames Chart durante scroll
- [ ] Frame Analysis de frame com operação pesada
- [ ] Timeline Events de uma mudança de estado completa

---

## 💾 Exportar Dados

- [ ] Exportar snapshot ANTES das correções: `baseline_performance.json`
- [ ] (Após correções) Exportar snapshot DEPOIS: `optimized_performance.json`
- [ ] Comparar ambos snapshots
- [ ] Documentar melhorias obtidas

---

## 📝 Anotações Específicas

### Problemas Identificados

1. **Problema:** _____
   - **Evidência no Timeline:** _____
   - **Impacto:** _____
   - **Linha de código:** _____

2. **Problema:** _____
   - **Evidência no Timeline:** _____
   - **Impacto:** _____
   - **Linha de código:** _____

### Insights

- [ ] Widget que mais causa rebuilds: _____
- [ ] Operação mais cara: _____
- [ ] Padrão de jank identificado: _____
- [ ] Melhorias imediatas recomendadas: _____

---

## 🔗 Referências

- [Flutter DevTools Performance](https://docs.flutter.dev/tools/devtools/performance)
- `PERFORMANCE_PROFILING_GUIDE.md` - Guia detalhado
- `PERFORMANCE_METRICS_EVIDENCE.md` - Métricas esperadas

---

**Status:** 🔄 Em andamento  
**Próxima Ação:** Executar profiling e preencher checklist  
**Data de Conclusão:** _____



