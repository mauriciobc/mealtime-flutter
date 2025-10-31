# 📱 Processo de Login e Retorno do Backend - Mealtime

## 🎯 Visão Geral

Este documento detalha como funciona o processo de autenticação (login) no aplicativo Mealtime, explicando passo a passo o que acontece desde quando o usuário clica em "Entrar" até receber os dados de volta do servidor.

---

## 🔐 Endpoint de Login

### URL e Método
- **Endpoint**: `POST https://mealtime.app.br/api/auth/mobile`
- **Content-Type**: `application/json`
- **Arquivo Backend**: `/app/api/auth/mobile/route.ts`

---

## 📤 Requisição (O que o app envia)

### Estrutura JSON
```json
{
  "email": "usuario@exemplo.com",
  "password": "senhaSecreta123"
}
```

### Implementação no Flutter
O app Flutter usa a classe `LoginRequest` para enviar os dados:

```dart
// Arquivo: auth_api_service.dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email, 
    'password': password
  };
}
```

---

## 🔄 Processamento no Backend (TypeScript/Next.js)

### Passo 1: Validação Inicial
O backend primeiro valida se email e senha foram enviados:

```typescript
const { email, password } = await request.json();

if (!email || !password) {
  return NextResponse.json(
    { 
      success: false, 
      error: 'Email e senha são obrigatórios' 
    },
    { status: 400 }
  );
}
```

### Passo 2: Autenticação no Supabase
O backend usa o Supabase para verificar as credenciais:

```typescript
const supabase = await createClient();

const { data: authData, error: authError } = 
  await supabase.auth.signInWithPassword({
    email,
    password,
  });
```

**O que acontece aqui:**
- O Supabase verifica se o email existe
- Compara a senha usando bcrypt (hash seguro)
- Se correto, gera tokens JWT (access_token e refresh_token)
- Retorna os dados do usuário autenticado

### Passo 3: Buscar Dados Completos no Prisma
Após autenticar no Supabase, o backend busca informações adicionais no banco de dados:

```typescript
const prismaUser = await prisma.user.findUnique({
  where: { auth_id: authData.user.id },
  include: {
    household: {
      include: {
        household_members: {
          include: {
            user: {
              select: {
                id: true,
                full_name: true,
                email: true,
              }
            }
          }
        }
      }
    }
  }
});
```

**O que é buscado:**
- Dados completos do perfil do usuário
- Informações da casa (household) do usuário
- Lista de todos os membros da casa
- Papéis (roles) de cada membro (admin, member, etc.)

### Passo 4: Preparar Resposta
O backend monta um objeto completo com todos os dados:

```typescript
const userData = {
  id: prismaUser.id,
  auth_id: prismaUser.auth_id,
  full_name: prismaUser.full_name,
  email: prismaUser.email,
  household_id: prismaUser.householdId,
  household: prismaUser.household ? {
    id: prismaUser.household.id,
    name: prismaUser.household.name,
    members: prismaUser.household.household_members
      .filter(member => member.user !== null)
      .map(member => ({
        id: member.user!.id,
        name: member.user!.full_name,
        email: member.user!.email,
        role: member.role
      }))
  } : null
};
```

---

## 📥 Resposta do Backend (O que o app recebe)

### Resposta de Sucesso (Status 200)

