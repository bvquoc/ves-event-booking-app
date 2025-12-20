import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/notification_model.dart';
import 'package:ves_event_booking/widgets/notifications_screen_widgets/offer_card.dart';

class OfferTab extends StatelessWidget {
  const OfferTab({super.key});

  @override
  Widget build(BuildContext context) {
    // replace this with actual api or data source
    final List<NotificationModel> offers = [];

    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8.0, bottom: 80.0),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return OfferCard(notification: offer);
        },
      ),
    );
  }
}
