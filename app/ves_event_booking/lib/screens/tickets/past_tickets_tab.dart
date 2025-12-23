import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ves_event_booking/enums/ticket_status.dart';
import 'package:ves_event_booking/providers/ticket_provider.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/ticket_card_item.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/timeline_info.dart';

class PastTicketsTab extends StatefulWidget {
  const PastTicketsTab({super.key});

  @override
  State<PastTicketsTab> createState() => PastTicketsTabState();
}

class PastTicketsTabState extends State<PastTicketsTab> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TicketProvider>().fetchTickets(TicketStatus.USED);
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
              top: 24.0,
              bottom: 80.0,
            ), // <-- Chừa không gian cho bottom nav
            itemCount: tickets.length,

            // 3. Build item
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              return TimelineTile(
                // Căn chỉnh cho nội dung bên phải (endChild)
                axis: TimelineAxis.vertical,
                alignment: TimelineAlign.manual,
                lineXY: 0.22, // Dịch chuyển đường line sang bên trái
                // Widget trái (Ngày/Giờ)
                startChild: TimelineInfo(date: ticket.eventStartDate),

                // Widget phải (Thẻ sự kiện)
                endChild: RepaintBoundary(
                  child: TicketCardItem(ticket: ticket),
                ),

                indicatorStyle: const IndicatorStyle(
                  width: 18,
                  color: Colors.blue, // Màu của dấu chấm
                ),

                beforeLineStyle: LineStyle(
                  color: Colors.blue.withOpacity(0.5),
                  thickness: 2,
                ),

                // Đánh dấu item đầu và cuối
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
