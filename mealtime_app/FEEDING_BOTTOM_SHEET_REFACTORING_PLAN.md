# Plano de Refatoração: Bottom Sheet de Alimentação Múltipla

## 📋 Visão Geral

Este documento descreve o plano de refatoração para implementar um bottom sheet de alimentação que permite selecionar múltiplos gatos simultaneamente, replicando o comportamento da aplicação web.

## 🎯 Objetivo

Criar uma experiência de usuário mais eficiente onde o usuário pode:
1. Clicar no FAB (Floating Action Button) e abrir um bottom sheet
2. Selecionar múltiplos gatos usando checkboxes
3. Ver formulários individuais para cada gato selecionado
4. Registrar alimentações para múltiplos gatos de uma só vez

## 📱 Comportamento da Web App (Referência)

### Estrutura do Bottom Sheet

#### Header
- **Título**: "Registrar Nova Alimentação"
- **Subtítulo**: "Selecione os gatos e informe os detalhes da refeição."
- **Contador**: "X de Y gatos selecionados"
- **Botões auxiliares**:
  - "Todos" - Seleciona todos os gatos
  - "Limpar" - Desmarca todos (disabled quando nenhum selecionado)

#### Lista de Gatos
Para cada gato disponível:
- **Checkbox** à esquerda
- **Avatar do gato** (imagem circular)
- **Informações**:
  - Nome do gato (bold)
  - "Última refeição: há X dias/horas/meses"

#### Formulário Expansível (quando gato selecionado)
Ao marcar um checkbox, expande automaticamente um formulário abaixo com:

**Linha 1 (3 campos horizontais):**
1. **Porção (g)**: 
   - Tipo: Spinbutton/TextField numérico
   - Valor padrão: 10
   - Label: "Porção (g)"

2. **Status**:
   - Tipo: Dropdown/Select
   - Opções: Normal, Reluctante, Faminto, etc.
   - Valor padrão: "Normal"
   - Label: "Status"

3. **Tipo**:
   - Tipo: Dropdown/Select
   - Opções: "Ração Seca", "Ração Úmida", "Sachê", etc.
   - Valor padrão: "Ração Seca"
   - Label: "Tipo"

**Linha 2 (campo completo):**
4. **Observações**:
   - Tipo: TextArea/TextField multiline
   - Placeholder: "Opcional"
   - Label: "Observações"

#### Footer (Sticky Button)
- **Botão primário**: "Confirmar Alimentação (X)"
  - X = número de gatos selecionados
  - Disabled quando nenhum gato selecionado
  - Cor: Azul primário
  - Largura: Full width

## 🏗️ Arquitetura Flutter

### Novos Arquivos a Criar

```
lib/features/meals/presentation/
├── widgets/
│   ├── feeding_bottom_sheet.dart         # Bottom sheet principal
│   ├── cat_selection_item.dart           # Item de seleção com checkbox
│   ├── feeding_form_fields.dart          # Campos do formulário por gato
│   └── multiple_feeding_form.dart        # Formulário completo
└── bloc/ (opcional)
    ├── feeding_sheet_state.dart          # Estado do bottom sheet
    └── feeding_sheet_cubit.dart          # Lógica de estado
```

### Estrutura de Dados

#### FeedingFormData (novo)
```dart
class FeedingFormData {
  final String catId;
  final double portion;      // em gramas
  final String status;       // "Normal", "Reluctante", etc.
  final String foodType;     // "Ração Seca", etc.
  final String? notes;       // Observações opcionais
  
  FeedingFormData({
    required this.catId,
    this.portion = 10.0,
    this.status = 'Normal',
    this.foodType = 'Ração Seca',
    this.notes,
  });
}
```

#### BottomSheetState (novo)
```dart
class FeedingBottomSheetState {
  final Set<String> selectedCatIds;                    // IDs dos gatos selecionados
  final Map<String, FeedingFormData> feedingData;      // Dados por gato
  final bool isSubmitting;
  
  // Métodos helper
  int get selectedCount => selectedCatIds.length;
  bool isCatSelected(String catId) => selectedCatIds.contains(catId);
  FeedingFormData? getDataForCat(String catId) => feedingData[catId];
}
```

## 🔧 Implementação Detalhada

### 1. FeedingBottomSheet Widget

**Responsabilidades:**
- Gerenciar estado local do bottom sheet (seleções e dados)
- Renderizar lista de gatos disponíveis
- Controlar expansão/colapso de formulários
- Validar e submeter dados

