# Resumo da Migração: Datasources e Repositories para API V2

**Data:** 28 de Dezembro de 2024  
**Status:** ✅ Implementado - Camada de Dados

---

## ✅ Fases Completas

### FASE 1: CatsRemoteDataSource Atualizado
**Arquivo:** `lib/features/cats/data/datasources/cats_remote_datasource.dart`

**Mudanças:**
- ✅ Removidos métodos obsoletos: `getCatById`, `updateCat`, `deleteCat`, `updateCatWeight`, `getCatsByHome`
- ✅ Atualizado `getCats()` para aceitar parâmetro opcional `householdId`
- ✅ Atualizado `createCat()` para usar `CreateCatRequestV2` com campos V2:
  - `homeId` → `householdId`
  - `imageUrl` → `photoUrl`
  - `birthDate` → `birthdate`
  - Adicionado suporte para `feedingInterval`

**Resultado:** Apenas 2 métodos V2 disponíveis: `getCats` e `createCat`

---

### FASE 2: CatsLocalDataSource Criado
**Arquivo:** `lib/features/cats/data/datasources/cats_local_datasource.dart`

**Implementação:**
- ✅ Cache em memória usando `Map<String, Cat>`
- ✅ Métodos: `cacheCats()`, `getCachedCats()`, `getCachedCat()`, `cacheCat()`, `clearCache()`
- ✅ Usado para substituir `getCatById()` da API (endpoint removido na V2)

---

### FASE 3: FeedingLogsRemoteDataSource Atualizado
**Arquivo:** `lib/features/feeding_logs/data/datasources/feeding_logs_remote_datasource.dart`

**Mudanças:**
- ✅ Removidos métodos obsoletos: `updateFeedingLog()`, `getLastFeeding()`
- ✅ Atualizado `createFeedingLog()` já usa formato V2 correto
- ✅ Mantidos apenas métodos V2: `getFeedingLogs()`, `getFeedingLogById()`, `createFeedingLog()`, `deleteFeedingLog()`

---

### FASE 4: WeightLogsRemoteDataSource Criado
**Arquivo:** `lib/features/cats/data/datasources/weight_logs_remote_datasource.dart`

**Implementação:**
- ✅ Interface completa: `getWeightLogs()`, `createWeightLog()`, `updateWeightLog()`, `deleteWeightLog()`
- ✅ Usa `WeightLogsApiService` V2
- ✅ Substitui `updateCatWeight()` que estava em `CatsRemoteDataSource`

---

### FASE 5: Repositories Atualizados
**Arquivos:**
- `lib/features/cats/domain/repositories/cats_repository.dart`
- `lib/features/cats/data/repositories/cats_repository_impl.dart`
- `lib/features/feeding_logs/domain/repositories/feeding_logs_repository.dart`
- `lib/features/feeding_logs/data/repositories/feeding_logs_repository_impl.dart`

**Mudanças:**
- ✅ **CatsRepository**: Removidos métodos `updateCat`, `deleteCat`, `updateCatWeight`, `getCatsByHome`
- ✅ **CatsRepository**: `getCatById()` agora retorna `Cat?` e usa cache local
- ✅ **CatsRepositoryImpl**: Adicionado `CatsLocalDataSource` como dependência
- ✅ **FeedingLogsRepository**: Removidos métodos `updateFeedingLog`, `getLastFeeding`
- ✅ Implementações atualizadas para chamar apenas datasources V2

---

### FASE 6: Dependency Injection Atualizado
**Arquivo:** `lib/core/di/injection_container.dart`

**Mudanças:**
- ✅ Registrado `CatsLocalDataSource`
- ✅ Registrado `WeightLogsRemoteDataSource`
- ✅ Atualizado registro de `CatsRepository` para injetar ambos `remoteDataSource` e `localDataSource`

---

### FASE 7: Código Deprecated Removido
**Arquivo:** `lib/services/api/cats_api_service.dart`

**Mudanças:**
- ✅ Removidas classes V1: `CreateCatRequest`, `UpdateCatRequest`, `AddWeightEntryRequest`, `UpdateWeightEntryRequest`, `UpdateCatWeightRequest`
- ✅ Mantida apenas `CreateCatRequestV2`

---

## ⚠️ Pendências - Camada de Apresentação

### Use Cases que Precisam Ser Removidos ou Adaptados

**Arquivos afetados:**
- `lib/features/cats/domain/usecases/update_cat.dart` - Método não existe mais no repository
- `lib/features/cats/domain/usecases/delete_cat.dart` - Método não existe mais no repository
- `lib/features/cats/domain/usecases/update_cat_weight.dart` - Deve usar `WeightLogsRepository` em vez de `CatsRepository`

**Registros no `injection_container.dart`:**
```dart
// LINHAS 186-188
sl.registerLazySingleton(() => UpdateCat(sl()));      // ❌ Remover
sl.registerLazySingleton(() => DeleteCat(sl()));      // ❌ Remover
sl.registerLazySingleton(() => UpdateCatWeight(sl())); // ❌ Remover ou modificar
```

### BLoC e Events que Precisam Ser Ajustados

**Arquivo:** `lib/features/cats/presentation/bloc/cats_bloc.dart`

**Linhas afetadas:**
- 21-23: Use cases removidos
- 37-39: Handlers removidos
- 122-208: Métodos `_onUpdateCat`, `_onDeleteCat`, `_onUpdateCatWeight` não funcionam mais

**Arquivo:** `lib/features/cats/presentation/bloc/cats_event.dart`

