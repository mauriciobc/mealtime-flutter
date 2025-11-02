# Cenários de Teste do Benchmark de Performance

**Data de Criação:** 2025-01-23  
**Versão:** 1.0  
**Objetivo:** Documentar os 8 cenários críticos para profiling do app MealTime

---

## Visão Geral

Estes cenários foram selecionados para cobrir as principais funcionalidades do app e identificar problemas de performance críticos. Cada cenário deve ser executado **antes** e **depois** das otimizações para comparar os resultados.

## Configuração Prévia

### Ambiente Recomendado
- **Modo:** Profile (`flutter run --profile`)
- **Dispositivo:** Emulador Android ou dispositivo físico
- **Estado:** Clean install (app reinstalado)
- **Dados:** Usuário de teste com dados pré-populados (10+ cats, 50+ feeding logs)

### Configurações DevTools
Antes de cada teste, ativar no DevTools Performance:
- ✅ Track Widget Builds
- ✅ Track Layouts  
- ✅ Track Paints
- ✅ Memory Tracking
- ✅ Network Logging

---

## Cenário 1: Login Flow (Cold Start)

**Duração esperada:** 5-10 segundos  
**Objetivo:** Medir tempo de inicialização do app

### Passos de Execução
1. App não está em execução (cold start)
2. Abrir o app
3. Tela de login aparece
4. Inserir credenciais válidas
5. Clicar em "Login"
6. Aguardar navegação para HomePage
7. Aguardar carregamento completo da HomePage

### Métricas a Coletar
- **Cold Start Time:** Tempo desde a abertura até o primeiro frame renderizado
- **Login API Time:** Tempo da requisição de login
- **HomePage Load Time:** Tempo para HomePage estar totalmente carregada
- **FPS médio:** Durante toda a navegação
- **Memory Spike:** Pico de memória durante login

### Snapshot Nome
`scenario_1_login_cold_start.json`

---

## Cenário 2: HomePage Completa

**Duração esperada:** 10-15 segundos  
**Objetivo:** Medir performance da tela principal

### Passos de Execução
1. App já está logado e na HomePage
2. Aguardar carregamento completo de:
   - Lista de cats
   - Última refeição registrada
   - Resumo de cards (statistics)
3. Scroll completo na página (se necessário)
4. Aguardar 5 segundos para estabilizar
5. Forçar um rebuild (pull-to-refresh)

### Métricas a Coletar
- **Initial Load Time:** Tempo até primeira renderização completa
- **API Calls:** Número e duração de chamadas API
- **Build Time:** Tempo médio de build dos widgets
- **FPS:** Durante scroll e rebuild
- **Rebuilds Count:** Número de rebuilds desnecessários
- **Memory Usage:** Consumo de memória na HomePage

### Snapshot Nome
`scenario_2_homepage_complete.json`

---

## Cenário 3: Cats List (Scroll Performance)

**Duração esperada:** 15-20 segundos  
**Objetivo:** Testar performance de listas grandes

### Passos de Execução
1. Na HomePage, navegar para "Meus Gatos"
2. Aguardar carregamento da lista (10+ cats)
3. Fazer scroll **lento** do topo ao fim da lista
4. Fazer scroll **rápido** do topo ao fim da lista
5. Aguardar estabilização (2 segundos)
6. Abrir o menu de contexto de um cat (long press)

### Métricas a Coletar
- **List Render Time:** Tempo de renderização inicial
- **Scroll FPS:** FPS durante scroll lento e rápido
- **Frame Drops:** Frames janky durante scroll
- **Build Time per Item:** Tempo médio para construir cada item
- **Memory:** Consumo durante scroll

### Snapshot Nome
`scenario_3_cats_list_scroll.json`

---

## Cenário 4: Create Cat Flow

**Duração esperada:** 10-15 segundos  
**Objetivo:** Testar performance de formulários

### Passos de Execução
1. Na lista de cats, clicar em "Adicionar Gato"
2. Aguardar abertura do formulário
3. Preencher todos os campos:
   - Nome
   - Data de nascimento
   - Peso inicial
4. Selecionar foto (se disponível)
5. Clicar em "Salvar"
6. Aguardar salvamento e navegação de volta

### Métricas a Coletar
- **Form Open Time:** Tempo de abertura do formulário
- **API Call Time:** Tempo de salvamento no backend
- **Navigation Smoothness:** FPS durante navegação
- **Rebuilds:** Durante preenchimento do formulário
- **Memory:** Pico durante upload de imagem

### Snapshot Nome
`scenario_4_create_cat_flow.json`

---

## Cenário 5: Feeding Logs (Bottom Sheet Performance)

**Duração esperada:** 15-20 segundos  
**Objetivo:** Testar performance de modals e bottom sheets

### Passos de Execução
1. Na HomePage, clicar em "Registrar Alimentação"
2. Aguardar abertura do bottom sheet
3. Preencher todos os campos:
   - Selecionar cat
   - Quantidade
   - Tipo
   - Data/hora
4. Clicar em "Salvar"
5. Aguardar salvamento e fechamento
6. Repetir o processo mais 2 vezes

### Métricas a Coletar
- **Bottom Sheet Open Time:** Tempo de animação de abertura
- **Form Interactivity:** FPS durante interação
- **Animation Smoothness:** Suavidade das animações
- **API Calls:** Número de chamadas durante o flow
- **Memory Leaks:** Verificar se bottom sheet libera memória ao fechar

