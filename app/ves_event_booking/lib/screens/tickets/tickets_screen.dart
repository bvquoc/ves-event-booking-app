import 'package:flutter/material.dart';
import 'package:ves_event_booking/screens/explore/explore_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';
import 'package:ves_event_booking/screens/tickets/cancelled_tickets_tab.dart';
import 'package:ves_event_booking/screens/tickets/up_coming_tickets_tab.dart';
import 'package:ves_event_booking/screens/tickets/past_tickets_tab.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // <-- Số lượng tab
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,

          title: const Text(
            'Vé của tôi',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            // Màu của đường gạch chân
            indicatorColor: Colors.blue,
            // Màu chữ của tab đang được chọn
            labelColor: Colors.black,
            // Màu chữ của các tab không được chọn
            unselectedLabelColor: Colors.black,
            // Kiểu chữ cho tab đang được chọn
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Sắp diễn ra'),
              Tab(text: 'Đã diễn ra'),
              // Tab(text: 'Đã hủy'),
            ],
          ),
        ),
        body: Stack(
          children: [
            const TabBarView(
              children: [
                // Nội dung cho tab "Sắp diễn ra"
                UpcomingTicketsTab(),
                // Nội dung cho tab "Đã diễn ra"
                PastTicketsTab(),
                // Nội dung cho tab "Đã hủy"
                // CancelledTicketsTab(),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 32,
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                      isActive: true,
                      onTap: () {},
                    ),
                    NavItem(
                      icon: Icons.grid_view_rounded,
                      isActive: false,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExploreScreen(),
                          ),
                        );
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
      ),
    );
  }
}
