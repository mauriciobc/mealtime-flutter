# 🔧 Plano Detalhado de Refatoração: Households API

**Data:** 11 de Outubro de 2025  
**Objetivo:** Alcançar 100% de compatibilidade com a API  
**Tempo Estimado Total:** 3-4 horas  
**Complexidade:** Média

---

## 📋 Índice

1. [Análise de Impacto](#análise-de-impacto)
2. [Estratégia de Refatoração](#estratégia-de-refatoração)
3. [Plano Detalhado Passo a Passo](#plano-detalhado-passo-a-passo)
4. [Código Completo dos Novos Modelos](#código-completo-dos-novos-modelos)
5. [Migrações Necessárias](#migrações-necessárias)
6. [Testes de Validação](#testes-de-validação)
7. [Rollback Plan](#rollback-plan)

---

## 📊 Análise de Impacto

### Arquivos que SERÃO Modificados

| Arquivo | Tipo de Mudança | Impacto | Tempo |
|---------|----------------|---------|-------|
| `home_model.dart` | Refatoração completa | 🔴 Alto | 30 min |
| `homes_api_service.dart` | Atualização de endpoints | 🔴 Alto | 20 min |
| `api_constants.dart` | Atualização de constantes | 🟡 Médio | 5 min |
| `homes_remote_datasource.dart` | Atualização de métodos | 🟡 Médio | 15 min |
| `homes_repository_impl.dart` | Pequenos ajustes | 🟢 Baixo | 10 min |
| `home.dart` (entity) | Decisão estratégica | 🟡 Médio | 15 min |
| `homes_bloc.dart` | Possíveis ajustes | 🟢 Baixo | 10 min |

### Arquivos que serão CRIADOS

- `household_model.dart` - Novo modelo compatível com API
- `household_model.g.dart` - Gerado automaticamente
- `household_owner_model.dart` - Modelo do proprietário
- `household_member_model.dart` - Modelo de membros

### Arquivos UI Potencialmente Afetados

- Formulários de criação/edição de homes
- Telas que exibem informações de homes
- Validações de campos

---

## 🎯 Estratégia de Refatoração

### Abordagem Escolhida: **Refatoração Incremental Segura**

**Por quê?**
- ✅ Minimiza riscos de quebrar a aplicação
- ✅ Permite testes incrementais
- ✅ Facilita rollback se necessário
- ✅ Mantém app funcional durante refatoração

### Fases da Refatoração

```
Fase 1: Preparação (30 min)
  ├─ Criar branch de refatoração
  ├─ Backup do código atual
  └─ Documentar estado atual

Fase 2: Novos Modelos (45 min)
  ├─ Criar HouseholdModel
  ├─ Criar modelos auxiliares
  └─ Gerar código com build_runner

Fase 3: Atualizar API Layer (30 min)
  ├─ Atualizar API Service
  ├─ Atualizar constantes
  └─ Atualizar DataSource

Fase 4: Atualizar Camada de Domínio (30 min)
  ├─ Decisão sobre entity Home
  ├─ Atualizar Repository
  └─ Atualizar UseCases (se necessário)

Fase 5: Atualizar Presentation (30 min)
  ├─ Ajustar BLoC/State
  ├─ Remover campos não suportados da UI
  └─ Atualizar validações

Fase 6: Testes e Validação (30 min)
  ├─ Testes unitários
  ├─ Testes de integração
  └─ Testes manuais
```

---

## 📝 Plano Detalhado Passo a Passo

### FASE 1: Preparação (30 minutos)

#### Passo 1.1: Criar Branch de Refatoração

```bash
cd /home/mauriciobc/Documentos/Code/mealtime-flutter/mealtime_app
git checkout -b refactor/households-api-compatibility
git status
```

**Verificação:** Branch criada com sucesso ✓

---

#### Passo 1.2: Backup dos Arquivos Atuais

```bash
# Criar pasta de backup
mkdir -p backup/households_refactor_$(date +%Y%m%d)

# Copiar arquivos que serão modificados
cp lib/features/homes/data/models/home_model.dart backup/households_refactor_$(date +%Y%m%d)/
cp lib/services/api/homes_api_service.dart backup/households_refactor_$(date +%Y%m%d)/
cp lib/core/constants/api_constants.dart backup/households_refactor_$(date +%Y%m%d)/
```

**Verificação:** Backup criado com sucesso ✓

---

#### Passo 1.3: Documentar Estado Atual

```bash
# Salvar lista de dependências atuais
flutter pub deps > backup/households_refactor_$(date +%Y%m%d)/dependencies.txt

# Rodar testes atuais para ter baseline
flutter test > backup/households_refactor_$(date +%Y%m%d)/tests_before.txt
```

**Verificação:** Documentação salva ✓

---

### FASE 2: Criar Novos Modelos (45 minutos)

#### Passo 2.1: Criar HouseholdModel Principal

**Arquivo:** `lib/features/homes/data/models/household_model.dart`

**Ação:** Criar arquivo com o seguinte conteúdo:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';

part 'household_model.g.dart';

/// Modelo de dados para Household (Casa/Domicílio)
/// Compatível com a API real em /households
@JsonSerializable(explicitToJson: true)
class HouseholdModel {
  /// ID único do household
  final String id;
  
  /// Nome do household
  final String name;
  
  /// Descrição (opcional, pode retornar null da API)
  final String? description;
  
  /// ID do proprietário do household
  /// IMPORTANTE: API usa 'owner_id', não 'user_id'
  @JsonKey(name: 'owner_id')
  final String ownerId;
  
  /// Data de criação
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  /// Data de última atualização
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  
  /// Informações do proprietário (opcional)
  final HouseholdOwner? owner;
  
  /// Lista de membros (formato POST/simplificado)
  final List<HouseholdMember>? members;
  
  /// Lista de membros (formato GET/detalhado)
  @JsonKey(name: 'household_members')
  final List<HouseholdMemberDetailed>? householdMembers;
  
  /// Código de convite (apenas no GET)
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

  /// Cria HouseholdModel a partir de JSON da API
  factory HouseholdModel.fromJson(Map<String, dynamic> json) => 
    _$HouseholdModelFromJson(json);
  
  /// Converte HouseholdModel para JSON
  Map<String, dynamic> toJson() => _$HouseholdModelToJson(this);

  /// Converte para entidade de domínio
  Home toEntity() {
    return Home(
      id: id,
      name: name,
      address: null, // API não suporta address
      description: description,
      userId: ownerId, // Mapear ownerId para userId na entidade
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: true, // Valor padrão, API não retorna
    );
  }

  /// Cria HouseholdModel a partir de entidade
  factory HouseholdModel.fromEntity(Home home) {
    return HouseholdModel(
      id: home.id,
      name: home.name,
      description: home.description,
      ownerId: home.userId,
      createdAt: home.createdAt,
      updatedAt: home.updatedAt,
    );
  }

  /// Copia o modelo com novos valores
  HouseholdModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    HouseholdOwner? owner,
    List<HouseholdMember>? members,
    List<HouseholdMemberDetailed>? householdMembers,
    String? inviteCode,
  }) {
    return HouseholdModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      owner: owner ?? this.owner,
      members: members ?? this.members,
      householdMembers: householdMembers ?? this.householdMembers,
      inviteCode: inviteCode ?? this.inviteCode,
    );
  }
}

/// Modelo do proprietário do household
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

/// Modelo de membro do household (formato simplificado - POST)
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

/// Modelo de membro do household (formato detalhado - GET)
@JsonSerializable(explicitToJson: true)
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

/// Modelo de usuário dentro de household member
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

**Verificação:** Arquivo criado sem erros de sintaxe ✓

---

#### Passo 2.2: Gerar Código com build_runner

```bash
# Navegar para o diretório do projeto
cd /home/mauriciobc/Documentos/Code/mealtime-flutter/mealtime_app

# Gerar código
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar se o arquivo foi gerado
ls -la lib/features/homes/data/models/household_model.g.dart
```

**Verificação:** Arquivo `.g.dart` gerado com sucesso ✓

**Troubleshooting:** Se houver erros:
- Verificar que todas as dependências estão no `pubspec.yaml`
- Verificar que não há erros de sintaxe no modelo
- Executar `flutter pub get` antes do build_runner

---

### FASE 3: Atualizar API Layer (30 minutos)

#### Passo 3.1: Atualizar API Constants

**Arquivo:** `lib/core/constants/api_constants.dart`

**Ação:** Encontrar e substituir:

```dart
// ❌ REMOVER esta linha:
static const String homes = '/homes';

// ✅ ADICIONAR esta linha:
static const String households = '/households';

// ✅ ATUALIZAR métodos relacionados:
static String homeById(String id) => '/households/$id'; // Mudou de /homes/
static String homeCats(String homeId) => '/households/$homeId/cats';
```

**Mudanças específicas:**

```dart
class ApiConstants {
  // ... outras constantes ...
  
  // Households endpoints (ATUALIZADO)
  static const String households = '/households';  // ← NOVO
  static String householdById(String id) => '/households/$id';  // ← ATUALIZADO
  static String householdCats(String householdId) => '/households/$householdId/cats';  // ← ATUALIZADO
  
  // ... resto do código ...
}
```

**Verificação:** 
- [ ] Constante `households` criada
- [ ] Todas as referências a `/homes` foram mudadas para `/households`
- [ ] Código compila sem erros

---

#### Passo 3.2: Atualizar API Service

**Arquivo:** `lib/services/api/homes_api_service.dart`

**Ação:** Refatorar completamente para usar novos endpoints e modelo

```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:mealtime_app/core/models/api_response.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart'; // ← NOVO IMPORT

part 'homes_api_service.g.dart';

@RestApi()
abstract class HomesApiService {
  factory HomesApiService(Dio dio, {String baseUrl}) = _HomesApiService;

  /// Lista todos os households do usuário
  /// Endpoint: GET /households
  @GET('/households')  // ← MUDOU DE /homes
  Future<ApiResponse<List<HouseholdModel>>> getHouseholds();  // ← MUDOU NOME E TIPO

  /// Cria um novo household
  /// Endpoint: POST /households
  /// 
  /// Campos aceitos pela API:
  /// - name (obrigatório)
  /// - description (opcional, mas pode retornar null)
  /// 
  /// Campos NÃO suportados:
  /// - address (será ignorado)
  /// - is_active (será ignorado)
  @POST('/households')  // ← MUDOU DE /homes
  Future<ApiResponse<HouseholdModel>> createHousehold({
    @Field('name') required String name,
    @Field('description') String? description,
    // ❌ REMOVIDO: @Field('address') String? address,
    // ❌ REMOVIDO: @Field('is_active') bool? isActive,
  });

  /// Atualiza um household existente
  /// Endpoint: PUT /households/{id}
  @PUT('/households/{id}')  // ← MUDOU DE /homes/{id}
  Future<ApiResponse<HouseholdModel>> updateHousehold({
    @Path('id') required String id,
    @Field('name') required String name,
    @Field('description') String? description,
    // ❌ REMOVIDO: @Field('address') String? address,
  });

  /// Deleta um household
  /// Endpoint: DELETE /households/{id}
  @DELETE('/households/{id}')  // ← MUDOU DE /homes/{id}
  Future<ApiResponse<EmptyResponse>> deleteHousehold(@Path('id') String id);

  /// Define household como ativo
  /// Endpoint: POST /households/{id}/set-active
  @POST('/households/{id}/set-active')  // ← MUDOU DE /homes/{id}/set-active
  Future<ApiResponse<EmptyResponse>> setActiveHousehold(@Path('id') String id);
}

/// Classe para respostas vazias da API
class EmptyResponse {
  const EmptyResponse();
  
  factory EmptyResponse.fromJson(Map<String, dynamic> json) => const EmptyResponse();
  
  Map<String, dynamic> toJson() => {};
}
```

**Verificação:**
- [ ] Todos os endpoints mudaram de `/homes` para `/households`
- [ ] Campo `address` removido
- [ ] Tipo de retorno mudou para `HouseholdModel`
- [ ] Comentários documentando mudanças

---

#### Passo 3.3: Regenerar API Service

```bash
cd /home/mauriciobc/Documentos/Code/mealtime-flutter/mealtime_app

# Regenerar código do Retrofit
flutter pub run build_runner build --delete-conflicting-outputs

# Verificar arquivo gerado
ls -la lib/services/api/homes_api_service.g.dart
```

**Verificação:** Arquivo regenerado com sucesso ✓

---

#### Passo 3.4: Atualizar Remote DataSource

**Arquivo:** `lib/features/homes/data/datasources/homes_remote_datasource.dart`

**Ação:** Atualizar tipos e chamadas de API

```dart
import 'package:mealtime_app/core/errors/exceptions.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';  // ← MUDOU
import 'package:mealtime_app/services/api/homes_api_service.dart';

abstract class HomesRemoteDataSource {
  Future<List<HouseholdModel>> getHomes();  // ← MUDOU TIPO
  Future<HouseholdModel> createHome({  // ← MUDOU TIPO
    required String name,
    String? description,  // ← address REMOVIDO
  });
  Future<HouseholdModel> updateHome({  // ← MUDOU TIPO
    required String id,
    required String name,
    String? description,  // ← address REMOVIDO
  });
  Future<void> deleteHome(String id);
  Future<void> setActiveHome(String id);
}

class HomesRemoteDataSourceImpl implements HomesRemoteDataSource {
  final HomesApiService apiService;

  HomesRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<HouseholdModel>> getHomes() async {  // ← MUDOU TIPO
    try {
      // Mudou de getHomes() para getHouseholds()
      final apiResponse = await apiService.getHouseholds();  // ← MUDOU
      
      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao buscar residências'
        );
      }
      
      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao buscar residências: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> createHome({  // ← MUDOU TIPO
    required String name,
    String? description,  // ← address REMOVIDO
  }) async {
    try {
      // Mudou de createHome() para createHousehold()
      final apiResponse = await apiService.createHousehold(  // ← MUDOU
        name: name,
        description: description,
        // ❌ address REMOVIDO
      );
      
      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao criar residência'
        );
      }
      
      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao criar residência: ${e.toString()}');
    }
  }

  @override
  Future<HouseholdModel> updateHome({  // ← MUDOU TIPO
    required String id,
    required String name,
    String? description,  // ← address REMOVIDO
  }) async {
    try {
      // Mudou de updateHome() para updateHousehold()
      final apiResponse = await apiService.updateHousehold(  // ← MUDOU
        id: id,
        name: name,
        description: description,
        // ❌ address REMOVIDO
      );
      
      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao atualizar residência'
        );
      }
      
      return apiResponse.data!;
    } catch (e) {
      throw ServerException('Erro ao atualizar residência: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHome(String id) async {
    try {
      // Mudou de deleteHome() para deleteHousehold()
      final apiResponse = await apiService.deleteHousehold(id);  // ← MUDOU
      
      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao excluir residência'
        );
      }
    } catch (e) {
      throw ServerException('Erro ao excluir residência: ${e.toString()}');
    }
  }

  @override
  Future<void> setActiveHome(String id) async {
    try {
      // Mudou de setActiveHome() para setActiveHousehold()
      final apiResponse = await apiService.setActiveHousehold(id);  // ← MUDOU
      
      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.error ?? 'Erro desconhecido ao definir residência ativa'
        );
      }
    } catch (e) {
      throw ServerException(
        'Erro ao definir residência ativa: ${e.toString()}'
      );
    }
  }
}
```

**Verificação:**
- [ ] Todos os tipos mudaram para `HouseholdModel`
- [ ] Parâmetro `address` removido
- [ ] Chamadas de API atualizadas

---

### FASE 4: Atualizar Repository (20 minutos)

#### Passo 4.1: Atualizar Repository Implementation

**Arquivo:** `lib/features/homes/data/repositories/homes_repository_impl.dart`

**Ação:** Atualizar tipos retornados

```dart
import 'package:mealtime_app/features/homes/data/datasources/homes_remote_datasource.dart';
import 'package:mealtime_app/features/homes/data/datasources/homes_local_datasource.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class HomesRepositoryImpl implements HomesRepository {
  final HomesRemoteDataSource remoteDataSource;
  final HomesLocalDataSource localDataSource;

  HomesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Home>> getHomes() async {
    try {
      // homeModels agora é List<HouseholdModel>
      final homeModels = await remoteDataSource.getHomes();
      final homes = homeModels.map((model) => model.toEntity()).toList();
      await localDataSource.cacheHomes(homes);
      return homes;
    } catch (e) {
      // Fallback para dados locais em caso de erro
      return await localDataSource.getCachedHomes();
    }
  }

  @override
  Future<Home> createHome({
    required String name,
    String? description,  // ← address REMOVIDO
  }) async {
    // homeModel agora é HouseholdModel
    final homeModel = await remoteDataSource.createHome(
      name: name,
      description: description,
      // ❌ address REMOVIDO
    );
    final home = homeModel.toEntity();
    await localDataSource.cacheHome(home);
    return home;
  }

  @override
  Future<Home> updateHome({
    required String id,
    required String name,
    String? description,  // ← address REMOVIDO
  }) async {
    // homeModel agora é HouseholdModel
    final homeModel = await remoteDataSource.updateHome(
      id: id,
      name: name,
      description: description,
      // ❌ address REMOVIDO
    );
    final home = homeModel.toEntity();
    await localDataSource.cacheHome(home);
    return home;
  }

  @override
  Future<void> deleteHome(String id) async {
    await remoteDataSource.deleteHome(id);
    await localDataSource.removeCachedHome(id);
  }

  @override
  Future<void> setActiveHome(String id) async {
    await remoteDataSource.setActiveHome(id);
    await localDataSource.setActiveHome(id);
  }

  @override
  Future<Home?> getActiveHome() async {
    return await localDataSource.getActiveHome();
  }
}
```

**Verificação:**
- [ ] Comentários indicam mudanças de tipo
- [ ] Parâmetro `address` removido
- [ ] Código compila sem erros

---

#### Passo 4.2: Atualizar Domain Repository Interface

**Arquivo:** `lib/features/homes/domain/repositories/homes_repository.dart`

**Ação:** Remover parâmetro `address` das assinaturas

```dart
import 'package:mealtime_app/features/homes/domain/entities/home.dart';

abstract class HomesRepository {
  Future<List<Home>> getHomes();
  
  Future<Home> createHome({
    required String name,
    String? description,  // ← address REMOVIDO
  });
  
  Future<Home> updateHome({
    required String id,
    required String name,
    String? description,  // ← address REMOVIDO
  });
  
  Future<void> deleteHome(String id);
  Future<void> setActiveHome(String id);
  Future<Home?> getActiveHome();
}
```

**Verificação:**
- [ ] Parâmetro `address` removido
- [ ] Interface atualizada

---

### FASE 5: Atualizar UseCases (15 minutos)

#### Passo 5.1: Atualizar CreateHome UseCase

**Arquivo:** `lib/features/homes/domain/usecases/create_home.dart`

**Ação:** Remover parâmetro `address`

```dart
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class CreateHome implements UseCase<Home, CreateHomeParams> {
  final HomesRepository repository;

  CreateHome(this.repository);

  @override
  Future<Home> call(CreateHomeParams params) async {
    return await repository.createHome(
      name: params.name,
      description: params.description,
      // ❌ address REMOVIDO
    );
  }
}

class CreateHomeParams {
  final String name;
  final String? description;  // ← address REMOVIDO

  const CreateHomeParams({
    required this.name,
    this.description,  // ← address REMOVIDO
  });
}
```

**Verificação:**
- [ ] Parâmetro `address` removido de `CreateHomeParams`
- [ ] Chamada ao repository atualizada

---

#### Passo 5.2: Atualizar UpdateHome UseCase

**Arquivo:** `lib/features/homes/domain/usecases/update_home.dart`

**Ação:** Remover parâmetro `address`

```dart
import 'package:mealtime_app/core/usecases/usecase.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';
import 'package:mealtime_app/features/homes/domain/repositories/homes_repository.dart';

class UpdateHome implements UseCase<Home, UpdateHomeParams> {
  final HomesRepository repository;

  UpdateHome(this.repository);

  @override
  Future<Home> call(UpdateHomeParams params) async {
    return await repository.updateHome(
      id: params.id,
      name: params.name,
      description: params.description,
      // ❌ address REMOVIDO
    );
  }
}

class UpdateHomeParams {
  final String id;
  final String name;
  final String? description;  // ← address REMOVIDO

  const UpdateHomeParams({
    required this.id,
    required this.name,
    this.description,  // ← address REMOVIDO
  });
}
```

**Verificação:**
- [ ] Parâmetro `address` removido
- [ ] UseCase atualizado

---

### FASE 6: Atualizar Presentation Layer (30 minutos)

#### Passo 6.1: Atualizar BLoC Events

**Arquivo:** `lib/features/homes/presentation/bloc/homes_event.dart`

**Ação:** Remover `address` dos eventos

```dart
import 'package:equatable/equatable.dart';

abstract class HomesEvent extends Equatable {
  const HomesEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomes extends HomesEvent {}

class CreateHomeEvent extends HomesEvent {
  final String name;
  final String? description;  // ← address REMOVIDO

  const CreateHomeEvent({
    required this.name,
    this.description,  // ← address REMOVIDO
  });

  @override
  List<Object?> get props => [name, description];  // ← address REMOVIDO
}

class UpdateHomeEvent extends HomesEvent {
  final String id;
  final String name;
  final String? description;  // ← address REMOVIDO

  const UpdateHomeEvent({
    required this.id,
    required this.name,
    this.description,  // ← address REMOVIDO
  });

  @override
  List<Object?> get props => [id, name, description];  // ← address REMOVIDO
}

class DeleteHomeEvent extends HomesEvent {
  final String id;

  const DeleteHomeEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SetActiveHomeEvent extends HomesEvent {
  final String id;

  const SetActiveHomeEvent(this.id);

  @override
  List<Object?> get props => [id];
}
```

**Verificação:**
- [ ] Campo `address` removido de eventos
- [ ] Props atualizadas

---

#### Passo 6.2: Atualizar BLoC

**Arquivo:** `lib/features/homes/presentation/bloc/homes_bloc.dart`

**Ação:** Atualizar handlers de eventos

```dart
// ... imports ...

class HomesBloc extends Bloc<HomesEvent, HomesState> {
  // ... construtor e dependências ...

  void _onCreateHome(CreateHomeEvent event, Emitter<HomesState> emit) async {
    emit(HomesLoading());
    try {
      final home = await createHomeUseCase(
        CreateHomeParams(
          name: event.name,
          description: event.description,
          // ❌ address REMOVIDO
        ),
      );
      
      emit(HomeCreated(home));
      add(LoadHomes()); // Recarregar lista
    } catch (e) {
      emit(HomesError(e.toString()));
    }
  }

  void _onUpdateHome(UpdateHomeEvent event, Emitter<HomesState> emit) async {
    emit(HomesLoading());
    try {
      final home = await updateHomeUseCase(
        UpdateHomeParams(
          id: event.id,
          name: event.name,
          description: event.description,
          // ❌ address REMOVIDO
        ),
      );
      
      emit(HomeUpdated(home));
      add(LoadHomes()); // Recarregar lista
    } catch (e) {
      emit(HomesError(e.toString()));
    }
  }

  // ... resto dos handlers ...
}
```

**Verificação:**
- [ ] Chamadas aos UseCases sem `address`
- [ ] BLoC compila sem erros

---

#### Passo 6.3: Atualizar Formulários UI

**Arquivos afetados:**
- `lib/features/homes/presentation/pages/create_home_page.dart`
- `lib/features/homes/presentation/pages/edit_home_page.dart`
- `lib/features/homes/presentation/widgets/home_form.dart`

**Ação:** Remover campo de endereço dos formulários

**Exemplo para `home_form.dart`:**

```dart
class HomeForm extends StatefulWidget {
  final Home? home;
  final Function(String name, String? description) onSubmit;  // ← address REMOVIDO

  const HomeForm({
    Key? key,
    this.home,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<HomeForm> createState() => _HomeFormState();
}

class _HomeFormState extends State<HomeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  // ❌ REMOVIDO: late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.home?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.home?.description ?? ''
    );
    // ❌ REMOVIDO: _addressController = TextEditingController(
    //   text: widget.home?.address ?? ''
    // );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    // ❌ REMOVIDO: _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo Nome
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da Casa',
              hintText: 'Ex: Minha Casa',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nome é obrigatório';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Campo Descrição
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição (opcional)',
              hintText: 'Ex: Casa principal',
            ),
            maxLines: 3,
          ),
          
          // ❌ CAMPO ENDEREÇO REMOVIDO
          // const SizedBox(height: 16),
          // TextFormField(
          //   controller: _addressController,
          //   decoration: const InputDecoration(
          //     labelText: 'Endereço',
          //     hintText: 'Rua, número...',
          //   ),
          // ),
          
          const SizedBox(height: 24),
          
          // Botão Salvar
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit(
                  _nameController.text,
                  _descriptionController.text.isEmpty 
                    ? null 
                    : _descriptionController.text,
                  // ❌ address REMOVIDO
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
```

**Verificação:**
- [ ] Campo de endereço removido da UI
- [ ] Controllers de endereço removidos
- [ ] Função onSubmit atualizada
- [ ] Formulário compila e funciona

---

### FASE 7: Adicionar Header x-user-id (20 minutos)

#### Passo 7.1: Atualizar Dio Interceptor

**Arquivo:** `lib/core/network/auth_interceptor.dart`

**Ação:** Adicionar header `x-user-id` automaticamente

```dart
import 'package:dio/dio.dart';
import 'package:mealtime_app/core/network/token_manager.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager tokenManager;

  AuthInterceptor({required this.tokenManager});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Obter token
    final token = await tokenManager.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // ✅ NOVO: Adicionar x-user-id
    final userId = await tokenManager.getUserId();
    if (userId != null) {
      options.headers['x-user-id'] = userId;
    }

    handler.next(options);
  }

  // ... resto do código ...
}
```

**Verificação:**
- [ ] Header `x-user-id` adicionado automaticamente
- [ ] TokenManager tem método `getUserId()`

---

#### Passo 7.2: Adicionar getUserId ao TokenManager (se não existir)

**Arquivo:** `lib/core/network/token_manager.dart`

**Ação:** Adicionar método para extrair userId do token

```dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _tokenKey = 'auth_token';
  final FlutterSecureStorage _secureStorage;

  TokenManager({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// ✅ NOVO: Extrai userId do token JWT
  Future<String?> getUserId() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      // Decodificar JWT
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Payload é a segunda parte
      final payload = parts[1];
      
      // Normalizar base64
      var normalized = base64.normalize(payload);
      
      // Decodificar
      final decoded = utf8.decode(base64.decode(normalized));
      final payloadMap = json.decode(decoded) as Map<String, dynamic>;

      // Extrair sub (subject) que é o userId
      return payloadMap['sub'] as String?;
    } catch (e) {
      print('Erro ao extrair userId do token: $e');
      return null;
    }
  }
}
```

**Verificação:**
- [ ] Método `getUserId()` criado
- [ ] Decodifica JWT corretamente
- [ ] Retorna userId do campo `sub`

---

### FASE 8: Testes (30 minutos)

#### Passo 8.1: Criar Testes Unitários para HouseholdModel

**Criar arquivo:** `test/features/homes/data/models/household_model_test.dart`

```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';

void main() {
  group('HouseholdModel', () {
    const tHouseholdModel = HouseholdModel(
      id: '123',
      name: 'Casa Teste',
      description: 'Descrição teste',
      ownerId: 'user-123',
      createdAt: DateTime(2025, 10, 11),
      updatedAt: DateTime(2025, 10, 11),
    );

    test('deve deserializar JSON da API corretamente', () {
      // Arrange
      final jsonMap = {
        'id': '123',
        'name': 'Casa Teste',
        'description': 'Descrição teste',
        'owner_id': 'user-123',
        'created_at': '2025-10-11T00:00:00.000Z',
        'updated_at': '2025-10-11T00:00:00.000Z',
      };

      // Act
      final result = HouseholdModel.fromJson(jsonMap);

      // Assert
      expect(result.id, '123');
      expect(result.name, 'Casa Teste');
      expect(result.ownerId, 'user-123');
    });

    test('deve serializar para JSON corretamente', () {
      // Act
      final result = tHouseholdModel.toJson();

      // Assert
      expect(result['id'], '123');
      expect(result['name'], 'Casa Teste');
      expect(result['owner_id'], 'user-123');
    });

    test('deve converter para entidade Home corretamente', () {
      // Act
      final result = tHouseholdModel.toEntity();

      // Assert
      expect(result.id, '123');
      expect(result.name, 'Casa Teste');
      expect(result.userId, 'user-123'); // ownerId → userId
    });

    test('deve aceitar campos opcionais da API', () {
      // Arrange
      final jsonMap = {
        'id': '123',
        'name': 'Casa Teste',
        'owner_id': 'user-123',
        'created_at': '2025-10-11T00:00:00.000Z',
        'updated_at': '2025-10-11T00:00:00.000Z',
        'owner': {
          'id': 'user-123',
          'name': 'Usuário',
          'email': 'user@test.com',
        },
        'members': [],
      };

      // Act
      final result = HouseholdModel.fromJson(jsonMap);

      // Assert
      expect(result.owner, isNotNull);
      expect(result.owner!.name, 'Usuário');
    });
  });
}
```

**Executar:**
```bash
flutter test test/features/homes/data/models/household_model_test.dart
```

**Verificação:**
- [ ] Todos os testes passam
- [ ] Deserialização funciona
- [ ] Serialização funciona
- [ ] Conversão para entidade funciona

---

#### Passo 8.2: Teste de Integração com API Real

**Criar arquivo:** `test/integration/household_api_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mealtime_app/features/homes/data/models/household_model.dart';

void main() {
  group('Household API Integration Tests', () {
    late Dio dio;
    const token = 'SEU_TOKEN_DE_TESTE'; // Usar token real
    const userId = 'SEU_USER_ID'; // Usar userId real

    setUp(() {
      dio = Dio(BaseOptions(
        baseUrl: 'https://mealtime.app.br/api',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-user-id': userId,
        },
      ));
    });

    test('deve criar household via API', () async {
      // Arrange
      final data = {
        'name': 'Casa Teste Integração',
        'description': 'Teste de integração',
      };

      // Act
      final response = await dio.post('/households', data: data);

      // Assert
      expect(response.statusCode, 201);
      final household = HouseholdModel.fromJson(response.data);
      expect(household.name, 'Casa Teste Integração');
      expect(household.ownerId, userId);
    });

    test('deve listar households via API', () async {
      // Act
      final response = await dio.get('/households');

      // Assert
      expect(response.statusCode, 200);
      expect(response.data, isList);
    });
  });
}
```

**Nota:** Estes testes precisam de credenciais reais. Executar manualmente ou configurar CI/CD.

---

### FASE 9: Documentação e Cleanup (15 minutos)

#### Passo 9.1: Atualizar Documentação

**Criar arquivo:** `lib/features/homes/README.md`

```markdown
# Homes/Households Feature

## ⚠️ Importante: API usa "households"

A API backend usa o termo "households" (domicílios), mas no app mantemos
o nome "homes" (casas) para melhor UX.

### Mapeamento de Termos

| App (Flutter) | API (Backend) |
|---------------|---------------|
| Home | Household |
| homes | households |
| userId | owner_id |

### Campos Não Suportados pela API

- ❌ `address` - API não suporta este campo
- ❌ `is_active` - API não retorna este campo

### Headers Necessários

Todas as requisições autenticadas precisam de:
- `Authorization: Bearer <token>`
- `x-user-id: <userId>` ← IMPORTANTE!

### Exemplo de Uso

\`\`\`dart
// Criar household
final home = await repository.createHome(
  name: 'Minha Casa',
  description: 'Casa principal',
  // NÃO enviar address
);
\`\`\`

### Modelos

- `HouseholdModel` - Modelo de dados (data layer)
- `Home` - Entidade de domínio (domain layer)

## Histórico de Mudanças

### 2025-10-11: Refatoração para Compatibilidade com API

- Migrou de `/homes` para `/households`
- Removeu campo `address` (não suportado pela API)
- Alterou `user_id` para `owner_id`
- Adicionou header `x-user-id`
```

**Verificação:**
- [ ] Documentação criada
- [ ] Mudanças documentadas

---

#### Passo 9.2: Atualizar CHANGELOG

**Arquivo:** `CHANGELOG.md`

Adicionar entrada:

```markdown
## [Unreleased] - 2025-10-11

### Changed
- **BREAKING:** Refatoração completa do módulo Homes para compatibilidade com API
  - Migrou endpoints de `/homes` para `/households`
  - Removido campo `address` (não suportado pela API)
  - Alterado `user_id` para `owner_id` no modelo de dados
  - Adicionado header `x-user-id` automaticamente em todas as requisições

### Removed
- Campo `address` dos formulários de home
- Parâmetro `address` de CreateHome e UpdateHome UseCases

### Added
- Novo `HouseholdModel` compatível 100% com API
- Modelos auxiliares: `HouseholdOwner`, `HouseholdMember`, etc.
- Método `getUserId()` no TokenManager
- Header `x-user-id` adicionado automaticamente pelo interceptor

### Fixed
- Erro 404 ao criar/listar homes (endpoint incorreto)
- Deserialização falhando devido a campos diferentes
```

---

## ✅ Checklist Final de Validação

### Compilação

- [ ] `flutter pub get` executa sem erros
- [ ] `flutter pub run build_runner build` executa sem erros
- [ ] `flutter analyze` não reporta erros críticos
- [ ] App compila: `flutter build apk --debug` (Android) ou `flutter build ios --debug` (iOS)

### Testes

- [ ] Testes unitários passam: `flutter test`
- [ ] Teste manual: Criar household funciona
- [ ] Teste manual: Listar households funciona
- [ ] Teste manual: Atualizar household funciona
- [ ] Teste manual: Deletar household funciona

### API

- [ ] Endpoint correto: `POST /households` (não `/homes`)
- [ ] Header `x-user-id` é enviado automaticamente
- [ ] Campo `address` NÃO é enviado
- [ ] Resposta da API é deserializada corretamente

### UI

- [ ] Campo de endereço removido dos formulários
- [ ] Formulário de criação funciona
- [ ] Formulário de edição funciona
- [ ] Nenhum campo obrigatório faltando

### Código

- [ ] Código comentado removido
- [ ] Imports não utilizados removidos
- [ ] Formatação: `dart format lib/`
- [ ] Linting: `flutter analyze`

---

## 🔙 Rollback Plan

Se algo der errado, seguir estes passos:

### Opção 1: Reverter Branch

```bash
git checkout main
git branch -D refactor/households-api-compatibility
```

### Opção 2: Reverter Commits Específicos

```bash
# Ver commits
git log --oneline

# Reverter commit específico
git revert <commit-hash>
```

### Opção 3: Restaurar Backup

```bash
# Copiar arquivos do backup
cp backup/households_refactor_*/home_model.dart lib/features/homes/data/models/
cp backup/households_refactor_*/homes_api_service.dart lib/services/api/
# ... etc
```

---

## 📊 Métricas de Sucesso

### Antes da Refatoração

- ❌ Criar household: Erro 404
- ❌ Deserialização: Falhando
- ❌ Campo address: Nunca salvo
- ❌ Compatibilidade: 30%

### Depois da Refatoração

- ✅ Criar household: Sucesso 201
- ✅ Deserialização: Funcionando
- ✅ Campo address: Removido (intencional)
- ✅ Compatibilidade: 100%

---

## 🎯 Conclusão

Após seguir este plano:

1. ✅ Código 100% compatível com API
2. ✅ Criar/listar/atualizar/deletar households funciona
3. ✅ Headers corretos enviados automaticamente
4. ✅ Modelo de dados alinhado com API
5. ✅ UI atualizada e funcional
6. ✅ Testes passando
7. ✅ Documentação atualizada

**Tempo Total Estimado:** 3-4 horas

**Benefícios:**
- App funcional com a API real
- Código limpo e manutenível
- Preparado para futuras features
- Sem workarounds ou gambiarras

---

*Plano criado via Cursor AI em 11/10/2025*

