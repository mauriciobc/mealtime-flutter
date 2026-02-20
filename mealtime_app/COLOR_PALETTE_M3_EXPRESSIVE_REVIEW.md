# Revisão da paleta de cores – Material 3 Expressive

## Objetivo

Analisar a implementação da **paleta de cores** do app em relação às diretrizes do **Material Design 3** e ao guia **M3 Expressive** (cores dinâmicas, tokens, contraste e uso semântico).

---

## 1. Diretrizes M3 relevantes para cores

- **Dynamic color**: preferência do usuário (wallpaper) como semente da paleta quando disponível.
- **Sistema de tons**: primary, secondary, tertiary e roles de superfície (surface, surfaceContainer*, surfaceDim, surfaceBright).
- **Contraste**: pares on/onPrimary, onSurface, etc., e diferença visível entre surface e surfaceContainer*.
- **Acessibilidade**: contraste mínimo (WCAG) e não depender só de cor para informação.

---

## 2. O que está alinhado

### 2.1 Fonte e geração da paleta

- **`ColorScheme.fromSeed()`** com `DynamicColorBuilder`: uso de dynamic color e fallback com `Colors.orange` está correto e alinhado ao M3.
- **Um único `_buildTheme(ColorScheme)`**: evita duplicação e garante que tema claro e escuro usem a mesma lógica de cores.

### 2.2 Ajuste de contraste (surface vs containers)

- **`_ensureThemeColorContrast()`** em `main.dart`:
  - Garante diferenças mínimas de luminância entre `surface` e `surfaceContainerHighest`, `surfaceContainer`, `surfaceContainerHigh`.
  - Usa saturação limitada nos containers (mais neutros), em linha com M3.
  - Comportamento correto: tema claro → containers mais escuros que surface; tema escuro → mais claros.

Isso atende às recomendações M3 de **hierarquia de superfícies** e **acessibilidade**.

### 2.3 Extensão expressiva e tokens

- **`M3ExpressiveTheme`** em `ThemeData.extensions` com `M3ExpressiveColors.fromColorScheme(colorScheme)` mantém uma cópia consistente com o `ColorScheme` e permite evolução (ex.: overlays, estados) sem fugir da paleta.
- **Elevation e border** expressivos estão aplicados via `M3ExpressiveElevation.expressive` e `M3ExpressiveBorder.expressive`.
- **Cards** usam `colorScheme.surfaceContainer` (e `cardTheme.color`), em conformidade com M3.

### 2.4 Uso nos widgets

- A maior parte da UI usa **`Theme.of(context).colorScheme`** (primary, onPrimary, secondary, tertiary, error, onError, surfaceContainer*, onSurface, onSurfaceVariant, outline, etc.).
- Gráficos usam **cores semânticas** (primary, secondary, tertiary, error, *Container) para séries e legendas, o que mantém consistência com o tema e dark mode.
- Botões de erro/destrutivos usam `colorScheme.error` / `onError`; SnackBars e estados vazios usam `primaryContainer`/`onPrimaryContainer` quando faz sentido.

Conclusão: a **base da paleta e seu uso** estão aderentes ao M3 e ao espírito expressivo (cores ricas e hierarquia clara).

---

## 3. Pontos de atenção e desvios menores

### 3.1 `M3ExpressiveColors.fromColorScheme` – mapeamentos

**surfaceVariant**

- Em `m3_expressive_theme.dart` (linha 98):  
  `surfaceVariant: scheme.surfaceContainerHighest`
- No Flutter, `ColorScheme.surfaceVariant` está **deprecated** em favor dos roles `surfaceContainer*`. Usar `surfaceContainerHighest` como “variante de superfície” está alinhado com a migração M3 e com a documentação do Flutter.
- **Recomendação**: manter. Opcionalmente documentar no próprio `M3ExpressiveColors` que `surfaceVariant` espelha `surfaceContainerHighest` por compatibilidade com a migração M3.

**background / onBackground**

