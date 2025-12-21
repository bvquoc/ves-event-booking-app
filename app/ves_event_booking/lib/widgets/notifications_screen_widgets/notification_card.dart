import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/notification/notification_model.dart';
import 'package:ves_event_booking/screens/notifications/notification_details_screen.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = notification.data?['image'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotificationDetailScreen(notification: notification),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Image.network(
                // Đổi sang Image.network
                imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(height: 180, color: Colors.grey[300]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    'Xem chi tiết',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue[600],
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
