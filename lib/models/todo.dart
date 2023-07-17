import 'package:flutter/material.dart';

@immutable
class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Todo.fromJson(dynamic json) {
    return Todo(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String,
      isCompleted: json['is_completed'] as bool,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
