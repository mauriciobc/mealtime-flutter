# Guia de Monitoramento com Scrcpy

## 🎯 Objetivo

Monitorar o app em tempo real durante execução para capturar:
- Erros de renderização
- Problemas de layout
- Comportamento dos gráficos
- Loops de erro em cascata

## 📱 Comandos para Monitoramento

### 1. Verificar Dispositivo Conectado
```bash
adb devices
```

### 2. Iniciar Scrcpy (em terminal separado)
```bash
scrcpy --stay-awake --turn-screen-off
```

**Flags Úteis**:
- `--stay-awake`: Mantém dispositivo acordado
- `--turn-screen-off`: Desliga tela do dispositivo (economiza bateria)
- `--record=screen.mp4`: Grava vídeo da tela
- `--no-display`: Apenas captura sem mostrar janela (útil para scripts)

### 3. Tirar Screenshot Manual
```bash
# Via adb
adb exec-out screencap -p > screenshot_$(date +%s).png

# Via scrcpy (Ctrl+C para capturar)
# O scrcpy tem screenshot automático em algumas versões
```

### 4. Monitorar Logs do Flutter
```bash
# Em outro terminal, enquanto app está rodando
adb logcat | grep flutter
```

## 🔍 Pontos de Atenção Durante Monitoramento

### Quando Observar a Tela:

1. **Inicialização do App**
   - Verificar se gráficos aparecem corretamente
   - Observar se há travamentos na HomePage

2. **Navegação para Statistics**
   - Capturar screenshot ao abrir página
   - Verificar se gráficos renderizam ou mostram erro
   - Observar se há erros de layout

3. **Interação com Gráficos**
   - Tentar navegar entre páginas rapidamente
   - Verificar se erros aparecem durante transições

4. **Momento do Erro**
   - Se erro aparecer, capturar screenshot imediatamente
   - Verificar qual widget está na tela quando erro ocorre
   - Observar padrão de erro (se é específico de algum gráfico)

## 📊 Informações para Capturar

Quando um erro ocorrer, anotar:
- **Tela atual**: Home, Statistics, ou outra?
- **Ação realizada**: Navegação, scroll, toque?
- **Widget visível**: Gráfico específico ou área da tela?
- **Momento**: Durante carregamento ou após dados carregados?
- **Screenshot**: Capturar estado visual da tela

## 🛠️ Script de Monitoramento Automático

Crie um script para automatizar captura de screenshots:

```bash
#!/bin/bash
# monitor_app.sh

echo "Iniciando monitoramento..."
DEVICE=$(adb devices | grep device | awk '{print $1}')

if [ -z "$DEVICE" ]; then
    echo "Nenhum dispositivo conectado!"
    exit 1
fi

echo "Dispositivo: $DEVICE"
mkdir -p screenshots

# Capturar screenshot a cada 5 segundos
while true; do
    timestamp=$(date +%Y%m%d_%H%M%S)
    adb exec-out screencap -p > "screenshots/screen_$timestamp.png"
    echo "Screenshot: screen_$timestamp.png"
    sleep 5
done
```

Execute com: `bash monitor_app.sh`

## 📝 Checklist de Testes

- [ ] App inicia sem erros visuais
- [ ] HomePage carrega gráfico corretamente
- [ ] Navegação para Statistics funciona
- [ ] Gráficos na Statistics renderizam
- [ ] Navegação rápida não causa erros
- [ ] Screenshots capturados em momentos críticos
- [ ] Logs verificados para erros não visíveis

## 🚨 Comandos de Emergência

Se app travar completamente:
```bash
# Parar app
adb shell am force-stop com.example.mealtime_app

# Limpar logs
adb logcat -c

# Reiniciar app
adb shell am start -n com.example.mealtime_app/.MainActivity
```

---

**Nota**: O tratamento de erro global foi adicionado ao `main.dart` para ajudar a prevenir loops infinitos de erro.