**Estrutura:**
```dart
class FeedingBottomSheet extends StatefulWidget {
  final List<Cat> availableCats;
  final String householdId;
  
  @override
  State<FeedingBottomSheet> createState() => _FeedingBottomSheetState();
}

class _FeedingBottomSheetState extends State<FeedingBottomSheet> {
  final Set<String> _selectedCatIds = {};
  final Map<String, FeedingFormData> _feedingData = {};
  
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            _buildHeader(),
            _buildSelectionControls(),
            Expanded(
              child: _buildCatsList(scrollController),
            ),
            _buildConfirmButton(),
          ],
        );
      },
    );
  }
}
```

### 2. CatSelectionItem Widget

**Responsabilidades:**
- Exibir informações do gato (avatar, nome, última refeição)
- Gerenciar estado do checkbox
- Expandir/colapsar formulário quando selecionado

**Estrutura:**
```dart
class CatSelectionItem extends StatelessWidget {
  final Cat cat;
  final bool isSelected;
  final FeedingFormData? formData;
  final ValueChanged<bool?> onSelectionChanged;
  final ValueChanged<FeedingFormData> onFormDataChanged;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildCatInfo(),
          if (isSelected) 
            FeedingFormFields(
              data: formData!,
              onChanged: onFormDataChanged,
            ),
        ],
      ),
    );
  }
}
```

### 3. FeedingFormFields Widget

**Responsabilidades:**
- Renderizar os 4 campos do formulário (Porção, Status, Tipo, Observações)
- Layout responsivo (3 campos na linha 1, 1 na linha 2)
- Validação de dados

**Estrutura:**
```dart
class FeedingFormFields extends StatelessWidget {
  final FeedingFormData data;
  final ValueChanged<FeedingFormData> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Linha 1: Porção, Status, Tipo
          Row(
            children: [
              Expanded(
                child: _buildPortionField(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusField(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFoodTypeField(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Linha 2: Observações
          _buildNotesField(),
        ],
      ),
    );
  }
}
```

### 4. Integração com HomePage

**Mudança no FAB:**
```dart
// Antes (home_page.dart linha 62)
floatingActionButton: FloatingActionButton(
  onPressed: () => context.push(AppRouter.createMeal),
  child: const Icon(Icons.add),
),

// Depois
floatingActionButton: FloatingActionButton(
  onPressed: () => _showFeedingBottomSheet(context),
  child: const Icon(Icons.add),
),
```

**Novo método:**
```dart
void _showFeedingBottomSheet(BuildContext context) {
  final catsBloc = context.read<CatsBloc>();
  final authBloc = context.read<SimpleAuthBloc>();
  
  // Pegar gatos disponíveis do estado atual
  final cats = catsBloc.state is CatsLoaded 
    ? (catsBloc.state as CatsLoaded).cats 
    : <Cat>[];
  
  // Pegar householdId do usuário autenticado
  final householdId = '...'; // TODO: Implementar lógica
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FeedingBottomSheet(
      availableCats: cats,
      householdId: householdId,
    ),
  );
}
```

### 5. Lógica de Submissão

Quando o usuário clicar em "Confirmar Alimentação (X)":

1. **Validar dados**: Verificar se todos os campos obrigatórios estão preenchidos
2. **Criar múltiplos Meals**: Um Meal para cada gato selecionado
3. **Dispatchar eventos**: Um evento `CreateMeal` para cada gato
4. **Feedback**: Mostrar loading e depois sucesso/erro
5. **Fechar bottom sheet**: Após sucesso

```dart
Future<void> _submitFeedings() async {
  setState(() => _isSubmitting = true);
  
  final now = DateTime.now();
  final mealsToCreate = <Meal>[];
  
  for (final catId in _selectedCatIds) {
    final data = _feedingData[catId]!;
    
    final meal = Meal(
      id: const Uuid().v4(),
      catId: catId,
      homeId: widget.householdId,
      type: MealType.snack, // ou detectar tipo baseado na hora
      scheduledAt: now,
      completedAt: now, // Marcar como completado imediatamente
      status: MealStatus.completed,
      amount: data.portion,
      foodType: data.foodType,
      notes: data.notes,
      createdAt: now,
      updatedAt: now,
    );
    
    mealsToCreate.add(meal);
  }
  
  // Dispatch para o bloc
  for (final meal in mealsToCreate) {
    context.read<MealsBloc>().add(CreateMeal(meal));
  }
  
  // Aguardar processamento e fechar
  await Future.delayed(const Duration(milliseconds: 500));
  if (mounted) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Alimentação registrada para ${mealsToCreate.length} gato(s)!',
        ),
      ),
    );
  }
}
```

## 🎨 Design e UX

### Animações
1. **Expansão do formulário**: AnimatedContainer com duration de 300ms
2. **Seleção de checkbox**: Animação de check suave
3. **Abertura do bottom sheet**: DraggableScrollableSheet com animação padrão

