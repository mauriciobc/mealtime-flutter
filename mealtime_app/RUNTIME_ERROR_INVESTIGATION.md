# 🔥 Investigação de Erros de Runtime

**Data:** 12 de Outubro de 2025  
**Método:** Tentativa de execução do app com `flutter run`  
**Resultado:** ❌ **FALHA NA COMPILAÇÃO**

---

## 📋 Protocolo Seguido

1. ✅ **Executar o app** - `flutter run --verbose`
2. ✅ **Monitorar logs** - Captura completa em `/tmp/flutter_run.log`
3. ✅ **Coletar evidências** - Análise de ~40 erros de compilação
4. ✅ **Elaborar causa raiz** - Identificação de 2 problemas principais
5. 🔄 **Planejar correção** - Em progresso

---

## 🔍 Evidências Coletadas

### Erro Fatal de Build

```
Target kernel_snapshot_program failed: Exception
ninja: build stopped: subcommand failed.
Building Linux application... (completed in 3,9s)
Error: Build process failed
exiting with code 1
```

---

### Categoria 1: Feature `meals` Não Implementada

**Total de Arquivos Faltando:** 20+

#### Arquivos Críticos Faltando:

```
❌ lib/services/api/meals_api_service.dart
❌ lib/features/meals/presentation/bloc/meals_bloc.dart
❌ lib/features/meals/presentation/bloc/meals_event.dart
❌ lib/features/meals/presentation/bloc/meals_state.dart
❌ lib/features/meals/domain/entities/meal.dart
❌ lib/features/meals/domain/repositories/meals_repository.dart
❌ lib/features/meals/data/repositories/meals_repository_impl.dart
❌ lib/features/meals/data/datasources/meals_remote_datasource.dart
❌ lib/features/meals/domain/usecases/get_meals.dart
❌ lib/features/meals/domain/usecases/get_meals_by_cat.dart
❌ lib/features/meals/domain/usecases/get_meal_by_id.dart
❌ lib/features/meals/domain/usecases/get_today_meals.dart
❌ lib/features/meals/domain/usecases/create_meal.dart
❌ lib/features/meals/domain/usecases/update_meal.dart
❌ lib/features/meals/domain/usecases/delete_meal.dart
❌ lib/features/meals/domain/usecases/complete_meal.dart
❌ lib/features/meals/domain/usecases/skip_meal.dart
❌ lib/features/meals/presentation/widgets/feeding_bottom_sheet.dart
```

#### Arquivos que Dependem (Quebrados):

```
🔴 lib/main.dart:10:8
🔴 lib/core/di/injection_container.dart:30-43
🔴 lib/features/home/presentation/pages/home_page.dart:9-15
```

---

### Categoria 2: Entidade `FeedingLog` Não Definida

**Arquivo Esperado mas Não Existe:**
```
❌ lib/features/feeding_logs/domain/entities/meal.dart
```

**Problema:** O caminho está errado. Deveria ser `feeding_log.dart` não `meal.dart`

#### Arquivos Quebrados que Tentam Importar:

```
🔴 lib/features/feeding_logs/domain/usecases/get_feeding_logs.dart:4:8
🔴 lib/features/feeding_logs/domain/usecases/get_feeding_logs_by_cat.dart:4:8
🔴 lib/features/feeding_logs/domain/usecases/get_today_feeding_logs.dart:4:8
🔴 lib/features/feeding_logs/domain/usecases/create_feeding_log.dart:4:8
🔴 lib/features/feeding_logs/domain/usecases/update_feeding_log.dart:4:8
🔴 lib/features/feeding_logs/presentation/bloc/feeding_logs_bloc.dart:3:8
🔴 lib/features/feeding_logs/presentation/bloc/feeding_logs_event.dart:2:8
🔴 lib/features/feeding_logs/presentation/bloc/feeding_logs_state.dart:3:8
🔴 lib/features/feeding_logs/presentation/pages/feeding_logs_list_page.dart:3:8
🔴 lib/features/feeding_logs/presentation/pages/create_feeding_log_page.dart:3:8
🔴 lib/features/feeding_logs/presentation/pages/feeding_log_detail_page.dart:3:8
```

**Total de Arquivos Afetados:** 11+

---

### Categoria 3: Widgets Faltando

```
❌ lib/features/feeding_logs/presentation/widgets/meal_card.dart
❌ lib/features/feeding_logs/presentation/widgets/meal_form.dart
```

**Dependências Quebradas:**
```
🔴 lib/features/feeding_logs/presentation/pages/feeding_logs_list_page.dart:7:8
🔴 lib/features/feeding_logs/presentation/pages/create_feeding_log_page.dart:7:8
```

