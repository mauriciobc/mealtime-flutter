# 🔐 Relatório de Compatibilidade: Login API

**Data:** 11 de Outubro de 2025  
**Status:** ⚠️ **PARCIALMENTE COMPATÍVEL** - Requer Ajustes

---

## 📊 Resumo Executivo

O código Flutter está **parcialmente compatível** com a API de Login. A estrutura básica funciona, mas há **inconsistências** nos campos retornados e no tratamento de erros.

### Status de Compatibilidade

| Aspecto | Status | Gravidade |
|---------|--------|-----------|
| **Endpoint URL** | ✅ Correto | 🟢 OK |
| **Campos Enviados** | ✅ Correto | 🟢 OK |
| **Método HTTP** | ✅ Correto | 🟢 OK |
| **Resposta de Sucesso** | ⚠️ Parcial | 🟡 Média |
| **Resposta de Erro** | ✅ Correto | 🟢 OK |
| **Modelo UserModel** | ❌ Incompatível | 🔴 Alta |

---

## 🔍 Análise Detalhada

### 1. ✅ Endpoint (OK)

**Código Flutter:**
```dart
static const String login = '/auth/mobile';

@POST(ApiConstants.login)
Future<ApiResponse<AuthResponse>> login(@Body() LoginRequest request);
```

**API Real:**
```
POST /auth/mobile
```

**Status:** ✅ **CORRETO** - Endpoint está certo

---

### 2. ✅ Request (OK)

**Código Flutter Envia:**
```dart
class LoginRequest {
  final String email;
  final String password;
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password
  };
}
```

**API Espera:**
```json
{
  "email": "user@example.com",
  "password": "senha123"
}
```

**Status:** ✅ **CORRETO** - Campos estão corretos

---

### 3. ⚠️ Response de Sucesso (PARCIAL)

**Código Flutter Espera:**
```dart
class AuthResponse {
  final bool success;
  final UserModel? user;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final String? tokenType;
  final String? error;
  final bool? requiresEmailConfirmation;
}
```

**API Retorna (via Supabase Auth):**
```json
{
  "access_token": "eyJhbGc...",
  "token_type": "bearer",
  "expires_in": 3600,
  "expires_at": 1760195881,
  "refresh_token": "pb5saderevva",
  "user": {
    "id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
    "aud": "authenticated",
    "role": "authenticated",
    "email": "testapi@email.com",
    "email_confirmed_at": "2025-10-11T14:16:46.027338Z",
    "phone": "",
    "confirmed_at": "2025-10-11T14:16:46.027338Z",
    "last_sign_in_at": "2025-10-11T14:18:01.079522306Z",
    "app_metadata": {
      "provider": "email",
      "providers": ["email"]
    },
    "user_metadata": {
      "email_verified": true
    },
    "identities": [...],
    "created_at": "2025-10-11T14:16:46.005256Z",
    "updated_at": "2025-10-11T14:18:01.160645Z",
    "is_anonymous": false
  },
  "weak_password": null
}
```

#### ❌ Problemas Identificados

| Campo Flutter | Campo API | Status |
|---------------|-----------|--------|
| `success` | ❌ Não existe | 🔴 Campo ausente |
| `accessToken` | ✅ `access_token` | 🟡 Nome snake_case |
| `refreshToken` | ✅ `refresh_token` | 🟡 Nome snake_case |
| `expiresIn` | ✅ `expires_in` | 🟡 Nome snake_case |
| `tokenType` | ✅ `token_type` | 🟡 Nome snake_case |
| `user` | ✅ `user` | ⚠️ Estrutura diferente |
| `error` | ❌ Só em erros | 🟢 OK |
| `requiresEmailConfirmation` | ❌ Não existe | 🟡 Não usado |

---

### 4. ❌ UserModel Incompatível (CRÍTICO)

#### Código Flutter Espera:

```dart
class UserModel {
  final String id;
  final String authId;           // ❌ API não retorna
  final String fullName;         // ❌ API usa 'email'
  final String email;            // ✅ OK
  final String? householdId;     // ❌ API não retorna
  final HouseholdModel? household; // ❌ API não retorna
  final DateTime createdAt;      // ✅ OK (created_at)
  final DateTime updatedAt;      // ✅ OK (updated_at)
  final bool isEmailVerified;    // ⚠️ API tem email_confirmed_at
  final String? currentHomeId;   // ❌ API não retorna
}
```

#### API Retorna (Supabase User):

