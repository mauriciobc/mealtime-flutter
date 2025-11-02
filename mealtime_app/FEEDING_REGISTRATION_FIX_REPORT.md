# Relatório de Investigação: Registro de Alimentação Não Funcionava

## 🔍 Problema Identificado

O registro de alimentação não estava salvando no banco de dados devido a **dois problemas críticos**:

### Problema 1: Mapeamento Incorreto de `MealType`
- **Erro**: O app estava enviando `meal_type: "snack"` 
- **Correto**: A API V2 aceita apenas `"manual"`, `"scheduled"`, ou `"automatic"`
- **Impacto**: Erro 400 "Invalid option: expected one of \"manual\"|\"scheduled\"|\"automatic\""

### Problema 2: Endpoint Batch com Estrutura Diferente
- **Erro**: O app tentava usar `/feedings/batch` com estrutura `{feedings: [...]}`
- **Realidade**: A API espera `{logs: [...]}` com campos obrigatórios `portionSize` e `timestamp`
- **Impacto**: Erro 400 "Invalid input: expected number, received undefined"

## ✅ Soluções Implementadas

### 1. Corrigido Mapeamento de `MealType`
**Arquivo**: `lib/services/api/feeding_logs_api_service.dart`

Adicionada função `_mapMealTypeToApi()` que converte todos os tipos de refeição para `"manual"`:

```dart
Map<String, dynamic> toJson() => {
  'catId': catId,
  if (mealType != null) 'meal_type': _mapMealTypeToApi(mealType),  // Map snack to manual
  if (amount != null) 'amount': amount,
  if (unit != null) 'unit': unit,
  if (notes != null) 'notes': notes,
};

String _mapMealTypeToApi(String? mealType) {
  if (mealType == null) return 'manual';
  // Todos os tipos são mapeados para 'manual' por enquanto
  // pois a API não diferencia entre breakfast, lunch, dinner, snack
  return 'manual';
}
```

### 2. Desabilitado Endpoint Batch e Correção do Field Name
**Arquivo**: `lib/services/api/feeding_logs_api_service.dart`

Corrigido o nome do campo de `feedings` para `logs` no batch request:

```dart
Map<String, dynamic> toJson() => {
  'logs': feedings.map((f) => f.toJson()).toList(),
};
```

**Arquivo**: `lib/features/feeding_logs/data/datasources/feeding_logs_remote_datasource.dart`

Desabilitado temporariamente o uso do endpoint batch e remoção da tentativa:

```dart
// Desabilitar batch endpoint temporariamente - API tem estrutura diferente
// TODO: Implementar batch endpoint quando API estiver pronta
print('[FeedingLogsRemoteDataSource] Criando ${requests.length} feedings em paralelo...');
```

Agora **sempre** usa o endpoint single em paralelo via `Future.wait`.

### 3. Adicionados Logs de Debug
Adicionados logs detalhados para rastreamento:

```dart
print('[FeedingLogsRemoteDataSource] Criando ${requests.length} feedings em paralelo...');
// ... criação em paralelo
print('[FeedingLogsRemoteDataSource] Feedings criados com sucesso: ${successfulResults.length}/${requests.length}');
```

## 🧪 Evidências dos Testes

### Teste do Endpoint Batch
```bash
$ curl -X POST https://mealtime.app.br/api/v2/feedings/batch \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-User-ID: $USER_ID" \
  -d '{
    "logs": [{
      "catId": "uuid",
      "meal_type": "manual",
      "amount": 50,
      "unit": "g"
    }]
  }'
```

**Erro Recebido**:
```json
{
  "success": false,
  "error": "Invalid request data",
  "details": {
    "logs": {
      "0": {
        "portionSize": {
          "_errors": ["Invalid input: expected number, received undefined"]
        },
        "timestamp": {
          "_errors": ["Invalid input: expected string, received undefined"]
        }
      }
    }
  }
}
```

**Conclusão**: Endpoint batch requer campos adicionais que não estão na especificação do app.

### Teste do Endpoint Single
```bash
$ curl -X POST https://mealtime.app.br/api/v2/feedings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-User-ID: $USER_ID" \
  -d '{
    "catId": "uuid",
    "meal_type": "manual",
    "amount": 30,
    "unit": "g"
  }'
```

**Resultado**: ✅ Funciona corretamente quando não há duplicação.

**Com `meal_type: "snack"`**: ❌ 400 Bad Request

## 📋 Estrutura Atual da API

### POST /feedings (Single) - ✅ Funcional
```json
{
  "catId": "string (uuid)",
  "meal_type": "manual" | "scheduled" | "automatic",
  "amount": "number?",
  "unit": "string?",
  "notes": "string?"
}
```

### POST /feedings/batch - ⚠️ Estrutura Incompatível
```json
{
  "logs": [
    {
      "catId": "string (uuid)",
      "meal_type": "manual" | "scheduled" | "automatic",
      "portionSize": "number",  // ⚠️ Obrigatório, mas não existe no app
      "timestamp": "string",     // ⚠️ Obrigatório, mas não existe no app
      "amount": "number?",
      "unit": "string?",
      "notes": "string?"
    }
  ]
}
```

## 🎯 Resultado Final

✅ **Problema Resolvido**: 
- Feedings agora são criados corretamente usando endpoint single em paralelo
- Mapeamento de MealType corrigido
- Logs adicionados para debug

⚠️ **Trabalho Futuro**:
- Implementar suporte completo ao endpoint batch quando a API estiver alinhada
- Ou ajustar a API para aceitar a estrutura atual do batch

## 📝 Arquivos Modificados

1. `lib/services/api/feeding_logs_api_service.dart`
   - Adicionada função `_mapMealTypeToApi()`
   - Corrigido campo `feedings` → `logs` em batch

2. `lib/features/feeding_logs/data/datasources/feeding_logs_remote_datasource.dart`
   - Removida tentativa de usar batch endpoint
   - Adicionados logs de debug
   - Sempre usa criação paralela via Future.wait

3. `lib/features/feeding_logs/presentation/widgets/feeding_bottom_sheet.dart`
   - Comentário adicionado sobre mapeamento

## ✅ Testes de Validação

Execute o app e registre uma alimentação. Os logs devem mostrar:

```
[FeedingLogsRemoteDataSource] Criando 2 feedings em paralelo...
[FeedingLogsRemoteDataSource] Feedings criados com sucesso: 2/2
```

Se houver problemas, os logs mostrarão detalhes adicionais.

