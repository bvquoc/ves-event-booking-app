import '../../models/ticket_type_model.dart';

class BookingState {
  TicketTypeModel? selectedTicket;
  int quantity = 1;
  List<String> selectedSeatIds = [];
  String? voucherCode;

  int get totalPrice {
    if (selectedTicket == null) return 0;
    return selectedTicket!.price.toInt() * quantity;
  }

  bool get requiresSeat =>
      selectedTicket?.requiresSeatSelection ?? false;
}
