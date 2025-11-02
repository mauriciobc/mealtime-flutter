import 'package:equatable/equatable.dart';

class Home extends Equatable {
  final String id;
  final String name;
  final String? address;
  final String? description;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const Home({
    required this.id,
    required this.name,
    this.address,
    this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    description,
    userId,
    createdAt,
    updatedAt,
    isActive,
  ];

  Home copyWith({
    String? id,
    String? name,
    String? address,
    String? description,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Home(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
