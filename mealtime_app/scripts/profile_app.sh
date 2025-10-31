#!/bin/bash

# Script para executar profiling do app MealTime em modo profile
# Uso: ./scripts/profile_app.sh

set -e

echo "🚀 Iniciando profiling do MealTime App"
echo "======================================"
echo ""

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar se DevTools está disponível (já vem com Flutter)
echo -e "${BLUE}1. Verificando Flutter DevTools...${NC}"
DEVTOOLS_VERSION=$(flutter --version | grep "DevTools" | awk '{print $NF}' || echo "desconhecido")
if [ "$DEVTOOLS_VERSION" != "desconhecido" ]; then
    echo -e "${GREEN}   ✓ DevTools ${DEVTOOLS_VERSION} está disponível (já vem com Flutter)${NC}"
else
    echo -e "${YELLOW}   ⚠ DevTools deveria estar disponível com Flutter${NC}"
    echo "   Não é necessário instalar separadamente!"
fi

# Verificar dispositivo conectado
echo ""
echo -e "${BLUE}2. Verificando dispositivos...${NC}"
DEVICE=$(flutter devices | grep -E "^\w+ \w+" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo -e "${YELLOW}   ⚠ Nenhum dispositivo encontrado${NC}"
    echo "   Conecte um dispositivo ou inicie um emulador"
    exit 1
else
    echo -e "${GREEN}   ✓ Dispositivo encontrado: $DEVICE${NC}"
fi

# Preparar ambiente
echo ""
echo -e "${BLUE}3. Preparando ambiente de profile...${NC}"
echo "   Limpando build anterior..."
flutter clean > /dev/null 2>&1 || true

# Verificar se app compila
echo "   Verificando compilação..."
if ! flutter build apk --profile > /dev/null 2>&1; then
    echo -e "${YELLOW}   ⚠ Aviso: Build pode ter problemas, mas continuando...${NC}"
fi

echo ""
echo -e "${BLUE}4. Instruções para profiling:${NC}"
echo ""
echo "   Passo 1: Execute o app em profile mode:"
echo -e "   ${GREEN}   flutter run --profile${NC}"
echo ""
echo "   Passo 2: DevTools abrirá automaticamente!"
echo -e "   ${GREEN}   A URL aparecerá no terminal automaticamente${NC}"
echo "   Exemplo: http://127.0.0.1:9100?uri=..."
echo ""
echo "   Passo 3: Copie a URL e cole no navegador"
echo -e "   ${YELLOW}   Ou pressione 'd' no terminal do flutter run${NC}"
echo ""
echo "   Passo 4: Na aba Performance, ative:"
echo "   • Track Widget Builds"
echo "   • Track Layouts"
echo "   • Track Paints"
echo ""
echo -e "${BLUE}5. Cenários de teste recomendados:${NC}"
echo "   • Carregar HomePage"
echo "   • Trigger mudança de estado (refresh cats)"
echo "   • Scroll em listas"
echo "   • Abrir/fechar bottom sheets"
echo ""
echo -e "${BLUE}6. Métricas a observar:${NC}"
echo "   • FPS (ideal: 55-60)"
echo "   • Frame time (ideal: <16ms)"
echo "   • Frames janky (ideal: <1%)"
echo "   • Rebuilds por evento (ideal: 1-2)"
echo ""
echo -e "${GREEN}Pronto! Siga os passos acima para iniciar o profiling.${NC}"
echo ""
echo "📚 Consulte PERFORMANCE_PROFILING_GUIDE.md para detalhes"

