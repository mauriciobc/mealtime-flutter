# Mapeamento Correto das APIs do Backend Mealtime

**Baseado no repositório:** `mauriciobc/mealtime` (Next.js/TypeScript)

## 🔍 Descobertas Importantes

1. **NÃO existe API `/meals`** - O backend usa outra estrutura
2. **Autenticação:** Todas as APIs requerem header `X-User-ID` com o ID do usuário Supabase
3. **Base URL:** `https://mealtime.app.br/api`

## 📋 APIs Disponíveis

### 1. Cats (Gatos) ✅
- **GET** `/api/cats` - Listar todos os gatos
  - Query opcional: `?householdId={id}` - filtrar por domicílio
  - **Requer:** Header `X-User-ID`
  - **Retorna:** Array de gatos com household_members

### 2. Schedules (Agendamentos) ⚠️ 
**NOTA:** O Flutter app está chamando `/meals`, mas deveria chamar `/schedules`

- **GET** `/api/schedules?householdId={id}` - Listar agendamentos
  - **Obrigatório:** Query parameter `householdId`
  - **Requer:** Header `X-User-ID`
  - **Retorna:** Array de schedules com informações do gato
  
- **POST** `/api/schedules` - Criar agendamento
  - **Body:**
    ```json
    {
      "catId": "uuid",
      "type": "string",
      "interval": "string",
      "times": ["HH:MM"],
      "enabled": boolean
    }
    ```

### 3. Feeding Logs (Registros de Alimentação) ✅
- **GET** `/api/feeding-logs?catId={id}` - Listar registros
  - **Obrigatório:** Query parameter `catId`
  - **Requer:** Header `X-User-ID`
  - **Retorna:** Array de feeding_logs ordenados por `fed_at DESC`
  - **Campos:** id, cat_id, fed_at, fed_by, meal_type, amount, unit, notes, household_id

### 4. Households (Domicílios) ✅
- **GET** `/api/households` - Listar domicílios do usuário
  - **Requer:** Supabase Auth (cookie ou header)
  - **Retorna:** Array de households com members
  - **Importante:** Usa Supabase Auth `getUser()` em vez de `X-User-ID`

## 🔧 Correções Necessárias no Flutter App

### 1. **Remover feature `/meals`**
O endpoint `/meals` NÃO EXISTE no backend. O app Flutter está fazendo chamadas para uma API inexistente.

### 2. **Usar `/schedules` para agendamentos**
Onde o app precisar de "refeições agendadas", deve usar:
- GET `/api/schedules?householdId={id}`

### 3. **Usar `/feeding-logs` para histórico**
Para registros de alimentações realizadas, usar:
- GET `/api/feeding-logs?catId={id}`

### 4. **Adicionar header `X-User-ID`**
Todas as APIs (exceto `/households`) exigem o header:
```dart
headers: {
  'X-User-ID': userId,
  'Content-Type': 'application/json',
}
```

### 5. **API de Households usa Supabase Auth**
A API `/households` é diferente: ela valida via Supabase cookie/session, não via `X-User-ID`.

## 📊 Estrutura de Dados

### Schedule (Agendamento)
```typescript
{
  id: string (uuid)
  catId: string (uuid)
  type: string
  interval: string
  times: string[]  // Array de horários "HH:MM"
  enabled: boolean
  days: string[]   // Adicionado pelo backend (sempre [])
  cat: {
    id: string
    name: string
  }
}
```

### Feeding Log (Registro de Alimentação)
```typescript
{
  id: string (uuid)
  cat_id: string (uuid)
  fed_at: DateTime
  fed_by: string (userId)
  meal_type: string
  amount: number
  unit: string
  notes: string?
  household_id: string (uuid)
  created_at: DateTime
  updated_at: DateTime
}
```

### Cat (Gato)
```typescript
{
  id: string (uuid)
  name: string
  owner_id: string (userId)
  household_id: string (uuid)
  birth_date: DateTime?
  weight: number?
  breed: string?
  avatar_url: string?
  created_at: DateTime
  updated_at: DateTime
  household: {
    id: string
    household_members: Array<{user_id: string}>
  }
}
```

## 🎯 Plano de Ação

1. ✅ **Documentar** APIs corretas (este arquivo)
2. ⚠️ **Remover** toda referência a `/meals` no Flutter
3. ⚠️ **Criar** serviços para `/schedules` 
4. ⚠️ **Corrigir** `ApiClient` para adicionar header `X-User-ID`
5. ⚠️ **Atualizar** `home_page.dart` para usar schedules + feeding_logs
6. ⚠️ **Testar** chamadas de API com usuário autenticado

## 🔗 Links Úteis

- **Repositório Backend:** https://github.com/mauriciobc/mealtime
- **Rotas de API:** `app/api/**/route.ts`



