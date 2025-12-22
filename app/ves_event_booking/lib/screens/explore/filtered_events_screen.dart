import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ves_event_booking/models/utils/pagination_request.dart';
import 'package:ves_event_booking/providers/event_provider.dart';
import 'package:ves_event_booking/widgets/explore_screen_widgets/event_item_card.dart';
import 'package:ves_event_booking/screens/home_screen.dart';
import 'package:ves_event_booking/screens/notifications/notifications_screen.dart';
import 'package:ves_event_booking/screens/profile/profile_creen.dart';
import 'package:ves_event_booking/screens/tickets/tickets_screen.dart';
import 'package:ves_event_booking/widgets/profile_widgets.dart';

class FilteredEventsScreen extends StatefulWidget {
  final String title;
  final String? categoryId;
  final String? cityId;

  const FilteredEventsScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.cityId,
  });

  @override
  State<FilteredEventsScreen> createState() => FilteredEventsScreenState();
}

class FilteredEventsScreenState extends State<FilteredEventsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EventProvider>().fetchEvents(
        pageable: PaginationRequest(page: 0, size: 20),
        category: widget.categoryId,
        city: widget.cityId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        // ⏳ Loading
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ❌ Error
        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final listEvents = provider.events;

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
              widget.title,
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
                itemCount: listEvents.length,
                itemBuilder: (context, index) {
                  final event = listEvents[index];
                  return EventItemCard(
                    event: event,
                    onFavoriteToggle: (eventId) {
                      provider.toggleFavorite(eventId);
                    },
                  );
                },
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
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
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
      },
    );
  }
}
