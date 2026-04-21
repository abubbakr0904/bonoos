class IncomeRange {
  const IncomeRange({
    required this.id,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
  });

  final int id;
  final String nameUz;
  final String nameRu;
  final String nameEn;

  factory IncomeRange.fromJson(Map<String, dynamic> json) {
    return IncomeRange(
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
