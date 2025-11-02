#!/bin/bash

# Script para monitorar a página Statistics especificamente
# Captura screenshots a cada 2 segundos quando Statistics estiver aberta

OUTPUT_DIR="screenshots"
INTERVAL=2
COUNT=0
MAX_CAPTURES=30  # Máximo de 30 capturas (1 minuto de monitoramento)

echo "📊 Monitorando página Statistics..."
echo "📁 Screenshots salvos em: $OUTPUT_DIR"
echo "⏱️  Intervalo: $INTERVAL segundos"
echo ""

mkdir -p "$OUTPUT_DIR"

while [ $COUNT -lt $MAX_CAPTURES ]; do
    # Verificar se Statistics está aberta
    CURRENT_ACTIVITY=$(adb shell dumpsys window windows | grep -E "mCurrentFocus" | grep -o "com.example.mealtime_app" || echo "")
    
    if [ ! -z "$CURRENT_ACTIVITY" ]; then
        # Verificar se é Statistics (pode ser identificado via logs ou activity)
        STATS_OPEN=$(adb logcat -d -t 50 | grep -i "statistics" | tail -1 || echo "")
        
        if [ ! -z "$STATS_OPEN" ] || [ $COUNT -gt 0 ]; then
            COUNT=$((COUNT + 1))
            timestamp=$(date +%Y%m%d_%H%M%S)
            filename="$OUTPUT_DIR/stats_page_${timestamp}_${COUNT}.png"
            
            if adb exec-out screencap -p > "$filename" 2>/dev/null; then
                if [ -f "$filename" ] && [ -s "$filename" ]; then
                    size=$(stat -c%s "$filename" 2>/dev/null || stat -f%z "$filename" 2>/dev/null)
                    echo "📸 [$COUNT] $filename (${size} bytes)"
                fi
            fi
        fi
    fi
    
    sleep "$INTERVAL"
done

echo ""
echo "✅ Monitoramento concluído. Total: $COUNT screenshots"

