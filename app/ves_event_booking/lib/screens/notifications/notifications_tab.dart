import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/notification/notification_model.dart';
import 'package:ves_event_booking/widgets/notifications_screen_widgets/notification_card.dart';

class NotificationTab extends StatelessWidget {
  final List<NotificationModel> notifications;
  const NotificationTab({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationCard(notification: notification);
        },
      ),
    );
  }
}
