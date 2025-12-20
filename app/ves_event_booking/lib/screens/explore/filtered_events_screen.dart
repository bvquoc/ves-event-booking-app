import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/event/event_model.dart';
import 'package:ves_event_booking/widgets/explore_screen_widgets/event_item_card.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class FilteredEventsScreen extends StatelessWidget {
  final String title;
  final String filterType; // 'category' hoặc 'city'
  final String filterValue; // id hoặc slug

  const FilteredEventsScreen({
    super.key,
    required this.title,
    required this.filterType,
    required this.filterValue,
  });

  @override
  Widget build(BuildContext context) {
    // Lọc sự kiện (Logic giả định)
    // Trong thực tế sẽ gọi API ở đây: /events?category=... hoặc /events?city=...
    // Tạm thời hiển thị tất cả event từ mock data
    final List<EventModel> events = [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          GridView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventItemCard(event: event);
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0f0c29),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  NavItem(
                    icon: Icons.home_rounded,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                  NavItem(
                    icon: Icons.confirmation_num_rounded,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TicketsScreen(),
                        ),
                      );
                    },
                  ),
                  NavItem(
                    icon: Icons.grid_view_rounded,
                    isActive: true,
                    onTap: () {
                      // Nếu bấm vào nút Khám phá khi đang ở chi tiết khám phá
                      // Quay về màn hình chính của Explore
                      Navigator.pop(context);
                    },
                  ),
                  NavItem(
                    icon: Icons.notifications_rounded,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  NavItem(
                    icon: Icons.person_2_rounded,
                    isActive: false,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
