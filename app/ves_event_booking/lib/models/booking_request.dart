// models/booking_request.dart

class BookingRequest {
  final String eventId;

  /// key: ticketTypeId
  /// value: quantity
  Map<String, int> items;

  /// Map lưu danh sách ghế theo loại vé
  /// key: ticketTypeId
  /// value: List<seatId (Danh sách các ghế đã chọn cho loại vé đó)
  Map<String, List<String>> ticketSeatMap;

  BookingRequest({
    required this.eventId,
    Map<String, int>? items,
    Map<String, List<String>>? ticketSeatMap,
  }) : items = items ?? {},
       ticketSeatMap = ticketSeatMap ?? {};

  int get totalQuantity => items.values.fold(0, (sum, q) => sum + q);

  List<String> getSeatIdsByTicketType(String ticketTypeId) {
    return ticketSeatMap[ticketTypeId] ?? [];
  }
}
