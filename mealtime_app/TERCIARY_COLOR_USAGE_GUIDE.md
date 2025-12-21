# 🎨 Guia de Uso de Cores Terciárias - Material Design 3

## 📋 Diretrizes do Material Design 3

Segundo as diretrizes oficiais do Material Design 3, as **cores terciárias** devem ser usadas para:

1. **Ações secundárias importantes** - Elementos que precisam de destaque mas não são a ação principal
2. **Diferenciação visual** - Para distinguir elementos relacionados mas diferentes
3. **Estados alternativos** - Para representar estados que não são primários nem de erro
4. **Elementos de destaque secundário** - Para chamar atenção sem competir com ações primárias

---

## ✅ Onde Já Estamos Usando (Bem Implementado)

### 1. Indicadores de Gênero
- ✅ **Ícone feminino** - Usa `colorScheme.tertiary` para diferenciar de macho (primary)
- ✅ **Status de peso** - Usa `tertiary` para indicar sobrepeso (diferente de primário/erro)

### 2. Gráficos e Visualizações
- ✅ **Paletas de cores** - Usa `tertiary` como uma das cores na rotação de gráficos
- ✅ **Barras de gráficos** - Usa `tertiary` para destacar dados específicos

---

## 🎯 Oportunidades de Uso Seguindo M3 Guidelines

### 1. **Botões Tonais (FilledButton.tonal)** ⭐ ALTA PRIORIDADE

**Diretriz M3**: Botões tonais são perfeitos para ações secundárias importantes que precisam de destaque visual.

**Onde aplicar:**
- Botões de ação secundária em formulários
- Botões de "Cancelar" ou "Voltar" em diálogos
- Ações alternativas em telas de criação/edição

**Exemplo:**
```dart
// Em vez de TextButton ou OutlinedButton para ações secundárias
FilledButton.tonal(
  onPressed: () {},
  style: FilledButton.styleFrom(
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
    foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
  ),
  child: const Text('Cancelar'),
)
```

**Arquivos para atualizar:**
- `lib/features/auth/presentation/widgets/login_form.dart` - Link "Esqueci minha senha"
- `lib/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart` - Botões de ação secundária
- `lib/features/cats/presentation/pages/cat_detail_page.dart` - Botões de ação secundária
- `lib/features/homes/presentation/pages/home_detail_page.dart` - Botões de ação secundária

---

### 2. **TextButton para Ações Secundárias** ⭐ ALTA PRIORIDADE

**Diretriz M3**: TextButtons podem usar cores terciárias quando representam ações secundárias importantes.

**Onde aplicar:**
- Links de navegação secundária
- Ações de "Ver mais" ou "Saiba mais"
- Links para telas relacionadas

**Exemplo:**
```dart
TextButton(
  onPressed: () {},
  style: TextButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.tertiary,
  ),
  child: const Text('Esqueci minha senha'),
)
```

**Arquivos para atualizar:**
- `lib/features/auth/presentation/widgets/login_form.dart` (linha 124)
- `lib/features/auth/presentation/pages/login_page.dart` (linha 141, 156)
- `lib/features/auth/presentation/pages/register_page.dart` (linha 63)

---

### 3. **OutlinedButton para Ações Secundárias Destacadas** ⭐ MÉDIA PRIORIDADE

**Diretriz M3**: OutlinedButtons podem usar cores terciárias quando a ação é importante mas secundária.

**Onde aplicar:**
- Botões de ação alternativa em formulários
- Botões de "Adicionar" em contextos secundários
- Ações complementares

**Exemplo:**
```dart
OutlinedButton.icon(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    foregroundColor: Theme.of(context).colorScheme.tertiary,
    side: BorderSide(
      color: Theme.of(context).colorScheme.tertiary,
    ),
  ),
  icon: const Icon(Icons.add),
  label: const Text('Adicionar'),
)
```

**Arquivos para atualizar:**
- `lib/features/homes/presentation/pages/home_detail_page.dart` (linhas 240, 336)
- `lib/features/feeding_logs/presentation/widgets/feeding_log_form.dart` (linhas 114, 122)

