# 🏠 Relatório de Compatibilidade: Household API

**Data:** 11 de Outubro de 2025  
**Status:** ⚠️ **INCOMPATÍVEL** - Requer Correções

---

## 📊 Resumo Executivo

O código Flutter **NÃO está totalmente compatível** com a API de Households. Foram identificadas **7 incompatibilidades** que precisam ser corrigidas.

### Status de Compatibilidade

| Aspecto | Status | Gravidade |
|---------|--------|-----------|
| **Endpoint URL** | ❌ Incorreto | 🔴 Alta |
| **Modelo de Dados** | ❌ Incompatível | 🔴 Alta |
| **Campos Enviados** | ⚠️ Parcial | 🟡 Média |
| **Campos Recebidos** | ❌ Incompatível | 🔴 Alta |
| **Método HTTP** | ✅ Correto | 🟢 OK |
| **Headers** | ⚠️ Parcial | 🟡 Média |

---

## 🔍 Análise Detalhada

### 1. ❌ Endpoint Incorreto (CRÍTICO)

**Código Flutter:**
```dart
@POST('/homes')  // ❌ ERRADO
Future<ApiResponse<HomeModel>> createHome({...});
```

**API Real:**
```
POST /households  // ✅ CORRETO
```

**Impacto:** 🔴 **ALTO** - A requisição retorna 404  
**Correção Necessária:** Alterar todos os endpoints de `/homes` para `/households`

---

### 2. ❌ Modelo de Dados Incompatível (CRÍTICO)

#### Campos no Modelo Flutter (HomeModel)

```dart
class HomeModel {
  final String id;
  final String name;
  final String? address;         // ❌ NÃO EXISTE NA API
  final String? description;     // ⚠️ ACEITO MAS RETORNA NULL
  final String userId;           // ❌ API USA 'owner_id'
  final DateTime createdAt;      // ✅ OK (API: created_at)
  final DateTime updatedAt;      // ✅ OK (API: updated_at)
  final bool isActive;           // ❌ NÃO RETORNADO PELA API
}
```

#### Resposta Real da API (POST /households)

```json
{
  "id": "03a37256-58cb-414b-8405-890f4eea970f",
  "name": "Casa Completa",
  "created_at": "2025-10-11T14:26:31.501Z",
  "updated_at": "2025-10-11T14:26:31.501Z",
  "owner_id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
  "owner": {
    "id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
    "name": "",
    "email": "testapi@email.com"
  },
  "members": [
    {
      "id": "6fedfb41-fe43-4054-8fd9-3ae9cf6ae594",
      "userId": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
      "name": "",
      "email": "testapi@email.com",
      "role": "ADMIN",
      "joinedAt": "2025-10-11T14:26:31.501Z"
    }
  ]
}
```

#### Resposta da API (GET /households)

```json
{
  "id": "ac65ae0d-e072-4a46-aa56-6d5114409e24",
  "created_at": "2025-10-11T14:26:11.465Z",
  "updated_at": "2025-10-11T14:26:11.465Z",
  "name": "Casa Teste API",
  "description": null,
  "owner_id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
  "inviteCode": null,
  "household_members": [
    {
      "id": "f196ec95-4f81-4289-8b21-47712bf55b21",
      "household_id": "ac65ae0d-e072-4a46-aa56-6d5114409e24",
      "user_id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
      "role": "ADMIN",
      "created_at": "2025-10-11T14:26:11.465Z",
      "user": {
        "id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
        "full_name": "",
        "email": "testapi@email.com"
      }
    }
  ],
  "owner": {
    "id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
    "name": "",
    "email": "testapi@email.com"
  },
  "members": [...]
}
```

---

## ❌ Problemas Identificados

### Problema 1: Campo `address` não existe na API

**Código Flutter Envia:**
```dart
@Field('address') String? address
```

**API:**
- ❌ **NÃO aceita** este campo
- ❌ **NÃO retorna** este campo
- ⚠️ Campo é **completamente ignorado** pela API

**Impacto:** Campo `address` nunca será salvo ou recuperado

---

### Problema 2: Campo `description` retorna NULL

**Código Flutter Envia:**
```dart
@Field('description') String? description
```

**API:**
- ⚠️ **Aceita** o campo no POST
- ❌ **Retorna sempre NULL** na resposta
- ⚠️ Parece não estar salvando no banco de dados

**Impacto:** Campo `description` é perdido após criação

---

### Problema 3: Nomenclatura `userId` vs `owner_id`

**Código Flutter Espera:**
```dart
@JsonKey(name: 'user_id')
final String userId;
```

**API Retorna:**
```json
{
  "owner_id": "915a9f01-d515-4b60-bf24-20b7c2f54c63"
}
```

**Impacto:** 🔴 **CRÍTICO** - Deserialização falhará

---

### Problema 4: Campo `is_active` não existe na API

**Código Flutter Espera:**
```dart
@JsonKey(name: 'is_active')
final bool isActive;
```

