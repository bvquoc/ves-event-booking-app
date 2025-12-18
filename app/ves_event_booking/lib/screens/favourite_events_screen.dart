import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/mock_data.dart';
import 'package:ves_event_booking/models/event_model.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/widgets/explore_screen_widgets/event_item_card.dart';

class FavoriteEventsScreen extends StatelessWidget {
  const FavoriteEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách yêu thích từ mock data
    final List<EventModel> favoriteEvents = [
      ...mockUpcomingTickets.map((t) => t.event),
      ...mockPastTickets.map((t) => t.event),
      ...mockEvents,
    ].where((event) => event.isFavorite).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
        ),
        title: const Text(
          'Sự kiện yêu thích',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: favoriteEvents.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: favoriteEvents.length,
              itemBuilder: (context, index) {
                final event = favoriteEvents[index];
                return EventItemCard(event: event);
              },
            ),
    );
  }

  // Widget hiển thị khi danh sách trống
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có sự kiện yêu thích',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
