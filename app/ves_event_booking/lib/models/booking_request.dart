class BookingRequest {
  final String eventId;

  /// key: ticketTypeId / zoneId
  /// value: quantity
  Map<String, int> items;

  BookingRequest({
    required this.eventId,
    Map<String, int>? items,
  }) : items = items ?? {};

  int get totalQuantity =>
      items.values.fold(0, (sum, q) => sum + q);
}
