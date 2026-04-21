class PaginationModel<T> {
  final int count;
  final int totalPages;
  final List<T> results;

  PaginationModel({required this.count, required this.totalPages, required this.results});

  factory PaginationModel.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return PaginationModel<T>(
      count: json['count'],
      totalPages: json['total_pages'],
      results: (json['results'] as List).map((item) => fromJsonT(item as Map<String, dynamic>)).toList(),
    );
  }
}
