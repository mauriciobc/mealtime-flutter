import 'package:json_annotation/json_annotation.dart';
import 'package:mealtime_app/features/homes/domain/entities/home.dart';

part 'home_model.g.dart';

@JsonSerializable()
class HomeModel {
  final String id;
  final String name;
  final String? address;
  final String? description;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const HomeModel({
    required this.id,
    required this.name,
    this.address,
    this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);
  Map<String, dynamic> toJson() => _$HomeModelToJson(this);

  factory HomeModel.fromEntity(Home home) {
    return HomeModel(
      id: home.id,
      name: home.name,
      address: home.address,
      description: home.description,
      userId: home.userId,
      createdAt: home.createdAt,
      updatedAt: home.updatedAt,
      isActive: home.isActive,
    );
  }

  Home toEntity() {
    return Home(
      id: id,
      name: name,
      address: address,
      description: description,
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }
}