---

### Categoria 4: UseCase `getTodayFeedingLogs()` Não Definido

**Erro Específico:**
```
lib/features/feeding_logs/domain/usecases/get_today_feeding_logs.dart:14:29
Error: The method 'getTodayFeedingLogs' isn't defined for the type 'FeedingLogsRepository'
```

**Causa:** Método não implementado no repositório

---

## 🎯 Root Cause Analysis

### Causa Raiz #1: Refatoração Incompleta

**O Que Aconteceu:**
1. Código original tinha feature `meals`
2. Tentativa de refatoração para `feeding_logs`
3. Refatoração foi abandonada no meio
4. Agora temos:
   - ❌ `meals` não implementada
   - ⚠️ `feeding_logs` parcialmente implementada
   - ❌ Imports apontando para arquivos inexistentes

**Evidência:**
```dart
// feeding_logs tenta importar meal.dart
import 'package:mealtime_app/features/feeding_logs/domain/entities/meal.dart';
//                                                              ^^^^^ ERRADO!
```

---

### Causa Raiz #2: Dependências Registradas Incorretamente

**Arquivo:** `lib/core/di/injection_container.dart`

**Problema:**
```dart
// Linhas 30-43: Imports de classes que não existem
import 'package:mealtime_app/services/api/meals_api_service.dart'; // ❌
import 'package:mealtime_app/features/meals/.../meals_bloc.dart'; // ❌
// ... 18 imports quebrados

// Linhas 92-196: Registros de dependências inexistentes
sl.registerLazySingleton(() => MealsApiService(sl())); // ❌
sl.registerLazySingleton<MealsBloc>(...); // ❌
// ... ~30 registros quebrados
```

**Impacto:** App não consegue nem compilar

---

### Causa Raiz #3: Arquitetura Inconsistente

**Problema:** Mistura de conceitos

- Feature `/meals/` → Refeições agendadas
- Feature `/feeding_logs/` → Logs de alimentação
- Mas código trata como se fossem a mesma coisa

**Confusão:**
- `feeding_logs` importa `meal.dart` (deveria ser `feeding_log.dart`)
- Usecases têm nomes misturados (`create_meal` vs `create_feeding_log`)
- Widgets têm nomes errados (`meal_card` vs `feeding_log_card`)

---

## 📊 Impacto de Bloqueio

### Severidade dos Erros

| Categoria | Arquivos Afetados | Severidade | Bloqueia Compilação? |
|-----------|-------------------|------------|---------------------|
| Feature `meals` faltando | 20+ | 🔴 Crítica | ✅ SIM |
| Entidade `FeedingLog` não definida | 11+ | 🔴 Crítica | ✅ SIM |
| Widgets faltando | 2 | 🔴 Crítica | ✅ SIM |
| Métodos não implementados | 3+ | 🟡 Alta | ✅ SIM |
| **TOTAL** | **36+** | **🔴 CRÍTICA** | **✅ SIM** |

---

## 💡 Plano de Correção

### Estratégia: Abordagem Cirúrgica por Prioridade

---

### Opção A: Remover Feature `meals` Completamente (Recomendado 🎯)

**Objetivo:** Permitir que o app compile sem `meals`

#### Passos:

1. **Comentar/Remover Imports de `meals` em `main.dart`**
   - Remover linha 10: `import meals_bloc.dart`
   - Remover registros de `MealsBloc` nas linhas 50-51

2. **Comentar/Remover Imports de `meals` em `injection_container.dart`**
   - Remover linhas 30-43 (18 imports)
   - Remover linhas 92-196 (~30 registros de dependências)

3. **Comentar/Remover Imports de `meals` em `home_page.dart`**
   - Remover linhas 9-11, 14-15 (5 imports)
   - Comentar código que usa `MealsBloc` (linhas 30, 109, 175, 335)
   - Comentar método `FeedingBottomSheet` (linha 615)

**Tempo Estimado:** 30 minutos  
**Risco:** Baixo  
**Benefício:** App compila (mas sem feature meals)

---

### Opção B: Implementar Feature `meals` Completa

**Objetivo:** Criar toda a feature do zero

#### Passos:

1. Criar entidade `Meal`
2. Criar repository
3. Criar use cases (17 arquivos)
4. Criar bloc
5. Criar API service
6. Criar widgets

**Tempo Estimado:** 8-12 horas  
**Risco:** Alto  
**Benefício:** Feature completa

---

### Opção C: Corrigir `feeding_logs` e Remover `meals` (Recomendado ⭐)

**Objetivo:** Focar no que existe e funciona

#### Passos:

**Fase 1: Remover `meals`** (mesma Opção A)

