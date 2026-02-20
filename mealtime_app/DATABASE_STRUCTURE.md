# 🗄️ Estrutura do Banco de Dados - MealTime

**Data:** 12 de Outubro de 2025  
**Banco:** Supabase PostgreSQL  
**URL:** `https://zzvmyzyszsqptgyqwqwt.supabase.co`

---

## 📊 Visão Geral

O banco de dados MealTime possui **13 tabelas** organizadas para gerenciar:
- 🔐 Autenticação e perfis de usuários
- 🏠 Casas/domicílios (households)
- 🐱 Gatos e seus dados
- 🍽️ Alimentação e agendamentos
- ⚖️ Controle de peso
- 🔔 Notificações

---

## 👤 Estrutura de Autenticação e Usuários

### Tabela: `profiles`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 11

#### Colunas:

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| `id` | UUID | ❌ | Primary Key, referencia `auth.users` |
| `updated_at` | TIMESTAMPTZ | ✅ | Data da última atualização |
| `username` | TEXT | ✅ | Nome de usuário (opcional) |
| `full_name` | TEXT | ✅ | Nome completo do usuário |
| `avatar_url` | TEXT | ✅ | URL da foto de perfil |
| `email` | TEXT | ✅ | Email do usuário |
| `timezone` | TEXT | ✅ | Fuso horário (ex: "America/Sao_Paulo") |

#### Relacionamentos:

Esta tabela é referenciada por:
- `cats.owner_id` (donos de gatos)
- `household_members.user_id` (membros de casas)
- `feeding_logs.fed_by` (quem alimentou)
- `cat_weight_logs.measured_by` (quem mediu peso)
- `weight_goals.created_by` (quem criou meta de peso)

#### Exemplo de Dados:

```json
{
  "id": "915a9f01-d515-4b60-bf24-20b7c2f54c63",
  "full_name": "",
  "email": "testapi@email.com",
  "username": null,
  "avatar_url": null,
  "timezone": null,
  "updated_at": null
}
```

#### ⚠️ Observação Importante:

**Alguns usuários podem ter `full_name` vazio!** O sistema deve lidar com isso graciosamente:

```dart
final displayName = profile.fullName?.isNotEmpty == true
    ? profile.fullName!
    : email.split('@').first;
```

---

## 🏠 Estrutura de Casas/Domicílios

### Tabela: `households`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 6

#### Colunas:

| Coluna | Tipo | Default | Descrição |
|--------|------|---------|-----------|
| `id` | UUID | - | Primary Key |
| `created_at` | TIMESTAMPTZ | `CURRENT_TIMESTAMP` | Data de criação |
| `updated_at` | TIMESTAMPTZ | `CURRENT_TIMESTAMP` | Data de atualização |
| `name` | TEXT | - | Nome da casa |
| `description` | TEXT | nullable | Descrição (opcional) |
| `owner_id` | UUID | - | ID do dono (referencia `profiles`) |
| `inviteCode` | TEXT | nullable | Código de convite |

#### Relacionamentos:

Esta tabela é referenciada por:
- `cats.household_id` (gatos da casa)
- `household_members.household_id` (membros da casa)
- `feeding_logs.household_id` (logs de alimentação)

---

### Tabela: `household_members`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 9

#### Colunas:

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | Primary Key |
| `household_id` | UUID | Referencia `households.id` |
| `user_id` | UUID | Referencia `profiles.id` |
| `role` | TEXT | Papel do membro (ex: "owner", "member") |
| `created_at` | TIMESTAMPTZ | Data de entrada |

---

## 🐱 Estrutura de Gatos

### Tabela: `cats`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 6

#### Colunas:

