import 'package:bonoos/core/api/dio_client.dart';
import 'package:bonoos/core/api/list_api.dart';
import 'package:bonoos/core/error/failure.dart';
import 'package:bonoos/di.dart';
import 'package:bonoos/features/calendar/domain/entity/calendar_event.dart';
import 'package:bonoos/features/calendar/domain/entity/event_type.dart';
import 'package:bonoos/features/calendar/domain/repository/calendar_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final DioClient _dio = inject<DioClient>();

  @override
  Future<Either<Failure, List<EventType>>> fetchEventTypes() async {
    try {
      final raw = await _dio.get(ListAPI.eventTypes);
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Left(
            BadResponseFailure(message: 'Event turlari ma\'lumoti yo\'q.'));
      }
      final eventTypes = list
          .whereType<Map>()
          .map((e) => EventType.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(eventTypes);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> fetchEventsByDay(
      String day) async {
    return fetchEvents(from: day, to: day);
  }

  @override
  Future<Either<Failure, List<CalendarEvent>>> fetchEvents({
    required String from,
    required String to,
  }) async {
    try {
      final raw =
          await _dio.get(ListAPI.clientCalendarEvents(from: from, to: to));
      final response = raw as Response<dynamic>;
      final body = response.data;
      if (body is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(body);
      final list = map['data'];
      if (list is! List) {
        return const Left(
            BadResponseFailure(message: 'Voqealar ma\'lumoti yo\'q.'));
      }
      final events = list
          .whereType<Map>()
          .map((e) => CalendarEvent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return Right(events);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> createEvent({
    required int typeId,
    required String title,
    required String eventDate,
    String? eventTime,
    String? note,
    int? reminderMinutesBefore,
  }) async {
    try {
      final body = <String, dynamic>{
        'type_id': typeId,
        'title': title,
        'event_date': eventDate,
      };
      if (eventTime != null && eventTime.isNotEmpty) {
        body['event_time'] = eventTime;
      }
      if (note != null && note.isNotEmpty) {
        body['note'] = note;
      }
      if (reminderMinutesBefore != null) {
        body['reminder_minutes_before'] = reminderMinutesBefore;
      }

      final raw = await _dio.post(
        ListAPI.clientCalendarEventsCreate,
        data: body,
      );
      final response = raw;
      final respBody = response.data;
      if (respBody is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(respBody);
      final data = map['data'];
      if (data is! Map) {
        return const Left(
            BadResponseFailure(message: 'Voqea ma\'lumoti yo\'q.'));
      }
      return Right(CalendarEvent.fromJson(Map<String, dynamic>.from(data)));
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CalendarEvent>> updateEvent({
    required int eventId,
    required int typeId,
    required String title,
    required String eventDate,
    String? eventTime,
    String? note,
    int? reminderMinutesBefore,
  }) async {
    try {
      final body = <String, dynamic>{
        'type_id': typeId,
        'title': title,
        'event_date': eventDate,
      };
      if (eventTime != null && eventTime.isNotEmpty) {
        body['event_time'] = eventTime;
      }
      if (note != null && note.isNotEmpty) {
        body['note'] = note;
      }
      if (reminderMinutesBefore != null) {
        body['reminder_minutes_before'] = reminderMinutesBefore;
      }

      final raw = await _dio.put(
        ListAPI.clientCalendarEventsUpdate(eventId),
        data: body,
      );
      final response = raw;
      final respBody = response.data;
      if (respBody is! Map) {
        return const Left(
            BadResponseFailure(message: 'Javob formati noto\'g\'ri.'));
      }
      final map = Map<String, dynamic>.from(respBody);
      final data = map['data'];
      if (data is! Map) {
        return const Left(
            BadResponseFailure(message: 'Voqea ma\'lumoti yo\'q.'));
      }
      return Right(CalendarEvent.fromJson(Map<String, dynamic>.from(data)));
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(int eventId) async {
    try {
      await _dio.delete(ListAPI.clientCalendarEventsDelete(eventId));
      return const Right(null);
    } on DioException catch (e) {
      return Left(_mapDio(e));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Failure _mapDio(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const ConnectionFailure(
        message: 'Internet aloqasi yo\'q yoki vaqt tugadi.',
      );
    }
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? msg;
    if (data is Map) {
      final m = Map<String, dynamic>.from(data);
      msg = m['message']?.toString() ?? m['detail']?.toString();
    }
    if (status == 401) {
      return UnAuthorizedFailure(message: msg ?? 'Kirish talab qilinadi.');
    }
    return ServerFailure(message: msg ?? 'So\'rov bajarilmadi.');
  }
}
