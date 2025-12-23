import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/providers/ticket_provider.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/timeline_info.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/ticket_card_item.dart';

class UpcomingTicketsTab extends StatefulWidget {
  const UpcomingTicketsTab({super.key});

  @override
  State<UpcomingTicketsTab> createState() => _UpcomingTicketsTabState();
}

class _UpcomingTicketsTabState extends State<UpcomingTicketsTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TicketProvider>().fetchTickets(TicketStatus.ACTIVE);
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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
            provider.clearError(); // VERY IMPORTANT
          });
        }

        final tickets = provider.tickets;

        // 📭 Empty
        if (tickets.isEmpty) {
          return const Center(child: Text('No upcoming events'));
        }

        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: 24, bottom: 80),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              return TimelineTile(
                axis: TimelineAxis.vertical,
                alignment: TimelineAlign.manual,
                lineXY: 0.22,
                startChild: TimelineInfo(date: ticket.eventStartDate),
                endChild: RepaintBoundary(
                  child: TicketCardItem(ticket: ticket),
                ),
                indicatorStyle: const IndicatorStyle(
                  width: 18,
                  color: Colors.blue,
                ),
                beforeLineStyle: LineStyle(
                  color: Colors.blue.withOpacity(0.5),
                  thickness: 2,
                ),
                isFirst: index == 0,
                isLast: index == tickets.length - 1,
              );
            },
          ),
        );
      },
    );
  }
}
