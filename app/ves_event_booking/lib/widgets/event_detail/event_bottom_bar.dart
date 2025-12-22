import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/screens/booking/concert_booking_screen.dart';
import 'package:ves_event_booking/screens/booking/exhibition_booking_screen.dart';

class EventBottomBar extends StatelessWidget {
  final EventModel event;

  const EventBottomBar({super.key, required this.event});

  void onBookingPressed(BuildContext context) {
    final String i = '0';
    switch (i) {
      case '0': //Triển lãm
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExhibitionBookingScreen(event: event),
          ),
        );
        break;

      case '1': //Concert
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ConcertBookingScreen(event: event)),
        );
        break;

      default:
        // sau này mở rộng
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              children: [
                Text(
                  'Giá chỉ từ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const SizedBox(width: 4),
                Text(
                  formatter.format(event.minPrice),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            ElevatedButton(
              onPressed: () {
                onBookingPressed(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150, 50),
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Đặt ngay',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
