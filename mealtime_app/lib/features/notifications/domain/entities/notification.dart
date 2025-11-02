import 'package:equatable/equatable.dart';

/// Entidade que representa uma notificação do sistema
class Notification extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type = 'info',
    this.read = false,
    this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  /// Cria uma cópia desta notificação com campos atualizados
  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        message,
        type,
        read,
        createdAt,
        updatedAt,
        metadata,
      ];
}

