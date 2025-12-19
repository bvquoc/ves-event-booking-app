import 'package:flutter/material.dart';
import 'package:ves_event_booking/screens/event_detail/event_detail_screen.dart';
import '../../models/event_model.dart';
import 'event_card.dart';
import 'section_header.dart';

class EventSection extends StatelessWidget {
  final String title;
  final List<EventModel> events;
  final VoidCallback? onViewAll;

  const EventSection({
    super.key,
    required this.title,
    required this.events,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SectionHeader(title: title, onTap: onViewAll),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.12,
            ),
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                event: event,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => EventDetailScreen(eventId: event.id),
                    ),
                  );
                },
                onFavoriteTap: () {
                  // TODO: call POST /favorites/{eventId}
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
