enum TicketStatus { ACTIVE, USED, CANCELLED, REFUNDED }

extension TicketStatusExt on TicketStatus {
  String get value => name; // converts enum to string
}
