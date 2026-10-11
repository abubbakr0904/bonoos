class Category {
  const Category({
    required this.id,
    required this.name,
    required this.sort,
    this.description = '',
    this.price = 0,
    this.unlocked = true,
  });

  final int id;
  final String name;
  final int sort;
  final String description;

  /// So‘mda. `0` — bepul kategoriya.
  final num price;

  /// Server: bepul yoki foydalanuvchi sotib olgan bo‘lsa `true`.
  final bool unlocked;

  bool get isPaid => price > 0;
  bool get isLocked => isPaid && !unlocked;

  String get formattedPrice {
    final s = price.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} so\'m';
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?) ?? 0;
    return Category(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      sort: (json['sort'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      price: price,
      // Eski backend `unlocked` yubormasa — bepul deb hisoblaymiz.
      unlocked: json['unlocked'] as bool? ?? price <= 0,
    );
  }
}
