class PaginationRequest {
  final int page;
  final int size;
  final List<String>? sort;

  PaginationRequest({required this.page, required this.size, this.sort});

  /// Convert to query parameters for GET requests
  Map<String, dynamic> toQueryParams() {
    return {'page': page, 'size': size, if (sort != null) 'sort': sort};
  }
}
