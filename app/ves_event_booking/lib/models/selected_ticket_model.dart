import 'ticket_type_model.dart';

class SelectedTicket {
  final TicketTypeModel ticketType;
  final int quantity;

  SelectedTicket({
    required this.ticketType,
    required this.quantity,
  });

  double get totalPrice => ticketType.price * quantity;
}
