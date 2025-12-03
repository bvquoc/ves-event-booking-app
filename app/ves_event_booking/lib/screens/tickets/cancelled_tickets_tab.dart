import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/mock_data.dart';
import 'package:ves_event_booking/models/ticket_model.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/cancelled_ticket_item.dart';

class CancelledTicketsTab extends StatelessWidget {
  const CancelledTicketsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // replace this with actual api or data source
    final List<TicketModel> cancelledTickets = mockCancelledTickets;

    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
          top: 24.0,
          bottom: 80.0,
        ), // <-- Chừa không gian cho bottom nav
        itemCount: cancelledTickets.length,

        itemBuilder: (context, index) {
          final ticket = mockCancelledTickets[index];
          return CancelledTicketItem(ticket: ticket);
        },
      ),
    );
  }
}
