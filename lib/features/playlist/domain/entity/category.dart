class Category {
  const Category({
    required this.id,
    required this.name,
    required this.sort,
  });

  final int id;
  final String name;
  final int sort;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      sort: (json['sort'] as num?)?.toInt() ?? 0,
    );
  }
}
