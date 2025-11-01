#!/bin/bash

# Script para monitorar tela do dispositivo e capturar screenshots
# Uso: ./scripts/monitor_screen.sh [intervalo_em_segundos]

INTERVAL=${1:-5}  # Padrão: 5 segundos
OUTPUT_DIR="screenshots"

echo "📱 Iniciando monitoramento da tela..."
echo "📊 Intervalo: $INTERVAL segundos"
echo "📁 Diretório: $OUTPUT_DIR"

# Verificar se dispositivo está conectado
DEVICE=$(adb devices | grep -w device | awk '{print $1}')

if [ -z "$DEVICE" ]; then
    echo "❌ Nenhum dispositivo conectado!"
    echo "Conecte um dispositivo Android via USB ou Wi-Fi ADB"
    exit 1
fi

echo "✅ Dispositivo detectado: $DEVICE"

# Criar diretório de screenshots
mkdir -p "$OUTPUT_DIR"

# Contador
COUNT=0

# Função para capturar screenshot
capture_screenshot() {
    COUNT=$((COUNT + 1))
    timestamp=$(date +%Y%m%d_%H%M%S)
    filename="$OUTPUT_DIR/screen_${timestamp}_${COUNT}.png"
    
    if adb exec-out screencap -p > "$filename" 2>/dev/null; then
        # Verificar se imagem foi criada e tem tamanho > 0
        if [ -f "$filename" ] && [ -s "$filename" ]; then
            echo "📸 Screenshot $COUNT: $filename ($(stat -c%s "$filename" 2>/dev/null || stat -f%z "$filename" 2>/dev/null) bytes)"
        else
            echo "⚠️  Falha ao capturar screenshot $COUNT"
        fi
    else
        echo "⚠️  Erro ao executar screencap"
    fi
}

# Capturar screenshot inicial
echo ""
echo "🎬 Capturando screenshot inicial..."
capture_screenshot

# Loop de captura contínua
echo ""
echo "🔄 Iniciando captura contínua (Ctrl+C para parar)..."
echo ""

trap 'echo ""; echo "🛑 Monitoramento interrompido. Total de screenshots: $COUNT"; exit 0' INT

while true; do
    sleep "$INTERVAL"
    capture_screenshot
done

