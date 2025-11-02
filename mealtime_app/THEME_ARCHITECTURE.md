# Arquitetura do Tema Material Design 3

## 🎨 Estrutura do Tema

### 1. Configuração Base
```dart
ThemeData(
  useMaterial3: true,  // Habilita Material Design 3
  colorScheme: ColorScheme.fromSeed(...),  // Cores dinâmicas
  textTheme: _buildTextTheme(...),  // Tipografia expressiva
  // ... outros temas de componentes
)
```

### 2. Sistema de Cores

#### Tema Claro
- **Primária**: #6750A4 (Roxo vibrante)
- **Secundária**: #625B71 (Cinza-azulado)
- **Terciária**: #7D5260 (Rosa-terroso)
- **Erro**: #BA1A1A (Vermelho vibrante)

#### Tema Escuro
- **Primária**: #D0BCFF (Roxo claro)
- **Secundária**: #CCC2DC (Cinza claro)
- **Terciária**: #EFB8C8 (Rosa claro)
- **Erro**: #FFB4AB (Vermelho claro)

### 3. Tipografia Expressiva

#### Hierarquia de Textos
- **Display**: 57px, 45px, 36px (Títulos principais)
- **Headline**: 32px, 28px, 24px (Títulos de seção)
- **Title**: 22px, 16px, 14px (Títulos de card)
- **Body**: 16px, 14px, 12px (Texto corrido)
- **Label**: 14px, 12px, 11px (Labels e botões)

### 4. Componentes Temáticos

#### Botões
```dart
// Elevated Button
ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
)

// Filled Button
FilledButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
)

// Outlined Button
OutlinedButton.styleFrom(
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
)
```

#### Cards
```dart
CardThemeData(
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
)
```

#### Inputs
```dart
InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  filled: true,
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
)
```

### 5. Navegação

#### AppBar
```dart
AppBarTheme(
  centerTitle: true,
  elevation: 0,
  scrolledUnderElevation: 4,  // Elevação ao fazer scroll
)
```

#### Bottom Navigation
```dart
BottomNavigationBarThemeData(
  type: BottomNavigationBarType.fixed,
  elevation: 0,
)
```

### 6. Adaptação Automática

O tema se adapta automaticamente entre modo claro e escuro baseado nas preferências do sistema:

```dart
MaterialApp(
  theme: _buildLightTheme(),      // Tema claro
  darkTheme: _buildDarkTheme(),   // Tema escuro
  themeMode: ThemeMode.system,    // Segue preferências do sistema
)
```

## 🔧 Como Personalizar

### 1. Alterar Cores
Modifique as constantes de cor no início dos métodos `_buildLightTheme()` e `_buildDarkTheme()`:

```dart
const Color primaryColor = Color(0xFF6750A4);  // Sua cor primária
const Color secondaryColor = Color(0xFF625B71); // Sua cor secundária
```

### 2. Ajustar Tipografia
Modifique o método `_buildTextTheme()` para alterar tamanhos, pesos e espaçamentos:

```dart
TextStyle(
  fontSize: 57,           // Tamanho da fonte
  fontWeight: FontWeight.w400,  // Peso da fonte
  letterSpacing: -0.25,   // Espaçamento entre letras
)
```

### 3. Personalizar Componentes
Cada componente tem seu próprio tema que pode ser customizado:

```dart
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    // Suas customizações aqui
  ),
),
```

## 📱 Responsividade

O tema é responsivo e se adapta a diferentes tamanhos de tela:

- **Mobile**: Navegação inferior, cards empilhados
- **Tablet**: Layout em grid, navegação lateral (futuro)
- **Desktop**: Layout em colunas, navegação superior (futuro)

## ♿ Acessibilidade

O tema inclui características de acessibilidade:

- **Contraste**: Cores com contraste adequado (WCAG AA)
- **Tamanhos**: Textos e botões com tamanhos mínimos recomendados
- **Navegação**: Suporte a navegação por teclado
- **Semântica**: Labels e descrições apropriadas

## 🚀 Performance

O tema é otimizado para performance:

- **Cores**: Calculadas uma vez e reutilizadas
- **Textos**: Estilos pré-definidos e reutilizáveis
- **Componentes**: Temas aplicados globalmente
- **Memória**: Uso eficiente de recursos

## 📚 Referências

- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Material 3](https://docs.flutter.dev/ui/material)
- [Color System](https://m3.material.io/styles/color/overview)
- [Typography](https://m3.material.io/styles/typography/overview)
