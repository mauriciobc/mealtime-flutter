# Benchmarks de Performance - MealTime Flutter App

Este diretório contém todos os dados de benchmarking de performance do app MealTime, incluindo snapshots do DevTools, análises processadas e relatórios comparativos.

---

## 📁 Estrutura de Diretórios

```
benchmarks/
├── baseline/              # Snapshots ANTES das otimizações
│   ├── scenario_1_login_cold_start.json
│   ├── scenario_2_homepage_complete.json
│   └── ...
├── optimized/             # Snapshots DEPOIS das otimizações
│   ├── scenario_1_login_cold_start.json
│   ├── scenario_2_homepage_complete.json
│   └── ...
├── analysis/              # Resultados processados
│   ├── baseline_analysis.json
│   ├── optimized_analysis.json
│   ├── comparison_report.json
│   └── metrics_comparison.csv
├── screenshots/           # Prints visuais do DevTools
│   ├── baseline_fps.png
│   ├── optimized_fps.png
│   └── ...
└── README.md             # Este arquivo
```

---

## 🎯 Como Executar o Benchmark

### Pré-requisitos

1. **Dispositivo conectado**: Emulador Android ou dispositivo físico
2. **Flutter DevTools**: Já vem com o Flutter
3. **Python 3**: Para scripts de análise

### Passo 1: Executar Benchmark Baseline

```bash
# Executar o script de benchmark
./scripts/run_benchmark.sh baseline
```

O script irá:
- Verificar dispositivo
- Criar estrutura de diretórios
- Fornecer instruções manuais

### Passo 2: Coletar Dados

Siga as instruções do script e:

1. Execute o app: `flutter run --profile`
2. Abra DevTools (URL aparecerá no terminal)
3. Para cada cenário (8 no total):
   - Clique em "Record" no DevTools
   - Execute o cenário conforme `BENCHMARK_TEST_SCENARIOS.md`
   - Clique em "Stop"
   - Exporte snapshot com nome correto

### Passo 3: Implementar Otimizações

Após coletar baseline, implemente as otimizações documentadas no plano de benchmark.

### Passo 4: Executar Benchmark Otimizado

```bash
# Repetir processo com versão otimizada
./scripts/run_benchmark.sh optimized
```

### Passo 5: Analisar Resultados

```bash
# Analisar baseline
python3 scripts/analyze_devtools_snapshot.py baseline

# Analisar versão otimizada
python3 scripts/analyze_devtools_snapshot.py optimized

# Gerar comparação (próximo passo implementado)
python3 scripts/generate_comparison_report.py
```

---

## 📊 Interpretando Resultados

### Métricas Principais

#### FPS (Frames Per Second)
- **Ideal**: 55-60 FPS
- **Aceitável**: 40-54 FPS
- **Ruim**: <40 FPS
- **Crítico**: <30 FPS

#### Frame Time
- **Ideal**: <16ms
- **Aceitável**: 16-33ms
- **Ruim**: 33-50ms
- **Crítico**: >50ms

#### Frames Janky
- **Ideal**: <1%
- **Aceitável**: 1-5%
- **Ruim**: 5-10%
- **Crítico**: >10%

#### Build Time
- **Ideal**: <8ms
- **Aceitável**: 8-16ms
- **Ruim**: 16-100ms
- **Crítico**: >100ms

### Relatório de Comparação

Após executar análise em ambas as versões, o relatório de comparação mostrará:

```
Métrica                    Baseline    Optimized   Melhoria
───────────────────────────────────────────────────────────
FPS Média                  0.08 fps    45.2 fps    +56,400%
Frame Time Médio           11,775 ms   18.5 ms     -99.8%
Build Time Médio           380 ms      8.2 ms      -97.8%
Frames Janky               5.65%       0.8%        -85.8%
```

---

## 🧪 Cenários de Teste

O benchmark cobre 8 cenários principais:

1. **Login Flow (Cold Start)** - Tempo de inicialização
2. **HomePage Completa** - Performance da tela principal
3. **Cats List (Scroll)** - Performance de listas
4. **Create Cat Flow** - Performance de formulários
5. **Feeding Logs (Bottom Sheet)** - Performance de modals
6. **Statistics Page** - Performance de cálculos e gráficos
7. **Change Household** - Troca de contexto
8. **Navigation Flow** - Navegação end-to-end

Ver `../BENCHMARK_TEST_SCENARIOS.md` para detalhes completos de cada cenário.

---

## 📝 Adicionar Novo Cenário

Para adicionar um novo cenário de teste:

1. Criar snapshot no DevTools: `scenario_N_name.json`
2. Adicionar descrição em `../BENCHMARK_TEST_SCENARIOS.md`
3. Executar em ambos baseline e optimized
4. Re-executar análise

---

## 🔍 Validar Regressões

Após mudanças significativas no código:

```bash
# Executar benchmark rápido (apenas cenários críticos)
./scripts/run_benchmark.sh optimized

# Verificar se métricas não regrediram
python3 scripts/analyze_devtools_snapshot.py optimized

# Comparar com último resultado conhecido
python3 scripts/generate_comparison_report.py
```

---

## 📚 Referências

- **Flutter DevTools**: https://docs.flutter.dev/tools/devtools
- **Performance Best Practices**: https://docs.flutter.dev/perf/best-practices
- **Profiling Guide**: `../PERFORMANCE_PROFILING_GUIDE.md`
- **Benchmark Plan**: `../performance-benchmark-dev.plan.md`

---

## ✅ Checklist de Benchmark

- [ ] Dispositivo configurado (emulador/dispositivo físico)
- [ ] App em modo profile (`flutter run --profile`)
- [ ] DevTools aberto com enhanced tracing ativado
- [ ] 8 cenários executados e snapshots exportados
- [ ] Nomes de arquivo corretos conforme convenção
- [ ] Métricas anotadas manualmente (se necessário)
- [ ] Script de análise executado
- [ ] Relatórios gerados

---

**Última Atualização**: 2025-01-23  
**Versão do Benchmark**: 1.0  
**App**: MealTime Flutter

