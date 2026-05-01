class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.typeId,
    required this.title,
    required this.eventDate,
    this.eventTime,
    this.note,
    this.reminderMinutesBefore,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int typeId;
  final String title;
  final String eventDate;
  final String? eventTime;
  final String? note;
  final int? reminderMinutesBefore;
  final String createdAt;
  final String updatedAt;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    // Parse event_time from "0000-01-01T14:30:00Z" to "14:30"
    String? parsedEventTime;
    final rawEventTime = json['event_time'] as String?;
    if (rawEventTime != null && rawEventTime.isNotEmpty) {
      try {
        final dt = DateTime.parse(rawEventTime);
        parsedEventTime =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        parsedEventTime = rawEventTime;
      }
    }

    return CalendarEvent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      typeId: (json['type_id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      eventDate: json['event_date'] as String? ?? '',
      eventTime: parsedEventTime,
      note: json['note'] as String?,
      reminderMinutesBefore: (json['reminder_minutes_before'] as num?)?.toInt(),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_id': typeId,
      'title': title,
      'event_date': eventDate,
      'event_time': eventTime,
      'note': note,
      'reminder_minutes_before': reminderMinutesBefore,
    };
  }
}
