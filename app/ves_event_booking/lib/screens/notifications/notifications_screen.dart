import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/providers/notification_provider.dart';
import 'package:ves_event_booking/screens/explore/explore_screen.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';
import 'package:ves_event_booking/screens/notifications/notifications_tab.dart';
import 'package:ves_event_booking/screens/notifications/offers_tab.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        // ⏳ Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final eventNotifications = provider.eventNotifications;
        final offerNotifications = provider.offerNotifications;

        return DefaultTabController(
          length: 2, // <-- Số lượng tab
          child: Scaffold(
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
                'Thông báo',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
                  Tab(text: 'Sự kiện'),
                  Tab(text: 'Ưu đãi'),
                ],
              ),
            ),
            body: Stack(
              children: [
                TabBarView(
                  children: provider.errorMessage != null
                      ? [
                          // Tab "Sự kiện"
                          const Center(
                            child: Text(
                              'There was an error with notifications\nWaiting for Quoc to fix',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          // Tab "Ưu đãi"
                          const Center(
                            child: Text(
                              'There was an error with notifications\nWaiting for Quoc to fix',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ]
                      : [
                          // Nội dung cho tab "Sự kiện"
                          NotificationTab(notifications: eventNotifications),
                          // Nội dung cho tab "Ưu đãi"
                          OfferTab(notifications: offerNotifications),
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
                          isActive: true,
                          onTap: () {},
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
      },
    );
  }
}
