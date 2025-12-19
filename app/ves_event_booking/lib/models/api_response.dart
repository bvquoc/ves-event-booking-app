class ApiResponse<T> {
  final int code;
  final String message;
  final T result;

  ApiResponse({
    required this.code,
    required this.message,
    required this.result,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'],
      message: json['message'],
      result: fromJsonT(json['result']),
    );
  }
}
