import 'package:equatable/equatable.dart';

class MedicineItem extends Equatable {
  const MedicineItem({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  final int id;
  final String name;
  final int hour;
  final int minute;
  final bool enabled;

  String get timeLabel => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  MedicineItem copyWith({
    int? id,
    String? name,
    int? hour,
    int? minute,
    bool? enabled,
  }) {
    return MedicineItem(
      id: id ?? this.id,
      name: name ?? this.name,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
      };

  factory MedicineItem.fromJson(Map<String, dynamic> json) => MedicineItem(
        id: json['id'] as int,
        name: json['name'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        enabled: json['enabled'] as bool,
      );

  @override
  List<Object?> get props => [id, name, hour, minute, enabled];
}

class MedicineDraft {
  const MedicineDraft({
    required this.name,
    required this.hour,
    required this.minute,
  });

  final String name;
  final int hour;
  final int minute;
}