### Cores e Tema
- **Borda do gato selecionado**: `Theme.of(context).colorScheme.primary`
- **Botão primário**: `ElevatedButton` com cor primária
- **Botão desabilitado**: Opacidade reduzida
- **Background do bottom sheet**: `Theme.of(context).colorScheme.surface`

### Responsividade
- **Campos em linha**: 3 campos horizontais em tablets/landscape
- **Campos empilhados**: Considerar empilhar campos em telas pequenas
- **Tamanho do bottom sheet**: 
  - Inicial: 70% da tela
  - Mínimo: 50%
  - Máximo: 95%

## 📝 Opções de Status e Tipo de Comida

### Status do Gato
```dart
enum FeedingStatus {
  normal('Normal'),
  reluctant('Reluctante'),
  hungry('Faminto'),
  picky('Exigente');
  
  final String displayName;
  const FeedingStatus(this.displayName);
}
```

### Tipos de Comida
```dart
enum FoodType {
  dryCat('Ração Seca'),
  wetCat('Ração Úmida'),
  sachet('Sachê'),
  homemade('Caseira'),
  treat('Petisco');
  
  final String displayName;
  const FoodType(this.displayName);
}
```

## ✅ Checklist de Implementação

### Fase 1: Estrutura Base
- [ ] Criar `FeedingFormData` class
- [ ] Criar `FeedingBottomSheet` widget
- [ ] Implementar header com título e contador
- [ ] Implementar botões "Todos" e "Limpar"

### Fase 2: Seleção de Gatos
- [ ] Criar `CatSelectionItem` widget
- [ ] Implementar checkbox funcional
- [ ] Exibir informações do gato (nome, avatar, última refeição)
- [ ] Implementar lógica de seleção/deseleção

### Fase 3: Formulário Expansível
- [ ] Criar `FeedingFormFields` widget
- [ ] Implementar campo "Porção (g)"
- [ ] Implementar dropdown "Status"
- [ ] Implementar dropdown "Tipo"
- [ ] Implementar campo "Observações"
- [ ] Adicionar animação de expansão/colapso

### Fase 4: Validação e Submissão
- [ ] Implementar validação de campos obrigatórios
- [ ] Criar lógica de submissão para múltiplos gatos
- [ ] Adicionar estado de loading durante submissão
- [ ] Implementar feedback de sucesso/erro
- [ ] Fechar bottom sheet após sucesso

### Fase 5: Integração
- [ ] Atualizar FAB na HomePage
- [ ] Conectar com CatsBloc para obter gatos
- [ ] Conectar com MealsBloc para criar meals
- [ ] Testar fluxo completo
- [ ] Ajustes de UX e polish

### Fase 6: Melhorias (Opcional)
- [ ] Adicionar imagens reais dos gatos (se disponível)
- [ ] Implementar "última refeição" dinâmica
- [ ] Adicionar suporte a fotos da alimentação
- [ ] Implementar scroll infinito se muitos gatos
- [ ] Adicionar busca/filtro de gatos

## 🔄 Compatibilidade com Código Existente

### Mantém compatibilidade com:
- ✅ `MealsBloc` e eventos existentes
- ✅ `CatsBloc` e estado existente
- ✅ Entity `Meal` (não requer alterações)
- ✅ Entity `Cat` (não requer alterações)
- ✅ Navegação existente (não remove `CreateMealPage`)

### Depreca/Modifica:
- ⚠️ `CreateMealPage` ainda existe mas não é acessada pelo FAB
- ⚠️ Pode ser mantida para edição de meals existentes
- ⚠️ `MealForm` widget pode ser reutilizado ou adaptado

## 🧪 Testes

### Casos de Teste
1. **Seleção única**: Selecionar um gato e preencher formulário
2. **Seleção múltipla**: Selecionar vários gatos simultaneamente
3. **Botão "Todos"**: Verificar seleção de todos os gatos
4. **Botão "Limpar"**: Verificar deseleção de todos os gatos
5. **Validação**: Tentar submeter com campos vazios
6. **Submissão**: Criar alimentações para múltiplos gatos
7. **Cancelamento**: Fechar bottom sheet sem salvar

## 📚 Referências

- Web App: https://mealtime.app.br
- Material Design Bottom Sheets: https://m3.material.io/components/bottom-sheets
- Flutter DraggableScrollableSheet: https://api.flutter.dev/flutter/widgets/DraggableScrollableSheet-class.html

## 🚀 Próximos Passos

1. Revisar e aprovar este plano
2. Criar branch para desenvolvimento: `feature/feeding-bottom-sheet`
3. Implementar fase por fase conforme checklist
4. Code review após cada fase
5. Testar em dispositivos reais
6. Deploy para beta testers
7. Coletar feedback e iterar

---

**Data de Criação**: 12 de Outubro de 2025  
**Autor**: AI Assistant (Claude)  
**Status**: Aguardando Aprovação