---

### 4. **Chips e Badges** ⭐ MÉDIA PRIORIDADE

**Diretriz M3**: Chips podem usar cores terciárias para filtros e seleções secundárias.

**Onde aplicar:**
- Chips de filtro secundário
- Badges de status alternativo
- Tags de categoria secundária

**Exemplo:**
```dart
FilterChip(
  selected: isSelected,
  onSelected: (value) {},
  label: const Text('Filtro'),
  selectedColor: Theme.of(context).colorScheme.tertiaryContainer,
  checkmarkColor: Theme.of(context).colorScheme.onTertiaryContainer,
)
```

**Arquivos para atualizar:**
- `lib/features/feeding_logs/presentation/widgets/feeding_log_form.dart` (linha 53) - FilterChip
- `lib/features/homes/presentation/widgets/home_card.dart` (linha 80) - Badge "ATIVA" (poderia ter variante terciária para status inativo)

---

### 5. **Ícones de Ação Secundária** ⭐ BAIXA PRIORIDADE

**Diretriz M3**: Ícones podem usar cores terciárias para ações secundárias.

**Onde aplicar:**
- Ícones de ação alternativa
- Ícones de informação complementar
- Ícones de navegação secundária

**Exemplo:**
```dart
IconButton(
  onPressed: () {},
  icon: Icon(
    Icons.info_outline,
    color: Theme.of(context).colorScheme.tertiary,
  ),
)
```

**Arquivos para atualizar:**
- `lib/features/homes/presentation/widgets/home_card.dart` (linha 151) - Ícone "Definir como Ativa" poderia usar tertiary

---

### 6. **Containers e Superfícies Terciárias** ⭐ BAIXA PRIORIDADE

**Diretriz M3**: `tertiaryContainer` pode ser usado para destacar áreas secundárias.

**Onde aplicar:**
- Cards de informação complementar
- Seções de destaque secundário
- Containers de ajuda ou dicas

**Exemplo:**
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.tertiaryContainer,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Dica: Você pode...',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onTertiaryContainer,
    ),
  ),
)
```

---

## 📊 Priorização de Implementação

### 🔴 Alta Prioridade (Impacto Alto, Esforço Baixo)
1. **TextButton** em links secundários (login, registro)
2. **FilledButton.tonal** em ações secundárias de formulários

### 🟡 Média Prioridade (Impacto Médio, Esforço Médio)
3. **OutlinedButton** com cores terciárias
4. **Chips** com cores terciárias para filtros secundários

### 🟢 Baixa Prioridade (Impacto Baixo, Esforço Baixo)
5. **Ícones** de ação secundária
6. **Containers terciários** para áreas de destaque secundário

---

## 🎨 Hierarquia de Cores no Material Design 3

```
PRIMÁRIA (Primary)
  ↓ Ação principal, elementos mais importantes
SECUNDÁRIA (Secondary)  
  ↓ Elementos de suporte, menos proeminentes
TERCIÁRIA (Tertiary) ⭐
  ↓ Ações secundárias importantes, diferenciação visual
ERRO (Error)
  ↓ Estados de erro, ações destrutivas
```

---

## 📚 Referências

- [Material Design 3 - Color System](https://m3.material.io/styles/color/overview)
- [Material Design 3 - Component Theming](https://m3.material.io/components/buttons/guidelines)
- [Material Design 3 - Expressive Guidelines](https://m3.material.io/blog/building-with-m3-expressive)

---

## ✅ Checklist de Implementação

- [ ] Atualizar TextButtons em formulários de autenticação
- [ ] Implementar FilledButton.tonal em ações secundárias
- [ ] Adicionar cores terciárias em OutlinedButtons secundários
- [ ] Atualizar Chips com cores terciárias
- [ ] Revisar ícones de ação secundária
- [ ] Considerar containers terciários para áreas de destaque

---

**Última atualização**: 2025-01-27  
**Status**: Documentação completa - Pronto para implementação

