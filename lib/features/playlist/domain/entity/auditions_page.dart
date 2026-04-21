import 'package:bonoos/features/playlist/domain/entity/audition.dart';

/// GET `/api/v1/auditions?limit=&offset=` javobi (`data` obyekti).
class AuditionsPage {
  const AuditionsPage({
    required this.items,
    required this.limit,
    required this.offset,
    required this.total,
  });

  final List<Audition> items;
  final int limit;
  final int offset;
  final int total;

  bool get hasMore {
    if (total <= 0) return false;
    return offset + items.length < total;
  }
}
