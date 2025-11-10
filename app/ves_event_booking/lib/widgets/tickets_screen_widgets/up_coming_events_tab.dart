import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/event_model.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/timeline_info.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/ticket_item/ticket_card_item.dart';

// replace this with actual api or data source
final List<EventModel> events = MockEvents().events;

class UpcomingEventsTab extends StatelessWidget {
  const UpcomingEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ).copyWith(top: 24.0, bottom: 80.0), // <-- Chừa không gian cho bottom nav
      itemCount: events.length,

      // 3. Build item
      itemBuilder: (context, index) {
        final event = events[index];

        return TimelineTile(
          // Căn chỉnh cho nội dung bên phải (endChild)
          axis: TimelineAxis.vertical,
          alignment: TimelineAlign.manual,
          lineXY: 0.22, // Dịch chuyển đường line sang bên trái
          // Widget trái (Ngày/Giờ)
          startChild: TimelineInfo(date: event.eventDate),

          // Widget phải (Thẻ sự kiện)
          endChild: RepaintBoundary(child: TicketCardItem(event: event)),

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
          isLast: index == events.length - 1,
        );
      },
    );
  }
}