**Fase 2: Corrigir `feeding_logs`**

1. **Criar entidade `FeedingLog` correta**
   ```bash
   touch lib/features/feeding_logs/domain/entities/feeding_log.dart
   ```

2. **Atualizar todos os imports** (11 arquivos)
   ```dart
   // DE:
   import '.../meal.dart';
   // PARA:
   import '.../feeding_log.dart';
   ```

3. **Criar widgets faltando**
   ```bash
   touch lib/features/feeding_logs/presentation/widgets/feeding_log_card.dart
   touch lib/features/feeding_logs/presentation/widgets/feeding_log_form.dart
   ```

4. **Implementar método `getTodayFeedingLogs()` no repository**

5. **Renomear usecases confusos**
   - `complete_meal.dart` → `complete_feeding_log.dart`
   - `create_meal.dart` → `create_feeding_log.dart`
   - etc

**Tempo Estimado:** 2-3 horas  
**Risco:** Médio  
**Benefício:** Feature `feeding_logs` funcional + App compila

---

## 🎯 Recomendação Final

### ⭐ Seguir **Opção C**: Corrigir `feeding_logs` + Remover `meals`

**Justificativa:**

1. **Pragmático**
   - Remove bloqueio imediato (`meals`)
   - Corrige feature existente (`feeding_logs`)
   - App funciona no final

2. **Escopo Gerenciável**
   - ~3 horas de trabalho focado
   - Não precisa implementar feature inteira do zero
   - Aproveit código existente

3. **Alinhado com Objetivo Original**
   - Tarefa era: corrigir carregamento de informações da conta ✅ FEITO
   - Agora: fazer app rodar para testar
   - Não faz sentido gastar 12h implementando `meals`

4. **Minimiza Risco**
   - Não toca em código funcionando (`auth`)
   - Remove dependências quebradas
   - Foca em uma feature de cada vez

---

## 📋 Checklist de Execução (Opção C)

### Fase 1: Remover `meals` (30 min)

- [ ] Remover imports de `meals` em `main.dart`
- [ ] Remover registros de `MealsBloc` em `main.dart`
- [ ] Remover imports de `meals` em `injection_container.dart` (linhas 30-43)
- [ ] Remover registros de dependências de `meals` em `injection_container.dart` (linhas 92-196)
- [ ] Remover imports de `meals` em `home_page.dart` (linhas 9-11, 14-15)
- [ ] Comentar usos de `MealsBloc` em `home_page.dart`
- [ ] Comentar `FeedingBottomSheet` em `home_page.dart`
- [ ] Testar compilação

### Fase 2: Corrigir `feeding_logs` (2h)

- [ ] Criar `feeding_log.dart` entity com todos os tipos
- [ ] Atualizar 11 imports de `meal.dart` → `feeding_log.dart`
- [ ] Criar `feeding_log_card.dart` widget
- [ ] Criar `feeding_log_form.dart` widget  
- [ ] Implementar `getTodayFeedingLogs()` no repository
- [ ] Renomear usecases confusos (opcional)
- [ ] Testar compilação
- [ ] Executar app e verificar runtime

### Fase 3: Validação (30 min)

- [ ] `flutter analyze` deve passar
- [ ] `flutter run` deve compilar
- [ ] App deve abrir sem crash
- [ ] Feature `auth` deve continuar funcionando
- [ ] Navegar para páginas de `feeding_logs` e verificar

---

## 🚦 Semáforo de Decisão

| Opção | Tempo | Risco | Benefício | Recomendação |
|-------|-------|-------|-----------|--------------|
| A: Remover meals | 30 min | 🟢 Baixo | App compila (sem meals) | 🟡 OK |
| B: Implementar meals | 8-12h | 🔴 Alto | Feature completa | ❌ NÃO |
| C: Corrigir feeding_logs + Remover meals | 2-3h | 🟡 Médio | App funcional | ✅ **SIM** |

---

## 📝 Próximos Passos

1. ✅ **Aprovar plano** - Opção C recomendada
2. 🔄 **Executar Fase 1** - Remover `meals` (30 min)
3. 🔄 **Executar Fase 2** - Corrigir `feeding_logs` (2h)
4. 🔄 **Executar Fase 3** - Validação (30 min)
5. ✅ **App rodando** - Testar feature `auth`

**Tempo Total Estimado:** 3 horas  
**Resultado Esperado:** App compilando e rodando com feature `auth` 100% funcional

---

**Documentação gerada via Cursor AI**  
*Data: 12 de Outubro de 2025*  
*Método: Protocolo de Investigação Completo*  
*Evidências: 100% coletadas*