### Snapshot Nome
`scenario_5_feeding_logs_bottom_sheet.json`

---

## Cenário 6: Statistics Page

**Duração esperada:** 15-20 segundos  
**Objetivo:** Testar performance de cálculos e gráficos

### Passos de Execução
1. Na HomePage, navegar para "Estatísticas"
2. Aguardar carregamento completo da página
3. Aguardar cálculos de estatísticas
4. Interagir com gráficos (se houver zoom, pan, etc.)
5. Filtrar por período (ex: últimos 30 dias)
6. Aguardar recálculo
7. Fazer scroll na página

### Métricas a Coletar
- **Page Load Time:** Tempo até renderização completa
- **Calculation Time:** Tempo de cálculos estatísticos
- **Chart Render Time:** Tempo para renderizar gráficos
- **FPS:** Durante interação com gráficos
- **CPU Usage:** Pico durante cálculos
- **Memory:** Consumo com gráficos renderizados

### Snapshot Nome
`scenario_6_statistics_page.json`

---

## Cenário 7: Change Household

**Duração esperada:** 10-15 segundos  
**Objetivo:** Testar performance de troca de contexto

### Passos de Execução
1. Na HomePage, clicar no seletor de household
2. Aguardar abertura da lista de households
3. Selecionar um household diferente
4. Aguardar carregamento dos dados do novo household
5. Verificar se HomePage atualizou corretamente
6. Repetir mais uma vez (trocar de volta)

### Métricas a Coletar
- **Household Switch Time:** Tempo de troca completa
- **Data Reload Time:** Tempo para carregar dados do novo household
- **UI Update Smoothness:** FPS durante atualização
- **Cache Efficiency:** Se dados foram cacheados
- **Memory:** Consumo durante troca

### Snapshot Nome
`scenario_7_change_household.json`

---

## Cenário 8: Navigation Flow (End-to-End)

**Duração esperada:** 30-45 segundos  
**Objetivo:** Testar navegação entre todas as telas

### Passos de Execução
1. Na HomePage, navegar para Cats List
2. Abrir detail de um cat
3. Voltar para Cats List
4. Navegar para Statistics
5. Voltar para HomePage
6. Navegar para Feeding Logs
7. Registrar uma alimentação
8. Voltar para HomePage
9. Navegar para Account Settings
10. Voltar para HomePage

### Métricas a Coletar
- **Total Navigation Time:** Tempo total do flow
- **Per-Page Load Time:** Tempo de cada navegação
- **Memory Accumulation:** Acúmulo de memória durante navegação
- **Average FPS:** FPS médio durante todo o flow
- **Frame Drops:** Pontos com mais jank
- **Cache Hits:** Eficiência do cache entre telas

### Snapshot Nome
`scenario_8_navigation_end_to_end.json`

---

## Checklist de Execução

Para cada cenário, seguir este checklist:

- [ ] App reinstalado (clean state)
- [ ] DevTools aberto e configurado
- [ ] Enhanced tracing ativado
- [ ] Recording iniciado no DevTools
- [ ] Cenário executado conforme passos
- [ ] Aguardar estabilização (3-5s após fim)
- [ ] Recording pausado
- [ ] Snapshot exportado com nome correto
- [ ] Métricas anotadas em planilha
- [ ] Screenshots capturados (se necessário)

---

## Template de Coleta de Métricas

Para cada cenário, preencher:

```
Cenário: [Número e Nome]
Data: [YYYY-MM-DD]
Dispositivo: [Modelo]
Build: [Baseline | Optimized]

Métricas:
- Initial Load Time: ___ ms
- FPS Média: ___ fps
- FPS Mínima: ___ fps
- Frame Time Médio: ___ ms
- Frame Time Máximo: ___ ms
- Frames Janky: ___ % (___ de ___)
- Build Time Médio: ___ ms
- Build Time Máximo: ___ ms
- Raster Time Médio: ___ ms
- Raster Time Máximo: ___ ms
- Memory Pico: ___ MB
- Memory Final: ___ MB
- API Calls: ___ chamadas
- API Time Total: ___ ms
- Rebuilds: ___ rebuilds
- Top 3 Widgets Mais Pesados:
  1. ___ (___ ms)
  2. ___ (___ ms)
  3. ___ (___ ms)

Observações:
[Anotar qualquer anomalia ou comportamento inesperado]
```

---

## Notas Importantes

1. **Consistência:** Executar cenários sempre no mesmo dispositivo/configuração
2. **Ambiente:** Minimizar variáveis (mesma versão do app, mesmo dispositivo, mesma rede)
3. **Controle:** Fazer 3 tentativas de cada cenário e usar a mediana
4. **Documentação:** Anotar qualquer ação manual adicional ou comportamento inesperado
5. **Comparação:** Baseline e Optimized devem ser executados nas mesmas condições

---

**Próximos Passos:**  
- [ ] Criar script de automatização para captura de snapshots
- [ ] Preparar planilha para coleta de métricas
- [ ] Testar primeiro cenário manualmente

---

**Desenvolvido para o MealTime Flutter App**  
*Benchmark de Performance - Jan 2025*

