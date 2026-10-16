/// So‘mni guruhlab yozadi: 29000 → "29 000 so'm".
String formatSom(num amount) {
  final s = amount.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
    buf.write(s[i]);
  }
  return '${buf.toString()} so\'m';
}

/// Kategoriya tarifi: muddat (kun) + narx. Sotib olishda `id` yuboriladi.
class CategoryPrice {
  const CategoryPrice({required this.id, required this.durationDays, required this.price});

  final int id;
  final int durationDays;
  final num price;

  /// 365 → "1 yil", 30 → "30 kun"
  String get durationLabel =>
      durationDays % 365 == 0 ? '${durationDays ~/ 365} yil' : '$durationDays kun';

  String get formattedPrice => formatSom(price);

  /// 30 kundan uzun tariflar uchun oylik ekvivalent (taqqoslash uchun).
  num get monthlyPrice => price * 30 / durationDays;

  factory CategoryPrice.fromJson(Map<String, dynamic> json) => CategoryPrice(
        id: (json['id'] as num?)?.toInt() ?? 0,
        durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
        price: (json['price'] as num?) ?? 0,
      );
}

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.sort,
    this.description = '',
    this.isPaid = false,
    this.prices = const [],
    this.unlocked = true,
    this.expiresAt,
  });

  final int id;
  final String name;
  final int sort;
  final String description;

  /// Pullik to‘plam: audiolar faqat to‘langan (muddati tugamagan) davrda ochiq.
  final bool isPaid;

  /// Sotib olish mumkin bo‘lgan tariflar (muddat bo‘yicha o‘sish tartibida).
  final List<CategoryPrice> prices;

  /// Server: bepul yoki muddati tugamagan bo‘lsa `true`.
  final bool unlocked;

  /// Ochiq pullik to‘plam qachongacha ochiq; `null` — bepul, umrbod yoki yopiq.
  final DateTime? expiresAt;

  bool get isLocked => isPaid && !unlocked;

  /// Sotib olingan va umrbod (muddatsiz) ochiq.
  bool get isLifetime => isPaid && unlocked && expiresAt == null;

  /// Tugashigacha qolgan to‘liq kunlar (yuqoriga yaxlitlangan); muddatsiz — `null`.
  int? get daysLeft {
    final e = expiresAt;
    if (!isPaid || !unlocked || e == null) return null;
    final diff = e.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return (diff.inMinutes / (24 * 60)).ceil();
  }

  /// Muddat tugashiga oz qolgan — uzaytirishni taklif qilamiz.
  bool get expiresSoon => (daysLeft ?? 999) <= 7;

  CategoryPrice? get cheapestPrice {
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) => a.price <= b.price ? a : b);
  }

  /// "29 000 so'm dan" — eng arzon tarif.
  String get fromPriceLabel {
    final p = cheapestPrice;
    return p == null ? '' : '${p.formattedPrice} dan';
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final prices = (json['prices'] as List?)
            ?.whereType<Map>()
            .map((e) => CategoryPrice.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.id > 0 && p.durationDays > 0)
            .toList() ??
        <CategoryPrice>[];
    prices.sort((a, b) => a.durationDays.compareTo(b.durationDays));
    final isPaid = json['is_paid'] as bool? ?? false;
    final expires = json['expires_at'] as String?;
    return Category(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      isPaid: isPaid,
      prices: prices,
      unlocked: json['unlocked'] as bool? ?? !isPaid,
      expiresAt: expires == null ? null : DateTime.tryParse(expires),
    );
  }
}
