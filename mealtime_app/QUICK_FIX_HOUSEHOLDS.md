# ⚡ Correção Rápida: Household API

## 🚨 Problema

**SEU CÓDIGO NÃO FUNCIONA** para criar households!

---

## ❌ 7 Problemas Encontrados

### 1. **Endpoint Errado** 🔴 CRÍTICO
- **Flutter usa:** `/homes`
- **API real:** `/households`
- **Resultado:** 404 Not Found

### 2. **Campo user_id errado** 🔴 CRÍTICO
- **Flutter espera:** `user_id`
- **API retorna:** `owner_id`
- **Resultado:** Deserialização falha

### 3. **Campo address não existe** 🔴 CRÍTICO
- **Flutter envia:** `address`
- **API:** Ignora completamente
- **Resultado:** Endereço nunca é salvo

### 4. **Campo description quebrado** 🟡 MÉDIO
- **Flutter envia:** `description`
- **API retorna:** `null`
- **Resultado:** Descrição não é salva

### 5. **Campo is_active não existe** 🔴 CRÍTICO
- **Flutter espera:** `is_active`
- **API:** Não retorna
- **Resultado:** Campo sempre null

### 6. **Campos owner e members faltando** 🟡 MÉDIO
- **API retorna:** `owner` (objeto) e `members` (array)
- **Flutter:** Não tem no modelo
- **Resultado:** Dados importantes perdidos

### 7. **Header x-user-id faltando** 🟡 MÉDIO
- Alguns endpoints precisam deste header
- **Resultado:** Pode retornar 401 Unauthorized

---

## ✅ Correção Rápida (Passo a Passo)

### Passo 1: Alterar Endpoint

**Arquivo:** `lib/services/api/homes_api_service.dart`

```dart
// ❌ ANTES
@GET('/homes')
@POST('/homes')

// ✅ DEPOIS
@GET('/households')
@POST('/households')
```

### Passo 2: Criar Novo Modelo

**Criar arquivo:** `lib/features/homes/data/models/household_model.dart`

```dart
import 'package:json_annotation/json_annotation.dart';

part 'household_model.g.dart';

@JsonSerializable()
class HouseholdModel {
  final String id;
  final String name;
  final String? description;
  
  @JsonKey(name: 'owner_id')  // ✅ Correto!
  final String ownerId;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const HouseholdModel({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) => 
    _$HouseholdModelFromJson(json);
    
  Map<String, dynamic> toJson() => _$HouseholdModelToJson(this);
}
```

### Passo 3: Atualizar API Service

```dart
@POST('/households')
Future<ApiResponse<HouseholdModel>> createHousehold({
  @Field('name') required String name,
  @Field('description') String? description,
  // ❌ REMOVER: @Field('address')
  // ❌ REMOVER: @Field('is_active')
});
```

### Passo 4: Atualizar Constants

**Arquivo:** `lib/core/constants/api_constants.dart`

```dart
// ❌ ANTES
static const String homes = '/homes';

// ✅ DEPOIS
static const String households = '/households';
```

### Passo 5: Adicionar Header

Certifique-se de que TODAS as requisições incluem:

```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
  'x-user-id': '$userId',  // ← IMPORTANTE!
}
```

### Passo 6: Regenerar Código

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🎯 O Que a API Realmente Retorna

```json
{
  "id": "uuid",
  "name": "Casa Nome",
  "description": null,
  "owner_id": "user-uuid",
  "created_at": "2025-10-11T14:26:31.501Z",
  "updated_at": "2025-10-11T14:26:31.501Z",
  "owner": {
    "id": "user-uuid",
    "name": "Nome",
    "email": "email@example.com"
  },
  "members": [...]
}
```

**Campos que NÃO existem:**
- ❌ `address`
- ❌ `user_id` (é `owner_id`)
- ❌ `is_active`

---

## ⏱️ Tempo Estimado

- **Alterações necessárias:** 2-4 horas
- **Prioridade:** 🔴 **URGENTE**

---

## 📄 Documentos Completos

- **`HOUSEHOLD_API_COMPLIANCE_REPORT.md`** - Relatório técnico detalhado
- **`QUICK_FIX_HOUSEHOLDS.md`** - Este guia rápido

---

## ✅ Checklist

- [ ] Alterar `/homes` para `/households`
- [ ] Criar `HouseholdModel` com campos corretos
- [ ] Remover campo `address`
- [ ] Alterar `user_id` para `owner_id`
- [ ] Remover campo `is_active`
- [ ] Atualizar `api_constants.dart`
- [ ] Adicionar header `x-user-id`
- [ ] Regenerar código com build_runner
- [ ] Testar criação de household

---

**Não esqueça:** O endpoint correto é `/households` (plural)!

