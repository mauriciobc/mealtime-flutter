import 'package:json_annotation/json_annotation.dart';

part 'household_model.g.dart';

@JsonSerializable()
class HouseholdModel {
  final String id;
  final String name;
  final List<HouseholdMemberModel> members;

  const HouseholdModel({
    required this.id,
    required this.name,
    required this.members,
  });

  factory HouseholdModel.fromJson(Map<String, dynamic> json) =>
      _$HouseholdModelFromJson(json);

  Map<String, dynamic> toJson() => _$HouseholdModelToJson(this);
}

@JsonSerializable()
class HouseholdMemberModel {
  final String id;
  final String name;
  final String email;
  final String role;

  const HouseholdMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory HouseholdMemberModel.fromJson(Map<String, dynamic> json) =>
      _$HouseholdMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$HouseholdMemberModelToJson(this);
}
