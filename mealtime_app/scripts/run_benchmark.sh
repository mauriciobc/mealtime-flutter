#!/bin/bash

# Script automatizado para executar benchmark completo de performance
# Uso: ./scripts/run_benchmark.sh [baseline|optimized]

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar argumento
MODE=${1:-baseline}
if [[ "$MODE" != "baseline" && "$MODE" != "optimized" ]]; then
    echo -e "${RED}Erro: Modo deve ser 'baseline' ou 'optimized'${NC}"
    echo "Uso: ./scripts/run_benchmark.sh [baseline|optimized]"
    exit 1
fi

echo "🚀 Iniciando Benchmark de Performance - Modo: $MODE"
echo "=================================================="
echo ""

# Verificar se dispositivo está conectado
echo -e "${BLUE}1. Verificando dispositivo...${NC}"
DEVICE=$(flutter devices | grep -E "^\w+ \w+" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo -e "${RED}   ✗ Nenhum dispositivo encontrado${NC}"
    echo "   Conecte um dispositivo ou inicie um emulador"
    exit 1
else
    echo -e "${GREEN}   ✓ Dispositivo encontrado: $DEVICE${NC}"
fi

# Configurar diretórios
BENCHMARK_DIR="benchmarks"
if [ "$MODE" == "baseline" ]; then
    OUTPUT_DIR="$BENCHMARK_DIR/baseline"
else
    OUTPUT_DIR="$BENCHMARK_DIR/optimized"
fi

mkdir -p "$OUTPUT_DIR"
mkdir -p "$BENCHMARK_DIR/screenshots"

# Limpar builds anteriores
echo ""
echo -e "${BLUE}2. Limpando builds anteriores...${NC}"
flutter clean > /dev/null 2>&1 || true
echo -e "${GREEN}   ✓ Build limpo${NC}"

# Instruções manuais (por enquanto, até automatizar totalmente)
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}⚠ IMPORTANTE: Este script requer passos manuais${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "📋 Passo a passo:"
echo ""
echo -e "${BLUE}1. Execute o app em profile mode:${NC}"
echo -e "   ${GREEN}flutter run --profile${NC}"
echo ""
echo -e "${BLUE}2. DevTools abrirá automaticamente no navegador${NC}"
echo "   (ou pressione 'd' no terminal do flutter run)"
echo ""
echo -e "${BLUE}3. Na aba Performance do DevTools, ative:${NC}"
echo "   • ✅ Track Widget Builds"
echo "   • ✅ Track Layouts"
echo "   • ✅ Track Paints"
echo "   • ✅ Memory Tracking"
echo ""
echo -e "${BLUE}4. Execute os 8 cenários descritos em:${NC}"
echo -e "   ${GREEN}BENCHMARK_TEST_SCENARIOS.md${NC}"
echo ""
echo -e "${BLUE}5. Para cada cenário:${NC}"
echo "   a) Clique em 'Record' no DevTools"
echo "   b) Execute o cenário conforme documentado"
echo "   c) Clique em 'Stop' no DevTools"
echo "   d) Exporte o snapshot:"
echo "      • Clique no ícone de download"
echo "      • Salve em: $OUTPUT_DIR/scenario_X_nome.json"
echo ""
echo -e "${BLUE}6. Anote as métricas no template de coleta${NC}"
echo ""

# Listar cenários
echo -e "${GREEN}📊 Cenários de teste:${NC}"
echo ""
echo "   1. Login Flow (Cold Start)"
echo "   2. HomePage Completa"
echo "   3. Cats List (Scroll Performance)"
echo "   4. Create Cat Flow"
echo "   5. Feeding Logs (Bottom Sheet)"
echo "   6. Statistics Page"
echo "   7. Change Household"
echo "   8. Navigation Flow (End-to-End)"
echo ""

# Exportar nome de arquivo esperado
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="benchmarks/${MODE}_execution_${TIMESTAMP}.log"

echo -e "${BLUE}7. Log de execução será salvo em:${NC}"
echo "   $LOG_FILE"
echo ""

# Criar checklist
CHECKLIST_FILE="benchmarks/${MODE}_checklist.txt"
cat > "$CHECKLIST_FILE" << EOF
Checklist de Execução - Modo: $MODE
Data: $(date)
Dispositivo: $DEVICE

Cenários:
- [ ] 1. scenario_1_login_cold_start.json
- [ ] 2. scenario_2_homepage_complete.json
- [ ] 3. scenario_3_cats_list_scroll.json
- [ ] 4. scenario_4_create_cat_flow.json
- [ ] 5. scenario_5_feeding_logs_bottom_sheet.json
- [ ] 6. scenario_6_statistics_page.json
- [ ] 7. scenario_7_change_household.json
- [ ] 8. scenario_8_navigation_end_to_end.json

Template de Métricas:
Consulte BENCHMARK_TEST_SCENARIOS.md para template completo

EOF

echo -e "${GREEN}✓ Checklist criado em: $CHECKLIST_FILE${NC}"
echo ""

# Próximos passos
echo -e "${YELLOW}📝 Próximos passos após coletar dados:${NC}"
echo ""
echo "1. Executar script de análise:"
echo "   python3 scripts/analyze_devtools_snapshot.py $MODE"
echo ""
echo "2. Gerar relatórios:"
echo "   python3 scripts/generate_comparison_report.py"
echo ""
echo -e "${GREEN}Pronto! Siga as instruções acima para iniciar o benchmark.${NC}"
echo ""