| Coluna | Tipo | Nullable | Descrição |
|--------|------|----------|-----------|
| `id` | UUID | ❌ | Primary Key |
| `created_at` | TIMESTAMPTZ | ❌ | Data de criação |
| `updated_at` | TIMESTAMPTZ | ❌ | Data de atualização |
| `name` | TEXT | ❌ | Nome do gato |
| `birth_date` | DATE | ✅ | Data de nascimento |
| `weight` | NUMERIC | ✅ | Peso atual |
| `household_id` | UUID | ❌ | Casa do gato |
| `owner_id` | UUID | ❌ | Dono principal |
| `portion_size` | NUMERIC | ✅ | Tamanho da porção |
| `portion_unit` | VARCHAR | ✅ | Unidade (g, kg, etc) |
| `photo_url` | VARCHAR | ✅ | URL da foto |
| `feeding_interval` | INTEGER | ✅ | Intervalo entre alimentações (horas) |
| `notes` | TEXT | ✅ | Notas sobre o gato |
| `restrictions` | TEXT | ✅ | Restrições alimentares |
| `gender` | TEXT | ✅ | Sexo do gato (ex: "male", "female") — ver [Alterações de schema](#-alterações-de-schema) |

---

## 🍽️ Sistema de Alimentação

### Tabela: `feeding_logs`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 29

#### Colunas:

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | Primary Key |
| `created_at` | TIMESTAMPTZ | Quando o registro foi criado |
| `updated_at` | TIMESTAMPTZ | Última atualização |
| `cat_id` | UUID | Gato alimentado |
| `household_id` | UUID | Casa onde ocorreu |
| `meal_type` | TEXT | Tipo de refeição (breakfast, lunch, dinner, snack) |
| `amount` | NUMERIC | Quantidade |
| `unit` | TEXT | Unidade (g, kg, xícaras) |
| `notes` | TEXT | Observações |
| `fed_by` | UUID | Quem alimentou (referencia `profiles`) |
| `fed_at` | TIMESTAMPTZ | Quando foi alimentado |

---

### Tabela: `schedules`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 2

#### Colunas:

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | Primary Key |
| `cat_id` | UUID | Gato do agendamento |
| `type` | TEXT | Tipo (feeding, weight_check) |
| `interval` | INTEGER | Intervalo em horas |
| `times` | ARRAY TEXT | Horários específicos ["08:00", "12:00"] |
| `enabled` | BOOLEAN | Se está ativo |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `updated_at` | TIMESTAMPTZ | Data de atualização |

---

## ⚖️ Sistema de Controle de Peso

### Tabela: `cat_weight_logs`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 17

#### Colunas:

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | Primary Key |
| `created_at` | TIMESTAMPTZ | Quando foi registrado |
| `updated_at` | TIMESTAMPTZ | Última atualização |
| `weight` | NUMERIC | Peso registrado |
| `date` | DATE | Data da medição |
| `cat_id` | UUID | Gato medido |
| `notes` | TEXT | Observações |
| `measured_by` | UUID | Quem mediu |

---

### Tabela: `weight_goals`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 5

#### Colunas:

| Coluna | Tipo | Default | Descrição |
|--------|------|---------|-----------|
| `id` | UUID | - | Primary Key |
| `created_at` | TIMESTAMPTZ | `CURRENT_TIMESTAMP` | Data de criação |
| `updated_at` | TIMESTAMPTZ | `CURRENT_TIMESTAMP` | Última atualização |
| `cat_id` | UUID | - | Gato da meta |
| `target_weight` | NUMERIC | - | Peso alvo |
| `target_date` | DATE | nullable | Data alvo |
| `start_weight` | NUMERIC | nullable | Peso inicial |
| `status` | TEXT | `'active'` | Status (active, completed, cancelled) |
| `notes` | TEXT | nullable | Notas |
| `created_by` | UUID | - | Quem criou |
| `goal_name` | TEXT | - | Nome da meta |
| `unit` | TEXT | - | Unidade (kg, g) |

---

### Tabela: `weight_goal_milestones`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 3

#### Colunas:

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | Primary Key |
| `created_at` | TIMESTAMPTZ | Data de criação |
| `goal_id` | UUID | Meta relacionada |
| `weight` | NUMERIC | Peso do marco |
| `date` | DATE | Data do marco |
| `notes` | TEXT | Observações |

---

## 🔔 Sistema de Notificações

### Tabela: `notifications`

**Row-Level Security (RLS):** ✅ Habilitado  
**Total de Registros:** 23

#### Colunas:

| Coluna | Tipo | Default | Descrição |
|--------|------|---------|-----------|
| `id` | UUID | - | Primary Key |
| `created_at` | TIMESTAMPTZ | `CURRENT_TIMESTAMP` | Data de criação |
| `updated_at` | TIMESTAMPTZ | `CURRENT_TIMESTAMP` | Última atualização |
| `user_id` | UUID | - | Destinatário |
| `title` | TEXT | - | Título |
| `message` | TEXT | - | Mensagem |
| `type` | TEXT | - | Tipo (info, warning, reminder) |
| `is_read` | BOOLEAN | `false` | Se foi lida |
| `metadata` | JSONB | `'{}'::jsonb` | Dados adicionais |

---

### Tabela: `scheduledNotification`

**Row-Level Security (RLS):** ❌ Desabilitado  
**Total de Registros:** 30

#### Colunas:

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | UUID | Primary Key |
| `userId` | TEXT | ID do usuário (camelCase) |
| `catId` | TEXT | ID do gato (opcional) |
| `type` | TEXT | Tipo de notificação |
| `title` | TEXT | Título |
| `message` | TEXT | Mensagem |
| `deliverAt` | TIMESTAMPTZ | Quando entregar |
| `delivered` | BOOLEAN | Se foi entregue |
| `deliveredAt` | TIMESTAMPTZ | Quando foi entregue |
| `createdAt` | TIMESTAMPTZ | Data de criação |
| `updatedAt` | TIMESTAMPTZ | Última atualização |

#### ⚠️ Nota:

Esta tabela usa **camelCase** em vez de **snake_case**. Provavelmente é gerenciada por um sistema externo.

---

## 🔐 Política de Segurança (RLS)

### Tabelas com RLS Habilitado:

✅ Todas as tabelas principais têm RLS:
- `profiles`
- `households`
- `household_members`
- `cats`
- `feeding_logs`
- `schedules`
- `notifications`
- `cat_weight_logs`
- `weight_goals`
- `weight_goal_milestones`

### Tabelas sem RLS:

❌ Apenas tabelas de sistema/infraestrutura:
- `_prisma_migrations`
- `schema_migrations`
- `scheduledNotification`

---

## 📐 Diagrama de Relacionamentos

```
auth.users (Supabase Auth)
    ↓
profiles (id)
    ├─→ households.owner_id (1:N)
    ├─→ household_members.user_id (1:N)
    ├─→ cats.owner_id (1:N)
    ├─→ feeding_logs.fed_by (1:N)
    ├─→ cat_weight_logs.measured_by (1:N)
    └─→ weight_goals.created_by (1:N)

households (id)
    ├─→ household_members.household_id (1:N)
    ├─→ cats.household_id (1:N)
    └─→ feeding_logs.household_id (1:N)

cats (id)
    ├─→ feeding_logs.cat_id (1:N)
    ├─→ schedules.cat_id (1:N)
    ├─→ cat_weight_logs.cat_id (1:N)
    └─→ weight_goals.cat_id (1:N)

weight_goals (id)
    └─→ weight_goal_milestones.goal_id (1:N)
```

---

## 🔍 Queries Importantes

### 1. Buscar Perfil Completo do Usuário

```sql
SELECT 
  p.*,
  (
    SELECT json_agg(json_build_object(
      'id', h.id,
      'name', h.name,
      'role', hm.role
    ))
    FROM household_members hm
    JOIN households h ON h.id = hm.household_id
    WHERE hm.user_id = p.id
  ) as households
FROM profiles p
WHERE p.id = 'user-uuid';
```

### 2. Buscar Gatos do Usuário

```sql
SELECT c.*
FROM cats c
WHERE c.owner_id = 'user-uuid'
   OR c.household_id IN (
     SELECT household_id 
     FROM household_members 
     WHERE user_id = 'user-uuid'
   );
```

### 3. Último Registro de Alimentação

```sql
SELECT fl.*, p.full_name as fed_by_name, c.name as cat_name
FROM feeding_logs fl
JOIN profiles p ON p.id = fl.fed_by
JOIN cats c ON c.id = fl.cat_id
WHERE fl.cat_id = 'cat-uuid'
ORDER BY fl.fed_at DESC
LIMIT 1;
```

---

## 💡 Boas Práticas de Uso

### 1. Sempre Verificar Nullable

Muitos campos são nullable, sempre use verificação:

```dart
final fullName = profile.fullName?.isNotEmpty == true
    ? profile.fullName!
    : 'Nome não informado';
```

### 2. Usar maybeSingle() em vez de single()

Para evitar erros quando registro não existe:

```dart
final data = await supabase
    .from('profiles')
    .select()
    .eq('id', userId)
    .maybeSingle(); // ✅ Retorna null se não existir

// ❌ NÃO USE: .single() - lança erro se não existir
```

### 3. Combinar Dados de Múltiplas Fontes

```dart
// Dados do Auth (sempre disponíveis)
final authUser = supabase.auth.currentUser;

// Dados do Profile (podem estar vazios)
final profile = await getProfile(authUser.id);

// Combinar
final displayData = {
  'email': authUser.email,
  'name': profile?.fullName ?? authUser.email.split('@').first,
  'verified': authUser.emailConfirmedAt != null,
};
```

### 4. Tratar Erros Graciosamente

```dart
try {
  final profile = await getProfile();
  // usar profile
} on PostgrestException catch (e) {
  // Tabela/registro não existe
  print('Profile não encontrado: ${e.message}');
  // Usar dados do Auth como fallback
} catch (e) {
  // Outro erro
  print('Erro: $e');
}
```

---

## 🔄 Sincronização de Dados

### Estratégia Recomendada:

1. **No Login:**
   - Buscar dados do Supabase Auth
   - Buscar dados da tabela `profiles`
   - Combinar e salvar em cache local

2. **No App (getCurrentUser):**
   - Primeiro, tentar cache local (rápido)
   - Se não houver, buscar do Supabase
   - Atualizar cache

3. **Refresh Periódico:**
   - A cada abertura do app
   - Pull-to-refresh manual
   - Background refresh a cada X minutos

### Exemplo de Implementação:

```dart
Future<User> getCurrentUser({bool forceRefresh = false}) async {
  // 1. Cache local (se não forçar refresh)
  if (!forceRefresh) {
    final cached = await localDataSource.getUser();
    if (cached != null && !cached.isStale) {
      return cached.toEntity();
    }
  }

  // 2. Buscar do Supabase
  final authUser = supabase.auth.currentUser;
  if (authUser == null) throw NotAuthenticatedException();

  // 3. Buscar profile
  final profileData = await supabase
      .from('profiles')
      .select()
      .eq('id', authUser.id)
      .maybeSingle();

  // 4. Combinar dados
  final user = UserModel(
    id: authUser.id,
    email: authUser.email,
    fullName: profileData?['full_name'] ?? '',
    // ... outros campos
  );

  // 5. Atualizar cache
  await localDataSource.saveUser(user);

  return user.toEntity();
}
```

---

## 📋 Alterações de schema

### Adição da coluna `gender` na tabela `cats`

**Data:** 2026-02-20

**Objetivo:** Permitir armazenar o sexo do gato (ex.: macho/fêmea) para uso na UI e em relatórios.

**Alteração:**

- **Tabela:** `cats`
- **Coluna:** `gender`
- **Tipo:** `TEXT` (nullable)
- **Descrição:** Sexo do gato. Valores típicos: `"male"`, `"female"` ou `null` quando não informado.

**Exemplo de migração SQL (Supabase/PostgreSQL):**

```sql
ALTER TABLE public.cats
  ADD COLUMN IF NOT EXISTS gender TEXT;
```

**Impacto no app:** O app já utiliza o campo no modelo local (Drift); a coluna no Supabase deve existir para sincronização. A UI usa o valor para cor/ícone por gênero (ex.: `cats_genderMale`, `cats_genderFemale` na l10n).

---

## 📝 Migrações e Versionamento

### Tabela: `_prisma_migrations`

Registra todas as migrações aplicadas:
- **10 migrações** executadas
- Usa Prisma como ORM
- Logs de execução disponíveis

### Tabela: `schema_migrations`

Alternativa de controle de migrações:
- **0 registros** (não utilizada)
- Pode ser usada por outro sistema de migração

---

## 🎯 Conclusão

### Pontos-Chave:

1. ✅ Tabela `profiles` **existe** e é a fonte de dados do usuário
2. ⚠️ Campos nullable requerem tratamento cuidadoso
3. 🔐 RLS habilitado em todas as tabelas principais
4. 🏗️ Arquitetura bem estruturada com relacionamentos claros
5. 📊 Sistema completo para gerenciamento de gatos e alimentação

### Para o Flutter App:

- ✅ Usar Supabase Client para queries diretas
- ✅ Combinar dados do Auth com dados do Profile
- ✅ Implementar cache local robusto
- ✅ Tratar erros graciosamente
- ✅ Sincronização inteligente

---

**Documentação gerada via Cursor AI + Supabase MCP**  
*Última atualização: 20/02/2026*