```json
{
  "id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
  "aud": "authenticated",
  "role": "authenticated",
  "email": "testapi@email.com",
  "email_confirmed_at": "2025-10-11T14:16:46.027338Z",
  "phone": "",
  "confirmed_at": "2025-10-11T14:16:46.027338Z",
  "last_sign_in_at": "2025-10-11T14:18:01.079522306Z",
  "app_metadata": {
    "provider": "email",
    "providers": ["email"]
  },
  "user_metadata": {
    "email_verified": true
  },
  "identities": [...],
  "created_at": "2025-10-11T14:16:46.005256Z",
  "updated_at": "2025-10-11T14:18:01.160645Z",
  "is_anonymous": false
}
```

#### ❌ Incompatibilidades Críticas

| Campo Flutter | Disponível na API? | Problema |
|---------------|-------------------|----------|
| `authId` | ❌ Não | Campo não existe na resposta |
| `fullName` | ❌ Não | API não retorna full_name no login |
| `householdId` | ❌ Não | Campo não vem no login |
| `household` | ❌ Não | Objeto não vem no login |
| `currentHomeId` | ❌ Não | Campo não vem no login |
| `isEmailVerified` | ⚠️ Parcial | API tem `email_confirmed_at` (timestamp) |

**Campos que a API tem mas Flutter não usa:**
- `aud` - Audience
- `role` - Role do usuário
- `phone` - Telefone
- `confirmed_at` - Timestamp de confirmação
- `last_sign_in_at` - Último login
- `app_metadata` - Metadados da aplicação
- `user_metadata` - Metadados do usuário
- `identities` - Identidades de autenticação
- `is_anonymous` - Se é anônimo

---

### 5. ✅ Response de Erro (OK)

**Código Flutter:**
```dart
class AuthResponse {
  final bool success;
  final String? error;
}
```

**API Retorna (Erro 401):**
```json
{
  "success": false,
  "error": "Credenciais inválidas"
}
```

**API Retorna (Erro 400):**
```json
{
  "success": false,
  "error": "Email e senha são obrigatórios"
}
```

**Status:** ✅ **CORRETO** - Tratamento de erros está bom

---

## ❌ Problemas Identificados

### Problema 1: Campo `success` não existe em resposta de sucesso

**Flutter Espera:**
```dart
AuthResponse(success: true, ...)
```

**API Retorna:**
```json
{
  "access_token": "...",
  // NÃO tem campo "success"
}
```

**Impacto:** 🔴 **CRÍTICO**
- Deserialização vai falhar ou campo ficará `false`
- Lógica que depende de `success` não funcionará

**Solução:**
- Considerar resposta como sucesso se `status code == 200`
- OU ajustar backend para adicionar campo `success: true`

---

### Problema 2: Nomenclatura snake_case vs camelCase

**Flutter usa camelCase:**
```dart
final String? accessToken;
final String? refreshToken;
final int? expiresIn;
final String? tokenType;
```

**API usa snake_case:**
```json
{
  "access_token": "...",
  "refresh_token": "...",
  "expires_in": 3600,
  "token_type": "bearer"
}
```

**Impacto:** 🟡 **MÉDIO**
- Deserialização falhará sem `@JsonKey`

**Solução:** Adicionar annotations:
```dart
@JsonKey(name: 'access_token')
final String? accessToken;

@JsonKey(name: 'refresh_token')
final String? refreshToken;

@JsonKey(name: 'expires_in')
final int? expiresIn;

@JsonKey(name: 'token_type')
final String? tokenType;
```

---

### Problema 3: UserModel incompatível com Supabase User

**UserModel espera campos que não existem:**
- `authId` - Não vem no login
- `fullName` - Não vem no login (só `email`)
- `householdId` - Não vem no login
- `household` - Não vem no login
- `currentHomeId` - Não vem no login

**Impacto:** 🔴 **CRÍTICO**
- Deserialização falhará
- Campos obrigatórios ficarão `null`
- App pode crashar

**Solução:** Duas opções:

#### Opção A: Criar SupabaseUserModel separado
```dart
@JsonSerializable()
class SupabaseUserModel {
  final String id;
  final String aud;
  final String role;
  final String email;
  @JsonKey(name: 'email_confirmed_at')
  final String? emailConfirmedAt;
  final String phone;
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  @JsonKey(name: 'last_sign_in_at')
  final String? lastSignInAt;
  @JsonKey(name: 'app_metadata')
  final Map<String, dynamic>? appMetadata;
  @JsonKey(name: 'user_metadata')
  final Map<String, dynamic>? userMetadata;
  final List<dynamic>? identities;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;
}
```

