import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/models/ticket/ticket_model.dart';
import 'package:ves_event_booking/providers/ticket_provider.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/grouped_ticket_card.dart';
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
          return const Center(child: Text('Chưa có vé sắp diễn ra'));
        }

        // 🔄 XỬ LÝ GOM NHÓM
        final groupedMap = _groupTicketsByEvent(rawTickets);
        final groupedList = groupedMap.values
            .toList(); // List<List<TicketModel>>

        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: 24, bottom: 80),
            itemCount: groupedList.length,
            itemBuilder: (context, index) {
              // Lấy ra danh sách vé của sự kiện tại index này
              final eventTickets = groupedList[index];

              // Lấy vé đầu tiên để đại diện cho thông tin ngày tháng
              final representativeTicket = eventTickets.first;

              return TimelineTile(
                axis: TimelineAxis.vertical,
                alignment: TimelineAlign.manual,
                lineXY: 0.22,
                // Hiển thị ngày tháng dựa trên vé đại diện
                startChild: TimelineInfo(
                  date: representativeTicket.eventStartDate,
                ),
                endChild: RepaintBoundary(
                  // Sử dụng Widget mới để hiển thị cả nhóm vé
                  child: GroupedTicketCard(tickets: eventTickets),
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
                isLast: index == groupedList.length - 1,
              );
            },
          ),
        );
      },
    );
  }
}
