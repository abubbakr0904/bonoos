class Activity {
  const Activity({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
  });

  final int id;
  final String nameUz;
  final String nameRu;
  final String nameEn;

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameUz: json['name_uz'] as String? ?? '',
      nameRu: json['name_ru'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
    );
  }

  String localizedName(String langCode) {
    switch (langCode) {
      case 'ru':
        return nameRu;
      case 'en':
        return nameEn;
      default:
        return nameUz;
    }
  }
}
