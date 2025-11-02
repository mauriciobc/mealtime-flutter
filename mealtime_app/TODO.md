# 📱 TODO: Port do MealTime para Flutter

## 🎯 Visão Geral

Este documento detalha o plano completo para portar o aplicativo **MealTime** (gerenciamento de alimentação de gatos) do Next.js/React para Flutter, mantendo o backend atual e criando uma experiência mobile nativa.

**Projeto Original**: [https://github.com/mauriciobc/mealtime](https://github.com/mauriciobc/mealtime)  
**Stack Original**: Next.js 14, React, TypeScript, Prisma, TailwindCSS, Shadcn UI  
**Stack Flutter**: Flutter 3.8+, BLoC, GoRouter, Dio, Hive, Material Design 3

---

## ✅ Status Atual do Projeto

- [x] **Projeto Flutter criado** com Material Design 3
- [x] **Tema expressivo** implementado (claro/escuro)
- [x] **Estrutura base** configurada
- [x] **Navegação** básica implementada
- [x] **Backend integration** ✅ CONCLUÍDA
- [x] **Sistema de autenticação** ✅ CONCLUÍDO
- [x] **Arquitetura Clean** ✅ CONCLUÍDA
- [x] **Gerenciamento de gatos** ✅ CONCLUÍDO
- [x] **Sistema de refeições** ✅ CONCLUÍDO
- [x] **Múltiplas residências** ✅ CONCLUÍDO

---

## ✅ FASE 1: Configuração e Estrutura (1-2 dias) - CONCLUÍDA

### 1.1 Dependências e Configuração
- [x] **Atualizar pubspec.yaml** com dependências necessárias
  ```yaml
  dependencies:
    # State Management
    flutter_bloc: ^8.1.3
    equatable: ^2.0.5
    
    # Navigation
    go_router: ^12.1.3
    
    # HTTP & API
    dio: ^5.4.0
    retrofit: ^4.0.3
    json_annotation: ^4.8.1
    
    # Local Storage
    shared_preferences: ^2.2.2
    hive: ^2.2.3
    hive_flutter: ^1.1.0
    
    # Notifications
    flutter_local_notifications: ^16.3.2
    timezone: ^0.9.2
    
    # UI Components
    flutter_svg: ^2.0.9
    lottie: ^2.7.0
    cached_network_image: ^3.3.0
    
    # Utils
    intl: ^0.19.0
    uuid: ^4.2.1
    permission_handler: ^11.1.0
  ```

- [x] **Configurar análise de código** (analysis_options.yaml)
- [x] **Configurar build runner** para code generation

### 1.2 Estrutura de Pastas
- [x] **Criar arquitetura Clean** com separação de responsabilidades
  ```
  lib/
  ├── core/
  │   ├── constants/
  │   ├── errors/
  │   ├── network/
  │   └── storage/
  ├── features/
  │   ├── auth/
  │   ├── cats/
  │   ├── meals/
  │   ├── homes/
  │   ├── notifications/
  │   └── settings/
  ├── shared/
  │   ├── widgets/
  │   ├── theme/
  │   └── utils/
  └── services/
      ├── api/
      ├── database/
      └── notifications/
  ```

---

## ✅ FASE 2: Integração com Backend (3-5 dias) - CONCLUÍDA

### 2.1 Configuração da API
- [x] **Criar ApiClient** com Dio
  ```dart
  // lib/services/api/api_client.dart
  class ApiClient {
    static const String baseUrl = 'https://mealtime-api.vercel.app/api';    late final Dio _dio;
    
    ApiClient() {
      _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));
      
      _dio.interceptors.add(AuthInterceptor());
      _dio.interceptors.add(LogInterceptor());
    }
  }
  ```

- [x] **Implementar interceptors** de autenticação
- [x] **Configurar endpoints** da API
- [x] **Implementar tratamento de erros**

### 2.2 Modelos de Dados
- [x] **Criar entidades de domínio**
  - [x] `Cat` - Gerenciamento de gatos
  - [x] `Meal` - Sistema de refeições
  - [x] `Home` - Múltiplas residências
  - [x] `User` - Autenticação
  - [x] `WeightEntry` - Controle de peso

- [x] **Implementar modelos JSON** com serialization
- [x] **Criar mappers** entre entidades e modelos
- [x] **Configurar Hive** para cache local

### 2.3 Serviços de API
- [x] **AuthApiService** - Login, registro, refresh token
- [x] **CatsApiService** - CRUD de gatos
- [x] **MealsApiService** - CRUD de refeições
- [x] **HomesApiService** - CRUD de residências
- [x] **NotificationsApiService** - Notificações push

---

## ✅ FASE 3: Sistema de Autenticação (2-3 dias) - CONCLUÍDA

### 3.1 Implementação de Auth
- [x] **Criar AuthBloc** para gerenciamento de estado
- [x] **Implementar login/register** com validação
- [x] **Configurar refresh token** automático
- [x] **Implementar logout** e limpeza de dados

### 3.2 Telas de Autenticação
- [x] **LoginScreen** - Tela de login
- [x] **RegisterScreen** - Tela de registro
- [x] **ForgotPasswordScreen** - Recuperação de senha
- [x] **SplashScreen** - Verificação de autenticação

### 3.3 Gerenciamento de Estado
- [x] **AuthState** - Estados de autenticação
- [x] **AuthEvent** - Eventos de autenticação
- [x] **AuthRepository** - Camada de dados
- [x] **AuthUseCase** - Lógica de negócio

---

## ✅ FASE 4: Gerenciamento de Gatos (1-2 semanas) - CONCLUÍDA

### 4.1 Funcionalidades Core
- [x] **Lista de gatos** com cards informativos
- [x] **Adicionar gato** com formulário completo
- [x] **Editar gato** com dados existentes
- [x] **Excluir gato** com confirmação
- [x] **Upload de foto** do gato (estrutura pronta)

### 4.2 Telas e Widgets
- [x] **CatsListPage** - Lista principal
- [x] **CreateCatPage** - Adicionar gato
- [x] **EditCatPage** - Editar gato
- [x] **CatDetailPage** - Detalhes do gato
- [x] **CatCard** - Widget de card
- [x] **CatForm** - Formulário reutilizável

### 4.3 State Management
- [x] **CatsBloc** - Gerenciamento de estado
- [x] **CatsState** - Estados da lista
- [x] **CatsEvent** - Eventos de CRUD
- [x] **CatsRepository** - Camada de dados

---

## ✅ FASE 5: Sistema de Refeições (1-2 semanas) - CONCLUÍDA

### 5.1 Funcionalidades Core
- [x] **Lista de refeições** com filtros
- [x] **Agendar refeição** com data/hora
- [x] **Concluir refeição** com confirmação
- [x] **Pular refeição** com motivo
- [x] **Histórico de refeições** por gato

### 5.2 Telas e Widgets
- [x] **MealsListPage** - Lista principal
- [x] **CreateMealPage** - Agendar refeição
- [x] **EditMealPage** - Editar refeição
- [x] **MealCard** - Widget de card
- [x] **MealForm** - Formulário de refeição
- [x] **MealCalendar** - Calendário de refeições

### 5.3 State Management
- [x] **MealsBloc** - Gerenciamento de estado
- [x] **MealsState** - Estados da lista
- [x] **MealsEvent** - Eventos de CRUD
- [x] **MealsRepository** - Camada de dados

---

## ✅ FASE 6: Múltiplas Residências (3-5 dias) - CONCLUÍDA

### 6.1 Funcionalidades
- [x] **Lista de residências** do usuário
- [x] **Criar residência** com nome e endereço
- [x] **Editar residência** existente
- [x] **Excluir residência** (se vazia)
- [x] **Trocar residência** ativa

### 6.2 Telas e Widgets
- [x] **HomesListPage** - Lista de residências
- [x] **CreateHomePage** - Criar residência
- [x] **EditHomePage** - Editar residência
- [x] **HomeCard** - Widget de card
- [x] **HomeSelector** - Seletor de residência

---

## 🔔 FASE 7: Sistema de Notificações (3-5 dias)

### 7.1 Notificações Push
- [ ] **Configurar Flutter Local Notifications**
- [ ] **Agendar lembretes** de refeições
- [ ] **Notificações em tempo real** para refeições
- [ ] **Ações rápidas** (concluir/pular) na notificação
- [ ] **Sincronização** com backend

### 7.2 Funcionalidades
- [ ] **Lembretes automáticos** baseados no agendamento
- [ ] **Notificações de peso** (se configurado)
- [ ] **Lembretes de vacinação** (futuro)
- [ ] **Configurações de notificação** por gato

### 7.3 Implementação
- [ ] **NotificationService** - Serviço principal
- [ ] **ScheduledNotifications** - Agendamento
- [ ] **NotificationBloc** - Gerenciamento de estado
- [ ] **NotificationSettings** - Configurações

---

## 📊 FASE 8: Estatísticas e Relatórios (1 semana)

### 8.1 Funcionalidades
- [ ] **Dashboard principal** com resumo
- [ ] **Estatísticas por gato** (peso, refeições)
- [ ] **Gráficos de evolução** de peso
- [ ] **Relatórios de alimentação** por período
- [ ] **Exportar dados** (futuro)

### 8.2 Telas e Widgets
- [ ] **DashboardPage** - Tela principal
- [ ] **CatStatisticsPage** - Estatísticas por gato
- [ ] **WeightChart** - Gráfico de peso
- [ ] **MealHistoryPage** - Histórico de refeições
- [ ] **ReportPage** - Relatórios detalhados

---

## 📱 FASE 9: Modo Offline (1 semana)

### 9.1 Cache Local
- [ ] **Configurar Hive** para armazenamento local
- [ ] **Implementar cache** de dados
- [ ] **Sincronização automática** quando online
- [ ] **Resolução de conflitos** de dados

### 9.2 Funcionalidades Offline
- [ ] **Visualizar dados** sem internet
- [ ] **Criar/editar** dados offline
- [ ] **Sincronizar** quando voltar online
- [ ] **Indicador de status** de conexão

### 9.3 Implementação
- [ ] **OfflineService** - Serviço principal
- [ ] **SyncService** - Sincronização
- [ ] **ConflictResolver** - Resolução de conflitos
- [ ] **ConnectivityService** - Monitor de conexão

---

## 🎨 FASE 10: Interface e UX (1 semana)

### 10.1 Componentes UI
- [ ] **Atualizar tema** para cores do MealTime
- [ ] **Criar widgets customizados** para o domínio
- [ ] **Implementar animações** Lottie
- [ ] **Otimizar responsividade** para diferentes telas

### 10.2 Melhorias de UX
- [ ] **Loading states** em todas as operações
- [ ] **Error handling** com mensagens claras
- [ ] **Empty states** quando não há dados
- [ ] **Pull-to-refresh** nas listas
- [ ] **Infinite scroll** para listas grandes

### 10.3 Acessibilidade
- [ ] **Semantic labels** em todos os widgets
- [ ] **Contraste adequado** nas cores
- [ ] **Tamanhos de toque** apropriados
- [ ] **Navegação por teclado** (desktop)

---

## 🧪 FASE 11: Testes (1 semana)

### 11.1 Testes Unitários
- [ ] **Testes de BLoCs** com bloc_test
- [ ] **Testes de repositórios** com mockito
- [ ] **Testes de serviços** de API
- [ ] **Testes de utilitários** e helpers

### 11.2 Testes de Widget
- [ ] **Testes de telas** principais
- [ ] **Testes de formulários** com validação
- [ ] **Testes de navegação** entre telas
- [ ] **Testes de temas** claro/escuro

### 11.3 Testes de Integração
- [ ] **Testes E2E** com integration_test
- [ ] **Testes de fluxo** completo de usuário
- [ ] **Testes de sincronização** offline/online
- [ ] **Testes de notificações**

---

## 🚀 FASE 12: Deploy e Publicação (3-5 dias)

### 12.1 Configuração de Build
- [ ] **Configurar Android** (build.gradle, proguard)
- [ ] **Configurar iOS** (Info.plist, permissões)
- [ ] **Configurar Web** (se necessário)
- [ ] **Configurar Linux** (se necessário)

### 12.2 CI/CD
- [ ] **GitHub Actions** para build automático
- [ ] **Testes automáticos** em PRs
- [ ] **Build de release** automático
- [ ] **Deploy automático** para stores

### 12.3 Publicação
- [ ] **Google Play Store** (Android)
- [ ] **App Store** (iOS)
- [ ] **TestFlight** para testes beta
- [ ] **Documentação** de usuário

---

## 📋 Checklist de Implementação

### ✅ Configuração Inicial
- [x] Projeto Flutter configurado
- [x] Dependências adicionadas
- [x] Estrutura de pastas criada
- [x] Análise de código configurada

### ✅ Backend Integration
- [x] Cliente HTTP configurado
- [x] Interceptors de autenticação
- [x] Serviços de API implementados
- [x] Tratamento de erros

### ✅ Autenticação
- [x] Login/Register implementado
- [x] Gerenciamento de tokens
- [x] Refresh automático
- [x] Logout e limpeza

### ✅ Core Features
- [ ] Gerenciamento de gatos
- [ ] Sistema de refeições
- [ ] Múltiplas residências
- [ ] Interface responsiva

### ✅ Notificações
- [ ] Push notifications
- [ ] Agendamento local
- [ ] Sincronização com backend
- [ ] Ações rápidas

### ✅ Offline Support
- [ ] Cache local (Hive)
- [ ] Sincronização automática
- [ ] Modo offline
- [ ] Resolução de conflitos

### ✅ Polish & Deploy
- [ ] Testes unitários
- [ ] Testes de integração
- [ ] Otimizações de performance
- [ ] Deploy nas stores

---

## 🎯 Próximos Passos Imediatos

### 1. Começar Hoje
```bash
# 1. Atualizar dependências
flutter pub get

# 2. Configurar estrutura de pastas
mkdir -p lib/{core,features,shared,services}

# 3. Implementar ApiClient
# (seguir código do plano)

# 4. Criar primeiro BLoC (Auth)
# (seguir arquitetura Clean)
```

### 2. Prioridade de Implementação
1. **Configuração base** (projeto + dependências)
2. **Integração com API** (cliente HTTP + auth)
3. **Tela de login** (primeira funcionalidade)
4. **Lista de gatos** (CRUD básico)
5. **Sistema de refeições** (funcionalidade principal)
6. **Notificações** (diferencial do app)
7. **Modo offline** (experiência robusta)

### 3. Recursos de Apoio
- **Código completo** para todos os componentes
- **Exemplos práticos** de implementação
- **Padrões de arquitetura** Clean + BLoC
- **Integração backend** pronta para usar

---

## 📚 Recursos de Aprendizado

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [GoRouter](https://pub.dev/packages/go_router)
- [Material Design 3](https://m3.material.io/)

---

## ⏱️ Cronograma Estimado

| Fase | Duração | Descrição |
|------|---------|-----------|
| 1-2 | 1-2 dias | Configuração e estrutura |
| 3-4 | 3-5 dias | Backend integration |
| 5-6 | 2-3 dias | Autenticação |
| 7-8 | 1-2 semanas | Gerenciamento de gatos |
| 9-10 | 1-2 semanas | Sistema de refeições |
| 11-12 | 3-5 dias | Múltiplas residências |
| 13-14 | 3-5 dias | Notificações |
| 15-16 | 1 semana | Estatísticas e relatórios |
| 17-18 | 1 semana | Modo offline |
| 19-20 | 1 semana | Interface e UX |
| 21-22 | 1 semana | Testes |
| 23-24 | 3-5 dias | Deploy e publicação |

**Total estimado: 6-8 semanas** para um desenvolvedor júnior seguindo este plano detalhado.

---

## 🏆 Resultado Final

Ao final da implementação, você terá:

- ✅ **Aplicativo Flutter completo** com Material Design 3
- ✅ **Integração total** com o backend atual
- ✅ **Experiência mobile nativa** e performática
- ✅ **Funcionalidades offline** robustas
- ✅ **Sistema de notificações** push nativo
- ✅ **Arquitetura escalável** e manutenível
- ✅ **Testes abrangentes** e CI/CD configurado

**O MealTime Flutter estará pronto para produção!** 🚀

---

## 🎯 Progresso Atual (Atualizado em 2024)

### ✅ **FASES CONCLUÍDAS**
- **Fase 1**: Configuração e Estrutura ✅
- **Fase 2**: Integração com Backend ✅  
- **Fase 3**: Sistema de Autenticação ✅
- **Fase 4**: Gerenciamento de Gatos ✅
- **Fase 5**: Sistema de Refeições ✅
- **Fase 6**: Múltiplas Residências ✅

### 🚀 **FUNCIONALIDADES IMPLEMENTADAS**
- ✅ **Arquitetura Clean** completa com separação de responsabilidades
- ✅ **Sistema de autenticação** funcional (login/registro/logout)
- ✅ **Integração com API** pronta para uso
- ✅ **Navegação** com GoRouter
- ✅ **Gerenciamento de estado** com BLoC
- ✅ **Tema Material Design 3** configurado
- ✅ **Injeção de dependências** com GetIt
- ✅ **Tratamento de erros** robusto
- ✅ **Interceptors de autenticação** automáticos
- ✅ **Sistema completo de gerenciamento de gatos** (CRUD)
- ✅ **Sistema completo de refeições** (CRUD + calendário)
- ✅ **Sistema completo de residências** (CRUD + seleção ativa)
- ✅ **Interface responsiva** com Material Design 3
- ✅ **Formulários validados** para criação/edição
- ✅ **Navegação entre telas** funcional
- ✅ **Calendário interativo** de refeições
- ✅ **Sistema de status** (agendada, concluída, pulada)
- ✅ **Filtros e busca** de refeições
- ✅ **Gerenciamento de múltiplas residências**
- ✅ **Seletor de residência ativa**

### 📱 **STATUS DO APLICATIVO**
- ✅ **Compilação**: Funcionando
- ✅ **Execução**: Funcionando
- ✅ **Testes**: Estrutura pronta
- ✅ **Análise de código**: Sem erros críticos

### 🎯 **PRÓXIMAS FASES**
- **Fase 7**: Sistema de Notificações
- **Fase 8**: Estatísticas e Relatórios
- **Fase 9**: Modo Offline

---

## ✅ FASE 13: Compatibilidade Total com API Mobile (2-3 dias) - 95% CONCLUÍDA

### 13.1 Análise de Incompatibilidades Identificadas

Com base na documentação da API Mobile, foram identificadas as seguintes incompatibilidades que precisam ser corrigidas:

#### 🚨 **Problemas Críticos**

1. **Base URL Incorreta**
   - **Atual**: `https://mealtime-api.vercel.app/api`
   - **Correto**: `https://mealtime.app.br/api`

2. **Endpoints de Autenticação Incorretos**
   - **Atual**: `/auth/login`, `/auth/register`, `/auth/refresh`
   - **Correto**: `/auth/mobile`, `/auth/mobile/register`, `/auth/mobile` (PUT)

3. **Estrutura de Resposta Incompatível**
   - **Atual**: `{accessToken, refreshToken, user}`
   - **Correto**: `{success, user, access_token, refresh_token, expires_in, token_type}`

4. **Modelos de Dados Incompatíveis**
   - **User**: Faltam campos `auth_id`, `household_id`, `household`
   - **Cat**: Faltam campos `weight`, `photo_url`, `household_id`
   - **IDs**: API usa `String`, Flutter usa `String` (✅ compatível)

### 13.2 Plano de Correção

#### **Passo 1: Atualizar Configurações da API** ✅ CONCLUÍDO

- [x] **Corrigir Base URL** em `lib/core/constants/api_constants.dart`
- [x] **Atualizar endpoints** de autenticação para `/auth/mobile`
- [x] **Adicionar novos endpoints** conforme documentação

#### **Passo 2: Atualizar Modelos de Dados** ✅ CONCLUÍDO

- [x] **Criar novo AuthResponse** compatível com API
- [x] **Atualizar UserModel** com campos `auth_id`, `household_id`, `household`
- [x] **Atualizar CatModel** com campos `weight`, `photo_url`, `household_id`
- [x] **Criar modelo Household** para residências
- [x] **Atualizar mappers** entre entidades e modelos

#### **Passo 3: Atualizar Serviços de API** ✅ CONCLUÍDO

- [x] **Modificar AuthApiService** para usar novos endpoints
- [x] **Atualizar request/response models** para compatibilidade
- [x] **Implementar tratamento** de estrutura de resposta `{success, data}`
- [x] **Adicionar suporte** a refresh token automático

#### **Passo 4: Atualizar Interceptors** ✅ CONCLUÍDO

- [x] **Modificar AuthInterceptor** para usar `access_token`
- [x] **Implementar refresh automático** com `refresh_token`
- [x] **Adicionar tratamento** de erros 401 com retry

### 13.3 Implementação Detalhada

#### **13.3.1 Atualizar ApiConstants**

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // ✅ CORRIGIR: Base URL
  static const String baseUrl = 'https://mealtime.app.br/api';
  
  // ✅ CORRIGIR: Endpoints de autenticação
  static const String login = '/auth/mobile';
  static const String register = '/auth/mobile/register';
  static const String refreshToken = '/auth/mobile'; // PUT method
  
  // ✅ MANTER: Outros endpoints (já corretos)
  static const String cats = '/cats';
  static const String meals = '/meals';
  static const String homes = '/homes';
}
```

#### **13.3.2 Criar Novo AuthResponse**

```dart
// lib/services/api/auth_api_service.dart
class AuthResponse {
  final bool success;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? tokenType;
  final String? error;
  final bool? requiresEmailConfirmation;

  AuthResponse({
    required this.success,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.tokenType,
    this.error,
    this.requiresEmailConfirmation,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json['success'] ?? false,
    user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    accessToken: json['access_token'],
    refreshToken: json['refresh_token'],
    expiresIn: json['expires_in'],
    tokenType: json['token_type'],
    error: json['error'],
    requiresEmailConfirmation: json['requires_email_confirmation'],
  );
}
```

#### **13.3.3 Atualizar UserModel**

```dart
// lib/features/auth/data/models/user_model.dart
@JsonSerializable()
class UserModel {
  final String id;
  @JsonKey(name: 'auth_id')
  final String authId;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String email;
  @JsonKey(name: 'household_id')
  final String? householdId;
  final HouseholdModel? household;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.authId,
    required this.fullName,
    required this.email,
    this.householdId,
    this.household,
    required this.createdAt,
    required this.updatedAt,
  });

  // ... resto da implementação
}

// Novo modelo para Household
@JsonSerializable()
class HouseholdModel {
  final String id;
  final String name;
  final List<HouseholdMemberModel> members;

  const HouseholdModel({
    required this.id,
    required this.name,
    required this.members,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) => 
      _$HouseholdModelFromJson(json);
}

@JsonSerializable()
class HouseholdMemberModel {
  final String id;
  final String name;
  final String email;
  final String role;

  const HouseholdMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory HouseholdMemberModel.fromJson(Map<String, dynamic> json) => 
      _$HouseholdMemberModelFromJson(json);
}
```

#### **13.3.4 Atualizar CatModel**

```dart
// lib/features/cats/data/models/cat_model.dart
@JsonSerializable()
class CatModel {
  final int id; // ✅ API usa int para ID do gato
  final String name;
  @JsonKey(name: 'birth_date')
  final String? birthDate; // ✅ API usa String para data
  final double? weight; // ✅ Adicionar campo weight
  @JsonKey(name: 'photo_url')
  final String? photoUrl; // ✅ Adicionar campo photo_url
  @JsonKey(name: 'household_id')
  final int householdId; // ✅ API usa int para household_id
  @JsonKey(name: 'created_at')
  final String createdAt; // ✅ API usa String para datas
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const CatModel({
    required this.id,
    required this.name,
    this.birthDate,
    this.weight,
    this.photoUrl,
    required this.householdId,
    required this.createdAt,
    required this.updatedAt,
  });

  // ... resto da implementação
}
```

#### **13.3.5 Atualizar AuthApiService**

```dart
// lib/services/api/auth_api_service.dart
@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  // ✅ CORRIGIR: Usar endpoints corretos
  @POST('/auth/mobile')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/mobile/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @PUT('/auth/mobile')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  // ... outros métodos
}

// ✅ ATUALIZAR: Request models
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class RegisterRequest {
  final String email;
  final String password;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'household_name')
  final String? householdName;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.householdName,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'full_name': fullName,
    if (householdName != null) 'household_name': householdName,
  };
}

class RefreshTokenRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'refresh_token': refreshToken,
  };
}
```

#### **13.3.6 Atualizar AuthInterceptor**

```dart
// lib/core/network/auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ✅ CORRIGIR: Usar access_token em vez de accessToken
    final token = TokenManager.getAccessToken();
    if (token != null && !options.path.contains('auth/mobile')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // ✅ IMPLEMENTAR: Refresh automático de token
      final refreshToken = TokenManager.getRefreshToken();
      if (refreshToken != null) {
        try {
          final newToken = await _refreshAccessToken(refreshToken);
          if (newToken != null) {
            // Retry da requisição original
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            final response = await Dio().fetch(options);
            handler.resolve(response);
            return;
          }
        } catch (e) {
          // Refresh falhou, redirecionar para login
          TokenManager.clearTokens();
        }
      }
    }
    handler.next(err);
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    // Implementar refresh do token
    // ... código de refresh
  }
}
```

### 13.4 Checklist de Implementação

#### **✅ Configuração Base** ✅ CONCLUÍDO
- [x] Atualizar `ApiConstants.baseUrl` para `https://mealtime.app.br/api`
- [x] Corrigir endpoints de autenticação para `/auth/mobile`
- [x] Adicionar método PUT para refresh token

#### **✅ Modelos de Dados** ✅ CONCLUÍDO
- [x] Criar novo `AuthResponse` com estrutura `{success, data, error}`
- [x] Atualizar `UserModel` com campos `auth_id`, `household_id`, `household`
- [x] Atualizar `CatModel` com campos `weight`, `photo_url`, `household_id`
- [x] Criar `HouseholdModel` e `HouseholdMemberModel`
- [x] Atualizar tipos de dados (int vs String para IDs)

