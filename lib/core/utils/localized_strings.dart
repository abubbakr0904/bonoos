
import 'package:bonoos/core/extension/for_context.dart';
import 'package:bonoos/core/routes/app_pages.dart';

class DateStrings {
  DateStrings._();

  static List<String> get monthNames {
    if (rootNavigatorKey.currentContext == null) {
      return [];
    }
    final loc = rootNavigatorKey.currentContext!.tr;

    return [
      loc.month_january,
      loc.month_february,
      loc.month_march,
      loc.month_april,
      loc.month_may,
      loc.month_june,
      loc.month_july,
      loc.month_august,
      loc.month_september,
      loc.month_october,
      loc.month_november,
      loc.month_december,
    ];
  }
  static List<String> get weekShortNames {
    if (rootNavigatorKey.currentContext == null) {
      return [];
    }
    final loc = rootNavigatorKey.currentContext!.tr;

    return [
      loc.mondayShort,
      loc.tuesdayShort,
      loc.wednesdayShort,
      loc.thursdayShort,
      loc.fridayShort,
      loc.saturdayShort,
      loc.sundayShort,
    ];
  }
}
