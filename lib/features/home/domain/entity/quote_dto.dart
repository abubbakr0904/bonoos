class QuoteDto {
  const QuoteDto({
    required this.id,
    required this.image,
    required this.text,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String image;
  final String text;
  final int status;
  final String? createdAt;
  final String? updatedAt;

  factory QuoteDto.fromJson(Map<String, dynamic> json) {
    return QuoteDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      image: json['image'] as String? ?? '',
      text: json['text'] as String? ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// `BASE_URL` (masalan `https://api.vibrant.uz/`) bilan to‘liq rasm manzili.
  String resolveImageUrl(String apiBaseUrl) {
    if (image.isEmpty) return '';
    if (image.startsWith('http://') || image.startsWith('https://')) return image;
    final base = apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final path = image.startsWith('/') ? image : '/$image';
    return '$base$path';
  }
}