#### **✅ Serviços de API** ✅ CONCLUÍDO
- [x] Atualizar `AuthApiService` com novos endpoints
- [x] Modificar request models para usar `full_name`, `household_name`
- [x] Implementar tratamento de resposta `{success, data, error}`
- [x] Adicionar suporte a `requires_email_confirmation`

#### **✅ Interceptors e Autenticação** ✅ CONCLUÍDO
- [x] Atualizar `AuthInterceptor` para usar `access_token`
- [x] Implementar refresh automático de token
- [x] Adicionar tratamento de erro 401 com retry
- [x] Atualizar `TokenManager` para novos campos

#### **✅ Testes e Validação** 🔧 EM ANDAMENTO
- [x] Testar login com credenciais válidas
- [x] Testar registro de novo usuário
- [x] Testar refresh automático de token
- [x] Testar tratamento de erros 401
- [ ] Validar compatibilidade com API real

### 13.5 Comandos de Execução

```bash
# 1. Atualizar dependências
flutter pub get

# 2. Regenerar código gerado
flutter packages pub run build_runner build --delete-conflicting-outputs

# 3. Executar testes
flutter test

# 4. Verificar análise de código
flutter analyze

# 5. Testar compilação
flutter build apk --debug
```

### 13.6 Validação de Compatibilidade

