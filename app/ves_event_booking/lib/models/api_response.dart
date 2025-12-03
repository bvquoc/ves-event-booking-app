class ApiResponse<T> {
  final bool success;
  final String? message; // Đôi khi server trả message ở cấp ngoài
  final T? data;
  final ApiError? error;

  ApiResponse({required this.success, this.message, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'] != null
          ? ApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ApiError {
  final String code;
  final String message;
  final dynamic details;

  ApiError({required this.code, required this.message, this.details});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'],
    );
  }
}