#### Opção B: Buscar UserModel completo após login
```dart
// 1. Login com Supabase
final authResponse = await login(credentials);

// 2. Buscar dados completos do usuário
final userModel = await getUserProfile();
```

---

### Problema 4: Campo `expires_at` não mapeado

**API Retorna:**
```json
{
  "expires_at": 1760195881  // Timestamp UNIX
}
```

**Flutter:**
```dart
// ❌ Campo não existe no AuthResponse
```

**Impacto:** 🟡 **MÉDIO**
- Não consegue verificar expiração do token de forma precisa
- Precisa calcular manualmente com `expires_in`

**Solução:** Adicionar campo:
```dart
@JsonKey(name: 'expires_at')
final int? expiresAt;
```

---

## 🔧 Correções Necessárias

### Prioridade CRÍTICA 🔴

#### 1. Atualizar AuthResponse

**Arquivo:** `lib/services/api/auth_api_service.dart`

```dart
@JsonSerializable()
class AuthResponse {
  // Campo success não vem em sucesso, apenas em erro
  final bool? success;
  
  // Campos do Supabase Auth (snake_case)
  @JsonKey(name: 'access_token')
  final String? accessToken;
  
  @JsonKey(name: 'token_type')
  final String? tokenType;
  
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  
  @JsonKey(name: 'expires_at')
  final int? expiresAt;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  
  // User virá como Supabase User
  @JsonKey(name: 'user')
  final SupabaseUserModel? user;
  
  // Apenas em respostas de erro
  final String? error;
  
  @JsonKey(name: 'requires_email_confirmation')
  final bool? requiresEmailConfirmation;
  
  @JsonKey(name: 'weak_password')
  final dynamic weakPassword;

  AuthResponse({
    this.success,
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.expiresAt,
    this.refreshToken,
    this.user,
    this.error,
    this.requiresEmailConfirmation,
    this.weakPassword,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
  
  /// Helper para verificar se login foi bem-sucedido
  bool get isSuccess => accessToken != null && accessToken!.isNotEmpty;
}
```

---

#### 2. Criar SupabaseUserModel

**Arquivo:** `lib/features/auth/data/models/supabase_user_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'supabase_user_model.g.dart';

/// Modelo de usuário retornado pelo Supabase Auth
/// Este é o formato que vem no login
@JsonSerializable(explicitToJson: true)
class SupabaseUserModel {
  /// ID do usuário no Supabase Auth
  final String id;
  
  /// Audience (sempre "authenticated")
  final String aud;
  
  /// Role do usuário (geralmente "authenticated")
  final String role;
  
  /// Email do usuário
  final String email;
  
  /// Timestamp de confirmação do email
  @JsonKey(name: 'email_confirmed_at')
  final String? emailConfirmedAt;
  
  /// Telefone (geralmente vazio)
  final String phone;
  
  /// Timestamp de confirmação geral
  @JsonKey(name: 'confirmed_at')
  final String? confirmedAt;
  
  /// Timestamp do último login
  @JsonKey(name: 'last_sign_in_at')
  final String? lastSignInAt;
  
  /// Metadados da aplicação
  @JsonKey(name: 'app_metadata')
  final Map<String, dynamic>? appMetadata;
  
  /// Metadados do usuário
  @JsonKey(name: 'user_metadata')
  final Map<String, dynamic>? userMetadata;
  
  /// Identidades de autenticação
  final List<dynamic>? identities;
  
  /// Data de criação
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  /// Data de atualização
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  /// Se é usuário anônimo
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;

  const SupabaseUserModel({
    required this.id,
    required this.aud,
    required this.role,
    required this.email,
    this.emailConfirmedAt,
    required this.phone,
    this.confirmedAt,
    this.lastSignInAt,
    this.appMetadata,
    this.userMetadata,
    this.identities,
    required this.createdAt,
    required this.updatedAt,
    required this.isAnonymous,
  });

  factory SupabaseUserModel.fromJson(Map<String, dynamic> json) =>
      _$SupabaseUserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$SupabaseUserModelToJson(this);
  
  /// Helper para verificar se email está verificado
  bool get isEmailVerified => emailConfirmedAt != null;
}
```

---

#### 3. Ajustar Fluxo de Login

**Estratégia Recomendada:**

```dart
class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password) async {
    // 1. Fazer login no Supabase Auth
    final authResponse = await authApiService.login(
      LoginRequest(email: email, password: password)
    );
    
    if (!authResponse.isSuccess) {
      throw ServerException(authResponse.error ?? 'Erro no login');
    }
    
    // 2. Salvar tokens
    await tokenManager.saveToken(authResponse.accessToken!);
    await tokenManager.saveRefreshToken(authResponse.refreshToken!);
    
    // 3. Buscar dados completos do usuário do backend
    // (não do Supabase, do seu backend que tem household, etc.)
    final userProfile = await authApiService.getProfile();
    
    return userProfile.data!;
  }
}
```

