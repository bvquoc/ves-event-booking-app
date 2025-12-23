import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/event/event_details_model.dart';

class EventAppBar extends StatelessWidget {
  final EventDetailsModel event;
  final VoidCallback onFavoritePressed;

  const EventAppBar({
    super.key,
    required this.event,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF1E3A5F),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Center(
        child: Text('Chi tiết sự kiện', style: TextStyle(color: Colors.white)),
      ),

      actions: [
        IconButton(
          icon: Icon(
            event.isFavorite == true ? Icons.favorite : Icons.favorite_border,
            color: event.isFavorite == true ? Colors.red : Colors.white,
          ),
          onPressed: onFavoritePressed,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Event Image
            Image.network(
              event.thumbnail ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.white54,
                  ),
                );
              },
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
