# Contraste em Dark Mode – Página de Estatísticas

## Evidência coletada

### Problemas identificados (antes das correções)

1. **statistics_page.dart**
   - Ícone do empty state com `onSurfaceVariant.withValues(alpha: 0.5)` → pouco visível no dark mode.
   - Títulos (noData, errorLoading) sem cor explícita → dependiam do default do tema.
   - Botão de retry como `ElevatedButton` → trocado por `FilledButton` para contraste consistente.

2. **statistics_summary_cards.dart**
   - Valor dos cards com `titleLarge` sem `color` → em alguns temas o texto poderia herdar cor de baixo contraste sobre `surfaceContainer`.

3. **statistics_filters.dart**
   - `DropdownButtonFormField` com `InputDecoration` constante, sem `fillColor` nem `labelStyle` → fundo e label poderiam ter pouco contraste no dark mode.

4. **Gráficos (daily_consumption, hourly, cat, food_type)**
   - `backgroundColor: theme.colorScheme.surface` na área do gráfico → em dark mode quase igual ao Card (`surfaceContainer`), pouca separação visual.
   - Títulos dos cards sem `color` explícita.
   - Ícones dos empty states com alpha 0.5 → pouco visíveis.
   - Legendas dos pie charts com `bodySmall` sem cor → garantido `onSurface`.

### Correções aplicadas

| Arquivo | Ajuste |
|--------|--------|
| statistics_page.dart | Empty icon alpha 0.5 → 0.7; títulos com `color: colorScheme.onSurface`; erro com `FilledButton`. |
| statistics_summary_cards.dart | Valor com `color: theme.colorScheme.onSurface`. |
| statistics_filters.dart | `fillColor: surfaceContainerHighest`, `labelStyle` com `onSurfaceVariant`, `filled: true`. |
| daily_consumption_chart.dart | Chart `backgroundColor: surfaceContainerLow`; títulos `onSurface`; empty icon alpha 0.7. |
| hourly_distribution_chart.dart | Idem (surfaceContainerLow, onSurface, alpha 0.7). |
| cat_distribution_chart.dart | Títulos e legenda `onSurface`; empty icon alpha 0.7. |
| food_type_distribution_chart.dart | Idem. |

### Uso de cores no app (revisão geral)

- **Tema**: `main.dart` usa `_ensureThemeColorContrast()` para garantir contraste entre surface e surfaceContainer/surfaceContainerHigh/Highest em light e dark.
- **Semântica M3**: Texto principal → `onSurface`; texto secundário → `onSurfaceVariant`; erros → `error` / `onErrorContainer`.
- **Pontos de atenção em outros módulos** (não alterados nesta tarefa):
  - `weight_page.dart`: uso de `Colors.green`, `Colors.red`, `Colors.grey` hardcoded → considerar `colorScheme.primary`/tertiary ou cores semânticas para consistência no dark mode.
  - `notifications_page.dart`: `Colors.green`, `Colors.orange`, `Colors.white` → idem.
  - `expressive_dialogs.dart`: `Colors.black`/`Colors.white` para contraste em overlay → adequado; manter.

### Referências

- Material Design 3: [Color system](https://m3.material.io/styles/color/overview)
- WCAG 2.1: contraste mínimo 4.5:1 para texto normal, 3:1 para texto grande e elementos gráficos.
- THEME_ARCHITECTURE.md do projeto.
