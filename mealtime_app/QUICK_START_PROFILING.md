# ⚡ Início Rápido - Profiling de Performance

**Boa notícia:** Seu Flutter já tem DevTools 2.48.0 instalado! Não precisa instalar nada.

---

## 🚀 Em 3 Passos Simples

### Passo 1: Rodar o App em Profile Mode

```bash
cd /home/mauriciobc/Documentos/Code/mealtime-flutter/mealtime_app
flutter run --profile
```

### Passo 2: Abrir DevTools

**Opção A (Automática - Recomendada):**
- Aguarde alguns segundos após iniciar o app
- No terminal, você verá uma mensagem como:
  ```
  The Flutter DevTools debugger and profiler on Linux is available at:
  http://127.0.0.1:9100?uri=http://127.0.0.1:xxxxx/xxxxx
  ```
- Copie essa URL e cole no navegador
- ✅ Pronto! DevTools abriu!

**Opção B (Tecla Rápida):**
- Enquanto o app está rodando, pressione `d` no terminal
- DevTools abrirá automaticamente

**Opção C (VS Code):**
- Abra Command Palette (Ctrl+Shift+P)
- Digite: `Flutter: Open DevTools`
- Selecione: `Performance`

### Passo 3: Configurar e Analisar

1. No DevTools, clique na aba **Performance**
2. Ative estas opções (no dropdown "Enhance tracing"):
   - ✅ Track Widget Builds
   - ✅ Track Layouts
   - ✅ Track Paints
3. Interaja com o app (navegar, scroll, etc.)
4. Observe os frames e timeline

---

## 📊 O Que Observar

### Frames Chart (Gráfico de Barras no Topo)

- **Verde:** Frame normal (< 16ms) ✅
- **Vermelho:** Frame janky (> 16ms) ⚠️
- **Vermelho escuro:** Shader compilation (temporário)

**Meta:** 55-60 FPS = frames verdes

### Timeline Events (Aba Inferior)

Após ativar "Track Widget Builds", você verá:
- Cada chamada de `build()` de widgets
- Operações pesadas (sort, firstWhere, etc.)
- Rebuilds duplicados

**Procure por:**
- Múltiplos rebuilds do mesmo widget
- Operações lentas no build method
- Widgets sendo reconstruídos desnecessariamente

---

## 🎯 Teste Rápido

### Cenário: Mudança de Estado

1. App rodando em profile mode
2. DevTools Performance aberto e configurado
3. Na HomePage, faça um pull-to-refresh (ou trigger mudança)
4. Observe:
   - Quantos frames ficam vermelhos?
   - Quantos rebuilds aparecem no timeline?
   - Qual widget mais rebuild?

**Resultado esperado:**
- Rebuilds: 1-2 (não 12!)
- Frames janky: < 1%
- Frame time: < 16ms

---

## 🔍 Problemas Comuns

### "DevTools não abre"

**Solução:**
- A URL aparece no terminal? Copie e cole manualmente
- Tente pressionar `d` no terminal do `flutter run`
- Use VS Code: Command Palette → "Flutter: Open DevTools"

### "Não vejo frames"

**Solução:**
- Certifique-se de estar em **profile mode** (não debug!)
- Aguarde o app carregar completamente
- Faça alguma interação com o app

### "Todos os frames estão vermelhos"

**Solução:**
- Isso é esperado inicialmente (shader compilation)
- Aguarde 5-10 segundos após carregar
- Depois os frames devem normalizar

---

## 📚 Documentação Completa

- **Guia Detalhado:** `PERFORMANCE_PROFILING_GUIDE.md`
- **Checklist:** `PERFORMANCE_PROFILING_CHECKLIST.md`
- **Relatório:** `PERFORMANCE_DIAGNOSTIC_REPORT.md`

---

## ✅ Pronto!

Agora você pode coletar dados reais de performance e comparar com as estimativas do relatório de diagnóstico!

**Dica:** Exporte snapshots do DevTools antes e depois das correções para comparar melhorias.

---

**Versão do Flutter:** 3.35.7  
**DevTools:** 2.48.0 (já incluído) ✅  
**Data:** 12 de Outubro de 2025



