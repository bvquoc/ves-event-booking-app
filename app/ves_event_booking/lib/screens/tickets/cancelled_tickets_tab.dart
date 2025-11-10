import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/cancelled_ticket_model.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/cancelled_ticket_item.dart';

// replace this with actual api or data source
final List<CancelledTicketModel> mockCancelledTickets =
    MockCancelledTickets().cancelledTickets;

class CancelledTicketsTab extends StatelessWidget {
  const CancelledTicketsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
          top: 24.0,
          bottom: 80.0,
        ), // <-- Chừa không gian cho bottom nav
        itemCount: mockCancelledTickets.length,

        itemBuilder: (context, index) {
          final ticket = mockCancelledTickets[index];
          return CancelledTicketItem(ticket: ticket);
        },
      ),
    );
  }
}
