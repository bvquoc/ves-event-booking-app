import 'package:flutter/material.dart';
import 'package:ves_event_booking/data/home_mock.dart';
import 'package:ves_event_booking/data/voucher_mock.dart';
import 'package:ves_event_booking/screens/explore_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/home_screen_widgets/event_section.dart';
import 'package:ves_event_booking/widgets/home_screen_widgets/home_header.dart';
import 'package:ves_event_booking/widgets/home_screen_widgets/section_header.dart';
import 'package:ves_event_booking/widgets/home_screen_widgets/voucher_section.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 440,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('assets/images/image 85.png'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            const Color.fromARGB(175, 39, 39, 39),
                            BlendMode.lighten,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        const HomeHeader(),
                        const SizedBox(height: 20),
                        const PosterCard(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                VoucherSection(
                  vouchers: mockVouchers, // hoặc data từ API
                ),
                const SizedBox(height: 20),


                EventSection(title: 'Buổi hòa nhạc', events: mockEvents),
                const SizedBox(height: 20),
                EventSection(title: 'Sân khấu kịch', events: mockEvents),
                const SizedBox(height: 20),
                EventSection(title: 'Thể thao', events: mockEvents),
                const SizedBox(height: 20),
                EventSection(title: 'Triển lãm', events: mockEvents),
                const SizedBox(height: 20),
              ],
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
                    isActive: true,
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
