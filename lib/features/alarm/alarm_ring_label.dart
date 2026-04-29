import 'package:bonoos/features/alarm/alarm_models.dart';
import 'package:bonoos/features/alarm/alarm_service.dart';

/// Keyingi jiringlashgacha qolgan vaqtni o‘zbekcha qisqa matn.
String alarmRingCountdownLabel(AlarmItem item) {
  if (!item.enabled) {
    return "O'chirilgan";
  }
  final next = AlarmService.nextRingDateTime(item);
  final now = DateTime.now();
  var diff = next.difference(now);
  if (diff.isNegative) diff = Duration.zero;

  final totalMinutes = diff.inMinutes;
  if (totalMinutes < 1) {
    return "Bir daqiqadan kam vaqt qoldi — jiringlaydi";
  }

  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  if (h > 0 && m > 0) {
    return "$h soat $m daqiqadan keyin jiringlaydi";
  }
  if (h > 0) {
    return "$h soatdan keyin jiringlaydi";
  }
  return "$m daqiqadan keyin jiringlaydi";
}