**Por quê?**
- Supabase Auth retorna dados mínimos
- Seu backend tem dados extras (household, fullName, etc.)
- Separar responsabilidades: Supabase = auth, Backend = dados

---

### Prioridade MÉDIA 🟡

#### 4. Adicionar Tratamento de Erro Consistente

```dart
class AuthResponse {
  // ... campos ...
  
  /// Verifica se houve erro
  bool get hasError => error != null;
  
  /// Verifica se login foi bem-sucedido
  bool get isSuccess => !hasError && accessToken != null;
  
  /// Verifica se precisa confirmar email
  bool get needsEmailConfirmation => 
    requiresEmailConfirmation == true || 
    error?.contains('confirm') == true;
}
```

---

#### 5. Adicionar Logs de Debug

```dart
Future<AuthResponse> login(LoginRequest request) async {
  try {
    final response = await authApiService.login(request);
    
    // Log de debug
    print('Login Response:');
    print('- Has access_token: ${response.accessToken != null}');
    print('- Has user: ${response.user != null}');
    print('- Has error: ${response.error != null}');
    
    return response;
  } catch (e) {
    print('Login Error: $e');
    rethrow;
  }
}
```

---

## 📊 Tabela de Compatibilidade

### Request

| Campo | Flutter Envia | API Aceita | Status |
|-------|---------------|------------|--------|
| `email` | ✅ Sim | ✅ Sim | ✅ OK |
| `password` | ✅ Sim | ✅ Sim | ✅ OK |

### Response de Sucesso

| Campo | API Retorna | Flutter Espera | Status |
|-------|-------------|----------------|--------|
| `access_token` | ✅ Sim | ⚠️ `accessToken` | 🟡 Precisa @JsonKey |
| `token_type` | ✅ Sim | ⚠️ `tokenType` | 🟡 Precisa @JsonKey |
| `expires_in` | ✅ Sim | ⚠️ `expiresIn` | 🟡 Precisa @JsonKey |
| `expires_at` | ✅ Sim | ❌ Não espera | 🟡 Adicionar campo |
| `refresh_token` | ✅ Sim | ⚠️ `refreshToken` | 🟡 Precisa @JsonKey |
| `user` | ✅ Sim | ❌ Estrutura diferente | 🔴 Incompatível |
| `success` | ❌ Não | ✅ Espera | 🔴 Campo não existe |
| `weak_password` | ✅ Sim | ❌ Não espera | 🟢 Ignorar |

### Response de Erro

| Campo | API Retorna | Flutter Espera | Status |
|-------|-------------|----------------|--------|
| `success` | ✅ Sim (false) | ✅ Sim | ✅ OK |
| `error` | ✅ Sim | ✅ Sim | ✅ OK |

---

## 🎯 Recomendações

### Arquitetura Sugerida

```
┌─────────────────────────────────────────┐
│  1. Login no Supabase Auth              │
│     POST /auth/mobile                   │
│     Retorna: access_token, user básico  │
└────────────┬────────────────────────────┘
             │
             v
┌─────────────────────────────────────────┐
│  2. Salvar tokens                       │
│     TokenManager.save()                 │
└────────────┬────────────────────────────┘
             │
             v
┌─────────────────────────────────────────┐
│  3. Buscar perfil completo              │
│     GET /profile                        │
│     Retorna: UserModel com household    │
└─────────────────────────────────────────┘
```

---

## ✅ Conclusão

**Status Atual:** ⚠️ **PARCIALMENTE COMPATÍVEL**

**Problemas Críticos:**
1. Campo `success` não existe em resposta de sucesso
2. Nomenclatura snake_case vs camelCase sem @JsonKey
3. UserModel incompatível com Supabase User
4. Falta campo `expires_at`

**Correções Obrigatórias:**
1. Adicionar `@JsonKey` para todos os campos snake_case
2. Criar `SupabaseUserModel` para login
3. Buscar `UserModel` completo após login
4. Verificar sucesso por presença de `accessToken`, não campo `success`

**Tempo Estimado de Correção:** 1-2 horas

**Prioridade:** 🟡 **MÉDIA** - Login pode funcionar parcialmente, mas requer ajustes

---

*Relatório gerado via Cursor AI*  
*Data: 11/10/2025*