**Eventos:**
- `UpdateCat` event (linhas 42-49)
- `DeleteCat` event (linhas 51-57)
- `UpdateCatWeight` event (linhas 60-65)

### Páginas UI que Precisam Ser Atualizadas

**Arquivos:**
- `lib/features/cats/presentation/pages/edit_cat_page.dart` - Usa `UpdateCat` event
- `lib/features/cats/presentation/pages/cat_detail_page.dart` - Usa `UpdateCatWeight` e `DeleteCat` events
- `lib/features/cats/presentation/pages/cats_list_page.dart` - Usa `DeleteCat` event
- `lib/features/homes/presentation/pages/home_detail_page.dart` - Usa `DeleteCat` event

---

## 📊 Estatísticas da Migração

### Arquivos Modificados
- ✅ 6 arquivos atualizados
- ✅ 2 arquivos criados (novos datasources)
- ⚠️ 10+ arquivos da camada de apresentação precisam de atualização

### Métodos Removidos/Substituídos
- **CatsDataSource**: 6 métodos removidos → 2 métodos V2 mantidos
- **FeedingLogsDataSource**: 2 métodos removidos → 4 métodos V2 mantidos
- **WeightLogsDataSource**: Criado do zero com 4 métodos V2

### Código Deprecated Removido
- **5 classes V1** removidas do `cats_api_service.dart`
- **1 comentário TODO** removido

---

## 🎯 Próximos Passos Sugeridos

### 1. Criar WeightLogsRepository e Use Cases
```dart
// lib/features/cats/domain/repositories/weight_logs_repository.dart
abstract class WeightLogsRepository {
  Future<Either<Failure, List<WeightEntry>>> getWeightLogs({String? catId});
  Future<Either<Failure, WeightEntry>> createWeightLog(...);
  // ...
}
```

### 2. Adaptar UpdateCatWeight Use Case
```dart
// Mudar para usar WeightLogsRepository ao invés de CatsRepository
class UpdateCatWeight {
  final WeightLogsRepository weightLogsRepository;
  // ...
}
```

### 3. Remover ou Comentar Use Cases Obsoletos
- Remover `UpdateCat` use case (endpoint não existe na V2)
- Remover `DeleteCat` use case (endpoint não existe na V2)
- Atualizar registros no `injection_container.dart`

### 4. Atualizar BLoC
- Remover handlers para eventos obsoletos
- Remover propriedades de use cases obsoletos
- Ajustar factory do BLoC

### 5. Adaptar UI
- Remover ou desabilitar botões de edição/deleção de gatos
- Atualizar próprio `UpdateCatWeight` para chamar novo use case
- Adicionar UI para gerenciar weight logs

---

## ✅ Validação

### Sem Erros de Lint
```bash
flutter analyze lib/features/cats/data
flutter analyze lib/features/feeding_logs/data
flutter analyze lib/core/di
```
**Resultado:** ✅ 0 erros encontrados

### Backwards Compatibility
- ⚠️ API V2 endpoints requerem ajustes na camada de apresentação
- ✅ Camada de dados completamente migrada para V2
- ✅ Código V1 deprecated removido dos datasources/repositories

---

## 📝 Notas Importantes

1. **Cache Local**: `CatsLocalDataSource` armazena gatos em memória após buscar. Considerar usar Hive ou outro storage persistente para produção.

2. **Weight Logs**: Funcionalidade separada em seu próprio datasource, seguindo princípio de responsabilidade única.

3. **Faltam Endpoints V2**: A API V2 não oferece UPDATE/DELETE para Cats. A aplicação precisa se adaptar para trabalhar sem essas operações ou implementá-las via outros meios.

4. **Feeding Logs**: API V2 não suporta UPDATE de feeding logs - apenas CREATE e DELETE. UI deve refletir isso.

---

**Status Final:** Camada de dados (datasources e repositories) 100% migrada para API V2 ✅

---

## Correções Finais Aplicadas

### Imports Corrigidos
- ✅ Removido import não usado em `cats_local_datasource.dart`
- ✅ Adicionado `ApiConstants` import em `feeding_logs_api_service.dart`
- ✅ Removidos imports não usados em `injection_container.dart`

### API Service Ajustado
- ✅ Removido endpoint `getCatNextFeeding` de `cats_api_service.dart` (não está na V2)
- ✅ Corrigido `feeding_logs_remote_datasource.dart` para usar parâmetros corretos da API
- ✅ Removido import não usado `weight_entry_model.dart` de `cats_api_service.dart`

### Build Runner
- ✅ Executado `build_runner` para regenerar arquivos `.g.dart`
- ✅ 27 arquivos gerados com sucesso

---

## Checklist Final ✅

- [x] FASE 1: Remover métodos obsoletos de CatsDataSource
- [x] FASE 1: Atualizar createCat para usar CreateCatRequestV2
- [x] FASE 2: Criar CatsLocalDataSource para cache
- [x] FASE 3: Remover métodos obsoletos de FeedingLogsDataSource
- [x] FASE 4: Atualizar interfaces de repositories
- [x] FASE 4: Atualizar implementações de repositories
- [x] FASE 5: Ajustar CatModel para alinhamento V2 (já estava correto)
- [x] FASE 6: Criar WeightLogsDataSource completo
- [x] FASE 7: Atualizar dependency injection
- [x] FASE 8: Remover classes V1 deprecated
- [x] FASE 9: Corrigir imports e builds
- [x] FASE 9: Verificar remoção completa de endpoints V1 da camada de dados

**Implementação 100% completa para a camada de dados!** 🎉

