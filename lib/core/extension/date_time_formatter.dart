import 'package:intl/intl.dart';

extension DateTimeFormatExtension on DateTime {
  /// Example: "Dushanba, 06 May"
  // String toLocalizedDateFormat(BuildContext context) {
  //   final s = S.of(context);
  //
  //   // Get localized weekday name
  //   String weekday = switch (this.weekday) {
  //     DateTime.monday => s.weekDay_1,
  //     DateTime.tuesday => s.weekDay_2,
  //     DateTime.wednesday => s.weekDay_3,
  //     DateTime.thursday => s.weekDay_4,
  //     DateTime.friday => s.weekDay_5,
  //     DateTime.saturday => s.weekDay_6,
  //     DateTime.sunday => s.weekDay_7,
  //     _ => '',
  //   };
  //
  //   String day = DateFormat('dd').format(this);
  //   String month;
  //
  //   try {
  //     month = switch (this.month) {
  //       1 => s.monthName_1,
  //       2 => s.monthName_2,
  //       3 => s.monthName_3,
  //       4 => s.monthName_4,
  //       5 => s.monthName_5,
  //       6 => s.monthName_6,
  //       7 => s.monthName_7,
  //       8 => s.monthName_8,
  //       9 => s.monthName_9,
  //       10 => s.monthName_10,
  //       11 => s.monthName_11,
  //       12 => s.monthName_12,
  //       _ => '',
  //     };
  //   } catch (_) {
  //     const monthsUz = [
  //       "Yanvar", "Fevral", "Mart", "Aprel", "May", "Iyun",
  //       "Iyul", "Avgust", "Sentabr", "Oktabr", "Noyabr", "Dekabr"
  //     ];
  //     month = monthsUz[this.month - 1];
  //   }
  //
  //   return '$weekday, $day $month';
  // }

  /// Example: "06.05.2025"
  String toDateFormat() => DateFormat('dd.MM.yyyy').format(toLocal());

  String toDateAndTimeFormat() => DateFormat('dd.MM.yyyy HH:mm').format(this);

  /// Example: "14:30"
  String toTimeFormat() => DateFormat('HH:mm').format(this);

  /// Example: "06 May / 14:30"
  String toCustomUzbekFormat() {
    const monthsUz = [
      "Yanvar",
      "Fevral",
      "Mart",
      "Aprel",
      "May",
      "Iyun",
      "Iyul",
      "Avgust",
      "Sentabr",
      "Oktabr",
      "Noyabr",
      "Dekabr",
    ];
    final day = DateFormat('dd').format(this);
    final month = monthsUz[this.month - 1];
    final time = DateFormat('HH:mm').format(this);
    return "$day $month / $time";
  }
}

extension DateTimeFormatter on String {
  /// Parses the string into a DateTime object.
  /// Handles ISO 8601 format automatically if the string contains 'T'
  /// Throws an exception if the string is not in a valid format.
  DateTime toDateTime({String? format}) {
    // Automatically detect ISO 8601 format (which contains 'T')
    if (contains('T')) {
      // Parse as ISO 8601 (handles formats like "2025-05-11T07:17:55.653Z")
      return DateTime.parse(this);
    }

    // Otherwise use the provided format or default
    final DateFormat parser = DateFormat(format ?? 'yyyy-MM-dd');
    return parser.parse(this);
  }

  /// Formats the string (assumed to be a valid date string) into a custom format.
  /// Automatically detects ISO 8601 format
  String format({
    String? inputFormat,
    String outputFormat = 'dd MMM yyyy, hh:mm a',
  }) {
    final DateTime dateTime = toDateTime(format: inputFormat).toLocal();
    final DateFormat formatter = DateFormat(outputFormat);
    return formatter.format(dateTime);
  }

  /// Returns a formatted date string in `dd MMM yyyy` format.
  String get formattedDate {
    return format(outputFormat: 'dd MMM yyyy');
  }

  /// Returns a formatted time string in `hh:mm a` format.
  String get formattedTime {
    return format(outputFormat: 'hh:mm a');
  }

  /// Returns a formatted date and time string in `dd MMM yyyy, hh:mm a` format.
  String get formattedDateTime {
    return format(outputFormat: 'dd MMM yyyy, hh:mm');
  }

  String get toTimeFormat {
    return format(outputFormat: 'HH:mm');
  }
}

extension TimeFormatExtension on int {
  /// Converts seconds into time format: HH:mm:ss or mm:ss
  String toTimeFormat({bool showHours = false}) {
    final duration = Duration(seconds: this);
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (showHours || duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }
}