**API:**
- ❌ **NÃO retorna** este campo
- ❌ **NÃO aceita** este campo no POST

**Impacto:** Campo sempre será `null` ou usará valor padrão

---

### Problema 5: Campos extras da API não mapeados

**API Retorna mas Flutter Ignora:**
- `owner` - Objeto com informações do dono
- `members` - Array de membros do household
- `household_members` - Array detalhado de membros (GET)
- `inviteCode` - Código de convite (GET)

**Impacto:** Informações importantes não ficam disponíveis no app

---

## 🔧 Correções Necessárias

### Prioridade CRÍTICA 🔴

#### 1. Alterar Endpoint

**Arquivo:** `lib/services/api/homes_api_service.dart`

```dart
// ❌ ANTES
@GET('/homes')
Future<ApiResponse<List<HomeModel>>> getHomes();

@POST('/homes')
Future<ApiResponse<HomeModel>> createHome({...});

// ✅ DEPOIS
@GET('/households')
Future<ApiResponse<List<HouseholdModel>>> getHouseholds();

@POST('/households')
Future<ApiResponse<HouseholdModel>> createHousehold({...});
```

#### 2. Criar Novo Modelo: HouseholdModel

**Arquivo:** `lib/features/homes/data/models/household_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'household_model.g.dart';

@JsonSerializable()
class HouseholdModel {
  final String id;
  final String name;
  final String? description;  // Aceitar mas saber que pode retornar null
  
  @JsonKey(name: 'owner_id')
  final String ownerId;  // ✅ Nome correto
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  // Campos extras da API
  final HouseholdOwner? owner;
  final List<HouseholdMember>? members;
  
  @JsonKey(name: 'household_members')
  final List<HouseholdMemberDetailed>? householdMembers;
  
  @JsonKey(name: 'inviteCode')
  final String? inviteCode;

  const HouseholdModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.owner,
    this.members,
    this.householdMembers,
    this.inviteCode,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) => 
    _$HouseholdModelFromJson(json);
    
  Map<String, dynamic> toJson() => _$HouseholdModelToJson(this);
}

@JsonSerializable()
class HouseholdOwner {
  final String id;
  final String name;
  final String email;

  const HouseholdOwner({
    required this.id,
    required this.name,
    required this.email,
  });

  factory HouseholdOwner.fromJson(Map<String, dynamic> json) => 
    _$HouseholdOwnerFromJson(json);
    
  Map<String, dynamic> toJson() => _$HouseholdOwnerToJson(this);
}

@JsonSerializable()
class HouseholdMember {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String role;
  final DateTime joinedAt;

  const HouseholdMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  factory HouseholdMember.fromJson(Map<String, dynamic> json) => 
    _$HouseholdMemberFromJson(json);
    
  Map<String, dynamic> toJson() => _$HouseholdMemberToJson(this);
}

@JsonSerializable()
class HouseholdMemberDetailed {
  final String id;
  
  @JsonKey(name: 'household_id')
  final String householdId;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  final String role;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  final HouseholdUser user;

  const HouseholdMemberDetailed({
    required this.id,
    required this.householdId,
    required this.userId,
    required this.role,
    required this.createdAt,
    required this.user,
  });

  factory HouseholdMemberDetailed.fromJson(Map<String, dynamic> json) => 
    _$HouseholdMemberDetailedFromJson(json);
    
  Map<String, dynamic> toJson() => _$HouseholdMemberDetailedToJson(this);
}

@JsonSerializable()
class HouseholdUser {
  final String id;
  
  @JsonKey(name: 'full_name')
  final String fullName;
  
  final String email;

  const HouseholdUser({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory HouseholdUser.fromJson(Map<String, dynamic> json) => 
    _$HouseholdUserFromJson(json);
    
  Map<String, dynamic> toJson() => _$HouseholdUserToJson(this);
}
```

#### 3. Remover Campo `address`

**Ação:** Remover completamente o campo `address` do código, pois a API não suporta

**Alternativas:**
1. Armazenar `address` localmente no app (não sincroniza com API)
2. Usar o campo `description` para armazenar endereço (não recomendado)
3. Solicitar ao backend para adicionar suporte a `address`

---

### Prioridade MÉDIA 🟡

#### 4. Atualizar api_constants.dart

```dart
// ❌ ANTES
static const String homes = '/homes';

// ✅ DEPOIS
static const String households = '/households';
```

#### 5. Renomear Classes e Arquivos

**Sugestão:** Manter nome "Homes" no domínio (usuário entende) mas adaptar data layer

Ou:

**Refatoração Completa:**
- `HomeModel` → `HouseholdModel`
- `HomesApiService` → `HouseholdsApiService`
- Manter interface do domínio igual para não quebrar UI

---

## 📝 Checklist de Correções

### Arquivos que PRECISAM ser alterados:

- [ ] `lib/services/api/homes_api_service.dart`
  - [ ] Trocar `/homes` por `/households`
  - [ ] Remover `@Field('address')`
  - [ ] Adicionar tratamento para novos campos

