import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/event_model.dart';
import 'package:ves_event_booking/widgets/notifications_screen_widgets/event_card.dart';

// replace this with actual api or data source
final List<EventModel> events = MockEvents().events;

class EventTab extends StatelessWidget {
  const EventTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return EventCard(event: event);
        },
      ),
    );
  }
}
