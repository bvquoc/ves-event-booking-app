import 'package:flutter/material.dart';
import 'package:ves_event_booking/models/ticket_model.dart';
import 'package:ves_event_booking/screens/explore_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';
import 'package:ves_event_booking/widgets/tickets_screen_widgets/cancelled_ticket_item/cancelled_ticket_details.dart';

class CancelledTicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  const CancelledTicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () {
            // Có thể dùng Navigator.pop(context) nếu đây là màn hình được push
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Vé đã hủy',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(child: CancelledTicketDetail(ticket: ticket)),
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
    );
  }
}
