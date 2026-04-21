// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ru';

  static String m0(price) => "Предложенная цена: ${price} UZS";

  static String m1(count) =>
      "${Intl.plural(count, zero: '0 студентов', one: '${count} студент', few: '${count} студента', many: '${count} студентов', other: '${count} студентов')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "absent": MessageLookupByLibrary.simpleMessage("Не пришли"),
        "acceptOrder": MessageLookupByLibrary.simpleMessage("Принять заказ"),
        "acceptPrice": MessageLookupByLibrary.simpleMessage("Принять цену"),
        "add_file": MessageLookupByLibrary.simpleMessage("+ Добавить файл"),
        "additional": MessageLookupByLibrary.simpleMessage("Дополнительно"),
        "additional_files":
            MessageLookupByLibrary.simpleMessage("Дополнительные файлы"),
        "additional_note":
            MessageLookupByLibrary.simpleMessage("Дополнительная заметка"),
        "advance": MessageLookupByLibrary.simpleMessage("Аванс"),
        "agreedPrice":
            MessageLookupByLibrary.simpleMessage("Договорённая цена"),
        "amount": MessageLookupByLibrary.simpleMessage("Введите сумму"),
        "an_issue_occurred":
            MessageLookupByLibrary.simpleMessage("Произошла ошибка!"),
        "announcement_date":
            MessageLookupByLibrary.simpleMessage("Дата объявления"),
        "april": MessageLookupByLibrary.simpleMessage("Апрель"),
        "assignment": MessageLookupByLibrary.simpleMessage("Задание"),
        "assignment_date": MessageLookupByLibrary.simpleMessage("Дата задания"),
        "attendance": MessageLookupByLibrary.simpleMessage("Посещаемость"),
        "august": MessageLookupByLibrary.simpleMessage("Август"),
        "auto": MessageLookupByLibrary.simpleMessage("Автоматическая"),
        "back": MessageLookupByLibrary.simpleMessage("Назад"),
        "balanceAndRating":
            MessageLookupByLibrary.simpleMessage("Баланс и рейтинг"),
        "came": MessageLookupByLibrary.simpleMessage("Пришел"),
        "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "cannotExceedHunnid":
            MessageLookupByLibrary.simpleMessage("Не может превышать 100"),
        "choose_from_gallery":
            MessageLookupByLibrary.simpleMessage("Выбрать из галереи"),
        "comment": MessageLookupByLibrary.simpleMessage("Комментарий"),
        "completed": MessageLookupByLibrary.simpleMessage("Завершено"),
        "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
        "confirmLogout":
            MessageLookupByLibrary.simpleMessage("Подтвердить выход"),
        "confirmed": MessageLookupByLibrary.simpleMessage("Подтверждено"),
        "control_table_title":
            MessageLookupByLibrary.simpleMessage("Таблица контроля"),
        "create_button": MessageLookupByLibrary.simpleMessage("Создать"),
        "create_title": MessageLookupByLibrary.simpleMessage("Создать"),
        "currency": MessageLookupByLibrary.simpleMessage("сум"),
        "dark": MessageLookupByLibrary.simpleMessage("Темная"),
        "date": MessageLookupByLibrary.simpleMessage("Дата"),
        "december": MessageLookupByLibrary.simpleMessage("Декабрь"),
        "deleteAllProfiles":
            MessageLookupByLibrary.simpleMessage("Удалить все профили"),
        "deleteAndLogout":
            MessageLookupByLibrary.simpleMessage("Удалить и выйти"),
        "delete_confirmation":
            MessageLookupByLibrary.simpleMessage("Вы хотите удалить?"),
        "description": MessageLookupByLibrary.simpleMessage("Описание"),
        "direction": MessageLookupByLibrary.simpleMessage("Направление"),
        "driverLicense":
            MessageLookupByLibrary.simpleMessage("Водительское удостоверение"),
        "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
        "end_date": MessageLookupByLibrary.simpleMessage("Дата окончания"),
        "enter": MessageLookupByLibrary.simpleMessage("Войти"),
        "enterLogin": MessageLookupByLibrary.simpleMessage("Введите логин"),
        "enter_login": MessageLookupByLibrary.simpleMessage("Введите логин"),
        "enter_password":
            MessageLookupByLibrary.simpleMessage("Введите пароль"),
        "enter_task_comment": MessageLookupByLibrary.simpleMessage(
            "Введите комментарий к заданию"),
        "error": MessageLookupByLibrary.simpleMessage("Ошибка"),
        "error_end_before_start": MessageLookupByLibrary.simpleMessage(
            "Дата окончания не может быть раньше даты начала"),
        "error_message": MessageLookupByLibrary.simpleMessage("Ошибка"),
        "error_not_graded":
            MessageLookupByLibrary.simpleMessage("Вы ещё не поставили оценку"),
        "error_occurred":
            MessageLookupByLibrary.simpleMessage("Произошла ошибка:"),
        "exam": MessageLookupByLibrary.simpleMessage("Экзамен"),
        "exam_date": MessageLookupByLibrary.simpleMessage("Дата экзамена"),
        "example_title":
            MessageLookupByLibrary.simpleMessage("Пример: глагол \'to be\'"),
        "exitCancel": MessageLookupByLibrary.simpleMessage("Отмена"),
        "exitConfirm": MessageLookupByLibrary.simpleMessage("Выйти"),
        "exitDoubleCheckMessage": MessageLookupByLibrary.simpleMessage(
            "Вы действительно хотите выйти?"),
        "exitDoubleCheckTitle":
            MessageLookupByLibrary.simpleMessage("Подтвердите выход"),
        "exitMessage": MessageLookupByLibrary.simpleMessage(
            "Вы уверены, что хотите выйти?"),
        "exitTitle":
            MessageLookupByLibrary.simpleMessage("Выйти из приложения"),
        "expired_date_attendance_not_taken":
            MessageLookupByLibrary.simpleMessage(
                "Посещаемость за прошедшую дату не будет учтена."),
        "f_i_sh": MessageLookupByLibrary.simpleMessage("Ф.И.О."),
        "february": MessageLookupByLibrary.simpleMessage("Февраль"),
        "fine": MessageLookupByLibrary.simpleMessage("Штраф"),
        "fio": MessageLookupByLibrary.simpleMessage("Ф.И.О."),
        "friday": MessageLookupByLibrary.simpleMessage("Пятница"),
        "fridayShort": MessageLookupByLibrary.simpleMessage("Пт"),
        "frontSide": MessageLookupByLibrary.simpleMessage("Лицевая сторона"),
        "go": MessageLookupByLibrary.simpleMessage("Перейти"),
        "graded": MessageLookupByLibrary.simpleMessage("Оценено"),
        "group_title": MessageLookupByLibrary.simpleMessage("Группы"),
        "groups": MessageLookupByLibrary.simpleMessage("Группы"),
        "hi": MessageLookupByLibrary.simpleMessage("Привет"),
        "hint_comment_task": MessageLookupByLibrary.simpleMessage(
            "Введите комментарий по заданию"),
        "hint_score_range": MessageLookupByLibrary.simpleMessage("0-100"),
        "login": MessageLookupByLibrary.simpleMessage("Главная"),
        "hour": MessageLookupByLibrary.simpleMessage("час"),
        "image_selection_error": MessageLookupByLibrary.simpleMessage(
            "Ошибка при выборе изображения:"),
        "inProgress": MessageLookupByLibrary.simpleMessage("В процессе"),
        "internetConnected":
            MessageLookupByLibrary.simpleMessage("Интернет подключен"),
        "january": MessageLookupByLibrary.simpleMessage("Январь"),
        "july": MessageLookupByLibrary.simpleMessage("Июль"),
        "june": MessageLookupByLibrary.simpleMessage("Июнь"),
        "label_comment": MessageLookupByLibrary.simpleMessage("Комментарий"),
        "label_score": MessageLookupByLibrary.simpleMessage("Оценка"),
        "language": MessageLookupByLibrary.simpleMessage("Язык"),
        "late": MessageLookupByLibrary.simpleMessage("Опоздали"),
        "lesson_schedule":
            MessageLookupByLibrary.simpleMessage("Расписание уроков"),
        "licenseAgreement":
            MessageLookupByLibrary.simpleMessage("Лицензионное соглашение"),
        "light": MessageLookupByLibrary.simpleMessage("Светлая"),
        "login": MessageLookupByLibrary.simpleMessage("Логин"),
        "logout": MessageLookupByLibrary.simpleMessage("Выйти"),
        "main": MessageLookupByLibrary.simpleMessage("Главная"),
        "march": MessageLookupByLibrary.simpleMessage("Март"),
        "max_score": MessageLookupByLibrary.simpleMessage("Максимальный балл"),
        "may": MessageLookupByLibrary.simpleMessage("Май"),
        "minute": MessageLookupByLibrary.simpleMessage("минута"),
        "monday": MessageLookupByLibrary.simpleMessage("Понедельник"),
        "mondayShort": MessageLookupByLibrary.simpleMessage("Пн"),
        "month_april": MessageLookupByLibrary.simpleMessage("Апрель"),
        "month_august": MessageLookupByLibrary.simpleMessage("Август"),
        "month_december": MessageLookupByLibrary.simpleMessage("Декабрь"),
        "month_february": MessageLookupByLibrary.simpleMessage("Февраль"),
        "month_january": MessageLookupByLibrary.simpleMessage("Январь"),
        "month_july": MessageLookupByLibrary.simpleMessage("Июль"),
        "month_june": MessageLookupByLibrary.simpleMessage("Июнь"),
        "month_march": MessageLookupByLibrary.simpleMessage("Март"),
        "month_may": MessageLookupByLibrary.simpleMessage("Май"),
        "month_november": MessageLookupByLibrary.simpleMessage("Ноябрь"),
        "month_october": MessageLookupByLibrary.simpleMessage("Октябрь"),
        "month_september": MessageLookupByLibrary.simpleMessage("Сентябрь"),
        "monthlyIncome":
            MessageLookupByLibrary.simpleMessage("Ежемесячный доход"),
        "myOffers": MessageLookupByLibrary.simpleMessage("Мои предложения"),
        "new_password": MessageLookupByLibrary.simpleMessage("Новый пароль"),
        "night_mode": MessageLookupByLibrary.simpleMessage("Ночной режим"),
        "noInternet": MessageLookupByLibrary.simpleMessage("Нет интернета"),
        "no_data": MessageLookupByLibrary.simpleMessage(
            "По запросу данные не найдены!"),
        "no_groups": MessageLookupByLibrary.simpleMessage("Групп нет"),
        "no_lessons": MessageLookupByLibrary.simpleMessage("Уроков нет :)"),
        "no_payments_found":
            MessageLookupByLibrary.simpleMessage("Платежей нет!"),
        "no_students": MessageLookupByLibrary.simpleMessage("Нет учеников"),
        "no_students_found":
            MessageLookupByLibrary.simpleMessage("Ученики не найдены"),
        "no_tasks_yet":
            MessageLookupByLibrary.simpleMessage("Заданий пока нет :)"),
        "not_graded": MessageLookupByLibrary.simpleMessage("Не оценено"),
        "notification": MessageLookupByLibrary.simpleMessage("Уведомление"),
        "november": MessageLookupByLibrary.simpleMessage("Ноябрь"),
        "october": MessageLookupByLibrary.simpleMessage("Октябрь"),
        "offerPrice": MessageLookupByLibrary.simpleMessage("Предложить цену"),
        "old_password": MessageLookupByLibrary.simpleMessage("Старый пароль"),
        "optional": MessageLookupByLibrary.simpleMessage("Необязательно"),
        "orders": MessageLookupByLibrary.simpleMessage("Заказы"),
        "passing_score": MessageLookupByLibrary.simpleMessage("Проходной балл"),
        "password": MessageLookupByLibrary.simpleMessage("Пароль"),
        "payments": MessageLookupByLibrary.simpleMessage("Зарплаты"),
        "phone_number": MessageLookupByLibrary.simpleMessage("Номер телефона"),
        "poweredBy":
            MessageLookupByLibrary.simpleMessage("©️ Поддерживается IMB Tech"),
        "present": MessageLookupByLibrary.simpleMessage("Пришли"),
        "privacyPolicy":
            MessageLookupByLibrary.simpleMessage("Политика конфиденциальности"),
        "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
        "proposedPrice": m0,
        "rate": MessageLookupByLibrary.simpleMessage("Оценить"),
        "rearSide": MessageLookupByLibrary.simpleMessage("Обратная сторона"),
        "reason_for_absence":
            MessageLookupByLibrary.simpleMessage("Причина отсутствия"),
        "reason_for_lateness":
            MessageLookupByLibrary.simpleMessage("Причина опоздания"),
        "refresh": MessageLookupByLibrary.simpleMessage("Обновить"),
        "refrigeratedTruck":
            MessageLookupByLibrary.simpleMessage("Рефрижераторный грузовик"),
        "register": MessageLookupByLibrary.simpleMessage("Регистрация"),
        "reload": MessageLookupByLibrary.simpleMessage("Перезагрузить"),
        "repeat_new_password":
            MessageLookupByLibrary.simpleMessage("Повторите новый пароль"),
        "resendCode":
            MessageLookupByLibrary.simpleMessage("Отправить код повторно"),
        "role": MessageLookupByLibrary.simpleMessage("Должность"),
        "salary": MessageLookupByLibrary.simpleMessage("Зарплата"),
        "saturday": MessageLookupByLibrary.simpleMessage("Суббота"),
        "saturdayShort": MessageLookupByLibrary.simpleMessage("Сб"),
        "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
        "score": MessageLookupByLibrary.simpleMessage("Балл"),
        "selectDateRange":
            MessageLookupByLibrary.simpleMessage("Выбрать диапазон дат"),
        "selectLang": MessageLookupByLibrary.simpleMessage("Выбрать язык"),
        "select_date": MessageLookupByLibrary.simpleMessage("Выбрать дату"),
        "select_image":
            MessageLookupByLibrary.simpleMessage("Выбрать изображение"),
        "september": MessageLookupByLibrary.simpleMessage("Сентябрь"),
        "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
        "sign_in": MessageLookupByLibrary.simpleMessage("Войти"),
        "start_date": MessageLookupByLibrary.simpleMessage("Дата начала"),
        "status": MessageLookupByLibrary.simpleMessage("Статус"),
        "status_active": MessageLookupByLibrary.simpleMessage("Активный"),
        "status_deleted": MessageLookupByLibrary.simpleMessage("Удалён"),
        "status_frozen": MessageLookupByLibrary.simpleMessage("Заморожен"),
        "status_not_submitted":
            MessageLookupByLibrary.simpleMessage("Не сдано"),
        "status_suspended":
            MessageLookupByLibrary.simpleMessage("Приостановлен"),
        "status_trial": MessageLookupByLibrary.simpleMessage("На испытании"),
        "students": MessageLookupByLibrary.simpleMessage("Ученики"),
        "students_count": m1,
        "students_upload_label": MessageLookupByLibrary.simpleMessage(
            "Разрешить студентам загружать задания"),
        "submitOffer":
            MessageLookupByLibrary.simpleMessage("Отправить предложение"),
        "sum": MessageLookupByLibrary.simpleMessage("Сум"),
        "sunday": MessageLookupByLibrary.simpleMessage("Воскресенье"),
        "sundayShort": MessageLookupByLibrary.simpleMessage("Вс"),
        "take_from_camera":
            MessageLookupByLibrary.simpleMessage("Сделать снимок"),
        "task": MessageLookupByLibrary.simpleMessage("Домашняя работа"),
        "tasks": MessageLookupByLibrary.simpleMessage("Задания"),
        "techPassport":
            MessageLookupByLibrary.simpleMessage("Технический паспорт"),
        "textbook": MessageLookupByLibrary.simpleMessage("Учебник"),
        "theme": MessageLookupByLibrary.simpleMessage("Тема"),
        "thursday": MessageLookupByLibrary.simpleMessage("Четверг"),
        "thursdayShort": MessageLookupByLibrary.simpleMessage("Чт"),
        "tilesInfo": MessageLookupByLibrary.simpleMessage(
            "Плитка имеется, погрузка завтра"),
        "time_error": MessageLookupByLibrary.simpleMessage(
            "Время возвращения не может быть раньше времени отправления"),
        "title_required":
            MessageLookupByLibrary.simpleMessage("Название обязательно"),
        "topic": MessageLookupByLibrary.simpleMessage("Тема"),
        "total_groups": MessageLookupByLibrary.simpleMessage("Всего групп"),
        "total_students":
            MessageLookupByLibrary.simpleMessage("Всего учеников"),
        "trailer": MessageLookupByLibrary.simpleMessage("Прицеп"),
        "tuesday": MessageLookupByLibrary.simpleMessage("Вторник"),
        "tuesdayShort": MessageLookupByLibrary.simpleMessage("Вт"),
        "unauthorized_access": MessageLookupByLibrary.simpleMessage(
            "Доступ запрещён, обратитесь в администрацию!"),
        "underReview": MessageLookupByLibrary.simpleMessage("На рассмотрении"),
        "version": MessageLookupByLibrary.simpleMessage("Версия"),
        "wednesday": MessageLookupByLibrary.simpleMessage("Среда"),
        "wednesdayShort": MessageLookupByLibrary.simpleMessage("Ср"),
        "workplaces": MessageLookupByLibrary.simpleMessage("Места работы"),
        "your_old_password":
            MessageLookupByLibrary.simpleMessage("Ваш старый пароль")
      };
}
