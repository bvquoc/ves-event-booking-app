import 'package:flutter/material.dart';
import 'package:ves_event_booking/screens/explore_screen.dart';
import 'package:ves_event_booking/screens/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/screens/ticket/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Trang chủ',
              style: TextStyle(fontSize: 40, color: Colors.blue),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
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
                    onTap: () {},
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
                    isActive: true,
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
