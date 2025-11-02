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
  
  @JsonKey(name: 'userId')
  final String userId;
  
  final String name;
  final String email;
  final String role;
  
  @JsonKey(name: 'joinedAt')
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