- [ ] `lib/features/homes/data/models/home_model.dart`
  - [ ] Alterar `@JsonKey(name: 'user_id')` para `@JsonKey(name: 'owner_id')`
  - [ ] Remover campo `address`
  - [ ] Remover campo `isActive` (ou tornar opcional com valor padrão)
  - [ ] Adicionar campos `owner` e `members`

- [ ] `lib/features/homes/data/models/home_model.g.dart`
  - [ ] Regenerar após alterações no modelo

- [ ] `lib/core/constants/api_constants.dart`
  - [ ] Trocar `homes` por `households`

- [ ] `lib/features/homes/domain/entities/home.dart`
  - [ ] Considerar remover `address` e `isActive`
  - [ ] Ou manter e tratar como campos "locais only"

### Testes que DEVEM ser adicionados:

- [ ] Teste de criação de household
- [ ] Teste de serialização/deserialização do modelo
- [ ] Teste de integração com API real

---

## ⚙️ Exemplo de Request Correto

### Criar Household

```dart
// ✅ CORRETO
final response = await dio.post(
  'https://mealtime.app.br/api/households',
  data: {
    'name': 'Minha Casa',
    'description': 'Casa principal',  // Opcional, mas pode retornar null
    // NÃO enviar 'address' - não existe na API
    // NÃO enviar 'is_active' - não existe na API
  },
  options: Options(
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'x-user-id': userId,
    },
  ),
);
```

### Response Esperada

```json
{
  "id": "uuid-aqui",
  "name": "Minha Casa",
  "created_at": "2025-10-11T14:26:31.501Z",
  "updated_at": "2025-10-11T14:26:31.501Z",
  "owner_id": "user-uuid",
  "owner": {
    "id": "user-uuid",
    "name": "Nome do Usuário",
    "email": "email@exemplo.com"
  },
  "members": [
    {
      "id": "member-uuid",
      "userId": "user-uuid",
      "name": "Nome do Usuário",
      "email": "email@exemplo.com",
      "role": "ADMIN",
      "joinedAt": "2025-10-11T14:26:31.501Z"
    }
  ]
}
```

---

## 🎯 Recomendações

### Opção 1: Corrigir Backend (RECOMENDADO)

Solicitar ao time de backend para:
1. Adicionar suporte ao campo `address`
2. Corrigir salvamento do campo `description`
3. Adicionar campo `is_active`
4. Padronizar nomenclatura (`owner_id` vs `user_id`)

### Opção 2: Adaptar Frontend

Se backend não pode ser alterado:
1. ✅ Atualizar modelo para corresponder à API real
2. ✅ Remover campos não suportados
3. ✅ Armazenar dados locais se necessário
4. ⚠️ Informar usuário sobre limitações

---

## 📊 Tabela de Compatibilidade Detalhada

| Campo | Flutter Envia | API Aceita | API Retorna | Status |
|-------|---------------|------------|-------------|--------|
| `name` | ✅ Sim | ✅ Sim | ✅ Sim | ✅ OK |
| `address` | ✅ Sim | ❌ Não | ❌ Não | 🔴 Remover |
| `description` | ✅ Sim | ⚠️ Sim | ⚠️ Null | 🟡 Aceito mas não funciona |
| `user_id` | ❌ Espera | ❌ Não | ❌ Não | 🔴 Usar `owner_id` |
| `owner_id` | ❌ Não envia | N/A | ✅ Sim | 🔴 Adicionar ao modelo |
| `is_active` | ✅ Sim | ❌ Não | ❌ Não | 🔴 Remover ou tornar local |
| `created_at` | N/A | N/A | ✅ Sim | ✅ OK |
| `updated_at` | N/A | N/A | ✅ Sim | ✅ OK |
| `owner` | ❌ Não espera | N/A | ✅ Sim | 🟡 Adicionar ao modelo |
| `members` | ❌ Não espera | N/A | ✅ Sim | 🟡 Adicionar ao modelo |

---

## 🚨 Impacto de NÃO Corrigir

Se não corrigir estas incompatibilidades:

1. **App não funcionará** - Endpoints retornam 404
2. **Deserialização falhará** - Campos com nomes diferentes causam erros
3. **Dados perdidos** - `address` nunca será salvo
4. **Crashes** - Campos obrigatórios inexistentes causam exceções
5. **UX ruim** - Usuário não consegue criar households

---

## ✅ Conclusão

**Status Atual:** 🔴 **CÓDIGO NÃO FUNCIONAL**

**Correções Obrigatórias:**
1. Alterar `/homes` para `/households`
2. Ajustar modelo de dados (user_id → owner_id)
3. Remover campo `address`
4. Adicionar campos `owner` e `members`

**Tempo Estimado de Correção:** 2-4 horas

**Prioridade:** 🔴 **URGENTE** - App não funciona sem estas correções

---

*Relatório gerado via Cursor AI*  
*Data: 11/10/2025*

