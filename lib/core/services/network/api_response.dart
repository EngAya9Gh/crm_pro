class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, List<String>>? errors;
  final PaginationMeta? meta;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json.containsKey('data') 
          ? (json['data'] != null ? fromJsonT(json['data']) : null)
          : fromJsonT(json),
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                (value as List).map((e) => e.toString()).toList(),
              ),
            )
          : null,
      meta: json['meta'] != null ? PaginationMeta.fromJson(json['meta']) : null,
    );
  }
}

class PaginationMeta {
  final int total;
  final int currentPage;
  final int perPage;
  final int lastPage;

  PaginationMeta({
    required this.total,
    required this.currentPage,
    required this.perPage,
    required this.lastPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] ?? 0,
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      lastPage: json['last_page'] ?? 1,
    );
  }
}