```json
{
  "success": true,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "auth_id": "550e8400-e29b-41d4-a716-446655440000",
    "full_name": "João Silva",
    "email": "joao@exemplo.com",
    "household_id": "660e8400-e29b-41d4-a716-446655440001",
    "household": {
      "id": "660e8400-e29b-41d4-a716-446655440001",
      "name": "Casa da Família Silva",
      "members": [
        {
          "id": "550e8400-e29b-41d4-a716-446655440000",
          "name": "João Silva",
          "email": "joao@exemplo.com",
          "role": "admin"
        },
        {
          "id": "770e8400-e29b-41d4-a716-446655440002",
          "name": "Maria Silva",
          "email": "maria@exemplo.com",
          "role": "member"
        }
      ]
    }
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

### Campos da Resposta

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `success` | boolean | Indica se a operação foi bem-sucedida |
| `user` | object | Dados completos do usuário |
| `user.id` | string (UUID) | ID único do usuário no banco |
| `user.auth_id` | string (UUID) | ID de autenticação do Supabase |
| `user.full_name` | string | Nome completo do usuário |
| `user.email` | string | Email do usuário |
| `user.household_id` | string (UUID) | ID da casa do usuário |
| `user.household` | object/null | Dados da casa (se existir) |
| `user.household.id` | string (UUID) | ID da casa |
| `user.household.name` | string | Nome da casa |
| `user.household.members` | array | Lista de membros da casa |
| `access_token` | string | Token JWT para autenticação nas requisições |
| `refresh_token` | string | Token para renovar o access_token quando expirar |
| `expires_in` | number | Tempo de expiração do token em segundos (padrão: 3600 = 1 hora) |
| `token_type` | string | Tipo do token (sempre "Bearer") |

---

## ❌ Respostas de Erro

### 1. Credenciais Inválidas (Status 401)
```json
{
  "success": false,
  "error": "Credenciais inválidas"
}
```
**Quando ocorre:** Email não existe ou senha incorreta

### 2. Campos Obrigatórios Faltando (Status 400)
```json
{
  "success": false,
  "error": "Email e senha são obrigatórios"
}
```
**Quando ocorre:** Email ou senha não foram enviados

### 3. Usuário Não Encontrado no Sistema (Status 404)
```json
{
  "success": false,
  "error": "Usuário não encontrado no sistema"
}
```
**Quando ocorre:** Autenticação no Supabase OK, mas usuário não existe no banco Prisma

### 4. Erro Interno do Servidor (Status 500)
```json
{
  "success": false,
  "error": "Erro interno do servidor"
}
```
**Quando ocorre:** Qualquer erro inesperado no backend

---

## 📲 Processamento no Flutter

### Passo 1: Chamada da API
O Flutter usa Retrofit + Dio para fazer a requisição:

```dart
// Arquivo: auth_api_service.dart
@POST(ApiConstants.login)
Future<ApiResponse<AuthResponse>> login(@Body() LoginRequest request);
```

### Passo 2: Validação da Resposta
O datasource verifica se a resposta é válida:

```dart
// Arquivo: auth_remote_datasource.dart
Future<AuthResponse> login(String email, String password) async {
  final apiResponse = await apiService.login(
    LoginRequest(email: email, password: password),
  );

  // Verificar se a resposta contém dados
  if (apiResponse.data == null) {
    throw ServerException('Resposta da API está vazia');
  }

  final authResponse = apiResponse.data!;
  
  // Verificar se foi bem-sucedido (tem access_token)
  if (!authResponse.isSuccess) {
    throw ServerException(
      authResponse.error ?? 'Erro desconhecido no login',
    );
  }

  // Validação adicional
  if (authResponse.accessToken == null) {
    throw ServerException('Token de acesso não foi retornado');
  }

  return authResponse;
}
```

### Passo 3: Conversão para Modelo
A resposta JSON é automaticamente convertida para objetos Dart:

```dart
// Arquivo: auth_api_service.dart
@JsonSerializable()
class AuthResponse {
  final bool? success;
  
  @JsonKey(name: 'access_token')
  final String? accessToken;
  
  @JsonKey(name: 'token_type')
  final String? tokenType;
  
  @JsonKey(name: 'expires_in')
  final int? expiresIn;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;
  
  final UserModel? user;
  final String? error;
  