- Atualmente: `background: scheme.surface`, `onBackground: scheme.onSurface`.
- No M3, em muitos contextos “background” e “surface” coincidem; no Flutter, `ColorScheme` pode não expor `background` em todas as versões. Espelhar em `surface`/`onSurface` é um fallback razoável.
- **Recomendação**: manter. Se no futuro o Flutter expuser `background`/`onBackground` distintos, vale refletir isso em `M3ExpressiveColors`.

**inverseOnSurface**

- ~~Código: `inverseOnSurface: scheme.onInverseSurface.withValues(alpha: 0.87)`.~~ **Corrigido**: passou a usar `scheme.onInverseSurface` sem alpha para contraste M3 adequado.

### 3.2 Cores fixas (preto/branco) em contextos específicos

- **`expressive_dialogs.dart`**  
  - `barrierColor: Colors.black54` e uso de `Colors.black`/`Colors.white` para texto sobre botão quando a cor do botão é customizada (por luminância).  
  - Já documentado em `STATISTICS_DARK_MODE_CONTRAST.md` como adequado para overlay e contraste sobre cor arbitrária. **Manter.**

- **`cat_distribution_chart.dart` e `food_type_distribution_chart.dart`**  
  - `_getContrastColor()` retorna `Colors.black` ou `Colors.white` conforme a luminância da **cor da fatia** (para legibilidade sobre a cor do segmento).  
  - Para cores que são exatamente as do tema (ex.: primary, secondary), em teoria poderíamos usar `onPrimary`, `onSecondary`, etc.; para contagem variável de fatias e cores derivadas, preto/branco por luminância é uma abordagem comum e aceitável para WCAG.  
  - **Recomendação**: manter; opcionalmente, para fatias que usem estritamente primary/secondary/tertiary, usar os pares on* do tema pode reforçar a paleta (melhoria futura, não obrigatória).

- **`notifications_page.dart`**  
  - **Corrigido**: `Colors.green`/`Colors.orange` em `_getColorForType` → `colorScheme.primary` (success) e `colorScheme.tertiary` (warning); ícone delete no Dismissible → `colorScheme.onError` (fundo já era `colorScheme.error`).

---

## 4. Resumo de aderência

| Aspecto                         | Status   | Nota |
|--------------------------------|----------|------|
| Dynamic color + fromSeed       | Conforme | Fallback orange; contraste garantido após ajuste. |
| Tokens M3 (surface, containers)| Conforme | Uso consistente de surfaceContainer* e onSurface/onSurfaceVariant. |
| Ajuste de contraste (surface vs containers) | Conforme | `_ensureThemeColorContrast` implementado e documentado. |
| Extensão M3ExpressiveTheme     | Conforme | Cores derivadas do ColorScheme; elevation/border expressivos. |
| Uso semântico nos widgets      | Conforme | Predominância de colorScheme; gráficos com roles semânticos. |
| surfaceVariant → surfaceContainerHighest | Conforme | Alinhado à migração M3/Flutter. |
| inverseOnSurface com alpha     | Conforme | Corrigido: uso de `onInverseSurface` sem alpha. |
| Cores fixas pontuais           | Conforme | notifications_page corrigido; demais contextos (overlay, contraste em fatia) justificados. |

---

## 5. Conclusão

A implementação da **paleta de cores** está **aderente às diretrizes Material 3 e ao uso expressivo**: dynamic color, tokens de superfície, contraste entre surface e containers, e uso semântico nas telas e gráficos. As correções aplicadas foram: (1) `inverseOnSurface` sem alpha em `m3_expressive_theme.dart`; (2) substituição de cores fixas em `notifications_page` por roles do `colorScheme` (primary/tertiary para tipos, onError para ícone no Dismissible).

---

**Referências**

- [Material Design 3 – Color system](https://m3.material.io/styles/color/overview)
- [Building with M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)
- Flutter: `ColorScheme`, depreciação de `surfaceVariant`, roles `surfaceContainer*`
- Documentos do projeto: `THEME_ARCHITECTURE.md`, `M3_EXPRESSIVE_COMPLIANCE_REPORT.md`, `STATISTICS_DARK_MODE_CONTRAST.md`