#### **Testes de Integração**
- [ ] **Login**: Verificar se retorna `{success: true, user: {...}, access_token: "..."}`
- [ ] **Registro**: Verificar se cria usuário e household
- [ ] **Refresh Token**: Verificar se renova token automaticamente
- [ ] **Lista de Gatos**: Verificar se retorna `{success: true, data: [...], count: N}`
- [ ] **Criar Gato**: Verificar se retorna `{success: true, data: {...}}`

#### **Verificação de Campos**
- [ ] **User**: `id`, `auth_id`, `full_name`, `email`, `household_id`, `household`
- [ ] **Cat**: `id`, `name`, `birth_date`, `weight`, `photo_url`, `household_id`
- [ ] **Household**: `id`, `name`, `members[]`
- [ ] **Member**: `id`, `name`, `email`, `role`

### 13.7 Benefícios da Compatibilidade

- ✅ **Integração Total**: 100% compatível com API Mobile documentada
- ✅ **Estrutura Padrão**: Usa formato `{success, data, error}` consistente
- ✅ **Refresh Automático**: Tokens renovados automaticamente
- ✅ **Tratamento de Erros**: Respostas de erro padronizadas
- ✅ **Múltiplas Residências**: Suporte completo a households
- ✅ **Segurança**: Tokens gerenciados de forma segura
- ✅ **Manutenibilidade**: Código alinhado com documentação oficial

---

*Última atualização: 2024*  
*Versão do plano: 1.6*  
*Status: Fases 1-6 Concluídas - Fase 13 95% Concluída para Compatibilidade Total*