  // Helper para verificar sucesso
  bool get isSuccess => accessToken != null && accessToken!.isNotEmpty;
  bool get hasError => error != null;
}
```

### Passo 4: Armazenamento Local
O repository salva os tokens e dados do usuário localmente:

```dart
// Arquivo: auth_repository_impl.dart
Future<Either<Failure, User>> login(String email, String password) async {
  final authResponse = await remoteDataSource.login(email, password);

  // Salvar tokens localmente
  await localDataSource.saveTokens(
    authResponse.accessToken!,
    authResponse.refreshToken ?? '',
  );

  // Salvar usuário localmente
  await localDataSource.saveUser(authResponse.user!);

  return Right(authResponse.user!.toEntity());
}
```

**O que é salvo:**
- `access_token` → usado para autenticar todas as requisições
- `refresh_token` → usado para renovar o token quando expirar
- Dados do usuário → acessados offline

---

## 🔒 Uso do Token nas Requisições

Após o login, todas as requisições devem incluir o token no header:

```dart
// Arquivo: auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await localDataSource.getAccessToken();
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }
}
```

**Exemplo de header:**
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 🔄 Renovação de Token (Refresh Token)

### Quando Renovar
O token expira após 1 hora (3600 segundos). Quando isso acontece:

1. O backend retorna erro 401 (Unauthorized)
2. O interceptor detecta o erro 401
3. Automaticamente chama o endpoint de refresh
4. Recebe um novo access_token
5. Repete a requisição original com o novo token

### Endpoint de Refresh
- **URL**: `PUT https://mealtime.app.br/api/auth/mobile`
- **Body**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Resposta
```json
{
  "success": true,
  "access_token": "novo_token_aqui",
  "refresh_token": "novo_refresh_token_aqui",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

---

## 📊 Fluxo Completo Simplificado

```
1. Usuário digita email/senha no app Flutter
        ↓
2. App envia POST /api/auth/mobile
        ↓
3. Backend valida no Supabase Auth
        ↓
4. Backend busca dados no Prisma
        ↓
5. Backend retorna JSON completo
        ↓
6. App salva tokens e dados localmente
        ↓
7. App navega para tela principal
        ↓
8. Usuário autenticado! 🎉
```

---

## 🛠️ Tecnologias Utilizadas

### Backend
- **Next.js 14** - Framework React/Node.js
- **TypeScript** - Linguagem com tipagem
- **Supabase Auth** - Autenticação e geração de tokens JWT
- **Prisma** - ORM para banco de dados PostgreSQL
- **bcrypt** - Hash de senhas (via Supabase)

### Frontend (Flutter)
- **Dio** - Cliente HTTP
- **Retrofit** - Geração automática de API clients
- **json_serializable** - Conversão JSON ↔ Dart
- **Riverpod** - Gerenciamento de estado
- **Dartz** - Programação funcional (Either<Failure, Success>)

---

## 🔍 Dicas de Debugging

### Ver Tokens no Flutter
```dart
final token = await localDataSource.getAccessToken();
print('Token: $token');
```

### Decodificar JWT (entender o que está dentro)
Acesse: https://jwt.io e cole o token

Você verá algo como:
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "email": "joao@exemplo.com",
  "iat": 1735848000,
  "exp": 1735851600
}
```

### Logs do Backend
O backend loga todas as operações importantes:
```typescript
logger.info('[Mobile Auth] Login successful', { 
  userId: prismaUser.id,
  email: prismaUser.email 
});
```

---

## ✅ Checklist de Implementação

- [x] Endpoint POST /api/auth/mobile implementado
- [x] Integração com Supabase Auth
- [x] Busca de dados no Prisma
- [x] Retorno de dados completos do usuário
- [x] Retorno de dados da household
- [x] Geração de access_token e refresh_token
- [x] Tratamento de erros (401, 404, 500)
- [x] Logging de operações
- [x] Cliente Flutter com Retrofit
- [x] Armazenamento local de tokens
- [x] Interceptor para adicionar token nas requisições
- [x] Sistema de refresh token automático

---

## 📚 Referências

- [Documentação Supabase Auth](https://supabase.com/docs/guides/auth)
- [Next.js API Routes](https://nextjs.org/docs/api-routes/introduction)
- [JWT (JSON Web Tokens)](https://jwt.io/introduction)
- [Retrofit Flutter](https://pub.dev/packages/retrofit)
- [Dio Flutter](https://pub.dev/packages/dio)

---

**Última atualização:** Janeiro 2025  
**Versão do Backend:** mealtime v1.0  
**Versão do Flutter App:** mealtime_app v1.0






