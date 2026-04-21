import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Formatters {
  static final priceFormatter = MaskTextInputFormatter(
      mask: '## ### ### SUM', filter: {"#": RegExp(r'[0-9]')});
  static final phoneFormatter = MaskTextInputFormatter(
    mask: '(##) ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  static final phoneFormatter2 = MaskTextInputFormatter(
    mask: '+998 (##) ### ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  static String formatNavigationDistance(double meters) {
    if (meters >= 1000) {
      // 1 km dan katta bo'lsa, kilometrga aylantiramiz
      double kilometers = meters / 1000;
      return "${kilometers.round()} km"; // Butun son sifatida
    } else {
      // 1 km dan kam bo'lsa, metrda ko'rsatamiz
      return "${meters.round()} m";
    }
  }

  static String formatNavigationTime(double seconds) {
    int totalMinutes = (seconds / 60).round(); // Sekundni minutga aylantiramiz
    if (totalMinutes >= 60) {
      // 1 soatdan katta bo'lsa, soat va qoldiq minutlarni hisoblaymiz
      int hours = totalMinutes ~/ 60;
      int remainingMinutes = totalMinutes % 60;
      return "$hours soat ${remainingMinutes > 0 ? '$remainingMinutes min' : ''}".trim();
    } else {
      // 1 soatdan kam bo'lsa, faqat minutda
      return "$totalMinutes min";
    }
  }

}

extension ViewCountFormatter on int {
  /// Formats the view count to display "K" for thousands and "M" for millions.
  /// Example: 1000 -> "1K", 1500 -> "1.5K", 1000000 -> "1M"
  String get formattedViewCount {
    if (this >= 1000000) {
      // Convert to millions
      double million = this / 1000000;
      return '${million.toStringAsFixed(million.truncateToDouble() == million ? 0 : 1)}M';
    } else if (this >= 1000) {
      // Convert to thousands
      double thousand = this / 1000;
      return '${thousand.toStringAsFixed(thousand.truncateToDouble() == thousand ? 0 : 1)}K';
    } else {
      // Return the number as is
      return toString();
    }
  }

}

