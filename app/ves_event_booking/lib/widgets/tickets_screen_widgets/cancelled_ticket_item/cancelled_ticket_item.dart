import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/cancelled_ticket_model.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/cancelled_ticket_card.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/cancellation_status_tracker.dart';

class CancelledTicketItem extends StatelessWidget {
  final CancelledTicketModel ticket;
  const CancelledTicketItem({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          // Widget con 1: Thẻ vé
          RepaintBoundary(child: CancelledTicketCard(ticket: ticket)),

          const SizedBox(height: 20),

          // Widget con 2: Thanh trạng thái
          RepaintBoundary(child: CancellationStatusTracker(ticket: ticket)),
        ],
      ),
    );
  }
}
