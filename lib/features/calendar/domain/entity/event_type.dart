import 'package:flutter/material.dart';

class EventType {
  const EventType({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String name;
  final String color;
  final String createdAt;
  final String updatedAt;

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '#4285F4',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF4285F4);
    }
  }
}
