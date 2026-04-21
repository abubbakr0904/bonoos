class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.description,
  });

  final int id;
  final String name;
  final int durationDays;
  final int price;
  final String description;

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
    );
  }

  String get formattedPrice {
    final s = price.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} so\'m';
  }

  String get perMonthFormatted {
    if (durationDays <= 0) return '';
    final months = (durationDays / 30).ceil();
    if (months <= 0) return '';
    final perMonth = (price / months).round();
    final s = perMonth.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf.toString()} / oy';
  }
}
