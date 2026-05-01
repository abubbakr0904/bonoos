import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/features/calendar/domain/entity/calendar_event.dart';
import 'package:bonoos/features/calendar/domain/entity/event_type.dart';
import 'package:dartz/dartz.dart';

abstract class CalendarRepository {
  /// Event turlarini olish
  Future<Either<Failure, List<EventType>>> fetchEventTypes();

  /// Kunlik voqealarni olish (from/to orqali)
  Future<Either<Failure, List<CalendarEvent>>> fetchEventsByDay(String day);

  /// Voqealar ro'yxatini olish (from/to orqali)
  Future<Either<Failure, List<CalendarEvent>>> fetchEvents({
    required String from,
    required String to,
  });

  /// Yangi voqea qo'shish
  Future<Either<Failure, CalendarEvent>> createEvent({
    required int typeId,
    required String title,
    required String eventDate,
    String? eventTime,
    String? note,
    int? reminderMinutesBefore,
  });

  /// Voqeani yangilash
  Future<Either<Failure, CalendarEvent>> updateEvent({
    required int eventId,
    required int typeId,
    required String title,
    required String eventDate,
    String? eventTime,
    String? note,
    int? reminderMinutesBefore,
  });

  /// Voqeani o'chirish
  Future<Either<Failure, void>> deleteEvent(int eventId);
}
