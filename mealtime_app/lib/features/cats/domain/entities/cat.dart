import 'package:equatable/equatable.dart';

class Cat extends Equatable {
  final String id;
  final String name;
  final String? breed;
  final DateTime birthDate;
  final String? gender;
  final String? color;
  final String? description;
  final String? imageUrl;
  final double? currentWeight;
  final double? targetWeight;
  final String homeId;
  final String? ownerId;  // ✅ NOVO: ID do dono principal
  final double? portionSize;  // ✅ NOVO: Tamanho da porção
  final String? portionUnit;  // ✅ NOVO: Unidade da porção (g, kg, xícaras)
  final int? feedingInterval;  // ✅ NOVO: Intervalo entre alimentações (horas)
  final String? restrictions;  // ✅ NOVO: Restrições alimentares
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Cat({
    required this.id,
    required this.name,
    this.breed,
    required this.birthDate,
    this.gender,
    this.color,
    this.description,
    this.imageUrl,
    this.currentWeight,
    this.targetWeight,
    required this.homeId,
    this.ownerId,
    this.portionSize,
    this.portionUnit,
    this.feedingInterval,
    this.restrictions,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    breed,
    birthDate,
    gender,
    color,
    description,
    imageUrl,
    currentWeight,
    targetWeight,
    homeId,
    ownerId,
    portionSize,
    portionUnit,
    feedingInterval,
    restrictions,
    createdAt,
    updatedAt,
    isActive,
  ];

  Cat copyWith({
    String? id,
    String? name,
    String? breed,
    DateTime? birthDate,
    String? gender,
    String? color,
    String? description,
    String? imageUrl,
    double? currentWeight,
    double? targetWeight,
    String? homeId,
    String? ownerId,
    double? portionSize,
    String? portionUnit,
    int? feedingInterval,
    String? restrictions,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Cat(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      color: color ?? this.color,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      homeId: homeId ?? this.homeId,
      ownerId: ownerId ?? this.ownerId,
      portionSize: portionSize ?? this.portionSize,
      portionUnit: portionUnit ?? this.portionUnit,
      feedingInterval: feedingInterval ?? this.feedingInterval,
      restrictions: restrictions ?? this.restrictions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  int get ageInMonths {
    final now = DateTime.now();
    final age = now.difference(birthDate);
    return (age.inDays / 30).round();
  }

  String get ageDescription {
    final months = ageInMonths;
    if (months < 12) {
      return '$months ${months == 1 ? 'mês' : 'meses'}';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      if (remainingMonths == 0) {
        return '$years ${years == 1 ? 'ano' : 'anos'}';
      } else {
        return '$years ${years == 1 ? 'ano' : 'anos'} e $remainingMonths ${remainingMonths == 1 ? 'mês' : 'meses'}';
      }
    }
  }
}
