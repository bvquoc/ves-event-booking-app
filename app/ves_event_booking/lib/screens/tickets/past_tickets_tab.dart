import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';
import 'package:ves_event_booking/providers/ticket_provider.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/timeline_info.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/grouped_ticket_card.dart';

class PastTicketsTab extends StatefulWidget {
  const PastTicketsTab({super.key});

  @override
  State<PastTicketsTab> createState() => _PastTicketsTabState();
}

class _PastTicketsTabState extends State<PastTicketsTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TicketProvider>().fetchTickets(TicketStatus.USED);
    });
  }

  Map<String, List<TicketModel>> _groupTicketsByEvent(
    List<TicketModel> tickets,
  ) {
    final Map<String, List<TicketModel>> grouped = {};
    for (var ticket in tickets) {
      if (!grouped.containsKey(ticket.eventId)) {
        grouped[ticket.eventId] = [];
      }
      grouped[ticket.eventId]!.add(ticket);
    }
    return grouped;
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

        final rawTickets = provider.tickets;

        // 📭 Empty
        if (rawTickets.isEmpty) {
          return const Center(child: Text('Không có vé đã sử dụng'));
        }

        final groupedMap = _groupTicketsByEvent(rawTickets);
        final groupedList = groupedMap.values.toList();

        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ).copyWith(top: 24.0, bottom: 80.0),
            itemCount: groupedList.length,

            itemBuilder: (context, index) {
              final eventTickets = groupedList[index];
              final representativeTicket = eventTickets.first;

              return TimelineTile(
                axis: TimelineAxis.vertical,
                alignment: TimelineAlign.manual,
                lineXY: 0.22,
                startChild: TimelineInfo(
                  date: representativeTicket.eventStartDate,
                ),

                endChild: RepaintBoundary(
                  child: GroupedTicketCard(tickets: eventTickets),
                ),

                indicatorStyle: const IndicatorStyle(
                  width: 18,
                  color: Colors.green, // Màu xám cho vé đã qua
                ),

                beforeLineStyle: LineStyle(
                  color: Colors.green.withOpacity(
                    0.5,
                  ), // Đường line màu xám nhạt
                  thickness: 2,
                ),

                // Đánh dấu item đầu và cuối
                isFirst: index == 0,
                isLast: index == groupedList.length - 1,
              );
            },
          ),
        );
      },
    );
  }
}
