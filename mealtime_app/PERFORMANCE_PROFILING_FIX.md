# 🔧 Correção: Problema com DevTools Installation

**Problema:** `flutter pub global activate devtools` falha com erro de null safety

**Solução:** Flutter já vem com DevTools integrado! Não precisa instalar separadamente.

---

## ✅ Solução Correta (DevTools Integrado)

### Opção 1: Via Flutter Run (Mais Simples)

```bash
# Executar em profile mode - DevTools abre automaticamente
flutter run --profile

# No terminal, você verá algo como:
# The Flutter DevTools debugger and profiler on Linux is available at:
# http://127.0.0.1:9100?uri=...
```

**Passos:**
1. Execute: `flutter run --profile`
2. Copie a URL que aparece no terminal
3. Cole no navegador
4. DevTools abrirá automaticamente!

### Opção 2: Abrir DevTools Manualmente Durante Run

```bash
# Terminal 1: Rodar app
flutter run --profile

# Durante a execução, pressione:
# - 'd' para abrir DevTools
# Ou aguarde a URL aparecer no terminal
```

### Opção 3: Usar VS Code / Android Studio

**VS Code:**
1. Execute: `flutter run --profile`
2. Abra Command Palette (Ctrl+Shift+P)
3. Digite: "Flutter: Open DevTools"
4. Selecione "Performance"

**Android Studio:**
1. Execute app em profile mode
2. Aba "Flutter Performance" estará disponível automaticamente

---

## 🚀 Guia Rápido Atualizado

### Passo 1: Rodar App em Profile Mode

```bash
cd /home/mauriciobc/Documentos/Code/mealtime-flutter/mealtime_app
flutter run --profile
```

### Passo 2: Abrir DevTools

**Método Automático:**
- A URL aparecerá no terminal automaticamente
- Exemplo: `http://127.0.0.1:9100?uri=http://127.0.0.1:xxxxx/xxxxx`
- Copie e cole no navegador

**Método Manual:**
- Enquanto o app está rodando, pressione `d` no terminal
- Ou use Command Palette no VS Code

### Passo 3: Usar Performance View

1. No DevTools, abra a aba **Performance**
2. Ative as opções:
   - ✅ Track Widget Builds
   - ✅ Track Layouts  
   - ✅ Track Paints
3. Interaja com o app
4. Observe os frames e timeline

---

## 🔍 Alternativas se DevTools não Abrir

### Opção A: Usar Timeline Events Programaticamente

Adicionar eventos customizados no código:

```dart
import 'dart:developer' as developer;

// No código, adicionar eventos manualmente
developer.Timeline.instantSync('MyEvent', arguments: {'key': 'value'});

// Ou tasks
final task = developer.TimelineTask();
task.start('OperationName');
// ... sua operação ...
task.finish();
```

Depois visualizar no DevTools ou exportar.

### Opção B: Usar flutter run com flags

```bash
# Rodar com observatory habilitado
flutter run --profile --observatory-port=8888

# Depois acessar DevTools manualmente em:
# http://localhost:8888
```

### Opção C: Verificar se DevTools está acessível

```bash
# Verificar se porta 9100 está em uso
netstat -tuln | grep 9100

# Ou tentar acessar diretamente
curl http://127.0.0.1:9100
```

---

## 🛠️ Script Atualizado (sem pub global activate)

Atualizei o script `scripts/profile_app.sh` para não usar `flutter pub global activate devtools`.

---

## ✅ Validação

Para verificar se está funcionando:

1. Execute: `flutter run --profile`
2. Procure por mensagem como:
   ```
   Flutter DevTools, a Flutter debugger and profiler, is available at:
   http://127.0.0.1:9100?uri=...
   ```
3. Se aparecer, está funcionando! ✅
4. Cole a URL no navegador

---

## 📚 Referências

- [Flutter DevTools Documentation](https://docs.flutter.dev/tools/devtools)
- [Flutter Performance Profiling](https://docs.flutter.dev/tools/devtools/performance)
- [Running Flutter in Profile Mode](https://docs.flutter.dev/testing/build-modes#profile)

---

**Nota:** O Flutter SDK já inclui DevTools. Não é necessário instalar via `pub global activate` na versão moderna do Flutter.



