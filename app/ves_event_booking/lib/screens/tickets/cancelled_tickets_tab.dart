import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/providers/ticket_provider.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/cancelled_ticket_item.dart';

class CancelledTicketsTab extends StatefulWidget {
  const CancelledTicketsTab({super.key});

  @override
  State<CancelledTicketsTab> createState() => CancelledTicketsTabState();
}

class CancelledTicketsTabState extends State<CancelledTicketsTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TicketProvider>().fetchTickets(TicketStatus.CANCELLED);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TicketProvider>(
      builder: (context, provider, _) {
        // ⏳ Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final tickets = provider.tickets;

        // 📭 Empty
        if (tickets.isEmpty) {
          return const Center(child: Text('No upcoming events'));
        }

        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
              top: 24.0,
              bottom: 80.0,
            ), // <-- Chừa không gian cho bottom nav
            itemCount: tickets.length,

            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return CancelledTicketItem(ticket: ticket);
            },
          ),
        );
      },
    );
  }
}
